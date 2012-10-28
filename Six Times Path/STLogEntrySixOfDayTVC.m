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
#import "NSDate+ST.h"

#import "STLogEntryTimedCell.h"
#import "STLogEntryBestWorstOrToDoTextEntryCell.h"

#define OVERVIEW_SECTION_NUMBER	0
#define BEST_SECTION_NUMBER		1
#define WORST_SECTION_NUMBER	2
#define TO_DO_SECTION_NUMBER	3

#define CELL_CONTENT_WIDTH				283.0f
#define CELL_CONTENT_VERTICAL_MARGIN	4.0f
#define CELL_CONTENT_LEFT_MARGIN		8.0f
#define FONT_SIZE						15.0f



@interface STLogEntrySixOfDayTVC ()

@property (nonatomic, strong) NSString *mostRecentlySavedPositiveActionTakenDescription;
@property (nonatomic, strong) NSString *mostRecentlySavedNegativeActionTakenDescription;
@property (nonatomic, strong) NSString *updatedPositiveActionTakenDescription;
@property (nonatomic, strong) NSString *updatedNegativeActionTakenDescription;

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
	NSSet *setOfPositiveActionsTaken	= self.leSixOfDay.getPositiveActionsTaken;
	if (self.debug)
		NSLog(@"The number of positive actions taken for this log entry is %i", [setOfPositiveActionsTaken count]);
	self.aPositiveActionTaken			= [setOfPositiveActionsTaken anyObject];
	self.mostRecentlySavedPositiveActionTakenDescription	= (self.aPositiveActionTaken) ? self.aPositiveActionTaken.text : @"No positive action has been added yet.";
	self.updatedPositiveActionTakenDescription				= self.mostRecentlySavedPositiveActionTakenDescription;

	NSSet *setOfNegativeActionsTaken	= self.leSixOfDay.getNegativeActionsTaken;
	if (self.debug)
		NSLog(@"The number of positive actions taken for this log entry is %i", [setOfNegativeActionsTaken count]);
	self.aNegativeActionTaken			= [setOfNegativeActionsTaken anyObject];
	self.mostRecentlySavedNegativeActionTakenDescription	= (self.aNegativeActionTaken) ? self.aNegativeActionTaken.text : @"No negative action has been added yet.";
	self.updatedNegativeActionTakenDescription				= self.mostRecentlySavedNegativeActionTakenDescription;
	
	[self.leSixOfDay logValuesOfLogEntry];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
		// Six of Day setup
		// Show: the guideline being evaluated,
		// time - scheduled, originally created, lastUpdated
		// 
		
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
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 3;
}
//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
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
				return @"";
				break;
		}
	}
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *overviewCellIdentifier		= @"logEntryAdvice";
	static NSString *bestOrWorstCellIdentifier	= @"bestOrWorstCell";
	static NSString *toDoCellIdentifier			= @"toDoCell";
	static NSString *ratingCellIdentifier		= @"ratingFocusCell";
	
	STLogEntryTimedCell *overviewCell							= (STLogEntryTimedCell *)[tableView dequeueReusableCellWithIdentifier:overviewCellIdentifier];
	STLogEntryBestWorstOrToDoTextEntryCell *bestWorstOrToDoCell	= (STLogEntryBestWorstOrToDoTextEntryCell *)[tableView dequeueReusableCellWithIdentifier:bestOrWorstCellIdentifier];
	


	switch (indexPath.section) {
		case OVERVIEW_SECTION_NUMBER:
		{
			// Init the cell...
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
			
			// Get data for the cell
			LESixOfDay *sixOfDayEntry	= self.leSixOfDay;
			
			// Configure the cell...
			NSString *labelText			= sixOfDayEntry.advice.name;
			
			CGSize constraint			= CGSizeMake(CELL_CONTENT_WIDTH, 20000.0f);
			
			CGSize labelSize			= [labelText sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE+3] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
			
			// Effectively, the MIN() will make sure that the height of the label will either 1 or 2 lines.
			// We add 10 to the height to give it some padding within the cell, to make sure that the tails of g and y are not clipped.
			CGFloat labelHeight			= labelSize.height;		// MIN(labelSize.height, 37.0f);
			
			overviewCell.guidelineLabel.text	= labelText;
			overviewCell.guidelineLabel.font	= [UIFont systemFontOfSize:FONT_SIZE+2];
			
			if (self.debug)
				NSLog(@"The height of the guideline text and the label is %g and %g", labelHeight, CGRectGetHeight(overviewCell.guidelineLabel.bounds));
			
			
			if (sixOfDayEntry.timeLastUpdated) {
				overviewCell.timeLabel.text	= [NSString stringWithFormat:@"Updated %@", sixOfDayEntry.timeLastUpdated.time];
				overviewCell.timeLabel.font	= [UIFont italicSystemFontOfSize:13.0];
			} else {
				overviewCell.timeLabel.text	= sixOfDayEntry.timeScheduled.time;
			}
			
			overviewCell.guidelineLabel.frame	= CGRectMake(CELL_CONTENT_LEFT_MARGIN, CELL_CONTENT_VERTICAL_MARGIN, CELL_CONTENT_WIDTH, labelHeight);
			overviewCell.timeLabel.frame		= CGRectMake(CELL_CONTENT_LEFT_MARGIN, CELL_CONTENT_VERTICAL_MARGIN + labelHeight - 2, CELL_CONTENT_WIDTH, CGRectGetHeight(overviewCell.timeLabel.frame));
			
			//	Highlighting used only to see relative positioning of UI Label within the cell
			//			[theSixEntryCell layoutSubviews];
			
			return overviewCell;
			
			
			break;
		}
		case BEST_SECTION_NUMBER:
		{
			// Init the cell...
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
			
			//
			bestWorstOrToDoCell.textInput.delegate		= self;
            bestWorstOrToDoCell.textInput.returnKeyType = UIReturnKeyDone;
			bestWorstOrToDoCell.textInput.tag			= 10 + BEST_SECTION_NUMBER;
			if (self.debug)
				NSLog(@"The tag number for the textInput is %i.", bestWorstOrToDoCell.textInput.tag);

			// set placeholder text
			bestWorstOrToDoCell.textInput.text		= self.updatedPositiveActionTakenDescription;
			// set updated status
			
			return bestWorstOrToDoCell;
		}
		case WORST_SECTION_NUMBER:
		{
			// Init the cell...
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
			
			//
			bestWorstOrToDoCell.textInput.delegate		= self;
            bestWorstOrToDoCell.textInput.returnKeyType = UIReturnKeyDone;
			bestWorstOrToDoCell.textInput.tag			= 10 + WORST_SECTION_NUMBER;
			if (self.debug)
				NSLog(@"The tag number for the textInput is %i.", bestWorstOrToDoCell.textInput.tag);
			
			// set placeholder text
			bestWorstOrToDoCell.textInput.text		= self.updatedNegativeActionTakenDescription;
			// set updated status
			
			return bestWorstOrToDoCell;
			
		}
/*
		case SPECIAL_FOCUS_SECTION_NUMBER:
		{
			// Init the cell...
			if (specialFocusCell == nil) {
				specialFocusCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:specialFocusCellIdentifier];
			}
			
			// Get data for the cell
			LESpecialFocus *specialFocus	= self.specialFocus;
			
			// Configure the cell...
			theSixEntryCell.textLabel.text	= specialFocus.advice.name;
			
			return specialFocusCell;
			
			break;
		}
		case WORST_SECTION_NUMBER:
		{
			// For Best of Day Entries that have already been made...
			if (indexPath.row < [self.bestOfDaySorted count]) {
				// Init the cell...
				if (bestOrWorstOfDayCell == nil) {
					NSArray *topLevelObjectsBest= [[NSBundle mainBundle]
												   loadNibNamed:@"LogEntryBestOrWorstOfDayCell"
												   owner:self
												   options:nil];
					for (id currentObject in topLevelObjectsBest) {
						if ([currentObject isKindOfClass:[UITableViewCell class]]) {
							bestOrWorstOfDayCell		= (STLogEntryBestOrWorstOfDayCell *)currentObject;
							break;
						}
					}
				}
				
				// Get data for the cell
				LEWorstOfDay *worstOfDayEntry	= [self.worstOfDaySorted objectAtIndex:indexPath.row];
				
				// Configure the cell...
				bestOrWorstOfDayCell.textLabel.text	= worstOfDayEntry.action.description;
				
				return bestOrWorstOfDayCell;
			} else {
				// Init the cell...
				if (addCell == nil) {
					NSArray *topLevelObjectsAdd	= [[NSBundle mainBundle]
												   loadNibNamed:@"LogEntryAddCell"
												   owner:self
												   options:nil];
					for (id currentObject in topLevelObjectsAdd) {
						if ([currentObject isKindOfClass:[UITableViewCell class]]) {
							addCell				= (STLogEntryAddCell *)currentObject;
							break;
						}
					}
				}
				addCell.addLabel.text	= @"Add a Worst of Day.";
				return addCell;
			}
			break;
		}
*/
		default:
			break;
	}

//	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
//
//    // Configure the cell...
//	
//	if (indexPath.section == 0 && indexPath.row == 0) {
//		cell.textLabel.text = self.leSixOfDay.advice.name;
//		NSLog(@"in first section and the first row");
//	}
//    
//    return cell;
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


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}



#pragma mark - Text View
-(void)textViewDidBeginEditing:(UITextView *)textView
{
	
}

//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//	
//    if([text isEqualToString:@"\n"]) {
//        [textView resignFirstResponder];
//        return NO;
//    }
//	
//    return YES;
//}

- (BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound ) {
        return YES;
    }
	
	// update variables
	switch (txtView.tag) {
		case 10+BEST_SECTION_NUMBER:
			self.updatedPositiveActionTakenDescription	= txtView.text;
			break;
		case 10+WORST_SECTION_NUMBER:
			self.updatedNegativeActionTakenDescription	= txtView.text;
			break;
			
		default:
			break;
	}
	
    [txtView resignFirstResponder];
    return NO;
}

- (IBAction)saveEntry:(id)sender {
	NSLog(@"updatedPositive is [%@].", self.updatedPositiveActionTakenDescription);
	NSLog(@"updatedNegative is [%@].", self.updatedNegativeActionTakenDescription);
	
	// update existing Positive and Negative actions, or add them as necessary
	if (self.aPositiveActionTaken) {
		[self.aPositiveActionTaken updateText:self.updatedPositiveActionTakenDescription
									andRating:1];
	} else {
		ActionTaken *aPositiveActionTaken	= [ActionTaken actionTakenWithText:self.updatedPositiveActionTakenDescription
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
		ActionTaken *aNegativeActionTaken	= [ActionTaken actionTakenWithText:self.updatedNegativeActionTakenDescription
																  isPositive:NO
																  withRating:1
																 forLogEntry:self.leSixOfDay
													  inManagedObjectContext:self.managedObjectContext];
		// there isn't a need to set timeFirstUpdated, as it has already been set for the positive
	}
	
	// set updated time
	self.leSixOfDay.timeLastUpdated	= [NSDate date];
	
	// save to store!
	
}
@end
