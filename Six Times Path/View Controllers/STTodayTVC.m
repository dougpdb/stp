//
//  STTodayTVC.m
//  Six Times Path
//
//  Created by Doug on 12/5/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "STAppDelegate.h"
#import "STTodayTVC.h"
#import "STLogEntrySixOfDayTVC.h"
#import "STPreviousDaysTVC.h"
#import "STSetsOfAdviceTVC.h"
#import "STNotificationController.h"
#import "Advice.h"
#import "Day+ST.h"
#import "LESixOfDay+ST.h"
#import "NSDate+ST.h"
#import "NSDate+ES.h"
#import "TestFlight.h"

#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_PORTRAIT 

#define GUIDELINE_LABEL_WIDTH	268
#define ACTION_LABEL_WIDTH		245

//	http://developer.apple.com/library/ios/samplecode/DateCell/Listings/MyTableViewController_m.html#//apple_ref/doc/uid/DTS40008866-MyTableViewController_m-DontLinkElementID_6

#define kPickerAnimationDuration    0.40   // duration for the animation to slide the date picker into view
#define kDatePickerTag              99     // view tag identifiying the date picker view

#define kTitleKey       @"title"   // key for obtaining the data source item's title
#define kDateKey        @"date"    // key for obtaining the data source item's date value

// keep track of which rows have date cells
#define kDateStartRow   0
// #define kDateEndRow     1

static NSString *kDateCellID = @"dateCell";     // the cells with the start or end date
static NSString *kDatePickerID = @"datePickerCell"; // the cell containing the date picker
static NSString *kOtherCell = @"otherCell";     // the remaining cells at the end


NSString *kNextEntry					= @"Next Entry";
NSString *kWelcomeIntroduction			= @"Welcome Introduction";
NSString *kNoSetsOfGuidelinesSelected	= @"No Sets of Guidelines Selected";
NSString *kRemainingScheduledEntries	= @"Remaining Scheduled Entries";
NSString *kUpdatedEntries				= @"Updated Entries";
NSString *kSetupForDay					= @"Setup for Day";
NSString *kPreviousDays					= @"Previous Days";
NSString *kIntroductoryMessage			= @"Welcome to Six Times Path!\n\nBegin by selecting 1 or more sets of ethical guidelines that you want to observe.\n\nFrom those, Six Times Path will daily select 6 guidelines, rotating through the guidelines you selected.\n\nYou can then consider and record how you have or haven't been following each guideline.\n\nBy checking in throughout the day, you strengthen your ability to live your life according to the principles that are important to you.";
NSString *kSelectGuidelinesMessage		= @"You do not have any sets of ethical guidelines selected to observe from day to day.\n\nSelect guidelines to resume using Six Times.";
NSString *kCongratulationsMessage		= @"You've made entries for all 6 guidelines. Be happy over what you've done well to day, and regret the mistaken actions.";

@interface STTodayTVC ()

@property (nonatomic, retain) IBOutlet UIDatePicker *pickerView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *feedbackButton;

@property (nonatomic, weak) NSArray *dataArray;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

// keep track which indexPath points to the cell with UIDatePicker
@property (nonatomic, strong) NSIndexPath *datePickerIndexPath;

@property (assign) NSInteger pickerCellRowHeight;

@property (nonatomic, strong) STNotificationController *notificationController;

- (IBAction)greatHighwayExplorerFeedback:(id)sender;


@end

@implementation STTodayTVC

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
	if (self.databaseWasJustCreatedForFirstTime && !self.setsOfGuidelinesHaveBeenSelected) {
		_countOfTheSixWithoutUserEntries	= 0;
	} else if (_countOfTheSixWithoutUserEntries == -1) {
		_countOfTheSixWithoutUserEntries	= [[self.thisDay getTheSixWithoutUserEntriesSorted] count];
	}
	
	return _countOfTheSixWithoutUserEntries;
}

-(void)resetCountOfTheSixWithoutUserEntries
{
	_countOfTheSixWithoutUserEntries	= -1;
}

-(NSMutableArray *)tableViewSections
{
	if (_tableViewSections == nil) {
		NSMutableArray *tmpSectionArray	= [NSMutableArray arrayWithObjects:kNextEntry,
																		   kWelcomeIntroduction,
																		   kNoSetsOfGuidelinesSelected,
																		   kRemainingScheduledEntries,
																		   kUpdatedEntries,
																		   kSetupForDay,
																		   kPreviousDays,
																			nil];

		[self resetCountOfTheSixWithoutUserEntries];

		if (self.databaseWasJustCreatedForFirstTime && !self.setsOfGuidelinesHaveBeenSelected) {
			[tmpSectionArray removeObjectIdenticalTo:kNextEntry];
			[tmpSectionArray removeObjectIdenticalTo:kNoSetsOfGuidelinesSelected];
			[tmpSectionArray removeObjectIdenticalTo:kRemainingScheduledEntries];
			[tmpSectionArray removeObjectIdenticalTo:kUpdatedEntries];
			[tmpSectionArray removeObjectIdenticalTo:kPreviousDays];
		} else if (!self.setsOfGuidelinesHaveBeenSelected) {
			[tmpSectionArray removeObjectIdenticalTo:kNextEntry];
			[tmpSectionArray removeObjectIdenticalTo:kWelcomeIntroduction];
			[tmpSectionArray removeObjectIdenticalTo:kRemainingScheduledEntries];
			[tmpSectionArray removeObjectIdenticalTo:kUpdatedEntries];
		} else if ([self.allAdviceFollowedByUser count] == 0) {
			[tmpSectionArray removeObjectIdenticalTo:kWelcomeIntroduction];
			[tmpSectionArray removeObjectIdenticalTo:kNoSetsOfGuidelinesSelected];
			[tmpSectionArray removeObjectIdenticalTo:kRemainingScheduledEntries];
			[tmpSectionArray removeObjectIdenticalTo:kUpdatedEntries];
		} else if (self.countOfTheSixWithoutUserEntries <= 1) {
			[tmpSectionArray removeObjectIdenticalTo:kWelcomeIntroduction];
			[tmpSectionArray removeObjectIdenticalTo:kNoSetsOfGuidelinesSelected];
			[tmpSectionArray removeObjectIdenticalTo:kRemainingScheduledEntries];
		} else if (self.countOfTheSixWithoutUserEntries == 6) {
			[tmpSectionArray removeObjectIdenticalTo:kWelcomeIntroduction];
			[tmpSectionArray removeObjectIdenticalTo:kNoSetsOfGuidelinesSelected];
			[tmpSectionArray removeObjectIdenticalTo:kUpdatedEntries];
		}

		_tableViewSections	= tmpSectionArray;
	}
	
	return _tableViewSections;
}

-(void)resetTableViewSections
{
	_tableViewSections = nil;
}


#pragma mark - View Loading and Appearing

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.debug					= YES;
	
	self.notificationController	= [[STNotificationController alloc] init];
	
	self.dateFormatter			= [[NSDateFormatter alloc] init];
	[self.dateFormatter setDateFormat:@"h:mm a"];
	// obtain the picker view cell's height, works because the cell was pre-defined in our storyboard
    UITableViewCell *pickerViewCellToCheck = [self.tableView dequeueReusableCellWithIdentifier:kDatePickerID];
    self.pickerCellRowHeight = pickerViewCellToCheck.frame.size.height;


	if ([self isMemberOfClass:[STTodayTVC class]])
		self.navigationItem.leftBarButtonItem	= self.feedbackButton;

	if (self.databaseWasJustCreatedForFirstTime)
		self.setsOfGuidelinesHaveBeenSelected	= NO;
	
	if (self.databaseWasJustCreatedForFirstTime)
		NSLog(@"first day of use.");
	else
		NSLog(@"not the first day of use.");
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	//	self.showRemainingScheduledEntries	= nil;
	//	self.showUpdatedEntries				= nil;
	
	self.thisDay					= nil;
	self.nextEntry					= nil;
	self.entryFromNotification		= nil;
	self.remainingScheduledEntries	= nil;
	self.updatedEntries				= nil;
	self. mostRecentlyAddedDate		= nil;
	//	self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay	= nil;
	self.allAdviceFollowedByUser	= nil;
	//	self.countOfTheSixWithoutUserEntries	= nil;
	self.tableViewSections			= nil;
	
	self.dataArray					= nil;
	self.dateFormatter				= nil;
	self.doneButton					= nil;
	self.feedbackButton				= nil;
	self.pickerView					= nil;
	self.fetchedResultsController	= nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewWillAppear:(BOOL)animated
{	
	[self setupDayAndAdviceData];
	self.title							= self.mostRecentlyAddedDate.weekdayMonthAndDay;
	[self resetTableViewSections];
	[self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
	self.showUpdatedEntries				= NO;
	self.showRemainingScheduledEntries	= NO;
}



#pragma mark - Set Data for the Table View Controller
//-(void)setup
//{
//	
//}
//
//-(void)setupSecond

-(void)setupDayAndAdviceData
{
	if (self.databaseWasJustCreatedForFirstTime) {
		self.setsOfGuidelinesHaveBeenSelected	= NO;
	} else {
		[self setupAdviceFetchedResultsController];
		self.allAdviceFollowedByUser			= [NSMutableArray arrayWithArray:self.fetchedResultsController.fetchedObjects];
		self.setsOfGuidelinesHaveBeenSelected	= ([self.allAdviceFollowedByUser count] > 0) ? YES : NO;

		if (self.setsOfGuidelinesHaveBeenSelected)
			NSLog(@"Guidelines have been selected.");
		else
			NSLog(@"Guidelines have NOT been selected.");
	}
	
	if (self.setsOfGuidelinesHaveBeenSelected && self.thereAreCoreDataRecordsForDay) {
		// This should be the typical use case -- where the user had already selected a set of guidelines
		// and has also set up a day of entries in Six Times
		
		[self setupDaysFetchedResultsController];
		Day *mostRecentDay							= [self.fetchedResultsController.fetchedObjects objectAtIndex:0];
		LESixOfDay *lastTheSixOfMostRecentDay		= [[mostRecentDay getTheSixSorted] lastObject];
		self.mostRecentlyAddedDate					= mostRecentDay.date;
		self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay = [self.allAdviceFollowedByUser indexOfObject:lastTheSixOfMostRecentDay.advice] + 1;
		self.thisDay								= mostRecentDay;
		
		[self addDay];
		
		NSArray *allRemainingEntries				= [self.thisDay getTheSixWithoutUserEntriesSorted];
		
		NSRange rangeRemainingScheduledEntries;
		rangeRemainingScheduledEntries.location		= 1;
		rangeRemainingScheduledEntries.length		= ([[self.thisDay getTheSixWithoutUserEntriesSorted] count] == 0) ? 0 : [allRemainingEntries count] - 1;
		
		if ([allRemainingEntries count] > 0)
			self.nextEntry							= [allRemainingEntries objectAtIndex:0];
		
		self.remainingScheduledEntries				= ([[self.thisDay getTheSixWithoutUserEntriesSorted] count] == 0) ? allRemainingEntries : [allRemainingEntries subarrayWithRange:rangeRemainingScheduledEntries];
		
		self.showRemainingScheduledEntries			= NO;
		
		self.updatedEntries							= [self.thisDay getTheSixThatHaveUserEntriesSorted];
		self.showUpdatedEntries						= NO;
		
		[self resetCountOfTheSixWithoutUserEntries];
	} else if (self.thereAreCoreDataRecordsForDay) {
		// Here might be a more common edge case -- the user has already has a day of entries set up in Six Times
		// but does not have a set of guidelines set up
	
		[self setupDaysFetchedResultsController];
		Day *mostRecentDay							= [self.fetchedResultsController.fetchedObjects objectAtIndex:0];
		LESixOfDay *lastTheSixOfMostRecentDay		= [[mostRecentDay getTheSixSorted] lastObject];
		self.mostRecentlyAddedDate					= mostRecentDay.date;
		self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay = [self.allAdviceFollowedByUser indexOfObject:lastTheSixOfMostRecentDay.advice] + 1;
		self.thisDay								= mostRecentDay;
		
		[self addDay];
		
		NSArray *allRemainingEntries				= [self.thisDay getTheSixWithoutUserEntriesSorted];
		
		NSRange rangeRemainingScheduledEntries;
		rangeRemainingScheduledEntries.location		= 1;
		rangeRemainingScheduledEntries.length		= ([[self.thisDay getTheSixWithoutUserEntriesSorted] count] == 0) ? 0 : [allRemainingEntries count] - 1;
		
		if ([allRemainingEntries count] > 0)
			self.nextEntry							= [allRemainingEntries objectAtIndex:0];
		
		self.remainingScheduledEntries				= ([[self.thisDay getTheSixWithoutUserEntriesSorted] count] == 0) ? allRemainingEntries : [allRemainingEntries subarrayWithRange:rangeRemainingScheduledEntries];
		
		self.showRemainingScheduledEntries			= NO;
		
		self.updatedEntries							= [self.thisDay getTheSixThatHaveUserEntriesSorted];
		self.showUpdatedEntries						= NO;
		
		[self resetCountOfTheSixWithoutUserEntries];
		
	} else if (self.setsOfGuidelinesHaveBeenSelected && !self.thereAreCoreDataRecordsForDay) {
		// The rare edge case for when the user is has started to used the app after installing it, but it will happen at least once -- the user has
		// selected a set of guidelines but a day of entries has not yet been set up. This will occur after going through the following use case.
		self.mostRecentlyAddedDate					= [NSDate dateYesterday];
		self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay = 0;
		self.thisDay								= nil;
		
		[self addDay];
		
		NSArray *allRemainingEntries				= [self.thisDay getTheSixWithoutUserEntriesSorted];
		
		NSRange rangeRemainingScheduledEntries;
		rangeRemainingScheduledEntries.location		= 1;
		rangeRemainingScheduledEntries.length		= ([[self.thisDay getTheSixWithoutUserEntriesSorted] count] == 0) ? 0 : [allRemainingEntries count] - 1;
		
		if ([allRemainingEntries count] > 0)
			self.nextEntry							= [allRemainingEntries objectAtIndex:0];
		
		self.remainingScheduledEntries				= ([[self.thisDay getTheSixWithoutUserEntriesSorted] count] == 0) ? allRemainingEntries : [allRemainingEntries subarrayWithRange:rangeRemainingScheduledEntries];
		
		self.showRemainingScheduledEntries			= NO;
		
		self.updatedEntries							= [self.thisDay getTheSixThatHaveUserEntriesSorted];
		self.showUpdatedEntries						= NO;
		
		[self resetCountOfTheSixWithoutUserEntries];

	} else {
		// This is the use case of when a user 1st runs Six Times app after it has been installed. The user hasn't selected any sets of guidelines
		// and a day of entries has not yet been set up. This use case will definitely run once, but if the user opens the app reads the welcome
		// message and closes it, then this use case would run again.l
	}
}


#pragma mark - Core Data Setup

-(void)setupDaysFetchedResultsController
{
	NSFetchRequest *request			= [NSFetchRequest fetchRequestWithEntityName:@"Day"];
    request.sortDescriptors			= @[[NSSortDescriptor sortDescriptorWithKey:@"date"
																ascending:NO]];
    self.fetchedResultsController	= [[NSFetchedResultsController alloc] initWithFetchRequest:request
																		managedObjectContext:self.managedObjectContext
																		  sectionNameKeyPath:nil
																				   cacheName:nil];
}

-(void)setupAdviceFetchedResultsController
{
    NSFetchRequest *request			= [NSFetchRequest fetchRequestWithEntityName:@"Advice"];
    request.predicate				= [NSPredicate predicateWithFormat:@"containedWithinSetOfAdvice.orderNumberInFollowedSets > 0", [NSNumber numberWithBool:YES]];
    request.sortDescriptors			= @[[NSSortDescriptor sortDescriptorWithKey:@"containedWithinSetOfAdvice.orderNumberInFollowedSets"
																	 ascending:YES
																	  selector:@selector(localizedCaseInsensitiveCompare:)],
										[NSSortDescriptor sortDescriptorWithKey:@"orderNumberInSet"
																	  ascending:YES]];
    self.fetchedResultsController	= [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:@"containedWithinSetOfAdvice.name"
                                                                                   cacheName:nil];
}


#pragma mark - Core Data Add and Manage Records

-(BOOL)isTimeToAddDay
{
	NSDate *now						= [NSDate date];
	NSDate *mostRecentDate			= [self.mostRecentlyAddedDate setHour:[self.thisDay.startHour intValue]
														 andMinute:[self.thisDay.startMinute intValue]];
	
	NSTimeInterval eighteenHours	= 18*60*60;

	if (self.mostRecentlyAddedDate)
		return ([now compare:[mostRecentDate dateByAddingTimeInterval:eighteenHours]] == NSOrderedDescending);
	else
		return false;
}

-(void)addDay
{
	NSDate *now						= [NSDate date];
	NSDate *mostRecentDate			= [self.mostRecentlyAddedDate setHour:[self.thisDay.startHour intValue]
																andMinute:[self.thisDay.startMinute intValue]];
	
	NSTimeInterval eighteenHours	= 18*60*60;
	NSTimeInterval twentyFourHours	= 24*60*60;
	
	if ([self isTimeToAddDay]) {
		NSLog(@"Now [%@] is later in time than 18 Hours after start of Most Recent Date [%@].", now.timeAndDate, mostRecentDate.timeAndDate);
		
		[self.notificationController cancelAllNotifications];
		
		Day *newDay					= [NSEntityDescription insertNewObjectForEntityForName:@"Day"
																	inManagedObjectContext:self.managedObjectContext];
		
		BOOL nowIsOnSameDateAsMostRecentDateButAfterEntryLogging	= ([now compare:[mostRecentDate dateByAddingTimeInterval:eighteenHours]] == NSOrderedDescending && [now compare:[mostRecentDate dateByAddingTimeInterval:twentyFourHours]] == NSOrderedAscending);
		
		newDay.date					= (nowIsOnSameDateAsMostRecentDateButAfterEntryLogging) ? [mostRecentDate dateByAddingTimeInterval:twentyFourHours] : now;
		
		newDay.startHour			= (self.thisDay.startHour) ? self.thisDay.startHour : [NSNumber numberWithInt:6];
		newDay.startMinute			= (self.thisDay.startMinute) ? self.thisDay.startMinute : [NSNumber numberWithInt:0];
		
		[self setTheSixFor:newDay withIndexOfFirstFollowedAdvice:self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay inManagedObjectContext:self.managedObjectContext];

		self.mostRecentlyAddedDate	= newDay.date;
		self.thisDay				= newDay;
		
		[self setSuspendAutomaticTrackingOfChangesInManagedObjectContext:YES];
		[self saveContext];
		[self performFetch];
		[self setSuspendAutomaticTrackingOfChangesInManagedObjectContext:NO];
		
		[self resetTableViewSections];
		[self.tableView reloadData];

		[TestFlight passCheckpoint:[NSString stringWithFormat:@"ADD DAY %i", [self.fetchedResultsController.fetchedObjects count]]];
	}
}

-(void)setTheSixFor:(Day *)day withIndexOfFirstFollowedAdvice:(NSInteger)indexOfFirstFollowedAdvice inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	int indexOfFollowedAdviceForTheDay;
	
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
        
		Advice *advice			= [self.allAdviceFollowedByUser objectAtIndex:indexOfFollowedAdviceForTheDay];
		
		// orderNumber range will be 1-6
		NSInteger orderNumber	= allAdviceFollowedByUserIncrement+1;
		
		LESixOfDay *logEntry	= [LESixOfDay logEntryWithAdvice:advice
											  withOrderNumber:orderNumber
														onDay:day
									   inManagedObjectContext:managedObjectContext];
		
		if (self.debug)
			[logEntry logValuesOfLogEntry];
		
		[day addTheSixObject:logEntry];
		
		self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay = indexOfFollowedAdviceForTheDay;
	}
	
	self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay++;
	
//	for (LESixOfDay *logEntry in day.theSix) {
//		[self addNotification:logEntry];
//	}
	
	[self.notificationController addNotifications:[day getTheSixSorted]];
}

-(void)resetTheSixToBeShown
{
	// TO BE COMPLETED
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
		[managedObjectContext hasChanges];
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


#pragma mark - Table View Structure

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.tableViewSections count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == [self.tableViewSections indexOfObject:kNextEntry]) {
		return 1;
	} else if (section == [self.tableViewSections indexOfObject:kRemainingScheduledEntries]) {
		if (self.showRemainingScheduledEntries)
			return [self.remainingScheduledEntries count] + 1;
		else
			return 1;		
	} else if (section == [self.tableViewSections indexOfObject:kUpdatedEntries]) {
		if (self.countOfTheSixWithoutUserEntries == 0)
			self.showUpdatedEntries	= YES;
		if (self.showUpdatedEntries)
			return [self.updatedEntries count] + 1;
		else
			return 1;
	} else if (section == [self.tableViewSections indexOfObject:kSetupForDay]) {
		if (self.setsOfGuidelinesHaveBeenSelected)
			return ([self hasInlineDatePicker]) ? 3 : 2;
		else
			return 1;
	} else {
		return 1;
	}
}

/*	PROCESSED
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ([self hasInlineDatePicker])
	{
		// we have a date picker, so allow for it in the number of rows in this section
		NSInteger numRows = self.dataArray.count;
		return ++numRows;
	}
	
	return self.dataArray.count;
}
*/

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == [self.tableViewSections indexOfObject:kNextEntry])
		return @"Today's Guidelines";
	else if (section == [self.tableViewSections indexOfObject:kSetupForDay])
		return @"Setup for Today";
	else
		return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UILabel *guidelineLabel			= [UILabel new];
	guidelineLabel.lineBreakMode	= NSLineBreakByWordWrapping;

	if (indexPath.section == [self.tableViewSections indexOfObject:kNextEntry]) {
		
		guidelineLabel.font				= [UIFont fontWithName:@"Palatino Bold" size:17]; // [UIFont boldSystemFontOfSize:17];
		
		if (self.setsOfGuidelinesHaveBeenSelected && self.countOfTheSixWithoutUserEntries > 0)
			guidelineLabel.text			= self.nextEntry.advice.name;
		else if (self.setsOfGuidelinesHaveBeenSelected && self.countOfTheSixWithoutUserEntries == 0)
			guidelineLabel.text			= kCongratulationsMessage;
		else if (!self.setsOfGuidelinesHaveBeenSelected && self.thereAreCoreDataRecordsForDay)
			guidelineLabel.text			= kSelectGuidelinesMessage;
		else if (!self.setsOfGuidelinesHaveBeenSelected)
			guidelineLabel.text			= kIntroductoryMessage;
		
		CGFloat guidelineLabelHeight	= [self heightForLabel:guidelineLabel withText:guidelineLabel.text labelWidth:GUIDELINE_LABEL_WIDTH];
		
		return 30 + guidelineLabelHeight + 8;		// change for landscape orientation?
		
	} else if (indexPath.section == [self.tableViewSections indexOfObject:kRemainingScheduledEntries] && indexPath.row > 0) {
		
		guidelineLabel.font				= [UIFont boldSystemFontOfSize:15];
		guidelineLabel.text				= [[[self.remainingScheduledEntries objectAtIndex:indexPath.row - 1] valueForKey:@"advice"] valueForKey:@"name"];
		
		CGFloat guidelineLabelHeight	= [self heightForLabel:guidelineLabel withText:guidelineLabel.text labelWidth:GUIDELINE_LABEL_WIDTH];

		return 30 + guidelineLabelHeight + 8;
		
	} else if (indexPath.section == [self.tableViewSections indexOfObject:kUpdatedEntries] && indexPath.row > 0) {
		
		guidelineLabel.font				= [UIFont boldSystemFontOfSize:15];
		guidelineLabel.text				= [[[self.updatedEntries objectAtIndex:indexPath.row - 1] valueForKey:@"advice"] valueForKey:@"name"];
		
		CGFloat guidelineLabelHeight	= [self heightForLabel:guidelineLabel withText:guidelineLabel.text labelWidth:GUIDELINE_LABEL_WIDTH];
		
		return 30 + guidelineLabelHeight + 65;
		
	} else if ([self indexPathHasPicker:indexPath]) {
		
		return self.pickerCellRowHeight;

	} else {
		
		return 35;
		
	}
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	return ([self indexPathHasPicker:indexPath] ? self.pickerCellRowHeight : self.tableView.rowHeight);
//}


#pragma mark - Managing Cell and Label Heights
-(CGFloat)heightForLabel:(UILabel *)label withText:(NSString *)text labelWidth:(CGFloat)labelWidth
{
	UIFont *font	= label.font;
	NSAttributedString *attributedText = [ [NSAttributedString alloc]
										  initWithString:text
										  attributes: @{NSFontAttributeName: font}
										  ];
	CGRect rect		= [attributedText boundingRectWithSize:(CGSize){labelWidth, CGFLOAT_MAX}
											   options:NSStringDrawingUsesLineFragmentOrigin
											   context:nil];
	CGSize size		= rect.size;
	CGFloat height	= ceilf(size.height);
	//	CGFloat width  = ceilf(size.width);
	return height;
}

-(void)resizeHeightToFitForLabel:(UILabel *)label labelWidth:(CGFloat)labelWidth
{
	CGRect newFrame			= label.frame;
	newFrame.size.height	= [self heightForLabel:label withText:label.text labelWidth:labelWidth];
	label.frame				= newFrame;
}



#pragma mark - Table view data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *guidelineNextEntryCellIdentifier		= @"GuidelineNextEntryCell";
	static NSString *guidelineOtherEntryCellIdentifier		= @"GuidelineOtherEntryCell";
	static NSString *guidelineSummaryEntryCellIdentifier	= @"GuidelineSummaryEntryCell";
	static NSString *summaryOrSetupCellIdentifier			= @"SummaryOrSetupCell";
	static NSString *dateCellIdentifier						= @"dateCell";
	static NSString *datePickerCellIdentifier				= @"datePickerCell";
		
    if (indexPath.section == [self.tableViewSections indexOfObject:kNextEntry]) {
		
			UITableViewCell *guidelineNextEntryCell		= [tableView dequeueReusableCellWithIdentifier:guidelineNextEntryCellIdentifier];
			
			UILabel *timeLabel							= (UILabel *)[guidelineNextEntryCell viewWithTag:10];
			UILabel *guidelineLabel						= (UILabel *)[guidelineNextEntryCell viewWithTag:11];
		
		
			NSString *timeEntryTextPrefix;
			
			if (self.setsOfGuidelinesHaveBeenSelected && self.countOfTheSixWithoutUserEntries == 0) {
				timeEntryTextPrefix	= @"Excellent!";
			} else if (self.setsOfGuidelinesHaveBeenSelected && self.countOfTheSixWithoutUserEntries == 1) {
				timeEntryTextPrefix	= @"Last Entry - ";
			} else if (self.setsOfGuidelinesHaveBeenSelected && self.countOfTheSixWithoutUserEntries == 6) {
				timeEntryTextPrefix	= @"First Entry - ";
			} else if (self.setsOfGuidelinesHaveBeenSelected && self.countOfTheSixWithoutUserEntries < 6) {
				timeEntryTextPrefix	= @"Next Entry - ";
			} else if (!self.setsOfGuidelinesHaveBeenSelected) {
				timeEntryTextPrefix = @"Choose Guidelines To Follow";
			}

			guidelineNextEntryCell.selectionStyle	= UITableViewCellSelectionStyleNone;
			guidelineNextEntryCell.accessoryType	= UITableViewCellAccessoryNone;
		
			if (self.setsOfGuidelinesHaveBeenSelected && self.thereAreCoreDataRecordsForDay && self.countOfTheSixWithoutUserEntries > 0) {
				timeLabel.text							= [NSString stringWithFormat:@"%@%@", timeEntryTextPrefix, self.nextEntry.timeScheduled.time];
				guidelineLabel.text						= self.nextEntry.advice.name;
				
				guidelineNextEntryCell.selectionStyle	= UITableViewCellSelectionStyleBlue;
				guidelineNextEntryCell.accessoryType	= UITableViewCellAccessoryDisclosureIndicator;
			} else if (self.setsOfGuidelinesHaveBeenSelected && self.thereAreCoreDataRecordsForDay && self.countOfTheSixWithoutUserEntries == 0) {
				timeLabel.text							= timeEntryTextPrefix;
				guidelineLabel.text						= kCongratulationsMessage;
			} else if (!self.setsOfGuidelinesHaveBeenSelected && self.thereAreCoreDataRecordsForDay) {
				timeLabel.text							= timeEntryTextPrefix;
				guidelineLabel.text						= kSelectGuidelinesMessage;
			} else if (!self.setsOfGuidelinesHaveBeenSelected) {
				timeLabel.text							= timeEntryTextPrefix;
				guidelineLabel.text						= kIntroductoryMessage;
			} 
		
			[self resizeHeightToFitForLabel:guidelineLabel
								 labelWidth:GUIDELINE_LABEL_WIDTH];
		
			return guidelineNextEntryCell;
		
	} else if (indexPath.section == [self.tableViewSections indexOfObject:kRemainingScheduledEntries]) {
	
			if (self.showRemainingScheduledEntries && indexPath.row > 0) {
				UITableViewCell *guidelineOtherEntryCell	= [tableView dequeueReusableCellWithIdentifier:guidelineOtherEntryCellIdentifier];
				UILabel *timeLabel							= (UILabel *)[guidelineOtherEntryCell viewWithTag:10];
				UILabel *guidelineLabel						= (UILabel *)[guidelineOtherEntryCell viewWithTag:11];
				
				LESixOfDay *scheduledEntry					= [self.remainingScheduledEntries objectAtIndex:indexPath.row - 1];		// -1 to account for "heading" row

				timeLabel.text								= [NSString stringWithFormat:@"Scheduled - %@", scheduledEntry.timeScheduled.time];
				guidelineLabel.text							= scheduledEntry.advice.name;
				
				[self resizeHeightToFitForLabel:guidelineLabel labelWidth:GUIDELINE_LABEL_WIDTH];
				
				return guidelineOtherEntryCell;
			} else {
				UITableViewCell *summaryOrSetupCell			= [tableView dequeueReusableCellWithIdentifier:summaryOrSetupCellIdentifier];
				
				summaryOrSetupCell.textLabel.text			= @"Remaining Guidelines";
				summaryOrSetupCell.detailTextLabel.text		= [NSString stringWithFormat:@"%i", [self.remainingScheduledEntries count]];
				
				if (self.showRemainingScheduledEntries) {
					summaryOrSetupCell.selectionStyle		= UITableViewCellSelectionStyleNone;
					summaryOrSetupCell.accessoryType		= UITableViewCellAccessoryNone;
				} else {
					summaryOrSetupCell.selectionStyle		= UITableViewCellSelectionStyleBlue;
					summaryOrSetupCell.accessoryType		= UITableViewCellAccessoryDisclosureIndicator;
				}
				
				return summaryOrSetupCell;
			}

	}
	else if (indexPath.section == [self.tableViewSections indexOfObject:kUpdatedEntries])
	{

			if (self.showUpdatedEntries && indexPath.row > 0)
			{
				UITableViewCell *guidelineSummaryEntryCell	= [tableView dequeueReusableCellWithIdentifier:guidelineSummaryEntryCellIdentifier];
				UILabel *timeLabel							= (UILabel *)[guidelineSummaryEntryCell viewWithTag:10];
				UILabel *guidelineLabel						= (UILabel *)[guidelineSummaryEntryCell viewWithTag:11];
				UILabel *positiveIconLabel					= (UILabel *)[guidelineSummaryEntryCell viewWithTag:15];
				UILabel *negativeIconLabel					= (UILabel *)[guidelineSummaryEntryCell viewWithTag:16];
				UILabel *positiveActionLabel				= (UILabel *)[guidelineSummaryEntryCell viewWithTag:20];
				UILabel *negativeActionLabel				= (UILabel *)[guidelineSummaryEntryCell viewWithTag:21];
				
				LESixOfDay *updatedEntry					= [self.updatedEntries objectAtIndex:indexPath.row - 1];		// -1 to account for "heading" row
				
				timeLabel.text								= [NSString stringWithFormat:@"Updated %@", updatedEntry.timeLastUpdated.time];
				guidelineLabel.text							= updatedEntry.advice.name;
				positiveActionLabel.text					= [[updatedEntry.getPositiveActionsTaken anyObject] valueForKey:@"text"];
				negativeActionLabel.text					= [[updatedEntry.getNegativeActionsTaken anyObject] valueForKey:@"text"];
				
				[self resizeHeightToFitForLabel:guidelineLabel labelWidth:GUIDELINE_LABEL_WIDTH];
				
				CGFloat	guidelineLabelHeight				= [self heightForLabel:guidelineLabel withText:guidelineLabel.text labelWidth:GUIDELINE_LABEL_WIDTH];

				CGRect positiveIconLabelFrame				= positiveIconLabel.frame;
				CGRect negativeIconLabelFrame				= negativeIconLabel.frame;
				CGRect positiveActionLabelFrame				= positiveActionLabel.frame;
				CGRect negativeActionLabelFrame				= negativeActionLabel.frame;
				positiveIconLabelFrame.origin.y				= 30 + guidelineLabelHeight + 5;
				negativeIconLabelFrame.origin.y				= 30 + guidelineLabelHeight + 31;
				positiveActionLabelFrame.origin.y			= 30 + guidelineLabelHeight + 10;
				negativeActionLabelFrame.origin.y			= 30 + guidelineLabelHeight + 35;
				positiveIconLabel.frame						= positiveIconLabelFrame;
				negativeIconLabel.frame						= negativeIconLabelFrame;
				positiveActionLabel.frame					= positiveActionLabelFrame;
				negativeActionLabel.frame					= negativeActionLabelFrame;
				
				return guidelineSummaryEntryCell;
			}
			else
			{
				UITableViewCell *summaryOrSetupCell		= [tableView dequeueReusableCellWithIdentifier:summaryOrSetupCellIdentifier];
			
				summaryOrSetupCell.textLabel.text		= @"Guidelines with Entries";
				summaryOrSetupCell.detailTextLabel.text	= [NSString stringWithFormat:@"%i", [self.updatedEntries count]];
				
				if (self.showUpdatedEntries)
				{
					summaryOrSetupCell.selectionStyle	= UITableViewCellSelectionStyleNone;
					summaryOrSetupCell.accessoryType	= UITableViewCellAccessoryNone;
				}
				else
				{
					summaryOrSetupCell.selectionStyle	= UITableViewCellSelectionStyleBlue;
					summaryOrSetupCell.accessoryType	= UITableViewCellAccessoryDisclosureIndicator;
				}

				return summaryOrSetupCell;
			}
		
	}
	else if (indexPath.section == [self.tableViewSections indexOfObject:kSetupForDay])
	{
			UITableViewCell *daySetupCell;
			
			if (self.setsOfGuidelinesHaveBeenSelected && [self indexPathHasPicker:indexPath])
			{
				daySetupCell						= [tableView dequeueReusableCellWithIdentifier:datePickerCellIdentifier];
			}
			else if (self.setsOfGuidelinesHaveBeenSelected && [self indexPathHasDate:indexPath])
			{
				daySetupCell						= [tableView dequeueReusableCellWithIdentifier:dateCellIdentifier];
				daySetupCell.textLabel.text			= @"Start of Day";
				daySetupCell.detailTextLabel.text	= [NSString stringWithFormat:@"%@", [self wakeUpAtTime]];
				daySetupCell.detailTextLabel.tag	= 10001;
			}
			else
			{
				daySetupCell						= [tableView dequeueReusableCellWithIdentifier:summaryOrSetupCellIdentifier];
				daySetupCell.textLabel.text			= (self.setsOfGuidelinesHaveBeenSelected) ? @"Guidelines Being Followed" : @"Select Guidelines to Follow";
				daySetupCell.detailTextLabel.text	= (self.setsOfGuidelinesHaveBeenSelected) ? [NSString stringWithFormat:@"%i", [self.allAdviceFollowedByUser count]] : @"";
			}
			return daySetupCell;
			
	}
	else	// Previous Days
	{

			UITableViewCell *summaryOrSetupCell		= [tableView dequeueReusableCellWithIdentifier:summaryOrSetupCellIdentifier];
			
			summaryOrSetupCell.textLabel.text		= @"Previous Days";
			summaryOrSetupCell.detailTextLabel.text	= @"";
			summaryOrSetupCell.selectionStyle		= UITableViewCellSelectionStyleBlue;
			summaryOrSetupCell.accessoryType		= UITableViewCellAccessoryDisclosureIndicator;
			return summaryOrSetupCell;

	}
	return nil;
}

		//	NEW

- (NSString *)wakeUpAtTime
{
	NSInteger countOfEntriesCompleted	= [[self.thisDay getTheSixThatHaveUserEntriesSorted] count];
	NSDate *wakeUpAt					= [self.nextEntry.timeScheduled dateByAddingTimeInterval:-2*(1+countOfEntriesCompleted)*60*60];
	return wakeUpAt.time;
}


/*		PROCESSED
		- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
		{
			UITableViewCell *cell = nil;
			
			NSString *cellID = kOtherCell;
			
			if ([self indexPathHasPicker:indexPath])
			{
				// the indexPath is the one containing the inline date picker
				cellID = kDatePickerID;     // the current/opened date picker cell
			}
			else if ([self indexPathHasDate:indexPath])
			{
				// the indexPath is one that contains the date information
				cellID = kDateCellID;       // the start/end date cells
			}
			
			cell = [tableView dequeueReusableCellWithIdentifier:cellID];
			
//			if (indexPath.row == 0)
//			{
//				// we decide here that first cell in the table is not selectable (it's just an indicator)
//				cell.selectionStyle = UITableViewCellSelectionStyleNone;
//			}
			
//			// if we have a date picker open whose cell is above the cell we want to update,
//			// then we have one more cell than the model allows
//			//
//			NSInteger modelRow = indexPath.row;
//			if (self.datePickerIndexPath != nil && self.datePickerIndexPath.row < indexPath.row)
//			{
//				modelRow--;
//			}
			
//			NSDictionary *itemData = self.dataArray[modelRow];
			
			// proceed to configure our cell
			if ([cellID isEqualToString:kDateCellID])
			{
				// we have either start or end date cells, populate their date field
				//
				cell.textLabel.text = [itemData valueForKey:kTitleKey];
				cell.detailTextLabel.text = [self.dateFormatter stringFromDate:[itemData valueForKey:kDateKey]];
			}
			else if ([cellID isEqualToString:kOtherCell])
			{
				// this cell is a non-date cell, just assign it's text label
				//
				cell.textLabel.text = [itemData valueForKey:kTitleKey];
			}
			
			return cell;
		}
*/
/*! Adds or removes a UIDatePicker cell below the given indexPath.
 
 @param indexPath The indexPath to reveal the UIDatePicker.
 */
- (void)toggleDatePickerForSelectedIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:[self.tableViewSections indexOfObject:kSetupForDay]]];
	
    // check if 'indexPath' has an attached date picker below it
    if ([self hasPickerForIndexPath:indexPath])
    {
        // found a picker below it, so remove it
        [self.tableView deleteRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        // didn't find a picker below it, so we should insert it
        [self.tableView insertRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.tableView endUpdates];
}

/*! Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath".
 
 @param indexPath The indexPath to reveal the UIDatePicker.
 */
- (void)displayInlineDatePickerForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // display the date picker inline with the table content
    [self.tableView beginUpdates];
    
    BOOL before = NO;   // indicates if the date picker is below "indexPath", help us determine which row to reveal
    if ([self hasInlineDatePicker])
    {
        before = self.datePickerIndexPath.row < indexPath.row;
    }
    
    BOOL sameCellClicked = (self.datePickerIndexPath.row - 1 == indexPath.row);
    
    // remove any date picker cell if it exists
    if ([self hasInlineDatePicker])
    {
        [self doneAction:Nil];
		[self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row
																	inSection:[self.tableViewSections indexOfObject:kSetupForDay]]]
                              withRowAnimation:UITableViewRowAnimationFade];
        self.datePickerIndexPath = nil;
    }
    
    if (!sameCellClicked)
    {
        // hide the old date picker and display the new one
        NSInteger rowToReveal = (before ? indexPath.row - 1 : indexPath.row);
        NSIndexPath *indexPathToReveal = [NSIndexPath indexPathForRow:rowToReveal
															inSection:[self.tableViewSections indexOfObject:kSetupForDay]];
        
        [self toggleDatePickerForSelectedIndexPath:indexPathToReveal];
        self.datePickerIndexPath = [NSIndexPath indexPathForRow:indexPathToReveal.row + 1
													  inSection:[self.tableViewSections indexOfObject:kSetupForDay]];
    }
    
    // always deselect the row containing the start or end date
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.tableView endUpdates];
    
    // inform our date picker of the current date to match the current cell
    [self updateDatePicker];
}

/*! Reveals the UIDatePicker as an external slide-in view, iOS 6.1.x and earlier, called by "didSelectRowAtIndexPath".
 
 @param indexPath The indexPath used to display the UIDatePicker.

- (void)displayExternalDatePickerForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // first update the date picker's date value according to our model
    NSDictionary *itemData = self.dataArray[indexPath.row];
    [self.pickerView setDate:[itemData valueForKey:kDateKey] animated:YES];
    
    // the date picker might already be showing, so don't add it to our view
    if (self.pickerView.superview == nil)
    {
        CGRect startFrame = self.pickerView.frame;
        CGRect endFrame = self.pickerView.frame;
        
        // the start position is below the bottom of the visible frame
        startFrame.origin.y = self.view.frame.size.height;
        
        // the end position is slid up by the height of the view
        endFrame.origin.y = startFrame.origin.y - endFrame.size.height;
        
        self.pickerView.frame = startFrame;
        
        [self.view addSubview:self.pickerView];
        
        // animate the date picker into view
        [UIView animateWithDuration:kPickerAnimationDuration animations: ^{ self.pickerView.frame = endFrame; }
                         completion:^(BOOL finished) {
                             // add the "Done" button to the nav bar
                             self.navigationItem.rightBarButtonItem = self.doneButton;
                         }];
    }
}
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == [self.tableViewSections indexOfObject:kNextEntry]) {
	
			if ([self.allAdviceFollowedByUser count] == 0) {
				[self performSegueWithIdentifier:@"Guidelines Followed" sender:self];
			} else if (self.countOfTheSixWithoutUserEntries > 0) {
				[self performSegueWithIdentifier:@"Guideline Entry" sender:self];
			}
			
	} else if (indexPath.section == [self.tableViewSections indexOfObject:kRemainingScheduledEntries]) {
		
			if ([self.remainingScheduledEntries count] > 0) {
				if (indexPath.row > 0) {
					[self performSegueWithIdentifier:@"Guideline Entry" sender:self];
				} else {
					self.showRemainingScheduledEntries	= (self.showRemainingScheduledEntries) ? NO : YES;		// toggle to other state
					[tableView reloadSections:[NSIndexSet indexSetWithIndex:[self.tableViewSections indexOfObject:@"Remaining Scheduled Entries"]]
							 withRowAnimation:YES];
				}
			}
		
	}
	else if (indexPath.section == [self.tableViewSections indexOfObject:kUpdatedEntries])
	{
			if ([self.updatedEntries count] > 0)
			{
				if (indexPath.row > 0)
				{
					[self performSegueWithIdentifier:@"Guideline Entry" sender:self];					
				}
				else if (indexPath.row < 6)
				{
					self.showUpdatedEntries = (self.showUpdatedEntries) ? NO : YES;
					[tableView reloadSections:[NSIndexSet indexSetWithIndex:[self.tableViewSections indexOfObject:@"Updated Entries"]]
							 withRowAnimation:YES];
				}
			}
	}
	else if (indexPath.section == [self.tableViewSections indexOfObject:kSetupForDay])
	{
			if (indexPath.row == 0 && self.setsOfGuidelinesHaveBeenSelected)
			{
				NSLog(@"Going to trigger -showDatePicker");
				//	[self showDatePicker];
				[self displayInlineDatePickerForRowAtIndexPath:indexPath];
			}
			else
			{
				[self performSegueWithIdentifier:@"Guidelines Followed" sender:self];
			}
	}
	else
	{
			[self performSegueWithIdentifier:@"Previous Days" sender:self];
	}
}
		//	NEW
		//	Processed
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
		{
			UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
			if (cell.reuseIdentifier == kDateCellID)
			{
				if (EMBEDDED_DATE_PICKER)
				else
					[self displayExternalDatePickerForRowAtIndexPath:indexPath];
			}
			else
			{
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
			}
		}
*/

#pragma mark - Managing the Start of the Day
/*! Determines if the given indexPath has a cell below it with a UIDatePicker.
 
 @param indexPath The indexPath to check if its cell has a UIDatePicker below it.
 */
- (BOOL)hasPickerForIndexPath:(NSIndexPath *)indexPath
{
    BOOL hasDatePicker = NO;
    
    NSInteger targetedRow = indexPath.row;
    targetedRow++;
    
    UITableViewCell *checkDatePickerCell =
	[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:targetedRow inSection:0]];
    UIDatePicker *checkDatePicker = (UIDatePicker *)[checkDatePickerCell viewWithTag:kDatePickerTag];
    
    hasDatePicker = (checkDatePicker != nil);
    return hasDatePicker;
}

/*! Updates the UIDatePicker's value to match with the date of the cell above it.
 */
- (void)updateDatePicker
{
    if (self.datePickerIndexPath != nil)
    {
        UITableViewCell *associatedDatePickerCell = [self.tableView cellForRowAtIndexPath:self.datePickerIndexPath];
        
        UIDatePicker *targetedDatePicker = (UIDatePicker *)[associatedDatePickerCell viewWithTag:kDatePickerTag];
        if (targetedDatePicker != nil)
        {
            // we found a UIDatePicker in this cell, so update its date value
			[targetedDatePicker	setDate:[self.dateFormatter dateFromString:[self wakeUpAtTime]]];
        }
    }
}

- (NSDate *)dateFromDatePicker
{
	if (self.datePickerIndexPath != nil)
    {
        UITableViewCell *associatedDatePickerCell = [self.tableView cellForRowAtIndexPath:self.datePickerIndexPath];
        
        UIDatePicker *targetedDatePicker = (UIDatePicker *)[associatedDatePickerCell viewWithTag:kDatePickerTag];

        if (targetedDatePicker != nil)
			return targetedDatePicker.date;
    }
	return nil;
}

/*! Determines if the UITableViewController has a UIDatePicker in any of its cells.
 */
- (BOOL)hasInlineDatePicker
{
    return (self.datePickerIndexPath != nil);
}

/*! Determines if the given indexPath points to a cell that contains the UIDatePicker.
 
 @param indexPath The indexPath to check if it represents a cell with the UIDatePicker.
 */
- (BOOL)indexPathHasPicker:(NSIndexPath *)indexPath
{
    return ([self hasInlineDatePicker] && self.datePickerIndexPath.row == indexPath.row);
}

/*! Determines if the given indexPath points to a cell that contains the start/end dates.
 
 @param indexPath The indexPath to check if it represents start/end date cell.
 */
- (BOOL)indexPathHasDate:(NSIndexPath *)indexPath
{
    BOOL hasDate = NO;
    
    if ((indexPath.row == kDateStartRow) || ([self hasInlineDatePicker]  && (indexPath.row == kDateStartRow + 1)))
    {
        hasDate = YES;
    }
    
    return hasDate;
}
#pragma mark - Actions

/*! User chose to change the date by changing the values inside the UIDatePicker.
 
 @param sender The sender for this action: UIDatePicker.
 */
- (IBAction)dateAction:(id)sender
{
    NSIndexPath *targetedCellIndexPath = nil;
    
    if ([self hasInlineDatePicker])
    {
        // inline date picker: update the cell's date "above" the date picker cell
        //
        targetedCellIndexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:0];
    }
    else
    {
        // external date picker: update the current "selected" cell's date
        targetedCellIndexPath = [self.tableView indexPathForSelectedRow];
    }
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:targetedCellIndexPath];
    UIDatePicker *targetedDatePicker = sender;
    
    // update our data model
    NSMutableDictionary *itemData = self.dataArray[targetedCellIndexPath.row];
    [itemData setValue:targetedDatePicker.date forKey:kDateKey];
    
    // update the cell's date string
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:targetedDatePicker.date];
}



-(void)showDatePicker
{
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

//-(void)cancelAllRemainingNotifications
//{
//	UIApplication *STPapp				= [UIApplication sharedApplication];
//	STPapp.applicationIconBadgeNumber	= 0;
//	[STPapp cancelAllLocalNotifications];
//}

- (IBAction)doneAction:(id)sender
{
	NSDate *updatedWakeUpTime			= [self dateFromDatePicker];
	self.thisDay.startHour				= [NSNumber numberWithInteger:[updatedWakeUpTime hour]];	//[NSNumber numberWithInt:[self.pickerView.date hour]];
	self.thisDay.startMinute			= [NSNumber numberWithInteger:[updatedWakeUpTime minute]]; // [NSNumber numberWithInt:[self.pickerView.date minute]];
	[self.notificationController cancelAllNotifications];
	
	// Reset scheduled times for log entries
	NSArray *allRemainingEntries		= [self.thisDay getTheSixWithoutUserEntriesSorted];
	NSInteger countOfCompletedEntries	= [[self.thisDay getTheSixThatHaveUserEntriesSorted] count];
	NSInteger badgeNumber				= 0;
	
	for (LESixOfDay *remainingEntry in allRemainingEntries) {
		[remainingEntry resetScheduledTimeAtHourInterval:countOfCompletedEntries + [allRemainingEntries indexOfObject:remainingEntry] + 1
											   startHour:[self.thisDay.startHour intValue]
											 startMinute:[self.thisDay.startMinute intValue]];
		
		[self.notificationController addNotification:remainingEntry withApplicationIconBadgeNumber:++badgeNumber];
	}

	// save to store!
	NSError *error;
	if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 */
		NSLog(@"Error occured when attempting to save. Error and userInfo: %@, %@", error, [error userInfo]);
	}

	UILabel *wakeUpTimeTextLabel	= (UILabel *)[self.tableView viewWithTag:10001];
	wakeUpTimeTextLabel.text		= [updatedWakeUpTime time]; //  [self.dateFormatter stringFromDate:self.pickerView.date];
	
	[TestFlight passCheckpoint:@"RESET WAKEUP TIME"];
/*
	CGRect screenRect				= [[UIScreen mainScreen] applicationFrame];
	CGRect endFrame					= self.pickerView.frame;
	endFrame.origin.y				= screenRect.origin.y + screenRect.size.height;
	
	// start the slide down animation
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	// we need to perform some post operations after the animation is complete
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
	
	self.pickerView.frame			= endFrame;
	[UIView commitAnimations];
	
	// grow the table back again in vertical size to make room for the date picker
	CGRect newFrame					= self.tableView.frame;
	newFrame.size.height			+= self.pickerView.frame.size.height;
	self.tableView.frame			= newFrame;
	
	// remove the "Done" button in the nav bar
	self.navigationItem.rightBarButtonItem = nil;
	
	// deselect the current table row
	NSIndexPath *indexPath			= [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self.tableView reloadData];
 */
}


#pragma mark - Managing Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
			
	if ([[segue identifier] isEqualToString:@"Guideline Entry"]) {
		
		STLogEntrySixOfDayTVC *leSixOfDayTVC	= segue.destinationViewController;
		leSixOfDayTVC.managedObjectContext		= self.managedObjectContext;
		NSIndexPath *indexPath  = [self.tableView indexPathForSelectedRow];
		
		if ([sender isMemberOfClass:[STAppDelegate class]]) {
			leSixOfDayTVC.leSixOfDay			= self.entryFromNotification;
		} else {
		
			if (indexPath.section == [self.tableViewSections indexOfObject:@"Next Entry"]) {
				leSixOfDayTVC.leSixOfDay						= self.nextEntry;
				[TestFlight passCheckpoint:@"GO TO NEXT ENTRY"];
			} else if (indexPath.section == [self.tableViewSections indexOfObject:@"Remaining Scheduled Entries"]) {
				leSixOfDayTVC.leSixOfDay						= [self.remainingScheduledEntries objectAtIndex:indexPath.row - 1];
				leSixOfDayTVC.isRemainingScheduledEntry	= YES;
				[TestFlight passCheckpoint:@"GO TO FUTURE ENTRY"];
			} else if (indexPath.section == [self.tableViewSections indexOfObject:@"Updated Entries"]) {
				leSixOfDayTVC.leSixOfDay						= [self.updatedEntries objectAtIndex:indexPath.row - 1];
				[TestFlight passCheckpoint:@"GO TO PREVIOUS ENTRY"];
			}
			
		}
		
	} else if ([[segue identifier] isEqualToString:@"Guidelines Followed"]) {
		
		STSetsOfAdviceTVC *tradtionsTVC			= segue.destinationViewController;
		tradtionsTVC.managedObjectContext		= self.managedObjectContext;
		tradtionsTVC.currentDay					= self.thisDay;
		[TestFlight passCheckpoint:@"GO TO GUIDELINES"];
		
	} else if ([[segue identifier] isEqualToString:@"Previous Days"]) {
		
		STPreviousDaysTVC *previousDaysTVC		= segue.destinationViewController;
		previousDaysTVC.managedObjectContext	= self.managedObjectContext;
		[TestFlight passCheckpoint:@"GO TO PREVIOUS DAYS"];
		
	} 
	self.title		= self.mostRecentlyAddedDate.shortWeekdayAndDate;

}

- (IBAction)greatHighwayExplorerFeedback:(id)sender {
	[TestFlight openFeedbackView];
}

/*
#pragma mark - Managing Notifications

- (void)addNotification:(LESixOfDay *)sixOfDayLogEntry {
	NSDictionary *userInfo	= @{
		@"logEntryTimeScheduled"				: sixOfDayLogEntry.timeScheduled.timeAndDate,
		@"logEntryAdviceText"					: sixOfDayLogEntry.advice.name,
		@"logEntryOrderNumberInSetOfEntries"	: sixOfDayLogEntry.orderNumberForType
	};
		
    UILocalNotification *localNotification = [[UILocalNotification alloc] init]; //Create the localNotification object
    
	localNotification.fireDate						= sixOfDayLogEntry.timeScheduled; //Set the date when the alert will be launched using the date adding the time the user selected on the timer
    localNotification.alertAction					= @"OK";							//The button's text that launches the application and is shown in the alert
	localNotification.alertBody						= sixOfDayLogEntry.advice.name;		//Set the message in the notification from the textField's text
    localNotification.hasAction						= YES;								//Set that pushing the button will launch the application
    localNotification.applicationIconBadgeNumber	= 1; //Set the Application Icon Badge Number of the application's icon to the current Application Icon Badge Number plus 1
	localNotification.soundName						= UILocalNotificationDefaultSoundName;
	localNotification.userInfo						= userInfo;
	
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification]; //Schedule the notification with the system
																					 //    [alertNotification setHidden:NO]; //Set the alertNotification to be shown showing the user that the application has registered the local notification
}

*/


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
