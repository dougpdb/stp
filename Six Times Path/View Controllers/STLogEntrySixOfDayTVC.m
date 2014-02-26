
//
//  STAdviceEntryTVC.m
//  Six Times Path
//
//  Created by Doug on 8/7/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "STLogEntrySixOfDayTVC.h"
#import "GHUIPlaceHolderTextView.h"


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


#define OVERVIEW_SECTION_NUMBER			0
#define BEST_AND_WORST_SECTION_NUMBER	1
#define BEST_SECTION_NUMBER				1
#define WORST_SECTION_NUMBER			2
#define TO_DO_SECTION_NUMBER			3

#define TAG_PREFIX_UITEXTVIEW	100

#define CELL_CONTENT_WIDTH				283.0f
#define CELL_CONTENT_VERTICAL_MARGIN	4.0f
#define CELL_CONTENT_LEFT_MARGIN		8.0f
#define FONT_SIZE						15.0f

#define GUIDELINE_LABEL_WIDTH	290

#define kFontSize	15.0
#define kTextViewWidth 268.0

static NSString *kFontNameGuideline			= @"Palatino";
static NSInteger kFontSizeGuidelineNext		= 22;
static NSString *kTrailingGhostTextToPreventDelayedTextViewResizing	= @"a few";

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

	// Set up Guideline Cell
	self.guidelineText.text				= self.leSixOfDay.advice.name;
	[self resizeHeightToFitForLabel:self.guidelineText labelWidth:GUIDELINE_LABEL_WIDTH];

	if (self.leSixOfDay.timeLastUpdated)
	{
		self.guidelineTime.text	= [NSString stringWithFormat:@"Updated %@", self.leSixOfDay.timeLastUpdated.time];
		self.guidelineTime.font	= [UIFont italicSystemFontOfSize:13.0];
	}
	else
	{
		NSString *timeEntryTextPrefix	= @"";
		self.guidelineTime.text	= [NSString stringWithFormat:@"%@%@", timeEntryTextPrefix, self.leSixOfDay.timeScheduled.time];
	}
	
	// Set delegate for text views
	self.positiveActionTextView.delegate = self;
	self.negativeActionTextView.delegate = self;
	
	// set placeholder label text
	self.positiveActionTextView.placeholder	= @"Add a recent positive action";
	self.negativeActionTextView.placeholder = @"Add a recent negative action";
	
    self.positiveActionTextView.text		= self.updatedPositiveActionTakenDescription;
	self.negativeActionTextView.text		= self.updatedNegativeActionTakenDescription;

	[self.positiveActionTextView updateShouldShowPlaceholder];
	[self.negativeActionTextView updateShouldShowPlaceholder];
	
	NSArray *fields						= @[self.positiveActionTextView, self.negativeActionTextView];
    
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    [self.keyboardControls setDelegate:self];
	
	self.navigationController.title		= self.leSixOfDay.advice.name;		// not working for some reason.
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


#pragma mark - Dictation



#pragma mark - Table view configure

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 0.1f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 3;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if (section == 0)
		return @"Reflect on how you've acted recently.\n\nEnter short, simple, and specific descriptions of recent postive (+) and negative (-) actions.";
	else
		return nil;
}

- (CGFloat)heightForTextView:(UITextView*)textView containingString:(NSString*)string
{
    
	string	= (string.length > 0) ? [NSString stringWithFormat:@"%@%@",string,kTrailingGhostTextToPreventDelayedTextViewResizing] : @"ipsum for height";
    
	float widthOfTextView = textView.contentSize.width;
	
	UIFont *font						= textView.font;
	NSAttributedString *attributedText	= [ [NSAttributedString alloc]
										   initWithString:string
										   attributes: @{NSFontAttributeName: font}
										   ];
	CGRect rect							= [attributedText boundingRectWithSize:(CGSize){widthOfTextView, CGFLOAT_MAX}
													 options:NSStringDrawingUsesLineFragmentOrigin
													 context:nil];
	CGSize size							= rect.size;
	CGFloat height						= ceilf(size.height);
	return height;
}


#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0)
	{
		switch (indexPath.row)
		{
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

	GHUIPlaceHolderTextView *placeholderTextView	= (GHUIPlaceHolderTextView *)textView;
	
	[placeholderTextView updateShouldShowPlaceholder];
	
	if ([placeholderTextView isPlaceholderShowing])
		[placeholderTextView moveCursorToBeginningOfContent];
}

-(void)textViewDidChange:(UITextView *)textView
{
	GHUIPlaceHolderTextView *placeholderTextView	= (GHUIPlaceHolderTextView *)textView;
	if ([placeholderTextView isPlaceholderShowing])
	{
		[placeholderTextView moveCursorToBeginningOfContent];
		[placeholderTextView updateShouldShowPlaceholder];
		NSLog(@"Placeholder is showing.");
	}
	else
	{
		switch (textView.tag)
		{
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
		[placeholderTextView updateShouldShowPlaceholder];
		
		[self.tableView beginUpdates];
		[self.tableView endUpdates];
	}
}


-(void)textViewDidEndEditing:(UITextView *)textView {
	GHUIPlaceHolderTextView *placeholderTextView	= (GHUIPlaceHolderTextView *)textView;
	[placeholderTextView updateShouldShowPlaceholder];
	
	[self.tableView beginUpdates];
    [self.tableView endUpdates];
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
	if (text != nil)
	{
		UIFont *font						= label.font;
		NSAttributedString *attributedText	= [ [NSAttributedString alloc]
											   initWithString:text
											   attributes: @{NSFontAttributeName: font}
											   ];
		CGRect rect							= [attributedText boundingRectWithSize:(CGSize){labelWidth, CGFLOAT_MAX}
														 options:NSStringDrawingUsesLineFragmentOrigin
														 context:nil];
		CGSize size							= rect.size;
		CGFloat height						= ceilf(size.height);
		return height;
	}
	else
		return 0;
	
}

-(void)resizeHeightToFitForLabel:(UILabel *)label labelWidth:(CGFloat)labelWidth
{
	CGRect newFrame			= label.frame;
	newFrame.size.height	= [self heightForLabel:label
									   withText:label.text
									 labelWidth:labelWidth];
	label.frame				= newFrame;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	if (indexPath.row == 0)
	{
		UILabel *guidelineLabel			= [UILabel new];
		guidelineLabel.lineBreakMode	= NSLineBreakByWordWrapping;
		
		guidelineLabel.font				= [UIFont fontWithName:kFontNameGuideline
												 size:kFontSizeGuidelineNext];
		guidelineLabel.text				= self.leSixOfDay.advice.name;
		
		CGFloat guidelineLabelHeight	= [self heightForLabel:guidelineLabel
												   withText:guidelineLabel.text
												 labelWidth:GUIDELINE_LABEL_WIDTH];
		
		return guidelineLabelHeight + 46;		// change for landscape orientation?
	}
	else
	{
		UITextView *actionTextView;
		NSString *descriptionModel;
		
		
		if (indexPath.row == 1)
		{
			actionTextView		= self.positiveActionTextView;
			descriptionModel	= self.updatedPositiveActionTakenDescription;
		}
		else if (indexPath.row == 2)
		{
			actionTextView		= self.negativeActionTextView;
			descriptionModel	= self.updatedNegativeActionTakenDescription;
		}
		else
		{
			return self.tableView.rowHeight;
		}
		
		float height = [self heightForTextView:actionTextView
							  containingString:descriptionModel] + 8; // a little extra padding is needed
		return height;
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
		
		if (!entryHasBeenPreviouslyUpdated){
			
			// NSDate *now													= [NSDate date];
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
	NSLog(@"Segue identifier: %@", [segue identifier]);
}
@end
