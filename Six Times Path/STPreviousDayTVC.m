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


@interface STPreviousDayTVC ()

@end

@implementation STPreviousDayTVC

@synthesize thisDay					= _thisDay;
@synthesize tableViewSections		= _tableViewSections;

@synthesize editingMode				= _editingMode;


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
		NSMutableArray *tmpSectionArray	= [NSMutableArray arrayWithObjects:@"Updated Entries",
																		   @"Remaining Scheduled Entries",
																		   nil];
		
		if (self.countOfTheSixWithoutUserEntries == 0)
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

	self.showRemainingScheduledEntries	= YES;
	self.showUpdatedEntries				= YES;
}

-(void)viewWillAppear:(BOOL)animated
{
	self.title		= self.thisDay.date.shortWeekdayAndDate;
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
	static NSString *summaryOrSetupCellIdentifier			= @"SummaryOrSetupCell";
	
    if (indexPath.section == [self.tableViewSections indexOfObject:@"Remaining Scheduled Entries"]) {
		
		if (self.showRemainingScheduledEntries && indexPath.row > 0) {
			UITableViewCell *guidelineOtherEntryCell	= [tableView dequeueReusableCellWithIdentifier:guidelineOtherEntryCellIdentifier];
			
			LESixOfDay *scheduledEntry					= [self.remainingScheduledEntries objectAtIndex:indexPath.row - 1];		// -1 to account for "heading" row
			NSString *timeEntryText						= [NSString stringWithFormat:@"Scheduled - %@", scheduledEntry.timeScheduled.time];
			NSString *guidelineText						= scheduledEntry.advice.name;
			
			[[guidelineOtherEntryCell viewWithTag:10] setValue:timeEntryText forKey:@"text"];
			[[guidelineOtherEntryCell viewWithTag:11] setValue:guidelineText forKey:@"text"];
			
			return guidelineOtherEntryCell;
		} else {
			UITableViewCell *summaryOrSetupCell			= [tableView dequeueReusableCellWithIdentifier:summaryOrSetupCellIdentifier];
			
			summaryOrSetupCell.textLabel.text			= @"Remaining Guidelines";
			summaryOrSetupCell.detailTextLabel.text		= [NSString stringWithFormat:@"%i", [self.remainingScheduledEntries count]];
			
			summaryOrSetupCell.selectionStyle			= UITableViewCellSelectionStyleNone;
			summaryOrSetupCell.accessoryType			= UITableViewCellAccessoryNone;
			
			return summaryOrSetupCell;
		}
		
	} else if (indexPath.section == [self.tableViewSections indexOfObject:@"Updated Entries"]) {
		
		if (self.showUpdatedEntries && indexPath.row > 0) {
			UITableViewCell *guidelineSummaryEntryCell	= [tableView dequeueReusableCellWithIdentifier:guidelineSummaryEntryCellIdentifier];
			
			LESixOfDay *updatedEntry					= [self.updatedEntries objectAtIndex:indexPath.row - 1];		// -1 to account for "heading" row
			NSString *timeEntryText						= [NSString stringWithFormat:@"Updated %@", updatedEntry.timeLastUpdated.time];
			NSString *guidelineText						= updatedEntry.advice.name;
			NSString *positiveAction					= [[updatedEntry.getPositiveActionsTaken anyObject] valueForKey:@"text"];
			NSString *negativeAction					= [[updatedEntry.getNegativeActionsTaken anyObject] valueForKey:@"text"];
			
			[[guidelineSummaryEntryCell viewWithTag:10] setValue:timeEntryText forKey:@"text"];
			[[guidelineSummaryEntryCell viewWithTag:11] setValue:guidelineText forKey:@"text"];
			[[guidelineSummaryEntryCell viewWithTag:20] setValue:positiveAction forKey:@"text"];
			[[guidelineSummaryEntryCell viewWithTag:21] setValue:negativeAction forKey:@"text"];
			
			return guidelineSummaryEntryCell;
		} else {
			UITableViewCell *summaryOrSetupCell			= [tableView dequeueReusableCellWithIdentifier:summaryOrSetupCellIdentifier];
			
			summaryOrSetupCell.textLabel.text			= @"Guidelines with Entries";
			summaryOrSetupCell.detailTextLabel.text		= [NSString stringWithFormat:@"%i", [self.updatedEntries count]];
			
			summaryOrSetupCell.selectionStyle			= UITableViewCellSelectionStyleNone;
			summaryOrSetupCell.accessoryType			= UITableViewCellAccessoryNone;
			
			return summaryOrSetupCell;
		}
		
	}
	return nil;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//switch (indexPath.section) {
    if (indexPath.section == [self.tableViewSections indexOfObject:@"Remaining Scheduled Entries"]) {
		if (indexPath.row > 0)
			[self performSegueWithIdentifier:@"Guideline Entry" sender:self];
	} else if (indexPath.section == [self.tableViewSections indexOfObject:@"Updated Entries"]) {
		if (indexPath.row > 0)
			[self performSegueWithIdentifier:@"Guideline Entry" sender:self];
	}
}


#pragma mark - UI Interactions



- (void)viewDidUnload {
    [super viewDidUnload];
}

@end
