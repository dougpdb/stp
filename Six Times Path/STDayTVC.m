//
//  STDayTVC.m
//  Six Times Path
//
//  Created by Doug on 8/7/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "STDayTVC.h"
#import "Advice.h"
#import "Day+ST.h"
#import "NSDate+ST.h"
#import "LESixOfDay.h"
#import "LESpecialFocus.h"
#import "LEBestOfDay.h"
#import "LEWorstOfDay.h"
#import "STLogEntryTimedCell.h"
#import "STLogEntryAddCell.h"
#import "STLogEntrySpecialFocusCell.h"
#import "STLogEntryBestOrWorstOfDayCell.h"
#import "STLogEntrySixOfDayTVC.h"
#import "STLogEntrySpecialFocusTVC.h"
#import "STLogEntryBestOfDayTVC.h"
#import "STLogEntryWorstOfDayTVC.h"


#define SIX_SECTION_NUMBER				0
#define SPECIAL_FOCUS_SECTION_NUMBER	1
#define BEST_SECTION_NUMBER				2
#define WORST_SECTION_NUMBER			3

#define CELL_CONTENT_WIDTH				283.0f
#define CELL_CONTENT_VERTICAL_MARGIN	4.0f
#define CELL_CONTENT_LEFT_MARGIN		8.0f
#define FONT_SIZE						15.0f


@interface STDayTVC ()



@end

@implementation STDayTVC

@synthesize managedObjectContext		= _managedObjectContext;
@synthesize fetchedResultsController	= _fetchedResultsController;

@synthesize selectedDay					= _selectedDay;
@synthesize theSixSorted				= _theSixSorted;
@synthesize bestOfDaySorted				= _bestOfDaySorted;
@synthesize worstOfDaySorted			= _worstOfDaySorted;
@synthesize specialFocus				= _specialFocus;

@synthesize isTipToBeShown				= _isTipToBeShown;
@synthesize debug						= _debug;

#pragma mark - init

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View Loading and Appearing

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.debug	= YES;
		
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	self.theSixSorted		= [self.selectedDay getTheSixSorted];
	if (self.debug)
		NSLog(@"The six have been sorted and set.");
	self.specialFocus		= [self.selectedDay specialFocus];
	if (self.debug)
		NSLog(@"Special focus has been set.");
	self.bestOfDaySorted	= [self.selectedDay getBestOfDaySorted];
	if (self.debug)
		NSLog(@"The best have been sorted and set.");
	self.worstOfDaySorted	= [self.selectedDay getWorstOfDaySorted];
	if (self.debug)
		NSLog(@"The worst have been sorted and set.");
	
	self.title				= self.selectedDay.date.date;
	self.isTipToBeShown		= YES;
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

#pragma mark - Table View Structure


 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // number of rows depends upon which section
	switch (section) {
		
		case 0:			// The Six
			return 6;
			break;
		
		case 1:			// Special Focus
			return 1;
			break;
			
		case 2:			// Best of Day
			return [self.bestOfDaySorted count] + 1;
			break;
			
		case 3:			// Worst of Day
			return [self.worstOfDaySorted count] + 1;
			
		default:
			break;
	}
	return 0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case 0:
			return @"The Six";
			break;
			
		case 1:
			return @"Special Focus";
			break;
			
		case 2:
			return @"Best of Day";
			break;
			
		case 3:
			return @"Worst of Day";
			break;
			
		default:
			break;
	}
	return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if (self.isTipToBeShown) {
		switch (section) {
			case 0:
				return @"Every 2 hours, review how you have been following one of these 6 guidelines.";
				break;
				
			case 1:
				return @"Any time during the day, review how you have been doing with this guideline that you have chosen to given extra attention.";
				break;
				
			case 2:
				return @"At the end of the day, list the 3 best things that you did today.";
				break;
				
			case 3:
				return @"At the end of the day, list the 3 worst things that you did today.";
				break;
				
			default:
				break;
		}
	}
	return nil;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *sixEntryCellIdentifier		= @"theSixCell";
	static NSString *specialFocusCellIdentifier	= @"specialFocusCell";
	static NSString *bestOrWorstCellIdentifier	= @"bestOrWorstOfDayCell";
	static NSString *addCellIdentifier			= @"addCell";
	
	STLogEntryTimedCell *theSixEntryCell					= (STLogEntryTimedCell *)[tableView dequeueReusableCellWithIdentifier:sixEntryCellIdentifier];
	STLogEntrySpecialFocusCell *specialFocusCell			= (STLogEntrySpecialFocusCell *)[tableView dequeueReusableCellWithIdentifier:specialFocusCellIdentifier];
	STLogEntryBestOrWorstOfDayCell *bestOrWorstOfDayCell	= (STLogEntryBestOrWorstOfDayCell *)[tableView dequeueReusableCellWithIdentifier:bestOrWorstCellIdentifier];
	STLogEntryAddCell *addCell								= (STLogEntryAddCell *)[tableView dequeueReusableCellWithIdentifier:addCellIdentifier];
	

	if (self.debug)
		NSLog(@"Index path [Section, Row]: %d, %d", indexPath.section, indexPath.row);
	
    switch (indexPath.section) {
		case SIX_SECTION_NUMBER:
		{
			// Init the cell...
			if (theSixEntryCell == nil) {
				NSArray *topLevelObjects	= [[NSBundle mainBundle]
											   loadNibNamed:@"Log Entry - Timed"
											   owner:self
											   options:nil];
				for (id currentObject in topLevelObjects) {
					if ([currentObject isKindOfClass:[UITableViewCell class]]) {
						theSixEntryCell		= (STLogEntryTimedCell *)currentObject;
						break;
					}
				}
			}
			
			// Get data for the cell
			LESixOfDay *sixOfDayEntry	= [self.theSixSorted objectAtIndex:[indexPath row]];

			// Configure the cell...
			NSString *labelText			= sixOfDayEntry.advice.name;
			
			CGSize constraint			= CGSizeMake(CELL_CONTENT_WIDTH, 20000.0f);
			
			CGSize labelSize			= [labelText sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
			
			// Effectively, the MIN() will make sure that the height of the label will either 1 or 2 lines.
			// We add 10 to the height to give it some padding within the cell, to make sure that the tails of g and y are not clipped.
			CGFloat labelHeight			= MIN(labelSize.height, 37.0f);
			
			theSixEntryCell.guidelineLabel.text	= labelText;

			if (self.debug)
				NSLog(@"The height of the guideline text and the label is %g and %g", labelHeight, CGRectGetHeight(theSixEntryCell.guidelineLabel.bounds));
			
			
			if (sixOfDayEntry.timeLastUpdated) {
				theSixEntryCell.timeLabel.text	= [NSString stringWithFormat:@"Updated %@", sixOfDayEntry.timeLastUpdated.time];
				theSixEntryCell.timeLabel.font	= [UIFont italicSystemFontOfSize:13.0];
			} else {
				theSixEntryCell.timeLabel.text	= sixOfDayEntry.timeScheduled.time;
			}

			theSixEntryCell.guidelineLabel.frame	= CGRectMake(CELL_CONTENT_LEFT_MARGIN, CELL_CONTENT_VERTICAL_MARGIN, CELL_CONTENT_WIDTH, labelHeight);
			theSixEntryCell.timeLabel.frame			= CGRectMake(CELL_CONTENT_LEFT_MARGIN, CELL_CONTENT_VERTICAL_MARGIN + labelHeight - 2, CELL_CONTENT_WIDTH, CGRectGetHeight(theSixEntryCell.timeLabel.frame));
			
			//	Highlighting used only to see relative positioning of UI Label within the cell 
//			[theSixEntryCell layoutSubviews];

			return theSixEntryCell;
			
			
			break;
		}
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
		case BEST_SECTION_NUMBER:
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
//				LEBestOfDay *bestOfDayEntry		= [self.bestOfDaySorted objectAtIndex:indexPath.row];
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
				addCell.addLabel.text	= @"Add a Best of Day.";
				return addCell;
			}
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
		default:
			break;
	}
	
	
	
	static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) {
		// Get data for the cell
		LESixOfDay *sixOfDayEntry	= [self.theSixSorted objectAtIndex:[indexPath row]];
		
		// Configure the cell...
		NSString *labelText			= sixOfDayEntry.advice.name;
		
		CGSize constraint			= CGSizeMake(CELL_CONTENT_WIDTH, 20000.0f);
		
		CGSize labelSize			= [labelText sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];

		// Effectively, the MIN() will make sure that the height of the label will either 1 or 2 lines.
		// We add 10 to the height to give it some padding within the cell, to make sure that the tails of g and y are not clipped.
		CGFloat labelHeight			= MIN(labelSize.height, 37.0f);
		CGFloat timeLabelHeight		= 21.0;
		
		CGFloat rowHeight			= CELL_CONTENT_VERTICAL_MARGIN + labelHeight + timeLabelHeight + CELL_CONTENT_VERTICAL_MARGIN - 2.;

		if (self.debug)
			NSLog(@"The height of the lable and row [%i, %i] is %g and %g", indexPath.section, indexPath.row, labelHeight, rowHeight);
		return rowHeight;
	} else {
		return 40.0;
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
	
	// Trigger the apporpriate segue
	switch (indexPath.section) {
		case 0:
			[self performSegueWithIdentifier:@"logEntrySixOfDaySegue" sender:self];
			break;
			
		case 1:
			[self performSegueWithIdentifier:@"logEntrySpecialFocusSegue" sender:self];
			break;
			
		case 2:
			[self performSegueWithIdentifier:@"logEntryBestOfDaySegue" sender:self];
			break;
			
		case 3:
			[self performSegueWithIdentifier:@"logEntryWorstOfDaySegue" sender:self];
			break;

		default:
			break;
	}
}


#pragma mark - UI Interactions

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([[segue identifier] isEqualToString:@"logEntrySixOfDaySegue"]) {
		STLogEntrySixOfDayTVC *leSixOfDayTVC	= segue.destinationViewController;

	} else if ([[segue identifier] isEqualToString:@"logEntrySpecialFocusSegue"]) {
		STLogEntrySpecialFocusCell *leSpecialFocusTVC	= segue.destinationViewController;
		
	
	} else if ([[segue identifier] isEqualToString:@"logEntryBestOfDaySegue"]) {
		STLogEntryBestOfDayTVC *leBestOfDayTVC			= segue.destinationViewController;
		

	} else if ([[segue identifier] isEqualToString:@"logEntryWorstOfDaySegue"]) {
		STLogEntryWorstOfDayTVC *leWorstOfDayTVC		= segue.destinationViewController;

	}
}

@end
