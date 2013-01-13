//
//  STTodayTVC.m
//  Six Times Path
//
//  Created by Doug on 12/5/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "STTodayTVC.h"
#import "Advice.h"
#import "Day+ST.h"
#import "NSDate+ST.h"
#import "LESixOfDay+ST.h"
#import "STLogEntrySixOfDayTVC.h"
#import "STPreviousDaysTVC.h"
#import "STTraditionsFollowedTVC.h"

#define OUT_OF_RANGE	10000

@interface STTodayTVC ()

@property BOOL isOnlyShowingTheSixWithoutUserEntriesSorted;
@property (strong, nonatomic) LESixOfDay *nextEntry;
@property (strong, nonatomic) NSArray *remainingScheduledEntries;
@property (strong, nonatomic) NSArray *updatedEntries;
@property BOOL showRemainingScheduledEntries;
@property BOOL showUpdatedEntries;
@property (strong, nonatomic) NSDate *mostRecentlyAddedDate;
@property NSInteger orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay;
@property (strong, nonatomic) NSMutableArray *allAdviceFollowedByUser;
@property (nonatomic) NSInteger countOfTheSixWithoutUserEntries;

@property (nonatomic, strong) NSMutableArray *tableViewSections;


-(void)determineAndSetTheSixToBeShown;
-(void)addNotification:(LESixOfDay *)sixOfDayLogEntry;
-(void)addDay:(id)sender;
-(void)setTheSixAdvicesFor:(Day *)day withIndexOfFirstFollowedAdvice:(NSInteger)indexOfFirstFollowedAdvice inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

@implementation STTodayTVC

@synthesize managedObjectContext			= _managedObjectContext;
@synthesize fetchedResultsController		= _fetchedResultsController;

@synthesize today							= _today;

@synthesize nextEntry						= _nextEntry;
@synthesize remainingScheduledEntries		= _remainingScheduledEntries;
@synthesize updatedEntries					= _updatedEntries;
@synthesize showRemainingScheduledEntries	= _showRemainingScheduledEntries;
@synthesize showUpdatedEntries				= _showUpdatedEntries;
@synthesize mostRecentlyAddedDate			= _mostRecentlyAddedDate;
@synthesize allAdviceFollowedByUser			= _allAdviceFollowedByUser;
@synthesize countOfTheSixWithoutUserEntries	= _countOfTheSixWithoutUserEntries;

@synthesize tableViewSections				= _tableViewSections;

@synthesize isOnlyShowingTheSixWithoutUserEntriesSorted			= _isOnlyShowingTheSixWithoutUserEntriesSorted;
@synthesize orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay	= _orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay;


@synthesize pickerView		= _pickerView;
@synthesize doneButton		= _doneButton;
@synthesize dataArray		= _dataArray;
@synthesize dateFormatter	= _dateFormatter;


#pragma mark - init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - Getters and Setters

-(NSInteger)countOfTheSixWithoutUserEntries
{
	if (_countOfTheSixWithoutUserEntries == OUT_OF_RANGE) {
		_countOfTheSixWithoutUserEntries	= [[self.today getTheSixWithoutUserEntriesSorted] count];
	}
	
	return _countOfTheSixWithoutUserEntries;
}

-(NSMutableArray *)tableViewSections
{
	if (_tableViewSections == nil) {
		NSMutableArray *tmpSectionArray	= [NSMutableArray arrayWithObjects:@"Next Entry",
																		   @"Remaining Scheduled Entries",
																		   @"Updated Entries",
																		   @"Setup for Day",
																		   @"Previous Days",
																		   nil];
		
		if (self.countOfTheSixWithoutUserEntries <= 1)
			[tmpSectionArray removeObjectIdenticalTo:@"Remaining Scheduled Entries"];
		else if (self.countOfTheSixWithoutUserEntries == 6)
			[tmpSectionArray removeObjectIdenticalTo:@"Updated Entries"];
		
		_tableViewSections	= tmpSectionArray;
	}
	
	return _tableViewSections;
}


#pragma mark - View Loading and Appearing

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.debug	= YES;
	
	self.dateFormatter = [[NSDateFormatter alloc] init];
	[self.dateFormatter setDateFormat:@"h:mm a"];
	//	[self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	self.showRemainingScheduledEntries	= NO;
	self.showUpdatedEntries				= NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewWillAppear:(BOOL)animated
{	
	[self setupAdviceFetchedResultsController];
    self.allAdviceFollowedByUser				= [NSMutableArray arrayWithArray:self.fetchedResultsController.fetchedObjects];
	
	if (self.debug) {
		NSLog(@"Fetch performed. Number of objects fetched: %u", [self.fetchedResultsController.fetchedObjects count]);
		NSLog(@"The count of the advice that is currently being followed is %i", [self.allAdviceFollowedByUser count]);
	}
	
	
	[self setupDaysFetchedResultsController];
	
	if ([self.fetchedResultsController.fetchedObjects count] == 0) {
		if (self.debug)
			NSLog(@"0 days have been fetched. There isn't a mostRecentlyAddedDate");
		self.mostRecentlyAddedDate				= nil;
	} else {
		Day *mostRecentDay						= [self.fetchedResultsController.fetchedObjects objectAtIndex:0];
		NSLog(@"the mostRecentDay is %@.", mostRecentDay.date.timeAndDate);
		LESixOfDay *lastTheSixOfMostRecentDay	= [[mostRecentDay getTheSixSorted] lastObject];
		self.mostRecentlyAddedDate				= mostRecentDay.date;
		self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay = [self.allAdviceFollowedByUser indexOfObject:lastTheSixOfMostRecentDay.advice] + 1;
		self.today								= mostRecentDay;
		if (self.debug) {
			NSLog(@"Most recent date: %@", self.mostRecentlyAddedDate.date);
			NSLog(@"lastTheSixOfMostRecentDay: %@", lastTheSixOfMostRecentDay.advice.name);
			NSLog(@"Index of that advice: %i", [self.allAdviceFollowedByUser indexOfObject:lastTheSixOfMostRecentDay.advice]);
			NSLog(@"Fetch performed. Number of objects fetched: %u", [self.fetchedResultsController.fetchedObjects count]);
		}
		
		[self addDay:0];
	}

	self.title		= self.mostRecentlyAddedDate.date;
		
	NSArray *allRemainingEntries			= [self.today getTheSixWithoutUserEntriesSorted];
	
	NSRange rangeRemainingScheduledEntries;
	rangeRemainingScheduledEntries.location	= 1;
	
	rangeRemainingScheduledEntries.length	= ([[self.today getTheSixWithoutUserEntriesSorted] count] == 0) ? 0 : [allRemainingEntries count] - 1;
	
	if ([allRemainingEntries count] > 0) {
		self.nextEntry						= [allRemainingEntries objectAtIndex:0];
	}
	
	if ([[self.today getTheSixWithoutUserEntriesSorted] count] == 0) {
		NSLog(@"There are 0 entries.");
		self.remainingScheduledEntries		= allRemainingEntries;
	} else {
		self.remainingScheduledEntries		= [allRemainingEntries subarrayWithRange:rangeRemainingScheduledEntries];
	}
	self.showRemainingScheduledEntries		= NO;
	
	self.updatedEntries						= [self.today getTheSixThatHaveUserEntriesSorted];
	self.showUpdatedEntries					= NO;
	
	if (self.debug) {
		NSLog(@"There are %u entries that have been updated.", [[self.today getTheSixThatHaveUserEntriesSorted] count]);
		NSLog(@"There are %u entries that have not yet been updated.", [[self.today getTheSixWithoutUserEntriesSorted] count]);
	}
	
	self.countOfTheSixWithoutUserEntries		= OUT_OF_RANGE;
	self.tableViewSections						= nil;
	
	[self.tableView reloadData];

}

-(void)viewWillDisappear:(BOOL)animated
{
	self.showUpdatedEntries				= NO;
	self.showRemainingScheduledEntries	= NO;
}

#pragma mark - Core Data Setup
-(void)setupDaysFetchedResultsController
{
    // Set request with sorting, then fetch
	NSFetchRequest *request			= [NSFetchRequest fetchRequestWithEntityName:@"Day"];
    request.sortDescriptors			= [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"date"
                                                                                      ascending:NO
                                                                                       selector:@selector(localizedCaseInsensitiveCompare:)], nil];
    self.fetchedResultsController	= [[NSFetchedResultsController alloc] initWithFetchRequest:request
																		managedObjectContext:self.managedObjectContext
																		  sectionNameKeyPath:nil
																				   cacheName:nil];
    [self performFetch];
}

-(void)setupAdviceFetchedResultsController
{
    // Set request with sorting and predicate, then fetch
    NSFetchRequest *request			= [NSFetchRequest fetchRequestWithEntityName:@"Advice"];
    request.predicate				= [NSPredicate predicateWithFormat:@"containedWithinSetOfAdvice.orderNumberInFollowedSets > 0", [NSNumber numberWithBool:YES]];
    request.sortDescriptors			= [NSArray arrayWithObjects:
                               [NSSortDescriptor sortDescriptorWithKey:@"containedWithinSetOfAdvice.orderNumberInFollowedSets"
                                                             ascending:YES
                                                              selector:@selector(localizedCaseInsensitiveCompare:)],
                               [NSSortDescriptor sortDescriptorWithKey:@"orderNumberInSet"
                                                             ascending:YES],
                               nil];
    self.fetchedResultsController	= [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:@"containedWithinSetOfAdvice.name"
                                                                                   cacheName:nil];
    [self performFetch];
}


#pragma mark - Core Data Add Records

-(void)addDay:(id)sender
{
	NSDate *now						= [NSDate date];
	NSDate *mostRecentDate			= [self.today.date setHour:[self.today.startHour intValue] andMinute:[self.today.startMinute intValue]];
	
	NSTimeInterval eighteenHours	= 18*60*60;
	NSTimeInterval twentyFourHours	= 24*60*60;
	
	if (self.mostRecentlyAddedDate) {
		if ([now compare:[mostRecentDate dateByAddingTimeInterval:eighteenHours]] == NSOrderedDescending) {
			NSLog(@"Now [%@] is later in time than 18 Hours after start of Most Recent Date [%@].", now.timeAndDate, mostRecentDate.timeAndDate);
			
			Day *newDay					= [NSEntityDescription insertNewObjectForEntityForName:@"Day"
															inManagedObjectContext:self.managedObjectContext];
			
			BOOL nowIsOnSameDateAsMostRecentDateButAfterEntryLogging	= ([now compare:[mostRecentDate dateByAddingTimeInterval:eighteenHours]] == NSOrderedDescending && [now compare:[mostRecentDate dateByAddingTimeInterval:twentyFourHours]] == NSOrderedAscending);
			
			if (nowIsOnSameDateAsMostRecentDateButAfterEntryLogging) {
				newDay.date				= [mostRecentDate dateByAddingTimeInterval:twentyFourHours];
			} else {
				newDay.date				= now;
			}
			
			newDay.startHour			= (self.today.startHour) ? self.today.startHour : [NSNumber numberWithInt:6];
			newDay.startMinute			= (self.today.startMinute) ? self.today.startMinute : [NSNumber numberWithInt:0];
			
			self.mostRecentlyAddedDate	= newDay.date;
			self.today					= newDay;

			if (self.debug)
				NSLog(@"A new Day has been created. Its date is %@. The most recently added date is %@.", newDay.date, self.mostRecentlyAddedDate);
			
			[self setTheSixAdvicesFor:newDay withIndexOfFirstFollowedAdvice:self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay inManagedObjectContext:self.managedObjectContext];
			
			[self.managedObjectContext save:nil];
			[self performFetch];
			[self.tableView reloadData];
			
			if (self.debug) {
				NSLog(@"newDay.date = %@", [newDay.date date]);
				NSLog(@"Fetch performed. Number of objects fetched: %u", [self.fetchedResultsController.fetchedObjects count]);
			}
		} else {
			NSLog(@"Now [%@] is earlier (or exactly equal) in time than 18 Hours after start of Most Recent Date [%@].", now.timeAndDate, mostRecentDate.timeAndDate);
		}
	}
}

-(void)setTheSixAdvicesFor:(Day *)day withIndexOfFirstFollowedAdvice:(NSInteger)indexOfFirstFollowedAdvice inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	int indexOfFollowedAdviceForTheDay;
	
	// Check to see if the index of the first followed Advice that was passed into the method exceeds the index limit of the allAdviceFollowedByUser array and reset as necessary
	
	if (indexOfFirstFollowedAdvice >= [self.allAdviceFollowedByUser count])
		indexOfFirstFollowedAdvice = 0;
	
    
    // Starting with the first advice to be followed for the day, cycle through the advice that has been
	// selected to be followed and add 6 advices to LogEntries that will be added to a day.
    for (int allAdviceFollowedByUserIncrement=0; allAdviceFollowedByUserIncrement<6; allAdviceFollowedByUserIncrement++) {
        indexOfFollowedAdviceForTheDay = allAdviceFollowedByUserIncrement + indexOfFirstFollowedAdvice;
		
		if (self.debug)
			NSLog(@"indexOfFollowedAdviceForTheDay: %i", indexOfFollowedAdviceForTheDay);
        
        if (indexOfFollowedAdviceForTheDay==[self.allAdviceFollowedByUser count] - 1)
        {
            // reset to the beginning
            indexOfFirstFollowedAdvice = -1 - allAdviceFollowedByUserIncrement;
			
			if (self.debug)
				NSLog(@"indexOfFirstFollowedAdvice has been reset. Value is now: %i", indexOfFirstFollowedAdvice);
        }
        
		// Add the advice to a log entry
		Advice *advice			= [self.allAdviceFollowedByUser objectAtIndex:indexOfFollowedAdviceForTheDay];
		
		// orderNumber range will be 1-6
		NSInteger orderNumber	= allAdviceFollowedByUserIncrement+1;
		
		// Create a log entry for the Six of the Day and initiate it with advice, and order number, and the day -- add to the managedObjectContext
		LESixOfDay *logEntry	= [LESixOfDay logEntryWithAdvice:advice
											  withOrderNumber:orderNumber
														onDay:day
									   inManagedObjectContext:managedObjectContext];
		
		if (self.debug)
			[logEntry logValuesOfLogEntry];
		
		[day addTheSixObject:logEntry];
		
		// TEMP
		//
		self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay = indexOfFollowedAdviceForTheDay;
	}
	
	self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay++;
	
	for (LESixOfDay *logEntry in day.theSix) {
		[self addNotification:logEntry];
	}
	
	
	if (self.debug)
		NSLog(@"The next starting orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay will be %i", self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay);
}




#pragma mark - Table View Structure

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.tableViewSections count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == [self.tableViewSections indexOfObject:@"Next Entry"]) {
		return 1;
	} else if (section == [self.tableViewSections indexOfObject:@"Remaining Scheduled Entries"]) {
		if (self.showRemainingScheduledEntries)
			return [self.remainingScheduledEntries count] + 1;
		else
			return 1;		
	} else if (section == [self.tableViewSections indexOfObject:@"Updated Entries"]) {
		if (self.showUpdatedEntries)
			return [self.updatedEntries count] + 1;
		else
			return 1;
	} else if (section == [self.tableViewSections indexOfObject:@"Setup for Day"]) {
		return 2;
	} else {
		return 1;
	}
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == [self.tableViewSections indexOfObject:@"Next Entry"])
		return @"Today's Guidelines";
	else if (section == [self.tableViewSections indexOfObject:@"Setup for Day"])
		return @"Setup for Today";
	else
		return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == [self.tableViewSections indexOfObject:@"Next Entry"]) {
		return 129;		// change for landscape orientation?
	} else if ((indexPath.section == [self.tableViewSections indexOfObject:@"Remaining Scheduled Entries"] || indexPath.section == [self.tableViewSections indexOfObject:@"Updated Entries"]) && indexPath.row > 0) {
		return 81;
	} else {
		return 35;
	}
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *guidelineNextEntryCellIdentifier	= @"GuidelineNextEntryCell";
	static NSString *guidelineOtherEntryCellIdentifier	= @"GuidelineOtherEntryCell";
	static NSString *summaryOrSetupCellIdentifier		= @"SummaryOrSetupCell";
		
    if (indexPath.section == [self.tableViewSections indexOfObject:@"Next Entry"]) {
		
			UITableViewCell *guidelineNextEntryCell		= [tableView dequeueReusableCellWithIdentifier:guidelineNextEntryCellIdentifier];
			
			NSString *timeEntryTextPrefix;
			
			if (self.countOfTheSixWithoutUserEntries == 0) {
				timeEntryTextPrefix	= @"Excellent!";
			} else if (self.countOfTheSixWithoutUserEntries == 1) {
				timeEntryTextPrefix	= @"Last Entry - ";
			} else if (self.countOfTheSixWithoutUserEntries < 6) {
				timeEntryTextPrefix	= @"Next Entry - ";
			} else {
				timeEntryTextPrefix	= @"First Entry - ";
			}
			
			if (self.countOfTheSixWithoutUserEntries > 0) {
				NSString *timeEntryText	= [NSString stringWithFormat:@"%@%@", timeEntryTextPrefix, self.nextEntry.timeScheduled.time];
				NSString *guidelineText	= self.nextEntry.advice.name;
				
				[[guidelineNextEntryCell viewWithTag:10] setValue:timeEntryText forKey:@"text"];
				[[guidelineNextEntryCell viewWithTag:11] setValue:guidelineText forKey:@"text"];
			} else {
				NSString *timeEntryText	= timeEntryTextPrefix;
				NSString *guidelineText	= @"You've made entries for all 6 guidelines. Be happy over what you've done well to day, and regret the mistaken actions.";
				
				[[guidelineNextEntryCell viewWithTag:10] setValue:timeEntryText forKey:@"text"];
				[[guidelineNextEntryCell viewWithTag:11] setValue:guidelineText forKey:@"text"];
				
				guidelineNextEntryCell.selectionStyle	= UITableViewCellSelectionStyleNone;
				guidelineNextEntryCell.accessoryType	= UITableViewCellAccessoryNone;
				
				//	guidelineNextEntryCell.hidden	= YES;
			}
			return guidelineNextEntryCell;
		
	} else if (indexPath.section == [self.tableViewSections indexOfObject:@"Remaining Scheduled Entries"]) {
	
			if (self.showRemainingScheduledEntries && indexPath.row > 0) {
				UITableViewCell *guidelineOtherEntryCell	= [tableView dequeueReusableCellWithIdentifier:guidelineOtherEntryCellIdentifier];
				
				LESixOfDay *scheduledEntry	= [self.remainingScheduledEntries objectAtIndex:indexPath.row - 1];		// -1 to account for "heading" row
				NSString *timeEntryText		= [NSString stringWithFormat:@"Scheduled - %@", scheduledEntry.timeScheduled.time];
				NSString *guidelineText		= scheduledEntry.advice.name;
				
				[[guidelineOtherEntryCell viewWithTag:10] setValue:timeEntryText forKey:@"text"];
				[[guidelineOtherEntryCell viewWithTag:11] setValue:guidelineText forKey:@"text"];
				
				return guidelineOtherEntryCell;
			} else {
				UITableViewCell *summaryOrSetupCell		= [tableView dequeueReusableCellWithIdentifier:summaryOrSetupCellIdentifier];
				
				summaryOrSetupCell.textLabel.text		= @"Remaining Guidelines";
				summaryOrSetupCell.detailTextLabel.text	= [NSString stringWithFormat:@"%i", [self.remainingScheduledEntries count]];
				
				if ([self.remainingScheduledEntries count] == 0) {
					summaryOrSetupCell.selectionStyle	= UITableViewCellSelectionStyleNone;
					summaryOrSetupCell.accessoryType	= UITableViewCellAccessoryNone;
				} else {
					summaryOrSetupCell.selectionStyle	= UITableViewCellSelectionStyleBlue;
					summaryOrSetupCell.accessoryType	= UITableViewCellAccessoryDisclosureIndicator;
				}
				
				return summaryOrSetupCell;
			}

	} else if (indexPath.section == [self.tableViewSections indexOfObject:@"Updated Entries"]) {

			if (self.showUpdatedEntries && indexPath.row > 0) {
				UITableViewCell *guidelineOtherEntryCell	= [tableView dequeueReusableCellWithIdentifier:guidelineOtherEntryCellIdentifier];
				
				LESixOfDay *updatedEntry	= [self.updatedEntries objectAtIndex:indexPath.row - 1];		// -1 to account for "heading" row
				NSString *timeEntryText		= [NSString stringWithFormat:@"Updated - %@", updatedEntry.timeLastUpdated.time];
				NSString *guidelineText		= updatedEntry.advice.name;
				
				[[guidelineOtherEntryCell viewWithTag:10] setValue:timeEntryText forKey:@"text"];
				[[guidelineOtherEntryCell viewWithTag:11] setValue:guidelineText forKey:@"text"];
				
				return guidelineOtherEntryCell;
			} else {
				UITableViewCell *summaryOrSetupCell					= [tableView dequeueReusableCellWithIdentifier:summaryOrSetupCellIdentifier];
			
				summaryOrSetupCell.textLabel.text		= @"Guidelines with Entries";
				summaryOrSetupCell.detailTextLabel.text	= [NSString stringWithFormat:@"%i", [self.updatedEntries count]];
				
				if ([self.updatedEntries count] == 0) {
					summaryOrSetupCell.selectionStyle	= UITableViewCellSelectionStyleNone;
					summaryOrSetupCell.accessoryType	= UITableViewCellAccessoryNone;
				} else {
					summaryOrSetupCell.selectionStyle	= UITableViewCellSelectionStyleBlue;
					summaryOrSetupCell.accessoryType	= UITableViewCellAccessoryDisclosureIndicator;
				}

				return summaryOrSetupCell;
			}
		
	} else if (indexPath.section == [self.tableViewSections indexOfObject:@"Setup for Day"]) {
		
			switch (indexPath.row) {
				case 0:
				{
					UITableViewCell *summaryOrSetupCell		= [tableView dequeueReusableCellWithIdentifier:summaryOrSetupCellIdentifier];
					
					summaryOrSetupCell.textLabel.text		= @"Wake Up Time";
					LESixOfDay *firstGuidelineOfDay			= [[self.today getTheSixSorted] objectAtIndex:0];
					NSDate *wakeUpAt						= [firstGuidelineOfDay.timeScheduled dateByAddingTimeInterval:-2*60*60];	// this will need to be fixed
					summaryOrSetupCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", wakeUpAt.time];
					return summaryOrSetupCell;
					break;
				}
				case 1:
				{
					UITableViewCell *summaryOrSetupCell					= [tableView dequeueReusableCellWithIdentifier:summaryOrSetupCellIdentifier];
					
					summaryOrSetupCell.textLabel.text		= @"Guidelines Being Followed";
					summaryOrSetupCell.detailTextLabel.text = [NSString stringWithFormat:@"%i", [self.allAdviceFollowedByUser count]];
					return summaryOrSetupCell;
					break;
				}
				default:
					break;
			}
			
	} else { // Previous Days

			UITableViewCell *summaryOrSetupCell				= [tableView dequeueReusableCellWithIdentifier:summaryOrSetupCellIdentifier];
			
			summaryOrSetupCell.textLabel.text				= @"Previous Days";
			summaryOrSetupCell.detailTextLabel.text			= @"";
			return summaryOrSetupCell;

	}
	return nil;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//switch (indexPath.section) {
    if (indexPath.section == [self.tableViewSections indexOfObject:@"Next Entry"]) {
	
			if (self.countOfTheSixWithoutUserEntries > 0) {
				[self performSegueWithIdentifier:@"Guideline Entry" sender:self];
			}
			
	} else if (indexPath.section == [self.tableViewSections indexOfObject:@"Remaining Scheduled Entries"]) {
		
			if ([self.remainingScheduledEntries count] > 0) {
				if (indexPath.row > 0) {
					[self performSegueWithIdentifier:@"Guideline Entry" sender:self];
				} else {
					self.showRemainingScheduledEntries	= (self.showRemainingScheduledEntries) ? NO : YES;		// toggle to other state
					[tableView reloadSections:[NSIndexSet indexSetWithIndex:[self.tableViewSections indexOfObject:@"Remaining Scheduled Entries"]]
							 withRowAnimation:YES];
				}
			}
		
	} else if (indexPath.section == [self.tableViewSections indexOfObject:@"Updated Entries"]) {

			if ([self.updatedEntries count] > 0) {
				if (indexPath.row > 0) {
					[self performSegueWithIdentifier:@"Guideline Entry" sender:self];					
				} else {
					self.showUpdatedEntries = (self.showUpdatedEntries) ? NO : YES;
					[tableView reloadSections:[NSIndexSet indexSetWithIndex:[self.tableViewSections indexOfObject:@"Updated Entries"]]
							 withRowAnimation:YES];
				}
			}

	} else if (indexPath.section == [self.tableViewSections indexOfObject:@"Setup for Day"]) {

			switch (indexPath.row) {
				case 0:
					NSLog(@"Going to trigger -showDatePicker");
					[self showDatePicker];
					break;
				case 1:
					[self performSegueWithIdentifier:@"Guidelines Followed" sender:self];
					break;
				default:
					break;
			}
	
	} else {
			[self performSegueWithIdentifier:@"Previous Days" sender:self];
	}
}


#pragma mark - UI Interactions
-(void)showDatePicker
{
	if (self.debug)
		NSLog(@"In -showDatePicker");
	NSIndexPath *indexPath		= [self.tableView indexPathForSelectedRow];
	UITableViewCell *targetCell = [self.tableView cellForRowAtIndexPath:indexPath];
	self.pickerView.date		= [self.dateFormatter dateFromString:targetCell.detailTextLabel.text];
	
	// check if our date picker is already on screen
	if (self.pickerView.superview == nil)
	{
		[self.view.window addSubview: self.pickerView];
		
		// size up the picker view to our screen and compute the start/end frame origin for our slide up animation
		//
		// compute the start frame
		CGRect screenRect		= [[UIScreen mainScreen] applicationFrame];
		CGSize pickerSize		= [self.pickerView sizeThatFits:CGSizeZero];
		CGRect startRect		= CGRectMake(0.0,
									  screenRect.origin.y + screenRect.size.height,
									  pickerSize.width, pickerSize.height);
		self.pickerView.frame = startRect;
		
		// compute the end frame
		CGRect pickerRect		= CGRectMake(0.0,
									   screenRect.origin.y + screenRect.size.height - pickerSize.height,
									   pickerSize.width,
									   pickerSize.height);
		// start the slide up animation
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
		
		// we need to perform some post operations after the animation is complete
		[UIView setAnimationDelegate:self];
		
		self.pickerView.frame	= pickerRect;
		
		// shrink the table vertical size to make room for the date picker
		CGRect newFrame			= self.tableView.frame;
		newFrame.size.height	-= self.pickerView.frame.size.height;
		self.tableView.frame	= newFrame;
		[UIView commitAnimations];
		
		// add the "Done" button to the nav bar
		self.navigationItem.rightBarButtonItem = self.doneButton;
	}
}


- (void)slideDownDidStop
{
	// the date picker has finished sliding downwards, so remove it
	[self.pickerView removeFromSuperview];
}


- (IBAction)doneAction:(id)sender
{
	
	self.today.startHour		= [NSNumber numberWithInt:[self.pickerView.date hour]];
	self.today.startMinute		= [NSNumber numberWithInt:[self.pickerView.date minute]];
	
	UIApplication *STPapp		= [UIApplication sharedApplication];
	[STPapp cancelAllLocalNotifications];
	// Reset scheduled times for log entries
	for (LESixOfDay *oneOfSix in [self.today getTheSixWithoutUserEntriesSorted]) {
		[oneOfSix resetScheduledTime];
		[self addNotification:oneOfSix];
	}

	// save to store!
	NSError *error;
	if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 */
		NSLog(@"Error occured when attempting to save. Error and userInfo: %@, %@", error, [error userInfo]);
	}

	NSIndexPath *indexPath		= [self.tableView indexPathForSelectedRow];
	UITableViewCell *cell		= [self.tableView cellForRowAtIndexPath:indexPath];
	cell.detailTextLabel.text	= [self.pickerView.date time]; //  [self.dateFormatter stringFromDate:self.pickerView.date];

	CGRect screenRect		= [[UIScreen mainScreen] applicationFrame];
	CGRect endFrame			= self.pickerView.frame;
	endFrame.origin.y		= screenRect.origin.y + screenRect.size.height;
	
	// start the slide down animation
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	// we need to perform some post operations after the animation is complete
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
	
	self.pickerView.frame	= endFrame;
	[UIView commitAnimations];
	
	// grow the table back again in vertical size to make room for the date picker
	CGRect newFrame			= self.tableView.frame;
	newFrame.size.height	+= self.pickerView.frame.size.height;
	self.tableView.frame	= newFrame;
	
	// remove the "Done" button in the nav bar
	self.navigationItem.rightBarButtonItem = nil;
	
	// deselect the current table row
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	[self.tableView reloadData];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	NSIndexPath *indexPath  = [self.tableView indexPathForSelectedRow];
	
	NSLog(@"Segue identifier is %@", segue.identifier.description);
		
	if ([[segue identifier] isEqualToString:@"Guideline Entry"]) {
		
		//	Get the indexPath for which entry this should go to
		
		STLogEntrySixOfDayTVC *leSixOfDayTVC	= segue.destinationViewController;
		leSixOfDayTVC.managedObjectContext		= self.managedObjectContext;
		
		if (indexPath.section == [self.tableViewSections indexOfObject:@"Next Entry"])
			leSixOfDayTVC.leSixOfDay			= self.nextEntry;
		else if (indexPath.section == [self.tableViewSections indexOfObject:@"Remaining Scheduled Entries"])
			leSixOfDayTVC.leSixOfDay			= [self.remainingScheduledEntries objectAtIndex:indexPath.row - 1];
		else if (indexPath.section == [self.tableViewSections indexOfObject:@"Updated Entries"])
			leSixOfDayTVC.leSixOfDay			= [self.updatedEntries objectAtIndex:indexPath.row - 1];
		
	} else if ([[segue identifier] isEqualToString:@"Guidelines Followed"]) {
		
		STTraditionsFollowedTVC *tradtionsTVC	= segue.destinationViewController;
		tradtionsTVC.managedObjectContext		= self.managedObjectContext;
		
	} else if ([[segue identifier] isEqualToString:@"Previous Days"]) {
		
		STPreviousDaysTVC *previousDaysTVC		= segue.destinationViewController;
		previousDaysTVC.managedObjectContext	= self.managedObjectContext;
		
	} 
}


#pragma mark - Notification

- (void)addNotification:(LESixOfDay *)sixOfDayLogEntry {
	NSDictionary *userInfo	= @{
	@"logEntryTimeScheduled"	: sixOfDayLogEntry.timeScheduled.timeAndDate,
	@"logEntryAdviceText"		: sixOfDayLogEntry.advice.name
	};
	
	NSLog(@"userInfo dictionary, %@", userInfo);
	
    UILocalNotification *localNotification = [[UILocalNotification alloc] init]; //Create the localNotification object
    
	localNotification.fireDate						= sixOfDayLogEntry.timeScheduled; //Set the date when the alert will be launched using the date adding the time the user selected on the timer
    localNotification.alertAction					= @"OK";							//The button's text that launches the application and is shown in the alert
	localNotification.alertBody						= sixOfDayLogEntry.advice.name;		//Set the message in the notification from the textField's text
    localNotification.hasAction						= YES;								//Set that pushing the button will launch the application
    localNotification.applicationIconBadgeNumber	= [[UIApplication sharedApplication] applicationIconBadgeNumber]+1; //Set the Application Icon Badge Number of the application's icon to the current Application Icon Badge Number plus 1
	localNotification.soundName						= UILocalNotificationDefaultSoundName;
	localNotification.userInfo						= userInfo;
	
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification]; //Schedule the notification with the system
																					 //    [alertNotification setHidden:NO]; //Set the alertNotification to be shown showing the user that the application has registered the local notification
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
