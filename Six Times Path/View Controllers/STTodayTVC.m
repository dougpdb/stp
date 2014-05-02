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
#import "STSettingsTVC.h"
#import "NSUserDefaults+ST.h"
#import "STNotificationController.h"
#import "Advice.h"
#import "Day+ST.h"
#import "LESixOfDay+ST.h"
#import "NSDate+ST.h"
#import "NSDate+ES.h"
#import "UIFont+ST.h"
#import "TestFlight.h"

#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define GUIDELINE_LABEL_WIDTH 272

//	http://developer.apple.com/library/ios/samplecode/DateCell/Listings/MyTableViewController_m.html#//apple_ref/doc/uid/DTS40008866-MyTableViewController_m-DontLinkElementID_6

#define kPickerAnimationDuration    0.40   // duration for the animation to slide the date picker into view
#define kDatePickerTag              99     // view tag identifiying the date picker view

#define kDateKey        @"date"    // key for obtaining the data source item's date value

// keep track of which rows have date cells
#define kDateStartRow   0

static NSString *kDateCellID = @"dateCell";     // the cells with the start or end date
static NSString *kDatePickerID = @"datePickerCell"; // the cell containing the date picker
static NSString *kOtherCell = @"otherCell";     // the remaining cells at the end

static NSString *kFontNameGuideline			= @"Palatino";




static NSString *kNextEntry = @"Next Entry";
static NSString *kWelcomeIntroduction = @"Welcome Introduction";
static NSString *kNoSetsOfGuidelinesSelected = @"No Sets of Guidelines Selected";
static NSString *kAllOtherEntries = @"All Other Entries";
static NSString *kSetupForDay = @"Setup for Day";
static NSString *kPreviousDays = @"Previous Days";
static NSString *kAboutAndSettings = @"About and Settings";


@interface STTodayTVC ()

@property (nonatomic) NSUserDefaults *sixTimesUserDefaults;


@property (nonatomic, retain) IBOutlet UIDatePicker *pickerView;

@property (nonatomic, weak) NSArray *dataArray;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

// keep track which indexPath points to the cell with UIDatePicker
@property (nonatomic, strong) NSIndexPath *datePickerIndexPath;
@property (assign) NSInteger pickerCellRowHeight;

@property (nonatomic, strong) STNotificationController *notificationController;

@property BOOL shouldShowWelcomeMessage;

@property (readonly) CGFloat screenWidth;
@property (readonly) CGFloat guidelineLabelWidth;
@property (readonly) CGFloat actionTextViewWidth;

@property BOOL isMemberOfSTTodayTVC;

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
	if (self.shouldShowWelcomeMessage) {
		_countOfTheSixWithoutUserEntries	= 0;
	} else if (_countOfTheSixWithoutUserEntries == -1) {
		NSLog(@"The nextEntry is %@", [self.nextEntry description]);
		_countOfTheSixWithoutUserEntries	= [self.remainingScheduledEntries count];
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
																		   kAllOtherEntries,
																		   kSetupForDay,
																		   kPreviousDays,
																		   kAboutAndSettings,
																			nil];

		[self resetCountOfTheSixWithoutUserEntries];

		if (self.databaseWasJustCreatedForFirstTime && !self.setsOfGuidelinesHaveBeenSelected) {
			
			[tmpSectionArray removeObjectIdenticalTo:kNextEntry];
			[tmpSectionArray removeObjectIdenticalTo:kNoSetsOfGuidelinesSelected];
			[tmpSectionArray removeObjectIdenticalTo:kAllOtherEntries];
			[tmpSectionArray removeObjectIdenticalTo:kPreviousDays];
			
		} else if (!self.setsOfGuidelinesHaveBeenSelected) {
			
			[tmpSectionArray removeObjectIdenticalTo:kNextEntry];
			[tmpSectionArray removeObjectIdenticalTo:kWelcomeIntroduction];
			[tmpSectionArray removeObjectIdenticalTo:kAllOtherEntries];
			
		} else if ([self.allAdviceFollowedByUser count] == 0) {
			
			[tmpSectionArray removeObjectIdenticalTo:kWelcomeIntroduction];
			[tmpSectionArray removeObjectIdenticalTo:kNoSetsOfGuidelinesSelected];
			[tmpSectionArray removeObjectIdenticalTo:kAllOtherEntries];
			
		} else if (self.countOfTheSixWithoutUserEntries <= 1) {
			
			[tmpSectionArray removeObjectIdenticalTo:kWelcomeIntroduction];
			[tmpSectionArray removeObjectIdenticalTo:kNoSetsOfGuidelinesSelected];
			
		} else if (self.countOfTheSixWithoutUserEntries == 6) {
			
			[tmpSectionArray removeObjectIdenticalTo:kWelcomeIntroduction];
			[tmpSectionArray removeObjectIdenticalTo:kNoSetsOfGuidelinesSelected];
			
		} else {
			
			[tmpSectionArray removeObjectIdenticalTo:kWelcomeIntroduction];
			[tmpSectionArray removeObjectIdenticalTo:kNoSetsOfGuidelinesSelected];
			
		}
		
		if (!self.isMemberOfSTTodayTVC) {
			
			[tmpSectionArray removeObjectIdenticalTo:kAboutAndSettings];
			
		}

		_tableViewSections	= tmpSectionArray;
		
	}
	
	return _tableViewSections;
}

-(void)resetTableViewSections
{
	_tableViewSections = nil;
}

-(CGFloat)screenWidth
{
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	if (
		([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortrait) ||
		([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown)
		){
		return screenRect.size.width;
	} else {
		return screenRect.size.height;
	}
}

-(CGFloat)guidelineLabelWidth
{
	return self.screenWidth - 30.0; //15.0 - 13.0 - 4.0 - 15.0;
}

-(CGFloat)actionTextViewWidth
{
	//	return self.screenWidth - 30.0; //15.0 - 15.0;
	return self.screenWidth - 47.0; //15.0 - 13.0 - 4.0 - 15.0;
}




#pragma mark - View Loading and Appearing

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.debug					= YES;
	
	self.isMemberOfSTTodayTVC = [self isMemberOfClass:[STTodayTVC class]];
	
	self.sixTimesUserDefaults = [NSUserDefaults standardUserDefaults];
	
	self.notificationController	= [[STNotificationController alloc] init];
	
	self.dateFormatter			= [[NSDateFormatter alloc] init];
	[self.dateFormatter setDateFormat:@"h:mm a"];
	// obtain the picker view cell's height, works because the cell was pre-defined in our storyboard
    UITableViewCell *pickerViewCellToCheck = [self.tableView dequeueReusableCellWithIdentifier:kDatePickerID];
    self.pickerCellRowHeight = pickerViewCellToCheck.frame.size.height;

	if (self.databaseWasJustCreatedForFirstTime) {
		self.setsOfGuidelinesHaveBeenSelected = NO;
		self.shouldShowWelcomeMessage = YES;
		NSLog(@"first day of use.");
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(preferredContentSizeChanged:)
												 name:UIContentSizeCategoryDidChangeNotification
											   object:nil];

}

- (void)preferredContentSizeChanged:(NSNotification *)aNotification {
    [self.tableView reloadData];
	
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
	self.thisDay					= nil;
	self.nextEntry					= nil;
	self.entryFromNotification		= nil;
	self.remainingScheduledEntries	= nil;
	self.updatedEntries				= nil;
	self.mostRecentlyAddedDate		= nil;
	self.allAdviceFollowedByUser	= nil;
	self.tableViewSections			= nil;
	
	self.dataArray					= nil;
	self.dateFormatter				= nil;
	self.pickerView					= nil;
	self.fetchedResultsController	= nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewWillAppear:(BOOL)animated
{	
	[self.sixTimesUserDefaults showLogOfAllSettings];
	[self setupDayAndAdviceData];
	
	if (self.databaseWasJustCreatedForFirstTime) {
	
		self.title = @"Six Times";
	
	} else {
		
		self.title = self.mostRecentlyAddedDate.weekdayMonthAndDay;

	}
	
	[self resetTableViewSections];
	[self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
	self.showAllEntries	= NO;
}



#pragma mark - Set Data for the Table View Controller
//-(void)setup
//{
//	
//}
//
//-(void)setupSecond

-(BOOL)isAllAdviceForDayUpdated
{
	return ([[self.thisDay getTheSixThatHaveUserEntriesSorted] count] == 6);
}

-(void)setupDayAndAdviceData
{
	if (self.databaseWasJustCreatedForFirstTime) {
		
		self.setsOfGuidelinesHaveBeenSelected	= NO;
		
	} else {
		
		[self setupAdviceFetchedResultsController];
		self.allAdviceFollowedByUser = [NSMutableArray arrayWithArray:self.fetchedResultsController.fetchedObjects];
		self.setsOfGuidelinesHaveBeenSelected = ([self.allAdviceFollowedByUser count] > 0) ? YES : NO;
		self.dayHasGuidelines = ([[self.thisDay getTheSixSorted] count] > 0) ? YES : NO;
		
	}
	
	if (self.thereAreCoreDataRecordsForDay) {
		
		[self setupDaysFetchedResultsController];
		Day *mostRecentDay = [self.fetchedResultsController.fetchedObjects objectAtIndex:0];
		self.mostRecentlyAddedDate = mostRecentDay.date;
		self.thisDay = mostRecentDay;
		[self addDay];

		LESixOfDay *lastTheSixOfMostRecentDay;
		if ([self.sixTimesUserDefaults isStaggerDailyGuidelinesOn]) {
		
			lastTheSixOfMostRecentDay = [[mostRecentDay getTheSixSorted] firstObject];
		
		} else {
		
			lastTheSixOfMostRecentDay = [[mostRecentDay getTheSixSorted] lastObject];
		
		}

		self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay = [self.allAdviceFollowedByUser indexOfObject:lastTheSixOfMostRecentDay.advice] + 1;
				
		if (self.setsOfGuidelinesHaveBeenSelected && !self.dayHasGuidelines) {
			// This should be the typical use case -- where the user had already selected a set of guidelines
			// and has also set up at least one day of entries in Six Times
			
			[self addGuidelinesToThisDay];
			
		}
		
		[self setUpdatedAndRemainingScheduledEntries];
				
	} else if (self.setsOfGuidelinesHaveBeenSelected) {
		
		// The rare edge case for when the user is has started to used the app after installing it, but it will happen at least once -- the user has
		// selected a set of guidelines but a day of entries has not yet been set up. This will occur after going through the following use case.
		self.mostRecentlyAddedDate					= [NSDate dateYesterday];
		self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay = 0;
		self.thisDay								= nil;
		
		[self addDay];
		[self addGuidelinesToThisDay];
		[self setUpdatedAndRemainingScheduledEntries];

	} else {
		
		// This is the use case of when a user 1st runs Six Times app after it has been installed. The user hasn't selected any sets of guidelines
		// and a day of entries has not yet been set up. This use case will definitely run once, but if the user opens the app reads the welcome
		// message and closes it, then this use case would run again.l
		
	}
}


-(void)setUpdatedAndRemainingScheduledEntries
{
	NSArray *allRemainingEntries = [self.thisDay getTheSixWithoutUserEntriesSorted];
	
	NSRange rangeRemainingScheduledEntries;
	rangeRemainingScheduledEntries.location = 1;
	rangeRemainingScheduledEntries.length = ([self isAllAdviceForDayUpdated]) ? 0 : [allRemainingEntries count] - 1;
	
	if ([allRemainingEntries count] > 0) {
	
		self.nextEntry = [allRemainingEntries objectAtIndex:0];
	
	}
	
	self.remainingScheduledEntries = (![self isMemberOfSTTodayTVC] || [self isAllAdviceForDayUpdated]) ? allRemainingEntries : [allRemainingEntries subarrayWithRange:rangeRemainingScheduledEntries];
	
	self.updatedEntries = [self.thisDay getTheSixThatHaveUserEntriesSorted];
	
	self.showAllEntries = (![self isMemberOfSTTodayTVC]);
	[self resetCountOfTheSixWithoutUserEntries];

}

#pragma mark - Core Data 

#pragma mark Setup

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


#pragma mark Add Records

-(BOOL)isTimeToAddDay
{
		NSDate *now						= [NSDate date];
		NSDate *mostRecentDate			= [self.mostRecentlyAddedDate setHour:[self.thisDay.startHour intValue]
															 andMinute:[self.thisDay.startMinute intValue]];
		
		NSTimeInterval eighteenHours	= 18*60*60;
		
	if (self.mostRecentlyAddedDate) {
		
		return ([now compare:[mostRecentDate dateByAddingTimeInterval:eighteenHours]] == NSOrderedDescending);
		
	} else {
		
		return NO;
		
	}
}

-(void)addDay
{
	if ([self isTimeToAddDay]) {
		
		[self.notificationController cancelAllNotifications];
		
		Day *newDay = [NSEntityDescription insertNewObjectForEntityForName:@"Day"
													inManagedObjectContext:self.managedObjectContext];

		NSDate *now						= [NSDate date];
		
		NSDate *mostRecentDate			= [self.mostRecentlyAddedDate setHour:[self.thisDay.startHour intValue]
															 andMinute:[self.thisDay.startMinute intValue]];
		NSTimeInterval twentyFourHours	= 24*60*60;
		
		BOOL nowIsOnSameDateAsMostRecentDateButAfterEntryLogging = ([now compare:[mostRecentDate dateByAddingTimeInterval:twentyFourHours]] == NSOrderedAscending);
		
		newDay.date = (nowIsOnSameDateAsMostRecentDateButAfterEntryLogging) ? [mostRecentDate dateByAddingTimeInterval:twentyFourHours] : now;
		
		newDay.startHour = (self.thisDay.startHour) ? self.thisDay.startHour : [NSNumber numberWithInt:6];
		newDay.startMinute = (self.thisDay.startMinute) ? self.thisDay.startMinute : [NSNumber numberWithInt:0];
		
		self.mostRecentlyAddedDate = newDay.date;
		self.thisDay = newDay;
		
		[self setSuspendAutomaticTrackingOfChangesInManagedObjectContext:YES];
		[self saveContext];
		[self performFetch];
		[self setSuspendAutomaticTrackingOfChangesInManagedObjectContext:NO];
		
		self.title = self.mostRecentlyAddedDate.weekdayMonthAndDay;
		self.highlightStartOfDayLabelWithColor	= YES;

		[TestFlight passCheckpoint:[NSString stringWithFormat:@"ADD DAY %lu", (unsigned long)[self.fetchedResultsController.fetchedObjects count]]];
		
	} else {
		
		self.highlightStartOfDayLabelWithColor	= NO;
		
	}
}

-(void)addGuidelinesToThisDay
{
	NSInteger indexOfFirstFollowedAdvice = self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay;
	[self setTheSixForDay:self.thisDay withIndexOfFirstFollowedAdvice:indexOfFirstFollowedAdvice inManagedObjectContext:self.managedObjectContext];
	
	[self setSuspendAutomaticTrackingOfChangesInManagedObjectContext:YES];
	[self saveContext];
	[self performFetch];
	[self setSuspendAutomaticTrackingOfChangesInManagedObjectContext:NO];
	
	[self resetTableViewSections];
	[self.tableView reloadData];
	
}

-(void)setTheSixForDay:(Day *)day withIndexOfFirstFollowedAdvice:(NSInteger)indexOfFirstFollowedAdvice inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	NSInteger indexOfFollowedAdviceForTheDay = 0;
	NSInteger indexIntervalOfAdvice = 0;
	
	if (indexOfFirstFollowedAdvice >= [self.allAdviceFollowedByUser count]) {
		
		indexOfFirstFollowedAdvice = 0;
		
	}
	
	// set values for indexIntervalOfAdvice and indexOfFollowedAdviceForTheDay
	if ([self.sixTimesUserDefaults isStaggerDailyGuidelinesOn]) {

		NSUInteger maximumOrdinalNumberOfFirstIndex = 0;
		NSUInteger maximumIndexOfFirstIndex = 0;
		NSUInteger countOfAdviceEntriesAlreadyAdded = [[self.thisDay getTheSixSorted] count];
		NSString *debugText;

		indexIntervalOfAdvice = [self.allAdviceFollowedByUser count] / 6;
		
		maximumOrdinalNumberOfFirstIndex = indexIntervalOfAdvice + [self.allAdviceFollowedByUser count] % 6;
		maximumIndexOfFirstIndex = (maximumOrdinalNumberOfFirstIndex - 1);
		if (countOfAdviceEntriesAlreadyAdded > 0) {
		
			maximumIndexOfFirstIndex *= countOfAdviceEntriesAlreadyAdded;
			
		}
		
		if (indexOfFirstFollowedAdvice <= maximumIndexOfFirstIndex) {
			
			debugText = @"the index of the first followed advice is less than or equal to the maximum index of the first advice";
			indexOfFollowedAdviceForTheDay = indexOfFirstFollowedAdvice;
			
		} else {

			NSUInteger numberOfThePrecedingEntry;
			NSUInteger ordinalNumberOfFirstIndex;
			
			numberOfThePrecedingEntry = indexOfFirstFollowedAdvice / indexIntervalOfAdvice;
			ordinalNumberOfFirstIndex = numberOfThePrecedingEntry % indexIntervalOfAdvice;
			indexOfFollowedAdviceForTheDay = ordinalNumberOfFirstIndex - 1;
			
		}
		
	} else {
		
		indexIntervalOfAdvice = 1;
		indexOfFollowedAdviceForTheDay = indexOfFirstFollowedAdvice;
		
	}
    
    // Starting with the first advice to be followed for the day, cycle through the advice that has been
	// selected to be followed and add up to 6 advices to LogEntries that will be added to a day.
	// Almost always,
    for (NSUInteger allAdviceFollowedByUserIncrement=[[self.thisDay getTheSixSorted] count]; allAdviceFollowedByUserIncrement<6; allAdviceFollowedByUserIncrement++) {

		Advice *advice = [self.allAdviceFollowedByUser objectAtIndex:indexOfFollowedAdviceForTheDay];
		
		// orderNumber range will be 1-6
		NSInteger orderNumber = allAdviceFollowedByUserIncrement+1;
		
		LESixOfDay *logEntry = [LESixOfDay logEntryWithAdvice:advice
											  withOrderNumber:orderNumber
														onDay:day
									   inManagedObjectContext:managedObjectContext];
		
		[day addTheSixObject:logEntry];
		
		self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay = indexOfFollowedAdviceForTheDay;

		if (self.debug) {
			NSLog(@"indexOfFollowedAdviceForTheDay: %lu", (unsigned long)indexOfFollowedAdviceForTheDay);
			[logEntry logValuesOfLogEntry];
		}

		indexOfFollowedAdviceForTheDay += indexIntervalOfAdvice;
        
		if (indexOfFollowedAdviceForTheDay==[self.allAdviceFollowedByUser count] - 1)
        {
            // reset to the beginning
            indexOfFollowedAdviceForTheDay = -1;
			
			if (self.debug)
				NSLog(@"indexOfFollowedAdviceForTheDay has been reset. Value is now: %li", (long)indexOfFirstFollowedAdvice);
        }
        
	}
	
	self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay++;
	
	[self.notificationController addNotifications:[day getTheSixSorted]];
}

#pragma mark Remove Records

-(void)removeEntries:(NSArray *)arrayOfEntries fromDay:(Day *)day
{
	for (LESixOfDay *remainingEntry in arrayOfEntries) {
		
		[day removeTheSixObject:remainingEntry];
		remainingEntry.dayOfSix = nil;
		
	}
}

#pragma mark Reset Records

-(void)resetFollowedEntries
{
	if ([self.remainingScheduledEntries count] > 0) {
		
		NSInteger indexOfFirstNewlyFollowedAdviceForTheDay = [self.allAdviceFollowedByUser indexOfObject:self.nextEntry.advice]; //[self.nextEntry.advice.orderNumberInSet integerValue];

		[self.notificationController cancelAllNotifications];
		
		[self removeEntries:[self.thisDay getTheSixWithoutUserEntriesSorted]
					fromDay:self.thisDay];
 		
		[self setSuspendAutomaticTrackingOfChangesInManagedObjectContext:NO];
		
		NSMutableArray *newFollowedAdvice = [[NSMutableArray alloc] init];
		NSInteger orderNumber = 0;
		
		
		// Set the order numbers of the advice
		for (LESixOfDay *entryStillBeingFollowed in [self.thisDay getTheSixThatHaveUserEntriesSorted]) {
			
			entryStillBeingFollowed.orderNumberForType = [NSNumber numberWithInteger:++orderNumber];
			[newFollowedAdvice addObject:entryStillBeingFollowed.advice];
			
		}
		
		[self setTheSixForDay:self.thisDay withIndexOfFirstFollowedAdvice:indexOfFirstNewlyFollowedAdviceForTheDay inManagedObjectContext:self.managedObjectContext];
		
		[self setSuspendAutomaticTrackingOfChangesInManagedObjectContext:YES];
		
		[self.managedObjectContext save:nil];
	}
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

#pragma mark Headers and Footers

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == [self.tableViewSections indexOfObject:kSetupForDay]) {
		
		return @"Setup for Today";
		
	} else {
		
		return nil;
		
	}
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if (section == [self.tableViewSections indexOfObject:kSetupForDay]) {
		
		return 75.0f;
		
	} else {
		
		return 0.1f;
		
	}
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 0;
}

#pragma mark Sections

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.tableViewSections count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == [self.tableViewSections indexOfObject:kNextEntry] ||
		section == [self.tableViewSections indexOfObject:kNoSetsOfGuidelinesSelected] ||
		section == [self.tableViewSections indexOfObject:kWelcomeIntroduction]) {
		
		return 1;
	
	} else if (section == [self.tableViewSections indexOfObject:kAllOtherEntries]) {
		
		if ([self isAllAdviceForDayUpdated]) {
			
			return [self.updatedEntries count];
			
		} else if (self.showAllEntries) {
			
			return [[self.thisDay getTheSixSorted] count];
			
		} else {
			
			return 1;
			
		}
		
	} else if (section == [self.tableViewSections indexOfObject:kSetupForDay]) {
		
		if (self.setsOfGuidelinesHaveBeenSelected) {
			
			return ([self hasInlineDatePicker]) ? 3 : 2;
		
		} else {
			
			return 1;
			
		}
		
	} else if (section == [self. tableViewSections indexOfObject:kPreviousDays]) {
		
		return 1;
		
	} else if (section == [self.tableViewSections indexOfObject:kAboutAndSettings]) {
		
		return 1;
		
	}
	
	return 0;
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	return nil;
}



#pragma mark Rows

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UILabel *guidelineLabel = [UILabel new];
	UILabel *timeLabel = [UILabel new];
	guidelineLabel.lineBreakMode = NSLineBreakByWordWrapping;

	if (indexPath.section == [self.tableViewSections indexOfObject:kNextEntry]) {

		if ([self isAllAdviceForDayUpdated]) {
		
			static NSString *congratulationsCellIdentifier = @"SixTimesCompletedCell";
			UITableViewCell *congratulationsCell = [tableView dequeueReusableCellWithIdentifier:congratulationsCellIdentifier];
			
			UILabel *messageLabel = (UILabel *)[congratulationsCell viewWithTag:1000];
			
			messageLabel.font = [UIFont preferredSerifFontForTextStyle:UIFontTextStyleBody];
			
			CGFloat messageLabelHeight = [self heightForLabel:messageLabel
													 withText:messageLabel.text
												   labelWidth:self.screenWidth - 30];
			
			CGFloat imageHeight = 32;
			
			CGFloat combinedTopAndBottomSpaceForLabelsAndHeight = 40;
			
			return messageLabelHeight + imageHeight + combinedTopAndBottomSpaceForLabelsAndHeight;
			
		} else {
				
			guidelineLabel.font	= [UIFont preferredFontForAdviceNameInEntry];
			guidelineLabel.text = self.nextEntry.advice.name;
			
			timeLabel.font = [UIFont preferredFontForTimeForNextEntry];
			timeLabel.text = @"8:00 placeholder";

			CGFloat guidelineLabelHeight = [self heightForLabel:guidelineLabel
													   withText:guidelineLabel.text
													 labelWidth:GUIDELINE_LABEL_WIDTH];
			CGFloat timeLabelHeight = [self heightForLabel:timeLabel
												  withText:timeLabel.text
												labelWidth:GUIDELINE_LABEL_WIDTH];
			
			return guidelineLabelHeight + 12 + timeLabelHeight + guidelineLabel.font.pointSize * 1.2;
		
		}
		
	} else if (indexPath.section == [self.tableViewSections indexOfObject:kAllOtherEntries]) {
		

		if (
			((self.isMemberOfSTTodayTVC) && (([self isAllAdviceForDayUpdated]) || (indexPath.row > 0 && indexPath.row < [self.updatedEntries count] + 1))) ||
			((!(self.isMemberOfSTTodayTVC) && (indexPath.row < [self.updatedEntries count])))
		   ){
		
			NSInteger indexForUpdatedEntry = [self indexOfEntryAt:indexPath
											  whichHasBeenUpdated:YES];
			
			LESixOfDay *updatedEntry = [self.updatedEntries objectAtIndex:indexForUpdatedEntry];
			
			guidelineLabel.font = [UIFont preferredFontForAdviceNameInEntry];
			guidelineLabel.text = [[updatedEntry valueForKey:@"advice"] valueForKey:@"name"];
			
			CGFloat guidelineLabelHeight = [self heightForLabel:guidelineLabel
													   withText:guidelineLabel.text
													 labelWidth:GUIDELINE_LABEL_WIDTH];
			
			UILabel *actionLabel = [UILabel new];
			actionLabel.lineBreakMode = NSLineBreakByWordWrapping;
			actionLabel.font = [UIFont preferredFontForActionText];
			
			NSInteger positiveActionHeight = 0;
			NSInteger negativeActionHeight = 0;
			
			if ([updatedEntry hasPositiveActionWithText]) {
				
				positiveActionHeight = [self heightForLabel:actionLabel
												   withText:[[updatedEntry.getPositiveActionsTaken anyObject] valueForKey:@"text"]
												 labelWidth:GUIDELINE_LABEL_WIDTH - 20];
				
				positiveActionHeight += 7;
				
			}
			
			if ([updatedEntry hasNegativeActionWithText]) {
				
				negativeActionHeight = [self heightForLabel:actionLabel
												   withText:[[updatedEntry.getNegativeActionsTaken anyObject] valueForKey:@"text"]
												 labelWidth:GUIDELINE_LABEL_WIDTH - 20];
				
				negativeActionHeight += 7;
				
			}
						
			NSInteger cellHeight = guidelineLabelHeight + positiveActionHeight + negativeActionHeight + 40;
			
			return cellHeight;
		
		} else if (!self.isMemberOfSTTodayTVC || (indexPath.row > 0)) {
			
			guidelineLabel.font = [UIFont preferredFontForAdviceNameInSetOfAdviceListing];
			
			NSInteger indexOfScheduledEntry = [self indexOfEntryAt:indexPath
											   whichHasBeenUpdated:NO];
			
			guidelineLabel.text = [[[self.remainingScheduledEntries objectAtIndex:indexOfScheduledEntry] valueForKey:@"advice"] valueForKey:@"name"];
			
			CGFloat guidelineLabelHeight = [self heightForLabel:guidelineLabel
													   withText:guidelineLabel.text
													 labelWidth:GUIDELINE_LABEL_WIDTH];

			return guidelineLabelHeight + 46;
			
		} else {
			
			UILabel	*label = [UILabel new];
			label.font = [UIFont preferredFontForUILabel];
			label.text = @"placeholder text";
			CGFloat labelHeight = [self heightForLabel:label
											  withText:label.text
											labelWidth:150.0];
			return labelHeight + label.font.pointSize * 1.3;
			
		}
		
	} else if ([self indexPathHasPicker:indexPath]) {
	
		return self.pickerCellRowHeight;
	
	} else if (indexPath.section == [self.tableViewSections indexOfObject:kNoSetsOfGuidelinesSelected]) {

		UITableViewCell *chooseGuidelinesCell;
		chooseGuidelinesCell = [tableView dequeueReusableCellWithIdentifier:@"NoSetsOfGuidelinesSelectedCell"];
		
		UILabel *headlineLabel = (UILabel *)[chooseGuidelinesCell viewWithTag:1000];
		UILabel *messageLabel = (UILabel *)[chooseGuidelinesCell viewWithTag:1001];
		
		headlineLabel.font = [UIFont preferredSerifFontForTextStyle:UIFontTextStyleSubheadline];
		messageLabel.font = [UIFont preferredFontForMainMessageBody];
		
		CGFloat headlineLabelHeight = [self heightForLabel:headlineLabel
												  withText:headlineLabel.text
												labelWidth:self.screenWidth - 30];
		
		CGFloat messageLabelHeight = [self heightForLabel:messageLabel
												 withText:messageLabel.text
											   labelWidth:self.screenWidth - 30];
		
		CGFloat combinedTopAndBottomSpacesForLabels = 45;
		
		return headlineLabelHeight + messageLabelHeight + combinedTopAndBottomSpacesForLabels;
	
	} else if (indexPath.section == [self.tableViewSections indexOfObject:kWelcomeIntroduction]) {
		
		
		static NSString *welcomeMessageCellIdentifier = @"WelcomeIntroductionCell";
		UITableViewCell *welcomeCell = [tableView dequeueReusableCellWithIdentifier:welcomeMessageCellIdentifier];

		UILabel *headlineLabel = (UILabel *)[welcomeCell viewWithTag:1000];
		UILabel *messageLabel = (UILabel *)[welcomeCell viewWithTag:1001];
		
		headlineLabel.font = [UIFont preferredSerifFontForTextStyle:UIFontTextStyleSubheadline];
		messageLabel.font = [UIFont preferredSerifFontForTextStyle:UIFontTextStyleBody];
		
		CGFloat headlineLabelHeight = [self heightForLabel:headlineLabel
												  withText:headlineLabel.text
												labelWidth:self.screenWidth - 30];
		
		CGFloat messageLabelHeight = [self heightForLabel:messageLabel
												 withText:messageLabel.text
											   labelWidth:self.screenWidth - 30];
		
		CGFloat imageHeight = 32;
		
		CGFloat combinedTopAndBottomSpaceForLabelsAndHeight = 50;
		
		return headlineLabelHeight + messageLabelHeight + imageHeight + combinedTopAndBottomSpaceForLabelsAndHeight;
		
	} else {

		UILabel	*label = [UILabel new];
		label.font = [UIFont preferredFontForUILabel];
		label.text = @"placeholder text";
		CGFloat labelHeight = [self heightForLabel:label
										  withText:label.text
										labelWidth:150.0];
		return labelHeight + label.font.pointSize * 1.3;
	
	}
}


-(NSInteger)indexOfEntryAt:(NSIndexPath *)indexPath whichHasBeenUpdated:(BOOL)entryHasBeenUpdated
{
	/* In the "Other Entries" section of the table view, scheduled/remaining entries appear _after_ any entries that have already been updated.
	 */
	
	NSInteger indexOfEntry = indexPath.row;

	if (!entryHasBeenUpdated) {
		
		indexOfEntry -= [self.updatedEntries count];
		
	}

	BOOL showHeaderRowForOtherEntriesSection = (self.isMemberOfSTTodayTVC && ![self isAllAdviceForDayUpdated]);
	
	if (showHeaderRowForOtherEntriesSection) {
		
		indexOfEntry -= 1;
		
	}

	return indexOfEntry;
}

#pragma mark Cell and Label Heights
-(CGFloat)heightForLabel:(UILabel *)label withText:(NSString *)text labelWidth:(CGFloat)labelWidth
{
	if (text != nil) {
		
		UIFont *font = label.font;
		NSAttributedString *attributedText	= [ [NSAttributedString alloc]
											  initWithString:text
											  attributes: @{NSFontAttributeName: font}
											  ];
		CGRect rect = [attributedText boundingRectWithSize:(CGSize){labelWidth, CGFLOAT_MAX}
												options:NSStringDrawingUsesLineFragmentOrigin
												context:nil];
		CGSize size = rect.size;
		CGFloat height = ceilf(size.height);
		return height;
		
	} else {
		
		return 0;
	
	}
}

-(void)resizeHeightToFitForLabel:(UILabel *)label labelWidth:(CGFloat)labelWidth
{
	CGRect newFrame = label.frame;
	newFrame.size.height = [self heightForLabel:label
									   withText:label.text
									 labelWidth:labelWidth];
	label.frame = newFrame;
}



#pragma mark - Table view data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *guidelineNextEntryCellIdentifier = @"GuidelineNextEntryCell";
	static NSString *guidelineOtherEntryCellIdentifier = @"GuidelineOtherEntryCell";
	static NSString *guidelineSummaryEntryCellIdentifier = @"GuidelineSummaryEntryCell";
	static NSString *congratulationsCellIdentifier = @"SixTimesCompletedCell";
	static NSString *summaryOrSetupCellIdentifier = @"SummaryOrSetupCell";
	static NSString *dateCellIdentifier = @"dateCell";
	static NSString *datePickerCellIdentifier = @"datePickerCell";
		
    if (indexPath.section == [self.tableViewSections indexOfObject:kNextEntry]) {
		
		if ([self isAllAdviceForDayUpdated]) {
			
			UITableViewCell *congratulationsCell = [tableView dequeueReusableCellWithIdentifier:congratulationsCellIdentifier];
			
			UILabel *messageLabel = (UILabel *)[congratulationsCell viewWithTag:1000];
			
			messageLabel.font = [UIFont preferredSerifFontForTextStyle:UIFontTextStyleBody];
						
			[self resizeHeightToFitForLabel:messageLabel
								 labelWidth:self.screenWidth - 30];
			
			return congratulationsCell;
			
		} else {
		
			UITableViewCell *guidelineNextEntryCell = [tableView dequeueReusableCellWithIdentifier:guidelineNextEntryCellIdentifier];
			UILabel *guidelineLabel = (UILabel *)[guidelineNextEntryCell viewWithTag:11];
			UILabel *timeLabel = (UILabel *)[guidelineNextEntryCell viewWithTag:10];
			
			for (NSInteger completedProgressBarStep = 0; completedProgressBarStep < [self.updatedEntries count]; completedProgressBarStep++) {
				
				UIView *completedProgressBarStepView = (UIView *)[guidelineNextEntryCell viewWithTag:60+completedProgressBarStep];
				[completedProgressBarStepView setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:204.0/255.0 blue:102.0/255.0 alpha:1.0]];
				
			}
		
			guidelineLabel.font = [UIFont preferredFontForAdviceNameInEntry];
			timeLabel.font = [UIFont preferredFontForTimeForNextEntry];
		
			NSString *timeEntryTextPrefix = @"";
					
			timeLabel.text = [NSString stringWithFormat:@"%@%@", timeEntryTextPrefix, self.nextEntry.timeScheduled.time];
			guidelineLabel.text = self.nextEntry.advice.name;
									
			[self resizeHeightToFitForLabel:guidelineLabel
								 labelWidth:GUIDELINE_LABEL_WIDTH];
		
			return guidelineNextEntryCell;
			
		}
		
	} else if (indexPath.section == [self.tableViewSections indexOfObject:kAllOtherEntries]) {
	
		if (
			((self.isMemberOfSTTodayTVC) && (([self isAllAdviceForDayUpdated]) || (indexPath.row > 0 && indexPath.row < [self.updatedEntries count] + 1))) ||
			((!(self.isMemberOfSTTodayTVC) && (indexPath.row < [self.updatedEntries count])))
			){
			
			NSInteger indexForUpdatedEntry = [self indexOfEntryAt:indexPath
											  whichHasBeenUpdated:YES];
			
			UITableViewCell *guidelineCell	= [tableView dequeueReusableCellWithIdentifier:guidelineSummaryEntryCellIdentifier];
			UILabel *timeLabel				= (UILabel *)[guidelineCell viewWithTag:10];
			UILabel *guidelineLabel			= (UILabel *)[guidelineCell viewWithTag:11];
			UILabel *positiveIconLabel		= (UILabel *)[guidelineCell viewWithTag:15];
			UILabel *negativeIconLabel		= (UILabel *)[guidelineCell viewWithTag:16];
			UILabel *positiveActionLabel	= (UILabel *)[guidelineCell viewWithTag:20];
			UILabel *negativeActionLabel	= (UILabel *)[guidelineCell viewWithTag:21];
			
			guidelineLabel.font = [UIFont preferredFontForAdviceNameInSetOfAdviceListing];
			timeLabel.font = [UIFont preferredFontForTimeForUpdatedEntry];
			
			LESixOfDay *updatedEntry		= [self.updatedEntries objectAtIndex:indexForUpdatedEntry];
			
			timeLabel.text					= [NSString stringWithFormat:@"Updated %@", updatedEntry.timeLastUpdated.time];
			guidelineLabel.text				= updatedEntry.advice.name;
			
			positiveActionLabel.font = [UIFont preferredFontForActionText];
			negativeActionLabel.font = [UIFont preferredFontForActionText];
			
			positiveActionLabel.text		= [[updatedEntry.getPositiveActionsTaken anyObject] valueForKey:@"text"];
			negativeActionLabel.text		= [[updatedEntry.getNegativeActionsTaken anyObject] valueForKey:@"text"];
			
			positiveActionLabel.hidden		= ([positiveActionLabel.text isEqualToString:@""]);
			positiveIconLabel.hidden		= ([positiveActionLabel.text isEqualToString:@""]);
			
			negativeActionLabel.hidden		= ([negativeActionLabel.text isEqualToString:@""]);
			negativeIconLabel.hidden		= ([negativeActionLabel.text isEqualToString:@""]);

			
			[self resizeHeightToFitForLabel:guidelineLabel
								 labelWidth:GUIDELINE_LABEL_WIDTH];
			
			if (!positiveActionLabel.hidden) {
				
				[self resizeHeightToFitForLabel:positiveActionLabel
									 labelWidth:GUIDELINE_LABEL_WIDTH - 20];
								
			}
			
			if (!negativeActionLabel.hidden) {
				
				[self resizeHeightToFitForLabel:negativeActionLabel
									 labelWidth:GUIDELINE_LABEL_WIDTH - 20];
				
			}
			
			return guidelineCell;
			
		} else if (!self.isMemberOfSTTodayTVC || (self.showAllEntries && indexPath.row > 0)) {
			
			UITableViewCell *guidelineCell	= [tableView dequeueReusableCellWithIdentifier:guidelineOtherEntryCellIdentifier];
			UILabel *timeLabel				= (UILabel *)[guidelineCell viewWithTag:10];
			UILabel *guidelineLabel			= (UILabel *)[guidelineCell viewWithTag:11];
			
			guidelineLabel.font = [UIFont preferredFontForAdviceNameInSetOfAdviceListing];
			timeLabel.font = [UIFont preferredFontForTimeForRemaingScheduledEntry];

			NSInteger indexOfScheduledEntry = [self indexOfEntryAt:indexPath
											   whichHasBeenUpdated:NO];

			LESixOfDay *scheduledEntry		= [self.remainingScheduledEntries objectAtIndex:indexOfScheduledEntry];

			timeLabel.text					= [NSString stringWithFormat:@"%@", scheduledEntry.timeScheduled.time];
			guidelineLabel.text				= scheduledEntry.advice.name;
			
			[self resizeHeightToFitForLabel:guidelineLabel
								 labelWidth:GUIDELINE_LABEL_WIDTH];
			
			return guidelineCell;
			
		} else {
			
			UITableViewCell *summaryOrSetupCell = [tableView dequeueReusableCellWithIdentifier:summaryOrSetupCellIdentifier];
			
			summaryOrSetupCell.textLabel.font = [UIFont preferredFontForUILabel];
			summaryOrSetupCell.textLabel.text = @"Today's Other Guidelines";
			summaryOrSetupCell.textLabel.textColor = [UIColor darkGrayColor];
			summaryOrSetupCell.detailTextLabel.text = @"";
			
			if (self.showAllEntries) {
				
				summaryOrSetupCell.selectionStyle = UITableViewCellSelectionStyleNone;
				
			} else {
			
				summaryOrSetupCell.selectionStyle = UITableViewCellSelectionStyleBlue;
			
			}
	
			summaryOrSetupCell.accessoryType = UITableViewCellAccessoryNone;
			
			return summaryOrSetupCell;
			
		}

	} else if (indexPath.section == [self.tableViewSections indexOfObject:kSetupForDay]) {
		
		UITableViewCell *daySetupCell;
		
		if (self.setsOfGuidelinesHaveBeenSelected && [self indexPathHasPicker:indexPath]){
			
			daySetupCell = [tableView dequeueReusableCellWithIdentifier:datePickerCellIdentifier];
			
		} else if (self.setsOfGuidelinesHaveBeenSelected && [self indexPathHasDate:indexPath]) {
			
			daySetupCell = [tableView dequeueReusableCellWithIdentifier:dateCellIdentifier];
			daySetupCell.textLabel.font = [UIFont preferredFontForUILabel];
			daySetupCell.textLabel.text = @"Start of Day";
			if (!self.highlightStartOfDayLabelWithColor) {
			
				daySetupCell.textLabel.textColor = [UIColor darkGrayColor];
			
			}
			daySetupCell.detailTextLabel.font = [UIFont preferredFontForUILabel];
			daySetupCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [self wakeUpAtTime]];
			daySetupCell.detailTextLabel.tag = 10001;
			
		} else {
			
			daySetupCell = [tableView dequeueReusableCellWithIdentifier:summaryOrSetupCellIdentifier];
			daySetupCell.textLabel.font = [UIFont preferredFontForUILabel];
			daySetupCell.textLabel.text = (self.setsOfGuidelinesHaveBeenSelected) ? @"Guidelines Being Followed" : @"Select Guidelines to Follow";
			if (self.setsOfGuidelinesHaveBeenSelected)
				daySetupCell.textLabel.textColor = [UIColor darkGrayColor];
			daySetupCell.detailTextLabel.font = [UIFont preferredFontForUILabel];
			daySetupCell.detailTextLabel.text = (self.setsOfGuidelinesHaveBeenSelected) ? [NSString stringWithFormat:@"%lu", (unsigned long)[self.allAdviceFollowedByUser count]] : @"";
			
		}
		
		return daySetupCell;

	} else if (indexPath.section == [self.tableViewSections indexOfObject:kNoSetsOfGuidelinesSelected]) {
		
		UITableViewCell *chooseGuidelinesCell;
		chooseGuidelinesCell = [tableView dequeueReusableCellWithIdentifier:@"NoSetsOfGuidelinesSelectedCell"];

		
		UILabel *headlineLabel = (UILabel *)[chooseGuidelinesCell viewWithTag:1000];
		UILabel *messageLabel = (UILabel *)[chooseGuidelinesCell viewWithTag:1001];
		
		headlineLabel.font = [UIFont preferredSerifFontForTextStyle:UIFontTextStyleSubheadline];
		messageLabel.font = [UIFont preferredFontForMainMessageBody];
		
		[self resizeHeightToFitForLabel:headlineLabel
							 labelWidth:self.screenWidth - 30];
		
		[self resizeHeightToFitForLabel:messageLabel
							 labelWidth:self.screenWidth - 30];
		
		return chooseGuidelinesCell;
	
	} else if (indexPath.section == [self.tableViewSections indexOfObject:kWelcomeIntroduction]) {
		
		static NSString *welcomeMessageCellIdentifier = @"WelcomeIntroductionCell";
		UITableViewCell *welcomeCell = [tableView dequeueReusableCellWithIdentifier:welcomeMessageCellIdentifier];
		
		UILabel *headlineLabel = (UILabel *)[welcomeCell viewWithTag:1000];
		UILabel *messageLabel = (UILabel *)[welcomeCell viewWithTag:1001];
		
		headlineLabel.font = [UIFont preferredSerifFontForTextStyle:UIFontTextStyleSubheadline];
		messageLabel.font = [UIFont preferredSerifFontForTextStyle:UIFontTextStyleBody];
		
		[self resizeHeightToFitForLabel:headlineLabel
							 labelWidth:self.screenWidth - 30];
		
		[self resizeHeightToFitForLabel:messageLabel
							 labelWidth:self.screenWidth - 30];
		
		return welcomeCell;
		
	} else if (indexPath.section == [self.tableViewSections indexOfObject:kPreviousDays]) {
		
		// Previous Days
		UITableViewCell *previousDaysCell = [tableView dequeueReusableCellWithIdentifier:summaryOrSetupCellIdentifier];
		
		previousDaysCell.textLabel.font = [UIFont preferredFontForUILabel];
		previousDaysCell.textLabel.text = @"Previous Days";
		previousDaysCell.textLabel.textColor = [UIColor darkGrayColor];
		previousDaysCell.detailTextLabel.font = [UIFont preferredFontForUILabel];
		previousDaysCell.detailTextLabel.text	= @"";
		previousDaysCell.selectionStyle = UITableViewCellSelectionStyleBlue;
		previousDaysCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		return previousDaysCell;
		
	} else if (indexPath.section == [self.tableViewSections indexOfObject:kAboutAndSettings]) {
		
		UITableViewCell *settingsCell = [tableView dequeueReusableCellWithIdentifier:summaryOrSetupCellIdentifier];
		
		settingsCell.textLabel.font = [UIFont preferredFontForUILabel];
		settingsCell.textLabel.text = @"Settings";
		settingsCell.textLabel.textColor = [UIColor darkGrayColor];
		settingsCell.detailTextLabel.text	= @"";

		return settingsCell;
	}
	return nil;
}


- (NSString *)wakeUpAtTime
{
	NSInteger startHour = [self.thisDay.startHour integerValue];
	NSInteger startMinute = [self.thisDay.startMinute integerValue];
	NSDate *wakeUpAt = [NSDate dateWithHour:startHour
								  andMinute:startMinute];
	return wakeUpAt.time;
}


/*! Adds or removes a UIDatePicker cell below the given indexPath.
 
 @param indexPath The indexPath to reveal the UIDatePicker.
 */
- (void)toggleDatePickerForSelectedIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:[self.tableViewSections indexOfObject:kSetupForDay]]];
	
    // check if 'indexPath' has an attached date picker below it
    if ([self hasPickerForIndexPath:indexPath]) {
		
        // found a picker below it, so remove it
        [self.tableView deleteRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
	
	} else {
		
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
    NSInteger originalStartHour = 0;
	NSInteger originalStartMinute = 0;
	NSInteger newStartHour = 0;
	NSInteger newStartMinute = 0;
	
	
	// display the date picker inline with the table content
    [self.tableView beginUpdates];
    
    BOOL before = NO;   // indicates if the date picker is below "indexPath", help us determine which row to reveal
	BOOL shouldReloadTableData = NO;
	
    if ([self hasInlineDatePicker]) {
		
        before = self.datePickerIndexPath.row < indexPath.row;
		
    }
    
    BOOL sameCellClicked = (self.datePickerIndexPath.row - 1 == indexPath.row);
    
    // remove any date picker cell if it exists
    if ([self hasInlineDatePicker]) {
		
		originalStartHour = [self.thisDay.startHour integerValue];
		originalStartMinute = [self.thisDay.startMinute integerValue];
        
		[self doneAction:Nil];
		
		newStartHour = [self.thisDay.startHour integerValue];
		newStartMinute = [self.thisDay.startMinute integerValue];
		
		[self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row
																	inSection:[self.tableViewSections indexOfObject:kSetupForDay]]]
                              withRowAnimation:UITableViewRowAnimationFade];
        self.datePickerIndexPath = nil;
		
		shouldReloadTableData = ((originalStartHour != newStartHour) || (originalStartMinute != newStartMinute));
		
    }
    
    if (!sameCellClicked) {
		
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
	
	if (shouldReloadTableData) {
	
		[self.tableView reloadData];
		
	}
    
    // inform our date picker of the current date to match the current cell
    [self updateDatePicker];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == [self.tableViewSections indexOfObject:kNextEntry]) {
	
		if ([self.allAdviceFollowedByUser count] == 0) {
			
			[self performSegueWithIdentifier:@"Guidelines Followed" sender:self];
			
		} else if ([[self.thisDay getTheSixWithoutUserEntriesSorted] count] > 0) {
		
			[self performSegueWithIdentifier:@"Guideline Entry" sender:self];
		
		}
			
	} else if (indexPath.section == [self.tableViewSections indexOfObject:kAllOtherEntries]) {
		
		if (indexPath.row > 0 || [self isAllAdviceForDayUpdated] || !self.isMemberOfSTTodayTVC) {
			
			[self performSegueWithIdentifier:@"Guideline Entry" sender:self];
		
		} else if (indexPath.row < 6) {
			
			self.showAllEntries = (self.showAllEntries) ? NO : YES;
			[tableView reloadSections:[NSIndexSet indexSetWithIndex:[self.tableViewSections indexOfObject:kAllOtherEntries]]
					 withRowAnimation:YES];
		
		}
		
	} else if (indexPath.section == [self.tableViewSections indexOfObject:kSetupForDay]) {
		
		if (indexPath.row == 0 && self.setsOfGuidelinesHaveBeenSelected) {
			
			[self displayInlineDatePickerForRowAtIndexPath:indexPath];
			
		} else {
			
			[self performSegueWithIdentifier:@"Guidelines Followed" sender:self];
			
		}
	} else if (indexPath.section == [self.tableViewSections indexOfObject:kPreviousDays]) {
		
		[self performSegueWithIdentifier:@"Previous Days" sender:self];
		
	} else if (indexPath.section == [self.tableViewSections indexOfObject:kAboutAndSettings]) {
		
		[self performSegueWithIdentifier:@"Settings" sender:self];
		
	}
}


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
    if (self.datePickerIndexPath != nil) {
		
        UITableViewCell *associatedDatePickerCell = [self.tableView cellForRowAtIndexPath:self.datePickerIndexPath];
        
        UIDatePicker *targetedDatePicker = (UIDatePicker *)[associatedDatePickerCell viewWithTag:kDatePickerTag];
		
        if (targetedDatePicker != nil) {
			
            // we found a UIDatePicker in this cell, so update its date value
			[targetedDatePicker	setDate:[self.dateFormatter dateFromString:[self wakeUpAtTime]]];
    
		}
    
	}
}

- (NSDate *)dateFromDatePicker
{
	if (self.datePickerIndexPath != nil) {
		
        UITableViewCell *associatedDatePickerCell = [self.tableView cellForRowAtIndexPath:self.datePickerIndexPath];
        
        UIDatePicker *targetedDatePicker = (UIDatePicker *)[associatedDatePickerCell viewWithTag:kDatePickerTag];

        if (targetedDatePicker != nil) {
		
			return targetedDatePicker.date;
			
		}
		
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
    
    if ((indexPath.row == kDateStartRow) || ([self hasInlineDatePicker]  && (indexPath.row == kDateStartRow + 1))) {
        
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
    
    if ([self hasInlineDatePicker]) {
    
		// inline date picker: update the cell's date "above" the date picker cell
        //
        targetedCellIndexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:0];
    
	} else {
		
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


- (IBAction)doneAction:(id)sender
{
	NSDate *updatedWakeUpTime = [self dateFromDatePicker];
	self.thisDay.startHour = [NSNumber numberWithInteger:[updatedWakeUpTime hour]];
	self.thisDay.startMinute = [NSNumber numberWithInteger:[updatedWakeUpTime minute]];
	[self.notificationController cancelAllNotifications];
	
	// Reset scheduled times for log entries
	NSArray *allRemainingEntries = [self.thisDay getTheSixWithoutUserEntriesSorted];
	NSInteger countOfCompletedEntries = [self.updatedEntries count];
	NSInteger badgeNumber = 0;
	
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

	UILabel *wakeUpTimeTextLabel = (UILabel *)[self.tableView viewWithTag:10001];
	wakeUpTimeTextLabel.text = [updatedWakeUpTime time];
	self.highlightStartOfDayLabelWithColor = NO;
	
	[TestFlight passCheckpoint:@"RESET WAKEUP TIME"];

}


#pragma mark - Managing Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
			
	if ([[segue identifier] isEqualToString:@"Guideline Entry"]) {
		
		STLogEntrySixOfDayTVC *leSixOfDayTVC = segue.destinationViewController;
		leSixOfDayTVC.managedObjectContext = self.managedObjectContext;
		
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		
		NSInteger indexOfUpdatedEntry = [self indexOfEntryAt:indexPath
										 whichHasBeenUpdated:YES];
						
		if ([sender isMemberOfClass:[STAppDelegate class]]) {
			
			leSixOfDayTVC.leSixOfDay = self.entryFromNotification;
			
		} else {
			
			if (indexPath.section == [self.tableViewSections indexOfObject:kNextEntry]) {
				
				leSixOfDayTVC.leSixOfDay = self.nextEntry;
				[TestFlight passCheckpoint:@"GO TO NEXT ENTRY"];
			
			} else if (indexPath.section == [self.tableViewSections indexOfObject:kAllOtherEntries] && indexOfUpdatedEntry < [self.updatedEntries count]) {
				
				leSixOfDayTVC.leSixOfDay = [self.updatedEntries objectAtIndex:indexOfUpdatedEntry];
				[TestFlight passCheckpoint:@"GO TO PREVIOUS ENTRY"];
				
			} else if (indexPath.section == [self.tableViewSections indexOfObject:kAllOtherEntries]) {
				
				NSInteger indexOfScheduledEntry = [self indexOfEntryAt:indexPath
												   whichHasBeenUpdated:NO];
								
				leSixOfDayTVC.leSixOfDay = [self.remainingScheduledEntries objectAtIndex:indexOfScheduledEntry];
				leSixOfDayTVC.isRemainingScheduledEntry	= YES;
				[TestFlight passCheckpoint:@"GO TO FUTURE ENTRY"];
				
			}
			
		}
		
	} else if ([[segue identifier] isEqualToString:@"Guidelines Followed"]) {
		
		STSetsOfAdviceTVC *tradtionsTVC = segue.destinationViewController;
		tradtionsTVC.managedObjectContext = self.managedObjectContext;
		tradtionsTVC.currentDay = self.thisDay;
		[TestFlight passCheckpoint:@"GO TO GUIDELINES"];
		
	} else if ([[segue identifier] isEqualToString:@"Previous Days"]) {
		
		STPreviousDaysTVC *previousDaysTVC = segue.destinationViewController;
		previousDaysTVC.managedObjectContext = self.managedObjectContext;
		[TestFlight passCheckpoint:@"GO TO PREVIOUS DAYS"];
		
	} else if ([[segue identifier] isEqualToString:@"Settings"]) {
		
		NSLog(@"Going to settings");
	
		STSettingsTVC *settingsTVC = segue.destinationViewController;
			settingsTVC.todayTVC = self;
		
	}
	
	self.title = self.mostRecentlyAddedDate.shortWeekdayAndDate;

}

- (IBAction)greatHighwayExplorerFeedback:(id)sender {
	//	[TestFlight openFeedbackView];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
