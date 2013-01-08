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

#import "STLogEntryTimedCell.h"
#import "STLogEntryBestWorstOrToDoTextEntryCell.h"

#define OVERVIEW_SECTION_NUMBER	0
#define BEST_SECTION_NUMBER		1
#define WORST_SECTION_NUMBER	2
#define TO_DO_SECTION_NUMBER	3

#define TAG_PREFIX_UITEXTVIEW	100

#define CELL_CONTENT_WIDTH				283.0f
#define CELL_CONTENT_VERTICAL_MARGIN	4.0f
#define CELL_CONTENT_LEFT_MARGIN		8.0f
#define FONT_SIZE						15.0f



@interface STLogEntrySixOfDayTVC ()

@property (nonatomic, strong) NSString *mostRecentlySavedPositiveActionTakenDescription;
@property (nonatomic, strong) NSString *mostRecentlySavedNegativeActionTakenDescription;
@property (nonatomic, strong) NSString *updatedPositiveActionTakenDescription;
@property (nonatomic, strong) NSString *updatedNegativeActionTakenDescription;
@property (nonatomic, strong) NSString *updatedToDoText;

-(void)updateTime;

@end

@implementation STLogEntrySixOfDayTVC

@synthesize fetchedResultsController	= _fetchedResultsController;
@synthesize managedObjectContext		= _managedObjectContext;

@synthesize leSixOfDay					= _leSixOfDay;
@synthesize aPositiveActionTaken		= _aPositiveActionTaken;
@synthesize aNegativeActionTaken		= _aNegativeActionTaken;

@synthesize showHints					= _showHints;

@synthesize mostRecentlySavedPositiveActionTakenDescription	= _mostRecentlySavedPositiveActionTakenDescription;
@synthesize mostRecentlySavedNegativeActionTakenDescription	= _mostRecentlySavedNegativeActionTakenDescription;
@synthesize updatedPositiveActionTakenDescription			= _updatedPositiveActionTakenDescription;
@synthesize updatedNegativeActionTakenDescription			= _updatedNegativeActionTakenDescription;
@synthesize updatedToDoText									= _updatedToDoText;


 

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
	
	// There should only be one postive and one negative action associated with the log entry type SixOfDay
	// Therefore, get the set of actions (there should only be one in the set at most) for each type of action
	// and assign the ActionTaken objects from that set and assign to the properties aPostiveActionTaken and aNegativeActionTaken
	NSSet *setOfPositiveActionsTaken						= self.leSixOfDay.getPositiveActionsTaken;
	self.aPositiveActionTaken								= [setOfPositiveActionsTaken anyObject];
	self.mostRecentlySavedPositiveActionTakenDescription	= (self.aPositiveActionTaken) ? self.aPositiveActionTaken.text : @"";
	self.updatedPositiveActionTakenDescription				= self.mostRecentlySavedPositiveActionTakenDescription;

	NSSet *setOfNegativeActionsTaken						= self.leSixOfDay.getNegativeActionsTaken;
	self.aNegativeActionTaken								= [setOfNegativeActionsTaken anyObject];
	self.mostRecentlySavedNegativeActionTakenDescription	= (self.aNegativeActionTaken) ? self.aNegativeActionTaken.text : @"";
	self.updatedNegativeActionTakenDescription				= self.mostRecentlySavedNegativeActionTakenDescription;
	
/*
	// get the updated to
	self.updatedToDoText									= (self.leSixOfDay.toDo) ? self.leSixOfDay.toDo.text : @"";
*/
	
	// for the Console
	[self.leSixOfDay logValuesOfLogEntry];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillDisappear:(BOOL)animated
{
	[self saveEntry];
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

#pragma mark - Table view configure

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;		// 3 for Name of Guideline and Best and Worst, 4 for To Do
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case OVERVIEW_SECTION_NUMBER:
			return @"";
			break;
		case BEST_SECTION_NUMBER:
			return @"+";
			break;
		case WORST_SECTION_NUMBER:
			return @"-";
			break;
		case TO_DO_SECTION_NUMBER:
			return @"To Do";
			break;
			
		default:
			break;
	}
	return @"";
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if (self.showHints) {
		switch (section) {
			case OVERVIEW_SECTION_NUMBER:
				return @"";
				break;
			case BEST_SECTION_NUMBER:
				return @"A recent, specific, positive action that fulfilled this guideline (as closely as possible).";
				break;
			case WORST_SECTION_NUMBER:
				return @"A recent, specific, negative action that did not fulfill this guideline.";
				break;
			case TO_DO_SECTION_NUMBER:
				return @"";
				break;
				
			default:
				break;
		}
	}
	return @"";
}



#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *overviewCellIdentifier		= @"logEntryAdvice";
	static NSString *bestOrWorstCellIdentifier	= @"bestOrWorstCell";
	
	STLogEntryTimedCell *overviewCell							= (STLogEntryTimedCell *)[tableView dequeueReusableCellWithIdentifier:overviewCellIdentifier];
	STLogEntryBestWorstOrToDoTextEntryCell *bestWorstOrToDoCell	= (STLogEntryBestWorstOrToDoTextEntryCell *)[tableView dequeueReusableCellWithIdentifier:bestOrWorstCellIdentifier];
	
	// Init the cells...
	if (overviewCell == nil) {
		NSArray *topLevelObjects	= [[NSBundle mainBundle]
									   loadNibNamed:@"Log Entry - Timed"
									   owner:self
									   options:nil];
		for (id currentObject in topLevelObjects) {
			if ([currentObject isKindOfClass:[UITableViewCell class]]) {
				overviewCell		= (STLogEntryTimedCell *)currentObject;
				break;
			}
		}
	
		// Modify the cell's formatting
		// Possibly move into the subclass as a method?
		overviewCell.accessoryType	= UITableViewCellAccessoryDetailDisclosureButton;

	}
	if (bestWorstOrToDoCell == nil) {
		NSArray *topLevelObjectsBest= [[NSBundle mainBundle]
									   loadNibNamed:@"STLogEntryBestWorstOrToDoTextEntryCell"
									   owner:self
									   options:nil];
		for (id currentObject in topLevelObjectsBest) {
			if ([currentObject isKindOfClass:[UITableViewCell class]]) {
				bestWorstOrToDoCell		= (STLogEntryBestWorstOrToDoTextEntryCell *)currentObject;
				break;
			}
		}
	}


	switch (indexPath.section) {
		case OVERVIEW_SECTION_NUMBER:
		{
			// Get data for the cell
			LESixOfDay *sixOfDayEntry			= self.leSixOfDay;
			
			// Configure the cell...
			NSString *labelText					= sixOfDayEntry.advice.name;
			
			CGSize constraint					= CGSizeMake(CELL_CONTENT_WIDTH, 20000.0f);
			
			CGSize labelSize					= [labelText sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE+3]
													   constrainedToSize:constraint
														   lineBreakMode:UILineBreakModeWordWrap];
			
			// Effectively, the MIN() will make sure that the height of the label will either 1 or 2 lines.
			// We add 10 to the height to give it some padding within the cell, to make sure that the tails of g and y are not clipped.
			CGFloat labelHeight					= labelSize.height;		// MIN(labelSize.height, 37.0f);
			
			overviewCell.guidelineLabel.text	= labelText;
			overviewCell.guidelineLabel.font	= [UIFont systemFontOfSize:FONT_SIZE+2];
			
			if (self.debug)
				NSLog(@"The height of the guideline text and the label is %g and %g", labelHeight, CGRectGetHeight(overviewCell.guidelineLabel.bounds));
			
			
			if (sixOfDayEntry.timeLastUpdated) {
				overviewCell.timeLabel.text		= [NSString stringWithFormat:@"Updated %@", sixOfDayEntry.timeLastUpdated.time];
				overviewCell.timeLabel.font		= [UIFont italicSystemFontOfSize:13.0];
			} else {
				overviewCell.timeLabel.text		= sixOfDayEntry.timeScheduled.time;
			}
			
			overviewCell.guidelineLabel.frame	= CGRectMake(CELL_CONTENT_LEFT_MARGIN,
															 CELL_CONTENT_VERTICAL_MARGIN,
															 CELL_CONTENT_WIDTH,
															 labelHeight);
			overviewCell.timeLabel.frame		= CGRectMake(CELL_CONTENT_LEFT_MARGIN,
															 CELL_CONTENT_VERTICAL_MARGIN + labelHeight - 2,
															 CELL_CONTENT_WIDTH,
															 CGRectGetHeight(overviewCell.timeLabel.frame));
			
			//	Highlighting used only to see relative positioning of UI Label within the cell
			//			[theSixEntryCell layoutSubviews];
			
			return overviewCell;
			
			
			break;
		}
		case BEST_SECTION_NUMBER:
		{			
			bestWorstOrToDoCell.textInput.delegate		= self;
            bestWorstOrToDoCell.textInput.returnKeyType = UIReturnKeyNext;
			bestWorstOrToDoCell.textInput.tag			= TAG_PREFIX_UITEXTVIEW + BEST_SECTION_NUMBER;

			// set placeholder text
			bestWorstOrToDoCell.textInput.text		= self.updatedPositiveActionTakenDescription;
			// set updated status
			
			return bestWorstOrToDoCell;
		}
		case WORST_SECTION_NUMBER:
		{
			bestWorstOrToDoCell.textInput.delegate		= self;
            bestWorstOrToDoCell.textInput.returnKeyType = UIReturnKeyDone;
			bestWorstOrToDoCell.textInput.tag			= TAG_PREFIX_UITEXTVIEW + WORST_SECTION_NUMBER;
			
			// set placeholder text
			bestWorstOrToDoCell.textInput.text		= self.updatedNegativeActionTakenDescription;
			// set updated status
			
			return bestWorstOrToDoCell;
			
		}
		case TO_DO_SECTION_NUMBER:
		{
			bestWorstOrToDoCell.textInput.delegate		= self;
            bestWorstOrToDoCell.textInput.returnKeyType = UIReturnKeyDone;
			bestWorstOrToDoCell.textInput.tag			= TAG_PREFIX_UITEXTVIEW + TO_DO_SECTION_NUMBER;
			if (self.debug)
				NSLog(@"The tag number for the textInput is %i.", bestWorstOrToDoCell.textInput.tag);
			
			// set placeholder text
			bestWorstOrToDoCell.textInput.text		= self.updatedToDoText;
			// set updated status
			
			return bestWorstOrToDoCell;
			
		}

		default:
			break;
	}
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) {
		// Get data for the cell
		LESixOfDay *sixOfDayEntry	= self.leSixOfDay;
		
		// Configure the cell...
		NSString *labelText			= sixOfDayEntry.advice.name;
		
		CGSize constraint			= CGSizeMake(CELL_CONTENT_WIDTH, 20000.0f);
		
		CGSize labelSize			= [labelText sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE+3] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
		
		// Effectively, the MIN() will make sure that the height of the label will either 1 or 2 lines.
		// We add 10 to the height to give it some padding within the cell, to make sure that the tails of g and y are not clipped.
		CGFloat labelHeight			= labelSize.height;		// MIN(labelSize.height, 37.0f);
		CGFloat timeLabelHeight		= 21.0;
		
		CGFloat rowHeight			= CELL_CONTENT_VERTICAL_MARGIN + labelHeight + timeLabelHeight + CELL_CONTENT_VERTICAL_MARGIN - 2.;
		
		if (self.debug)
			NSLog(@"The height of the lable and row [%i, %i] is %g and %g", indexPath.section, indexPath.row, labelHeight, rowHeight);
		return rowHeight;
	} else {
		return 90.0;
	}
}



#pragma mark - Table view delegate



#pragma mark - Text View

- (BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound ) {
        return YES;
    }
	
    [txtView resignFirstResponder];
    return NO;
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
			NSLog(@"updatedToDoText, textView.text: [%@], [%@]", self.updatedToDoText, textView.text);
			break;
		default:
			break;
	}
}

#pragma mark - Save

-(void)saveEntry {
	if ([self.mostRecentlySavedPositiveActionTakenDescription isEqualToString:[self.updatedPositiveActionTakenDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]] &&
		[self.mostRecentlySavedNegativeActionTakenDescription isEqualToString:[self.updatedNegativeActionTakenDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]) {
		// Do nothing, becausethe descriptions haven't changed
	} else {
		// Add or update objects
		if (self.aPositiveActionTaken) {
			[self.aPositiveActionTaken updateText:self.updatedPositiveActionTakenDescription
										andRating:1];
		} else {
			[ActionTaken actionTakenWithText:self.updatedPositiveActionTakenDescription
								   isPositive:YES
								   withRating:1
								  forLogEntry:self.leSixOfDay
					   inManagedObjectContext:self.managedObjectContext];
			self.leSixOfDay.timeFirstUpdated	= [NSDate date];
		}
		
		if (self.aNegativeActionTaken) {
			[self.aNegativeActionTaken updateText:self.updatedNegativeActionTakenDescription
										andRating:1];
		} else {
			[ActionTaken actionTakenWithText:self.updatedNegativeActionTakenDescription
								  isPositive:NO
								  withRating:1
								 forLogEntry:self.leSixOfDay
					  inManagedObjectContext:self.managedObjectContext];
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
			
		self.leSixOfDay.timeLastUpdated	= [NSDate date];
		
		// save to store!
		NSError *error;
		if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			*/
			NSLog(@"Error occured when attempting to save. Error and userInfo: %@, %@", error, [error userInfo]);
		}
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
