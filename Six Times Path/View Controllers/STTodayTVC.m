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
#import "STDaysTVC.h"
#import "STTraditionsFollowedTVC.h"

#define TODAYS_GUIDELINES			0
#define TODAYS_GUIDELINES_REMAINING	1
#define TODAYS_GUIDELINES_UPDATED	2
#define TODAYS_SETUP				3
#define PREVIOUS_DAYS				4

@interface STTodayTVC ()

@property BOOL isOnlyShowingTheSixWithoutUserEntriesSorted;
//@property (strong, nonatomic) NSArray *theSixToBeShown;
@property (strong, nonatomic) LESixOfDay *nextEntry;
@property (strong, nonatomic) NSArray *remainingScheduledEntries;
@property (strong, nonatomic) NSArray *updatedEntries;
@property BOOL showRemainingScheduledEntries;
@property BOOL showUpdatedEntries;
@property (strong, nonatomic) NSDate *mostRecentlyAddedDate;
@property NSInteger orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay;
@property (strong, nonatomic) NSMutableArray *followedAdvice;
@property NSInteger *wakingHour;
@property NSInteger *wakingMinute;


-(void)determineAndSetTheSixToBeShown;
-(void)addNotification:(LESixOfDay *)sixOfDayLogEntry;
-(void)addDay:(id)sender;
-(void)setTheSixAdvicesFor:(Day *)day withIndexOfFirstFollowedAdvice:(NSInteger)indexOfFirstFollowedAdvice inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

@implementation STTodayTVC

@synthesize managedObjectContext		= _managedObjectContext;
@synthesize fetchedResultsController	= _fetchedResultsController;

@synthesize today						= _today;

//@synthesize theSixToBeShown				= _theSixToBeShown;
@synthesize nextEntry					= _nextEntry;
@synthesize remainingScheduledEntries	= _remainingScheduledEntries;
@synthesize updatedEntries				= _updatedEntries;
@synthesize showRemainingScheduledEntries	= _showRemainingScheduledEntries;
@synthesize showUpdatedEntries				= _showUpdatedEntries;
@synthesize mostRecentlyAddedDate		= _mostRecentlyAddedDate;
@synthesize followedAdvice				= _followedAdvice;
@synthesize wakingHour					= _wakingHour;
@synthesize wakingMinute				= _wakingMinute;

@synthesize isOnlyShowingTheSixWithoutUserEntriesSorted	= _isOnlyShowingTheSixWithoutUserEntriesSorted;
@synthesize orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay	= _orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay;


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

//	DEPRECATED?
/*
-(void)onlyShowTheSixWithoutUserEntries:(BOOL)onlyShowWithoutUserEntries
{	
	self.isOnlyShowingTheSixWithoutUserEntriesSorted	= onlyShowWithoutUserEntries;
	
	if (self.isOnlyShowingTheSixWithoutUserEntriesSorted)
		self.theSixToBeShown = [self.today getTheSixWithoutUserEntriesSorted];
	else
		self.theSixToBeShown = [[self.today getTheSixWithoutUserEntriesSorted] arrayByAddingObjectsFromArray:[self.today getTheSixThatHaveUserEntriesSorted]];
	
	NSLog(@"Count of theSixToBeShown: %i", [self.theSixToBeShown count]);
}
 */

#pragma mark - View Loading and Appearing

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.debug	= YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewWillAppear:(BOOL)animated
{
	[self setupAdviceFetchedResultsController];
	[self setupDaysFetchedResultsController];
	self.title		= self.today.date.date;
	
	NSArray *allRemainingEntries			= [self.today getTheSixWithoutUserEntriesSorted];
	NSRange rangeRemainingScheduledEntries;
	rangeRemainingScheduledEntries.location	= 1;
	rangeRemainingScheduledEntries.length	= [allRemainingEntries count] - 1;
	self.nextEntry							= [allRemainingEntries objectAtIndex:0];
	self.remainingScheduledEntries			= [allRemainingEntries subarrayWithRange:rangeRemainingScheduledEntries];		// need to account for an empty array
	self.showRemainingScheduledEntries		= NO;
	
	self.updatedEntries						= [self.today getTheSixThatHaveUserEntriesSorted];
	self.showUpdatedEntries					= NO;
	
	if (self.debug) {
		NSLog(@"There are %u entries that have been updated.", [[self.today getTheSixThatHaveUserEntriesSorted] count]);
		NSLog(@"There are %u entries that have not yet been updated.", [[self.today getTheSixWithoutUserEntriesSorted] count]);
	}
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
	
	// check to see if any days have been added
	if ([self.fetchedResultsController.fetchedObjects count] == 0) {
		if (self.debug)
			NSLog(@"0 days have been fetched. There isn't a mostRecentlyAddedDate");
		self.mostRecentlyAddedDate				= nil;
	} else {
		// Set most recent day
		Day *mostRecentDay						= [self.fetchedResultsController.fetchedObjects objectAtIndex:0];
		NSLog(@"the mostRecentDay is %@.", mostRecentDay.date.timeAndDate);
		LESixOfDay *lastTheSixOfMostRecentDay	= [[mostRecentDay getTheSixSorted] lastObject];
		self.mostRecentlyAddedDate				= mostRecentDay.date;
		self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay = [self.followedAdvice indexOfObject:lastTheSixOfMostRecentDay.advice] + 1;
		self.today								= mostRecentDay;
		if (self.debug) {
			NSLog(@"Most recent date: %@", self.mostRecentlyAddedDate.date);
			NSLog(@"lastTheSixOfMostRecentDay: %@", lastTheSixOfMostRecentDay.advice.name);
			NSLog(@"Index of that advice: %i", [self.followedAdvice indexOfObject:lastTheSixOfMostRecentDay.advice]);
			NSLog(@"Fetch performed. Number of objects fetched: %u", [self.fetchedResultsController.fetchedObjects count]);
		}
		self.wakingHour		= 5;			// This will need to be fixed
		self.wakingMinute	= 30;			// This will need to be fixed
		
		[self addDay:0];
	}
	if (self.debug)
		NSLog(@"The setup for the Days fetchedResultsController is successful.");
}

-(void)setupAdviceFetchedResultsController
{
	if (self.debug)
		NSLog(@"Preparing to setup the fetchedResultsController for Advice.");
	
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

    self.followedAdvice	= [NSMutableArray arrayWithArray:self.fetchedResultsController.fetchedObjects];
	
	if (self.debug) {
		NSLog(@"Fetch performed. Number of objects fetched: %u", [self.fetchedResultsController.fetchedObjects count]);
		NSLog(@"The count of the advice that is currently being followed is %i", [self.followedAdvice count]);
		NSLog(@"The setup for the Days fetchedResultsController is successful.");
	}
}


#pragma mark - Core Data Add Records

-(void)addDay:(id)sender
{
	if (self.debug)
		NSLog(@"At start of addDay:");
	
	NSDate *now					= [NSDate date];
	
	if (self.mostRecentlyAddedDate) {
		LESixOfDay *lastScheduledLogEntryOfMostRecentDate					= [[self.today getTheSixSorted] lastObject];
		NSDate *sixHoursAfterDateOfLastScheduledLogEntryOfMostRecentDate	= [lastScheduledLogEntryOfMostRecentDate.timeScheduled dateByAddingTimeInterval:6*60*60];
		
		// do the compare
		if ([now compare:sixHoursAfterDateOfLastScheduledLogEntryOfMostRecentDate] == NSOrderedDescending) {
			NSLog(@"Now [%@] is later in time than 6 Hours After Date of Last Scheduled Loge Entry of Most Recent Date [%@].", now.timeAndDate, sixHoursAfterDateOfLastScheduledLogEntryOfMostRecentDate.timeAndDate);
			
			Day *newDay					= [NSEntityDescription insertNewObjectForEntityForName:@"Day"
															inManagedObjectContext:self.managedObjectContext];
			
			newDay.date					= now;
			self.mostRecentlyAddedDate	= newDay.date;
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
			NSLog(@"Now [%@] is earlier (or exactly equal) in time than 6 Hours After Date of Last Scheduled Loge Entry of Most Recent Date [%@].", now.timeAndDate, sixHoursAfterDateOfLastScheduledLogEntryOfMostRecentDate.timeAndDate);
		}
	}
}

-(void)setTheSixAdvicesFor:(Day *)day withIndexOfFirstFollowedAdvice:(NSInteger)indexOfFirstFollowedAdvice inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	int indexOfFollowedAdviceForTheDay;
	
	// Check to see if the index of the first followed Advice that was passed into the method exceeds the index limit of the followedAdvice array and reset as necessary
	
	if (indexOfFirstFollowedAdvice >= [self.followedAdvice count])
		indexOfFirstFollowedAdvice = 0;
	
    
    // Starting with the first advice to be followed for the day, cycle through the advice that has been
	// selected to be followed and add 6 advices to LogEntries that will be added to a day.
    for (int followedAdviceIncrement=0; followedAdviceIncrement<6; followedAdviceIncrement++) {
        indexOfFollowedAdviceForTheDay = followedAdviceIncrement + indexOfFirstFollowedAdvice;
		
		if (self.debug)
			NSLog(@"indexOfFollowedAdviceForTheDay: %i", indexOfFollowedAdviceForTheDay);
        
        if (indexOfFollowedAdviceForTheDay==[self.followedAdvice count] - 1)
        {
            // reset to the beginning
            indexOfFirstFollowedAdvice = -1 - followedAdviceIncrement;
			
			if (self.debug)
				NSLog(@"indexOfFirstFollowedAdvice has been reset. Value is now: %i", indexOfFirstFollowedAdvice);
        }
        
		// Add the advice to a log entry
		Advice *advice			= [self.followedAdvice objectAtIndex:indexOfFollowedAdviceForTheDay];
		
		// orderNumber range will be 1-6
		NSInteger orderNumber	= followedAdviceIncrement+1;
		
		// Create a log entry for the Six of the Day and initiate it with advice, and order number, and the day -- add to the managedObjectContext
		LESixOfDay *logEntry	= [LESixOfDay logEntryWithAdvice:advice withOrderNumber:orderNumber onDay:day withWakingHour:self.wakingHour andWakingMinute:self.wakingMinute inManagedObjectContext:managedObjectContext];
		
		if (self.debug)
			[logEntry logValuesOfLogEntry];
		
		// Add the log entry to the day
		[day addTheSixObject:logEntry];
		
		// TEMP
		//
		self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay = indexOfFollowedAdviceForTheDay;
	}
	
	// Increment up 1 for the next day to be created
	self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay++;
	
	// Set the notifications
	for (LESixOfDay *logEntry in day.theSix) {
		[self addNotification:logEntry];
	}
	
	
	if (self.debug)
		NSLog(@"The next starting orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay will be %i", self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay);
}




#pragma mark - Table View Structure

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return PREVIOUS_DAYS + 1;	// Index of Last Section + 1
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case TODAYS_GUIDELINES:
			return 1;
			break;
			
		case TODAYS_GUIDELINES_REMAINING:
			if (self.showRemainingScheduledEntries)
				return [self.remainingScheduledEntries count] + 1;
			else
				return 1;
			break;
			
		case TODAYS_GUIDELINES_UPDATED:
			if (self.showUpdatedEntries)
				return [self.updatedEntries count] + 1;
			else
				return 1;
			break;
		
		case TODAYS_SETUP:
			return 2;
			break;
			
		case PREVIOUS_DAYS:
			return 1;
			
		default:
			break;
	}
	return 0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case TODAYS_GUIDELINES:
			return @"Today's Guidelines";
			break;
			
		case TODAYS_SETUP:
			return @"Setup for Today";
			break;
			
		case PREVIOUS_DAYS:
			return nil;
			break;
			
		default:
			break;
	}
	return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == TODAYS_GUIDELINES)
		return 129;		// change for landscape orientation?
	else if ((indexPath.section == TODAYS_GUIDELINES_REMAINING || indexPath.section == TODAYS_GUIDELINES_UPDATED) && indexPath.row > 0)
		return 81;
	else
		return 35;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *guidelineNextEntryCellIdentifier	= @"GuidelineNextEntryCell";
	static NSString *guidelineOtherEntryCellIdentifier	= @"GuidelineOtherEntryCell";
	static NSString *summaryOrSetupCellIdentifier		= @"SummaryOrSetupCell";
	
	//	UITableViewCell
	
	
	if (self.debug)
		NSLog(@"Index path [Section, Row]: %d, %d", indexPath.section, indexPath.row);
	
    switch (indexPath.section) {
		case TODAYS_GUIDELINES:
		{
			UITableViewCell *guidelineNextEntryCell		= [tableView dequeueReusableCellWithIdentifier:guidelineNextEntryCellIdentifier];
			
			if ([[self.today getTheSixWithoutUserEntriesSorted] count] > 0) {
				NSString *timeEntryText	= [NSString stringWithFormat:@"Next Entry - %@", self.nextEntry.timeScheduled.time];
				NSString *guidelineText	= self.nextEntry.advice.name;
				
				[[guidelineNextEntryCell viewWithTag:10] setValue:timeEntryText forKey:@"text"];
				[[guidelineNextEntryCell viewWithTag:11] setValue:guidelineText forKey:@"text"];
			} else {
				NSString *timeEntryText	= @"Excellent!";
				NSString *guidelineText	= @"You've made entries for all 6 guidelines. Be happy over what you've done well to day, and regret the mistaken actions.";
				
				[[guidelineNextEntryCell viewWithTag:10] setValue:timeEntryText forKey:@"text"];
				[[guidelineNextEntryCell viewWithTag:11] setValue:guidelineText forKey:@"text"];
				
				//	guidelineNextEntryCell.hidden	= YES;
			}
			return guidelineNextEntryCell;
			break;
		}
		case TODAYS_GUIDELINES_REMAINING:
		{
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
			break;
		}
		case TODAYS_GUIDELINES_UPDATED:
		{
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
		}
		case TODAYS_SETUP:
		{
			switch (indexPath.row) {
				case 1:
				{
					UITableViewCell *summaryOrSetupCell					= [tableView dequeueReusableCellWithIdentifier:summaryOrSetupCellIdentifier];
					
					summaryOrSetupCell.textLabel.text		= @"Guidelines Being Followed";
					summaryOrSetupCell.detailTextLabel.text = [NSString stringWithFormat:@"%i", [self.followedAdvice count]];
					return summaryOrSetupCell;
					break;
				}
				case 0:
				{
					UITableViewCell *summaryOrSetupCell					= [tableView dequeueReusableCellWithIdentifier:summaryOrSetupCellIdentifier];
					
					summaryOrSetupCell.textLabel.text		= @"Wake Up Time";
					LESixOfDay *firstGuidelineOfDay			= [[self.today getTheSixSorted] objectAtIndex:0];
					NSDate *wakeUpAt						= [firstGuidelineOfDay.timeScheduled dateByAddingTimeInterval:-2*60*60];	// this will need to be fixed
					summaryOrSetupCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", wakeUpAt.time];
					return summaryOrSetupCell;
					break;
				}
				default:
					break;
			}
			break;
		}
		case PREVIOUS_DAYS:
		{
			UITableViewCell *summaryOrSetupCell					= [tableView dequeueReusableCellWithIdentifier:summaryOrSetupCellIdentifier];
			
			summaryOrSetupCell.textLabel.text		= @"Previous Days";
			summaryOrSetupCell.detailTextLabel.text	= @"";
			return summaryOrSetupCell;
			break;
		}
		default:
			break;
	}
	return nil;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) {
		case TODAYS_GUIDELINES:
			[self performSegueWithIdentifier:@"Guideline Entry" sender:self];
			break;
		case TODAYS_GUIDELINES_REMAINING:
		{
			if ([self.remainingScheduledEntries count] > 0) {
				if (indexPath.row > 0) {
					[self performSegueWithIdentifier:@"Guideline Entry" sender:self];
				} else {
					self.showRemainingScheduledEntries	= (self.showRemainingScheduledEntries) ? NO : YES;		// toggle to other state
					[tableView reloadSections:[NSIndexSet indexSetWithIndex:TODAYS_GUIDELINES_REMAINING] withRowAnimation:YES];
				}
			}
			break;
		}
			
		case TODAYS_GUIDELINES_UPDATED:
		{
			if ([self.updatedEntries count] > 0) {
				if (indexPath.row > 0) {
					[self performSegueWithIdentifier:@"Guideline Entry" sender:self];					
				} else {
					self.showUpdatedEntries = (self.showUpdatedEntries) ? NO : YES;
					[tableView reloadSections:[NSIndexSet indexSetWithIndex:TODAYS_GUIDELINES_UPDATED] withRowAnimation:YES];
				}
			}
			break;
		}
		case TODAYS_SETUP:
		{
			switch (indexPath.row) {
				case 0:
					// get date picker
					break;
				case 1:
					[self performSegueWithIdentifier:@"Guidelines Followed" sender:self];
					break;
				default:
					break;
			}
		}
		case PREVIOUS_DAYS:
			[self performSegueWithIdentifier:@"Previous Days" sender:self];
			break;
		default:
			break;
	}
}


#pragma mark - UI Interactions

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	NSIndexPath *indexPath  = [self.tableView indexPathForSelectedRow];
	
	if ([[segue identifier] isEqualToString:@"Guideline Entry"]) {
		
		//	Get the indexPath for which entry this should go to
		
		STLogEntrySixOfDayTVC *leSixOfDayTVC	= segue.destinationViewController;
		leSixOfDayTVC.managedObjectContext		= self.managedObjectContext;
		
		switch (indexPath.section) {
			case TODAYS_GUIDELINES:
				leSixOfDayTVC.leSixOfDay		= self.nextEntry;
				break;
			case TODAYS_GUIDELINES_REMAINING:
				leSixOfDayTVC.leSixOfDay		= [self.remainingScheduledEntries objectAtIndex:indexPath.row - 1];
				break;
			case TODAYS_GUIDELINES_UPDATED:
				leSixOfDayTVC.leSixOfDay		= [self.updatedEntries objectAtIndex:indexPath.row - 1];
				
			default:
				break;
		}
		
	} else if ([[segue identifier] isEqualToString:@"Guidelines Followed"]) {
		
		STTraditionsFollowedTVC *tradtionsTVC	= segue.destinationViewController;
		tradtionsTVC.managedObjectContext		= self.managedObjectContext;
		
	} else if ([[segue identifier] isEqualToString:@"Previous Days"]) {
		
		STDaysTVC *daysTVC						= segue.destinationViewController;
		daysTVC.managedObjectContext			= self.managedObjectContext;
		
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
