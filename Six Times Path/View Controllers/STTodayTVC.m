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

#define TODAYS_GUIDELINES	0
#define TODAYS_SETUP		1
#define PREVIOUS_DAYS		2

@interface STTodayTVC ()

@property BOOL isOnlyShowingTheSixWithoutUserEntriesSorted;
@property (strong, nonatomic) NSArray *theSixToBeShown;
@property (strong, nonatomic) LESixOfDay *nextEntry;
@property (strong, nonatomic) NSDate *mostRecentlyAddedDate;
@property NSInteger orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay;
@property (strong, nonatomic) NSMutableArray *followedAdvice;

-(void)determineAndSetTheSixToBeShown;
-(void)addNotification:(LESixOfDay *)sixOfDayLogEntry;
-(void)addDay:(id)sender;
-(void)setTheSixAdvicesFor:(Day *)day withIndexOfFirstFollowedAdvice:(NSInteger)indexOfFirstFollowedAdvice inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

@implementation STTodayTVC

@synthesize managedObjectContext		= _managedObjectContext;
@synthesize fetchedResultsController	= _fetchedResultsController;

@synthesize today						= _today;

@synthesize isOnlyShowingTheSixWithoutUserEntriesSorted	= _isOnlyShowingTheSixWithoutUserEntriesSorted;
@synthesize theSixToBeShown								= _theSixToBeShown;
@synthesize nextEntry									= _nextEntry;
@synthesize mostRecentlyAddedDate						= _mostRecentlyAddedDate;
@synthesize orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay	= _orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay;
@synthesize followedAdvice								= _followedAdvice;


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
-(void)onlyShowTheSixWithoutUserEntries:(BOOL)onlyShowWithoutUserEntries
{	
	self.isOnlyShowingTheSixWithoutUserEntriesSorted	= onlyShowWithoutUserEntries;
	
	if (self.isOnlyShowingTheSixWithoutUserEntriesSorted)
		self.theSixToBeShown = [self.today getTheSixWithoutUserEntriesSorted];
	else
		self.theSixToBeShown = [[self.today getTheSixWithoutUserEntriesSorted] arrayByAddingObjectsFromArray:[self.today getTheSixThatHaveUserEntriesSorted]];
	
	NSLog(@"Count of theSixToBeShown: %i", [self.theSixToBeShown count]);
}

#pragma mark - View Loading and Appearing

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.debug	= YES;
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

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
	// this is to make sure that any Core Data changes on other screens will be reflected
	// in this view as necessary (such as timeUpdated)
	[self setupAdviceFetchedResultsController];
	[self setupDaysFetchedResultsController];
	self.title		= self.today.date.date;
	self.nextEntry	= [[self.today getTheSixWithoutUserEntriesSorted] objectAtIndex:0];		// need to account for an empty array
	
	//  [self.tableView reloadData];
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
	} else {
		// Set most recent day
		Day *mostRecentDay						= [self.fetchedResultsController.fetchedObjects objectAtIndex:0];
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
	
    // Date to be added
	// Today
	NSDate *now					= [NSDate date];
	
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
		LESixOfDay *logEntry	= [LESixOfDay logEntryWithAdvice:advice withOrderNumber:orderNumber onDay:day inManagedObjectContext:managedObjectContext];
		
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
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case TODAYS_GUIDELINES:
			return 3;
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

//-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
//{
//	return @"";
//}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == TODAYS_GUIDELINES && indexPath.row == 0)
		return 129;
	else
		return 35;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *guidelineEntryCellIdentifier	= @"GuidelineEntryCell";
	static NSString *summaryOrSetupCellIdentifier	= @"SummaryOrSetupCell";
	
    UITableViewCell *guidelineEntryCell				= [tableView dequeueReusableCellWithIdentifier:guidelineEntryCellIdentifier];
    UITableViewCell *summaryOrSetupCell				= [tableView dequeueReusableCellWithIdentifier:summaryOrSetupCellIdentifier];
	
	
	if (self.debug)
		NSLog(@"Index path [Section, Row]: %d, %d", indexPath.section, indexPath.row);
	
    switch (indexPath.section) {
		case TODAYS_GUIDELINES:
		{
			switch (indexPath.row) {
				case 0:
				{
					if ([[self.today getTheSixWithoutUserEntriesSorted] count] > 0) {
						NSString *timeEntryText	= [NSString stringWithFormat:@"Next Entry - %@", self.nextEntry.timeScheduled.time];
						NSString *guidelineText	= self.nextEntry.advice.name;
						
						[[guidelineEntryCell viewWithTag:10] setValue:timeEntryText forKey:@"text"];
						[[guidelineEntryCell viewWithTag:11] setValue:guidelineText forKey:@"text"];
					} else {
						guidelineEntryCell.hidden	= YES;
					}
					return guidelineEntryCell;
					break;
				}
				case 1:
				{
					summaryOrSetupCell.textLabel.text		= @"Remaining Guidelines";
					summaryOrSetupCell.detailTextLabel.text	= [NSString stringWithFormat:@"%i", [[self.today getTheSixWithoutUserEntriesSorted] count]];
					return summaryOrSetupCell;
					break;
				}
				case 2:
				{
					summaryOrSetupCell.textLabel.text		= @"Guidelines with Entries";
					summaryOrSetupCell.detailTextLabel.text	= [NSString stringWithFormat:@"%i", [[self.today getTheSixThatHaveUserEntriesSorted] count]];
					return summaryOrSetupCell;
				}
				default:
					break;
			}
			break;
		}
		case TODAYS_SETUP:
		{
			switch (indexPath.row) {
				case 0:
				{
					summaryOrSetupCell.textLabel.text		= @"Guidelines Being Followed";
					summaryOrSetupCell.detailTextLabel.text = [NSString stringWithFormat:@"%i", [self.followedAdvice count]];
					return summaryOrSetupCell;
					break;
				}
				case 1:
				{
					summaryOrSetupCell.textLabel.text		= @"Wake Up Time";
					summaryOrSetupCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.today.date.time];
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
		{
			switch (indexPath.row) {
				case 0:
					[self performSegueWithIdentifier:@"Guideline Entry" sender:self];
					break;
				case 1:
					//
					break;
				case 2:
					//
					break;
				default:
					break;
			}
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
	if ([[segue identifier] isEqualToString:@"Guideline Entry"]) {
		
		STLogEntrySixOfDayTVC *leSixOfDayTVC	= segue.destinationViewController;
		leSixOfDayTVC.managedObjectContext		= self.managedObjectContext;
		leSixOfDayTVC.leSixOfDay				= self.nextEntry;
		
	} else if ([[segue identifier] isEqualToString:@"Previous Days"]) {
		
		STDaysTVC *daysTVC						= segue.destinationViewController;
		daysTVC.managedObjectContext			= self.managedObjectContext;
		
	} 
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
