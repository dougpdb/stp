
//
//  STAdviceEntryTVC.m
//  Six Times Path
//
//  Created by Doug on 8/7/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "STLogEntrySixOfDayTVC.h"
#import "LESixOfDay+ST.h"
#import "Day+ST.h"
#import "Advice.h"
#import "ActionTaken+ST.h"
#import "ToDo+ST.h"
#import "NSDate+ST.h"
#import "NSDate+ES.h"
#import "TestFlight.h"
#import "STNotificationController.h"

#import "BSKeyboardControls.h"



//#import "STLogEntryTimedCell.h"
//#import "STLogEntryBestWorstOrToDoTextEntryCell.h"

#define OVERVIEW_SECTION_NUMBER	0
#define BEST_SECTION_NUMBER		1
#define WORST_SECTION_NUMBER	2
#define TO_DO_SECTION_NUMBER	3

#define TAG_PREFIX_UITEXTVIEW	100

#define CELL_CONTENT_WIDTH				283.0f
#define CELL_CONTENT_VERTICAL_MARGIN	4.0f
#define CELL_CONTENT_LEFT_MARGIN		8.0f
#define FONT_SIZE						15.0f

#define GUIDELINE_LABEL_WIDTH	276



@interface STLogEntrySixOfDayTVC ()

@property (nonatomic, strong) BSKeyboardControls *keyboardControls;

@property (nonatomic, strong) NSString *mostRecentlySavedPositiveActionTakenDescription;
@property (nonatomic, strong) NSString *mostRecentlySavedNegativeActionTakenDescription;
@property (nonatomic, strong) NSString *updatedPositiveActionTakenDescription;
@property (nonatomic, strong) NSString *updatedNegativeActionTakenDescription;
@property (nonatomic, strong) NSString *updatedToDoText;

@property (nonatomic, strong) STNotificationController *notificationController;


@end

@implementation STLogEntrySixOfDayTVC



#pragma mark - Lifecycle


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.showHints	= YES;
	self.debug		= YES;
	
	self.notificationController			= [STNotificationController new];
	
	/*	There should only be one postive and one negative action associated with the log entry type SixOfDay
		Therefore, get the set of actions (there should only be one in the set at most) for each type of action
		and assign the ActionTaken objects from that set and assign to the properties aPostiveActionTaken and aNegativeActionTaken
	 */
	NSSet *setOfPositiveActionsTaken						= self.leSixOfDay.getPositiveActionsTaken;
	self.aPositiveActionTaken								= [setOfPositiveActionsTaken anyObject];
	self.mostRecentlySavedPositiveActionTakenDescription	= (self.aPositiveActionTaken) ? self.aPositiveActionTaken.text : @"";
	self.updatedPositiveActionTakenDescription				= self.mostRecentlySavedPositiveActionTakenDescription;

	NSSet *setOfNegativeActionsTaken						= self.leSixOfDay.getNegativeActionsTaken;
	self.aNegativeActionTaken								= [setOfNegativeActionsTaken anyObject];
	self.mostRecentlySavedNegativeActionTakenDescription	= (self.aNegativeActionTaken) ? self.aNegativeActionTaken.text : @"";
	self.updatedNegativeActionTakenDescription				= self.mostRecentlySavedNegativeActionTakenDescription;

	if (self.leSixOfDay.timeLastUpdated) {
		self.guidelineTime.text	= [NSString stringWithFormat:@"Updated %@", self.leSixOfDay.timeLastUpdated.time];
		self.guidelineTime.font	= [UIFont italicSystemFontOfSize:13.0];
	} else {
		NSString *timeEntryTextPrefix;
		
		if ([self.leSixOfDay.dayOfSix.getTheSixWithoutUserEntriesSorted count] < 6) {
			timeEntryTextPrefix	= @"Next Entry - ";
		} else if ([self.leSixOfDay.dayOfSix.getTheSixWithoutUserEntriesSorted count] == 6) {
			timeEntryTextPrefix	= @"First Entry - ";
		} else {
			timeEntryTextPrefix	= @"Last Entry - ";
		}
		self.guidelineTime.text	= [NSString stringWithFormat:@"%@%@", timeEntryTextPrefix, self.leSixOfDay.timeScheduled.time];
	}
	
	self.guidelineText.text				= self.leSixOfDay.advice.name;
	self.positiveActionTextView.text	= self.updatedPositiveActionTakenDescription;
	self.negativeActionTextView.text	= self.updatedNegativeActionTakenDescription;
	
	[self resizeHeightToFitForLabel:self.guidelineText labelWidth:GUIDELINE_LABEL_WIDTH];
	
	NSArray *fields						= @[self.positiveActionTextView, self.negativeActionTextView];
    
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    [self.keyboardControls setDelegate:self];
	
	self.navigationController.title		= self.leSixOfDay.advice.name;		// not working for some reason.
	
	self.textExpander = [[SMTEDelegateController alloc] init];
	[self.positiveActionTextView setDelegate:self.textExpander];
	[self.negativeActionTextView setDelegate:self.textExpander];
	[self.textExpander setNextDelegate:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:@"UIApplicationWillEnterForegroundNotification" object:nil];
}

- (void)willEnterForeground:(NSNotification*)notification {
	[self.textExpander willEnterForeground];
}


-(void)viewWillDisappear:(BOOL)animated
{
	[self saveEntry];
}

- (void)viewDidUnload
{
	[self setPositiveActionTextView:nil];
	[self setNegativeActionTextView:nil];
	[self setGuidelineTime:nil];
	[self setGuidelineText:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view configure

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;		// 3 for Name of Guideline and Best and Worst, 4 for To Do
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if (section == 2)
		return @"Reflect and the ethical guideline and how you've acted and spoken on the past 24 or 48 hours.\n\nEnter a short, simple, and specific description of a recent postive action(+). Do the same with a recent negative action (-).";
	else
		return nil;
}

#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) {
		case 1:
			[(UILabel *)[tableView viewWithTag:101] becomeFirstResponder];
			break;
		case 2:
			[(UILabel *)[tableView viewWithTag:102] becomeFirstResponder];
			break;
			
		default:
			break;
	}

}


#pragma mark - Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.keyboardControls setActiveField:textField];
	[self.tableView scrollRectToVisible:textField.frame animated:YES];
}


#pragma mark - Text View Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.keyboardControls setActiveField:textView];
}

-(void)textViewDidChange:(UITextView *)textView
{
	switch (textView.tag) {
		case TAG_PREFIX_UITEXTVIEW + BEST_SECTION_NUMBER:
			self.updatedPositiveActionTakenDescription	= textView.text;
			break;
		case TAG_PREFIX_UITEXTVIEW + WORST_SECTION_NUMBER:
			self.updatedNegativeActionTakenDescription	= textView.text;
			break;
		case TAG_PREFIX_UITEXTVIEW + TO_DO_SECTION_NUMBER:
			self.updatedToDoText						= textView.text;
			break;
		default:
			break;
	}
}


#pragma mark - Keyboard Controls Delegate

- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction
{
    UIView *view = keyboardControls.activeField.superview.superview;
    [self.tableView scrollRectToVisible:view.frame animated:YES];
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls
{
	[keyboardControls.activeField resignFirstResponder];
}


#pragma mark - TableView Resizing

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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UILabel *guidelineLabel			= [UILabel new];
	guidelineLabel.lineBreakMode	= NSLineBreakByWordWrapping;
	if (indexPath.section == 0) {
		
		guidelineLabel.font				= [UIFont boldSystemFontOfSize:17];
		
		guidelineLabel.text				= self.leSixOfDay.advice.name;
		
		CGFloat guidelineLabelHeight	= [self heightForLabel:guidelineLabel withText:guidelineLabel.text labelWidth:GUIDELINE_LABEL_WIDTH];
		
		return 36 + guidelineLabelHeight + 8;		// change for landscape orientation?
		
	} else {
		
		return 71;
		
	}

}

#pragma mark - Save

- (IBAction)greatHighwayExplorerFeedback:(id)sender {
	[TestFlight openFeedbackView];
}

-(void)saveEntry {
	if ([self.mostRecentlySavedPositiveActionTakenDescription isEqualToString:[self.updatedPositiveActionTakenDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]] &&
		[self.mostRecentlySavedNegativeActionTakenDescription isEqualToString:[self.updatedNegativeActionTakenDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]) {
		// Do nothing, becausethe descriptions haven't changed
		[TestFlight passCheckpoint:@"LEAVE LOG ENTRY WITHOUT SAVING"];

	} else {
		BOOL entryHasBeenPreviouslyUpdated	= [self.leSixOfDay.timeLastUpdated isKindOfClass:[NSDate class]];
		
		// Add or update objects
		if (self.aPositiveActionTaken) {
			[self.aPositiveActionTaken updateText:self.updatedPositiveActionTakenDescription
										andRating:1];
			[TestFlight passCheckpoint:@"LOG ENTRY + UPDATED"];
		} else {
			[ActionTaken actionTakenWithText:self.updatedPositiveActionTakenDescription
								   isPositive:YES
								   withRating:1
								  forLogEntry:self.leSixOfDay
					   inManagedObjectContext:self.managedObjectContext];
			self.leSixOfDay.timeFirstUpdated	= [NSDate date];
			[TestFlight passCheckpoint:@"LOG ENTRY + ADDED"];
		}
		
		if (self.aNegativeActionTaken) {
			[self.aNegativeActionTaken updateText:self.updatedNegativeActionTakenDescription
										andRating:1];
			[TestFlight passCheckpoint:@"LOG ENTRY - UPDATED"];
		} else {
			[ActionTaken actionTakenWithText:self.updatedNegativeActionTakenDescription
								  isPositive:NO
								  withRating:1
								 forLogEntry:self.leSixOfDay
					  inManagedObjectContext:self.managedObjectContext];
			[TestFlight passCheckpoint:@"LOG ENTRY - ADDED"];
		}
		
	/*
			if (self.leSixOfDay.toDo) {
			[self.leSixOfDay.toDo updateText:self.updatedToDoText
						   andDueDateAndTime:[NSDate dateWithTimeIntervalSinceNow:3600]];
		} else {
			ToDo *aToDo							= [ToDo toDoWithText:self.updatedToDoText
												withDueDateAndTime:[NSDate dateWithTimeIntervalSinceNow:3600]
													   forLogEntry:self.leSixOfDay
											inManagedObjectContext:self.managedObjectContext];
						}
	*/
			
		if (!entryHasBeenPreviouslyUpdated){
			
			NSDate *now													= [NSDate date];
			NSArray *allRemainingEntriesWithMostRecentlyUpdatedEntry	= [self.leSixOfDay.dayOfSix getTheSixWithoutUserEntriesSorted];
			NSInteger indexOfMostRecentlyUpdatedEntry					= [allRemainingEntriesWithMostRecentlyUpdatedEntry indexOfObject:self.leSixOfDay];
						
			NSInteger countOfCompletedEntries							= 6 - [allRemainingEntriesWithMostRecentlyUpdatedEntry count];
			
			[self.notificationController cancelAllNotifications];
						
			for (LESixOfDay *remainingEntry in allRemainingEntriesWithMostRecentlyUpdatedEntry) {
				NSInteger indexOfRemainingEntry							= [allRemainingEntriesWithMostRecentlyUpdatedEntry indexOfObject:remainingEntry];
				
				if (indexOfRemainingEntry < indexOfMostRecentlyUpdatedEntry) {
					NSInteger currentScheduledTimeHourInterval			= countOfCompletedEntries + indexOfRemainingEntry + 1;
					NSInteger newScheduledTimeHourInterval				= currentScheduledTimeHourInterval;

					[remainingEntry resetScheduledTimeAtHourInterval:newScheduledTimeHourInterval];
				}
			}
		}
		
		[self.leSixOfDay setTimeUpdatedToNow];
		
		if (!entryHasBeenPreviouslyUpdated)
			[self.notificationController addNotifications:[self.leSixOfDay.dayOfSix getTheSixWithoutUserEntriesSorted]];
				
		// save to store!
		NSError *error;
		if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			*/
			NSLog(@"Error occured when attempting to save. Error and userInfo: %@, %@", error, [error userInfo]);
		}
		[TestFlight passCheckpoint:@"LOG ENTRY SAVED"];

	}
}

#pragma mark - Using a Storyboard

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	// Get the index path of the currently selected row
	//	NSIndexPath *indexPath	= [self.tableView indexPathForSelectedRow];
	
	NSLog(@"Segue identifier: %@", [segue identifier]);
}
@end
