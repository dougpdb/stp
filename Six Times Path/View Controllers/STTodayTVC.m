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
#import "Advice.h"
#import "Day+ST.h"
#import "LESixOfDay+ST.h"
#import "NSDate+ST.h"
#import "NSDate+ES.h"
#import "TestFlight.h"

#define OUT_OF_RANGE	10000
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_PORTRAIT 

#define GUIDELINE_LABEL_WIDTH	268
#define ACTION_LABEL_WIDTH		245

@interface STTodayTVC ()

@property (nonatomic, retain) IBOutlet UIDatePicker *pickerView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *feedbackButton;

@property (nonatomic, weak) NSArray *dataArray;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

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
	if (_countOfTheSixWithoutUserEntries == OUT_OF_RANGE) {
		_countOfTheSixWithoutUserEntries	= [[self.thisDay getTheSixWithoutUserEntriesSorted] count];
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

	if ([self isMemberOfClass:[STTodayTVC class]])
		self.navigationItem.leftBarButtonItem	= self.feedbackButton;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	self.showRemainingScheduledEntries	= nil;
	self.showUpdatedEntries				= nil;
	
	self.thisDay					= nil;
	self.nextEntry					= nil;
	self.entryFromNotification		= nil;
	self.remainingScheduledEntries	= nil;
	self.updatedEntries				= nil;
	self. mostRecentlyAddedDate		= nil;
	self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay	= nil;
	self.allAdviceFollowedByUser	= nil;
	self.countOfTheSixWithoutUserEntries	= nil;
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
	self.tableViewSections				= nil;
	[self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
	self.showUpdatedEntries				= NO;
	self.showRemainingScheduledEntries	= NO;
}



#pragma mark - Set Data for the Table View Controller

-(void)setupDayAndAdviceData
{
	[self setupAdviceFetchedResultsController];
    self.allAdviceFollowedByUser				= [NSMutableArray arrayWithArray:self.fetchedResultsController.fetchedObjects];
	
	[self setupDaysFetchedResultsController];
	
	if ([self.fetchedResultsController.fetchedObjects count] == 0) {
		self.mostRecentlyAddedDate				= [NSDate dateYesterday];
		self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay = 0;
		self.thisDay							= nil;
	} else {
		Day *mostRecentDay						= [self.fetchedResultsController.fetchedObjects objectAtIndex:0];
		LESixOfDay *lastTheSixOfMostRecentDay	= [[mostRecentDay getTheSixSorted] lastObject];
		self.mostRecentlyAddedDate				= mostRecentDay.date;
		self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay = [self.allAdviceFollowedByUser indexOfObject:lastTheSixOfMostRecentDay.advice] + 1;
		self.thisDay							= mostRecentDay;
	}
		
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
	
	self.countOfTheSixWithoutUserEntries		= OUT_OF_RANGE;
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
		
		[self cancelAllRemainingNotifications];
		
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
	
	for (LESixOfDay *logEntry in day.theSix) {
		[self addNotification:logEntry];
	}
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
	if (section == [self.tableViewSections indexOfObject:@"Next Entry"]) {
		return 1;
	} else if (section == [self.tableViewSections indexOfObject:@"Remaining Scheduled Entries"]) {
		if (self.showRemainingScheduledEntries)
			return [self.remainingScheduledEntries count] + 1;
		else
			return 1;		
	} else if (section == [self.tableViewSections indexOfObject:@"Updated Entries"]) {
		if (self.countOfTheSixWithoutUserEntries == 0)
			self.showUpdatedEntries	= YES;
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
	UILabel *guidelineLabel			= [UILabel new];
	guidelineLabel.lineBreakMode	= NSLineBreakByWordWrapping;

	if (indexPath.section == [self.tableViewSections indexOfObject:@"Next Entry"]) {
		
		guidelineLabel.font				= [UIFont fontWithName:@"Palatino Bold" size:17]; // [UIFont boldSystemFontOfSize:17];

		if (self.countOfTheSixWithoutUserEntries > 0)
			guidelineLabel.text			= self.nextEntry.advice.name;
		else
			guidelineLabel.text			= @"You've made entries for all 6 guidelines. Be happy over what you've done well to day, and regret the mistaken actions.";
		
		CGFloat guidelineLabelHeight	= [self heightForLabel:guidelineLabel withText:guidelineLabel.text labelWidth:GUIDELINE_LABEL_WIDTH];
		
		return 36 + guidelineLabelHeight + 8;		// change for landscape orientation?
		
	} else if (indexPath.section == [self.tableViewSections indexOfObject:@"Remaining Scheduled Entries"] && indexPath.row > 0) {
		
		guidelineLabel.font				= [UIFont boldSystemFontOfSize:15];
		guidelineLabel.text				= [[[self.remainingScheduledEntries objectAtIndex:indexPath.row - 1] valueForKey:@"advice"] valueForKey:@"name"];
		
		CGFloat guidelineLabelHeight	= [self heightForLabel:guidelineLabel withText:guidelineLabel.text labelWidth:GUIDELINE_LABEL_WIDTH];

		return 30 + guidelineLabelHeight + 10;
		
	} else if (indexPath.section == [self.tableViewSections indexOfObject:@"Updated Entries"] && indexPath.row > 0) {
		
		guidelineLabel.font				= [UIFont boldSystemFontOfSize:15];
		guidelineLabel.text				= [[[self.updatedEntries objectAtIndex:indexPath.row - 1] valueForKey:@"advice"] valueForKey:@"name"];
		
		CGFloat guidelineLabelHeight	= [self heightForLabel:guidelineLabel withText:guidelineLabel.text labelWidth:GUIDELINE_LABEL_WIDTH];
		
		return 30 + guidelineLabelHeight + 65;
		
	} else {
		
		return 35;
		
	}
}



#pragma mark - Managing Cell and Label Heights
-(CGFloat)heightForLabel:(UILabel *)label withText:(NSString *)text labelWidth:(CGFloat)labelWidth
{
	CGSize maximumLabelSize		= CGSizeMake(labelWidth, FLT_MAX);
	
	CGSize expectedLabelSize	= [text sizeWithFont:label.font
								constrainedToSize:maximumLabelSize
									lineBreakMode:label.lineBreakMode];

	return expectedLabelSize.height;
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
		
    if (indexPath.section == [self.tableViewSections indexOfObject:@"Next Entry"]) {
		
			UITableViewCell *guidelineNextEntryCell		= [tableView dequeueReusableCellWithIdentifier:guidelineNextEntryCellIdentifier];
			
			UILabel *timeLabel							= (UILabel *)[guidelineNextEntryCell viewWithTag:10];
			UILabel *guidelineLabel						= (UILabel *)[guidelineNextEntryCell viewWithTag:11];

		
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
				timeLabel.text							= [NSString stringWithFormat:@"%@%@", timeEntryTextPrefix, self.nextEntry.timeScheduled.time];
				guidelineLabel.text						= self.nextEntry.advice.name;
				
				[self resizeHeightToFitForLabel:guidelineLabel
									 labelWidth:GUIDELINE_LABEL_WIDTH];

				guidelineNextEntryCell.selectionStyle	= UITableViewCellSelectionStyleBlue;
				guidelineNextEntryCell.accessoryType	= UITableViewCellAccessoryDisclosureIndicator;
			} else {
				timeLabel.text							= timeEntryTextPrefix;
				guidelineLabel.text						= @"You've made entries for all 6 guidelines. Be happy over what you've done well to day, and regret the mistaken actions.";
				
				[self resizeHeightToFitForLabel:guidelineLabel
									 labelWidth:GUIDELINE_LABEL_WIDTH];
				
				guidelineNextEntryCell.selectionStyle	= UITableViewCellSelectionStyleNone;
				guidelineNextEntryCell.accessoryType	= UITableViewCellAccessoryNone;
				
				//	guidelineNextEntryCell.hidden	= YES;
			}
		
			return guidelineNextEntryCell;
		
	} else if (indexPath.section == [self.tableViewSections indexOfObject:@"Remaining Scheduled Entries"]) {
	
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

	} else if (indexPath.section == [self.tableViewSections indexOfObject:@"Updated Entries"]) {

			if (self.showUpdatedEntries && indexPath.row > 0) {
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
			} else {
				UITableViewCell *summaryOrSetupCell		= [tableView dequeueReusableCellWithIdentifier:summaryOrSetupCellIdentifier];
			
				summaryOrSetupCell.textLabel.text		= @"Guidelines with Entries";
				summaryOrSetupCell.detailTextLabel.text	= [NSString stringWithFormat:@"%i", [self.updatedEntries count]];
				
				if (self.showUpdatedEntries) {
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
					LESixOfDay *firstGuidelineOfDay			= [[self.thisDay getTheSixSorted] objectAtIndex:0];
					NSInteger countOfEntriesCompleted		= [[self.thisDay getTheSixThatHaveUserEntriesSorted] count];
					//NSInteger hourInterval					= countOfEntriesCompleted * 2;
					NSDate *wakeUpAt						= [self.nextEntry.timeScheduled dateByAddingTimeInterval:-2*(1+countOfEntriesCompleted)*60*60];	// this will need to be fixed
					summaryOrSetupCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", wakeUpAt.time];
					summaryOrSetupCell.detailTextLabel.tag	= 10001;
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
				} else if (indexPath.row < 6) {
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


#pragma mark - Managing the Start of the Day
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

-(void)cancelAllRemainingNotifications
{
	UIApplication *STPapp				= [UIApplication sharedApplication];
	STPapp.applicationIconBadgeNumber	= 0;
	[STPapp cancelAllLocalNotifications];
}

- (IBAction)doneAction:(id)sender
{
	
	self.thisDay.startHour				= [NSNumber numberWithInt:[self.pickerView.date hour]];
	self.thisDay.startMinute			= [NSNumber numberWithInt:[self.pickerView.date minute]];
	[self cancelAllRemainingNotifications];
	
	// Reset scheduled times for log entries
	NSArray *allRemainingEntries		= [self.thisDay getTheSixWithoutUserEntriesSorted];
	NSInteger countOfCompletedEntries	= [[self.thisDay getTheSixThatHaveUserEntriesSorted] count];
	
	for (LESixOfDay *remainingEntry in allRemainingEntries) {
		[remainingEntry resetScheduledTimeAtHourInterval:countOfCompletedEntries + [allRemainingEntries indexOfObject:remainingEntry] + 1
											   startHour:[self.thisDay.startHour intValue]
											 startMinute:[self.thisDay.startMinute intValue]];
		
		[self addNotification:remainingEntry];
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
	wakeUpTimeTextLabel.text		= [self.pickerView.date time]; //  [self.dateFormatter stringFromDate:self.pickerView.date];
	
	[TestFlight passCheckpoint:@"RESET WAKEUP TIME"];

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
		
		STSetsOfAdviceTVC *tradtionsTVC	= segue.destinationViewController;
		tradtionsTVC.managedObjectContext		= self.managedObjectContext;
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
