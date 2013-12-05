//
//  STPreviousDayTVC.m
//  Six Times Path
//
//  Created by Doug on 1/14/13.
//  Copyright (c) 2013 A Great Highway. All rights reserved.
//

#import "STPreviousDayTVC.h"
#import "Day+ST.h"
#import "LESixOfDay+ST.h"
#import "NSDate+ST.h"
#import "STLogEntrySixOfDayTVC.h"
#import "Advice.h"
#import "TestFlight.h"

#define OUT_OF_RANGE	10000
#define GUIDELINE_LABEL_WIDTH	264
#define ACTION_LABEL_WIDTH		245

//NSString *kNextEntry					= @"Next Entry";
//NSString *kWelcomeIntroduction			= @"Welcome Introduction";
//NSString *kNoSetsOfGuidelinesSelected	= @"No Sets of Guidelines Selected";
//NSString *kAllOtherEntries				= @"All Other Entries";
//NSString *kRemainingScheduledEntries	= @"Remaining Scheduled Entries";
//NSString *kUpdatedEntries				= @"Updated Entries";
//NSString *kSetupForDay					= @"Setup for Day";
//NSString *kPreviousDays					= @"Previous Days";
static NSInteger kFontSizeGuidelineOther	= 16;
static NSString *kFontNameGuideline			= @"Palatino";
static NSString *kAllOtherEntries		= @"All Other Entries";


@interface STPreviousDayTVC ()

@property (nonatomic, retain) IBOutlet UIBarButtonItem *feedbackButton;

- (IBAction)greatHighwayExplorerFeedback:(id)sender;



@end

@implementation STPreviousDayTVC

@synthesize tableViewSections	= _tableViewSections;

#pragma mark - init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



#pragma mark - Getters and Setters

-(NSMutableArray *)tableViewSections
{	
	if (_tableViewSections == nil) {
		NSMutableArray *tmpSectionArray	= [NSMutableArray arrayWithObjects:kAllOtherEntries,
																		   nil];
		
//		if (self.countOfTheSixWithoutUserEntries == 0)
//			[tmpSectionArray removeObjectIdenticalTo:@"Remaining Scheduled Entries"];
//		else if (self.countOfTheSixWithoutUserEntries == 6)
//			[tmpSectionArray removeObjectIdenticalTo:@"Updated Entries"];
		
		_tableViewSections	= tmpSectionArray;
	}
	
	return _tableViewSections;
}


#pragma mark - View Loading and Appearing

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	self.countOfTheSixWithoutUserEntries	= OUT_OF_RANGE;
//	NSArray *allRemainingEntries			= [self.thisDay getTheSixWithoutUserEntriesSorted];
//	NSLog(@"There are %i entries remaining.", [allRemainingEntries count]);
//	
//	NSRange rangeRemainingScheduledEntries;
//	rangeRemainingScheduledEntries.location	= 1;
//	
//	rangeRemainingScheduledEntries.length	= ([[self.thisDay getTheSixWithoutUserEntriesSorted] count] == 0) ? 0 : [allRemainingEntries count] - 1;
//	
//	if ([allRemainingEntries count] > 0) {
//		self.nextEntry						= [allRemainingEntries objectAtIndex:0];
//	}
//	
//	if ([[self.thisDay getTheSixWithoutUserEntriesSorted] count] == 0) {
//		NSLog(@"There are 0 entries.");
//		self.remainingScheduledEntries		= allRemainingEntries;
//	} else {
//		self.remainingScheduledEntries		= [allRemainingEntries subarrayWithRange:rangeRemainingScheduledEntries];
//	}
	
	self.remainingScheduledEntries			= [self.thisDay getTheSixWithoutUserEntriesSorted];
	self.updatedEntries						= [self.thisDay getTheSixThatHaveUserEntriesSorted];

//	self.showRemainingScheduledEntries		= YES;
//	self.showUpdatedEntries					= YES;
	self.showAllEntries						= YES;
	
	self.navigationItem.rightBarButtonItem	= self.feedbackButton;

}

-(void)viewWillAppear:(BOOL)animated
{
	self.title		= self.thisDay.date.shortWeekdayAndDate;
}

-(void)viewWillDisappear:(BOOL)animated
{
//	self.showUpdatedEntries				= NO;
//	self.showRemainingScheduledEntries	= NO;
	self.showAllEntries					= NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View Structure



#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *guidelineOtherEntryCellIdentifier		= @"GuidelineOtherEntryCell";
	static NSString *guidelineSummaryEntryCellIdentifier	= @"GuidelineSummaryEntryCell";
	
	UITableViewCell *guidelineCell;
	if (indexPath.row < [self.updatedEntries count])
	{
		guidelineCell					= [tableView dequeueReusableCellWithIdentifier:guidelineSummaryEntryCellIdentifier];
		UILabel *timeLabel				= (UILabel *)[guidelineCell viewWithTag:10];
		UILabel *guidelineLabel			= (UILabel *)[guidelineCell viewWithTag:11];
		UILabel *positiveIconLabel		= (UILabel *)[guidelineCell viewWithTag:15];
		UILabel *negativeIconLabel		= (UILabel *)[guidelineCell viewWithTag:16];
		UILabel *positiveActionLabel	= (UILabel *)[guidelineCell viewWithTag:20];
		UILabel *negativeActionLabel	= (UILabel *)[guidelineCell viewWithTag:21];
		
		guidelineLabel.font				= [UIFont fontWithName:kFontNameGuideline
												 size:kFontSizeGuidelineOther];
		
		LESixOfDay *updatedEntry		= [self.updatedEntries objectAtIndex:indexPath.row];
		
		timeLabel.text					= [NSString stringWithFormat:@"Updated %@", updatedEntry.timeLastUpdated.time];
		guidelineLabel.text				= updatedEntry.advice.name;
		positiveActionLabel.text		= [[updatedEntry.getPositiveActionsTaken anyObject] valueForKey:@"text"];
		negativeActionLabel.text		= [[updatedEntry.getNegativeActionsTaken anyObject] valueForKey:@"text"];
		
		positiveActionLabel.hidden		= ([positiveActionLabel.text isEqualToString:@""]);
		positiveIconLabel.hidden		= ([positiveActionLabel.text isEqualToString:@""]);
		
		negativeActionLabel.hidden		= ([negativeActionLabel.text isEqualToString:@""]);
		negativeIconLabel.hidden		= ([negativeActionLabel.text isEqualToString:@""]);
		
		
		[self resizeHeightToFitForLabel:guidelineLabel
							 labelWidth:GUIDELINE_LABEL_WIDTH];
		
		return guidelineCell;
	}
	else 
	{
		guidelineCell					= [tableView dequeueReusableCellWithIdentifier:guidelineOtherEntryCellIdentifier];
		UILabel *timeLabel				= (UILabel *)[guidelineCell viewWithTag:10];
		UILabel *guidelineLabel			= (UILabel *)[guidelineCell viewWithTag:11];
		
		guidelineLabel.font				= [UIFont fontWithName:kFontNameGuideline
												 size:kFontSizeGuidelineOther];
		
		LESixOfDay *scheduledEntry		= [self.remainingScheduledEntries objectAtIndex:indexPath.row];
		
		timeLabel.text					= [NSString stringWithFormat:@"%@", scheduledEntry.timeScheduled.time];
		guidelineLabel.text				= scheduledEntry.advice.name;
		
		[self resizeHeightToFitForLabel:guidelineLabel
							 labelWidth:GUIDELINE_LABEL_WIDTH];
		
	}

	return guidelineCell;

	//	static NSString *summaryOrSetupCellIdentifier			= @"SummaryOrSetupCell";
	
//		if (indexPath.row < [self.updatedEntries count])
//		{
//			UITableViewCell *guidelineCell	= [tableView dequeueReusableCellWithIdentifier:guidelineOtherEntryCellIdentifier];
//			UILabel *timeLabel				= (UILabel *)[guidelineCell viewWithTag:10];
//			UILabel *guidelineLabel			= (UILabel *)[guidelineCell viewWithTag:11];
//			
////			LESixOfDay *scheduledEntry		= [self.remainingScheduledEntries objectAtIndex:indexPath.row];
//			
//			timeLabel.text					= [NSString stringWithFormat:@"Scheduled - %@", scheduledEntry.timeScheduled.time];
//			guidelineLabel.text				= scheduledEntry.advice.name;
//			
//			[self resizeHeightToFitForLabel:guidelineLabel
//								 labelWidth:GUIDELINE_LABEL_WIDTH];
//			
//			return guidelineCell;
//		}
//		else
//		{
//			UITableViewCell *guidelineSummaryEntryCell	= [tableView dequeueReusableCellWithIdentifier:guidelineSummaryEntryCellIdentifier];
//			UILabel *timeLabel							= (UILabel *)[guidelineSummaryEntryCell viewWithTag:10];
//			UILabel *guidelineLabel						= (UILabel *)[guidelineSummaryEntryCell viewWithTag:11];
//			UILabel *positiveIconLabel					= (UILabel *)[guidelineSummaryEntryCell viewWithTag:15];
//			UILabel *negativeIconLabel					= (UILabel *)[guidelineSummaryEntryCell viewWithTag:16];
//			UILabel *positiveActionLabel				= (UILabel *)[guidelineSummaryEntryCell viewWithTag:20];
//			UILabel *negativeActionLabel				= (UILabel *)[guidelineSummaryEntryCell viewWithTag:21];
//			
//			LESixOfDay *updatedEntry					= [self.updatedEntries objectAtIndex:indexPath.row - 1];		// -1 to account for "heading" row
//			
//			timeLabel.text								= [NSString stringWithFormat:@"Updated %@", updatedEntry.timeLastUpdated.time];
//			guidelineLabel.text							= updatedEntry.advice.name;
//			positiveActionLabel.text					= [[updatedEntry.getPositiveActionsTaken anyObject] valueForKey:@"text"];
//			negativeActionLabel.text					= [[updatedEntry.getNegativeActionsTaken anyObject] valueForKey:@"text"];
//			
//			[self resizeHeightToFitForLabel:guidelineLabel labelWidth:GUIDELINE_LABEL_WIDTH];
//			
//			CGFloat	guidelineLabelHeight				= [self heightForLabel:guidelineLabel withText:guidelineLabel.text labelWidth:GUIDELINE_LABEL_WIDTH];
//			
//			CGRect positiveIconLabelFrame				= positiveIconLabel.frame;
//			CGRect negativeIconLabelFrame				= negativeIconLabel.frame;
//			CGRect positiveActionLabelFrame				= positiveActionLabel.frame;
//			CGRect negativeActionLabelFrame				= negativeActionLabel.frame;
//			positiveIconLabelFrame.origin.y				= 30 + guidelineLabelHeight + 5;
//			negativeIconLabelFrame.origin.y				= 30 + guidelineLabelHeight + 31;
//			positiveActionLabelFrame.origin.y			= 30 + guidelineLabelHeight + 10;
//			negativeActionLabelFrame.origin.y			= 30 + guidelineLabelHeight + 35;
//			positiveIconLabel.frame						= positiveIconLabelFrame;
//			negativeIconLabel.frame						= negativeIconLabelFrame;
//			positiveActionLabel.frame					= positiveActionLabelFrame;
//			negativeActionLabel.frame					= negativeActionLabelFrame;
//			
//			return guidelineSummaryEntryCell;
//		} else {
//			UITableViewCell *summaryOrSetupCell		= [tableView dequeueReusableCellWithIdentifier:summaryOrSetupCellIdentifier];
//			
//			summaryOrSetupCell.textLabel.text		= @"Guidelines with Entries";
//			summaryOrSetupCell.detailTextLabel.text	= [NSString stringWithFormat:@"%i", [self.updatedEntries count]];
//			
//			if (self.showAllEntries)
//			{
//				summaryOrSetupCell.selectionStyle	= UITableViewCellSelectionStyleNone;
//				summaryOrSetupCell.accessoryType	= UITableViewCellAccessoryNone;
//			}
//			else
//			{
//				summaryOrSetupCell.selectionStyle	= UITableViewCellSelectionStyleBlue;
//				summaryOrSetupCell.accessoryType	= UITableViewCellAccessoryDisclosureIndicator;
//			}
//			
//			return summaryOrSetupCell;
//		}
//		
//	}
//	return nil;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self performSegueWithIdentifier:@"Guideline Entry" sender:self];
}


#pragma mark - UI Interactions

- (IBAction)greatHighwayExplorerFeedback:(id)sender {
	[TestFlight openFeedbackView];
}



- (void)viewDidUnload {
    [super viewDidUnload];
}

@end
