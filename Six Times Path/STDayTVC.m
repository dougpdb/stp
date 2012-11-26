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

@property BOOL isOnlyShowingTheSixWithoutUserEntriesSorted;
@property (strong, nonatomic) NSArray *theSixToBeShown;

-(void)determineAndSetTheSixToBeShown;

@end

@implementation STDayTVC

@synthesize managedObjectContext		= _managedObjectContext;
@synthesize fetchedResultsController	= _fetchedResultsController;

@synthesize selectedDay					= _selectedDay;
//@synthesize theSixSorted				= _theSixSorted;
@synthesize bestOfDaySorted				= _bestOfDaySorted;
@synthesize worstOfDaySorted			= _worstOfDaySorted;
@synthesize specialFocus				= _specialFocus;

@synthesize isTipToBeShown				= _isTipToBeShown;
//@synthesize debug						= _debug;

@synthesize isOnlyShowingTheSixWithoutUserEntriesSorted	= _isOnlyShowingTheSixWithoutUserEntriesSorted;
@synthesize theSixToBeShown								= _theSixToBeShown;


#pragma mark - init

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - Getters and Setters

-(void)onlyShowTheSixWithoutUserEntries:(BOOL)onlyShowWithoutUserEntries
{
	NSLog(@"Hey!");
	
	self.isOnlyShowingTheSixWithoutUserEntriesSorted	= onlyShowWithoutUserEntries;

	if (self.isOnlyShowingTheSixWithoutUserEntriesSorted)
		self.theSixToBeShown = [self.selectedDay getTheSixWithoutUserEntriesSorted];
	else
		self.theSixToBeShown = [[self.selectedDay getTheSixWithoutUserEntriesSorted] arrayByAddingObjectsFromArray:[self.selectedDay getTheSixThatHaveUserEntriesSorted]];
	
	NSLog(@"Count of theSixToBeShown: %i", [self.theSixToBeShown count]);
}

#pragma mark - View Loading and Appearing

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.debug	= YES;
			[self onlyShowTheSixWithoutUserEntries:YES];		
		
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
//	self.theSixSorted		= [self.selectedDay getTheSixSorted];
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

-(void)viewWillAppear:(BOOL)animated
{
	// this is to make sure that any Core Data changes on other screens will be reflected
	// in this view as necessary (such as timeUpdated)
			[self onlyShowTheSixWithoutUserEntries:YES];		// this doesn't seem like the best places
	[self.tableView reloadData];
	if (self.debug) {
		NSLog(@"There are %u entries that have been updated.", [[self.selectedDay getTheSixThatHaveUserEntriesSorted] count]);
		NSLog(@"There are %u entries that have not yet been updated.", [self.theSixToBeShown count]);
	}
}


#pragma mark - Table View Structure
 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;		// 1 for only The Six, 2 to include Special focus, 4 to include Best and Worst sections
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // number of rows depends upon which section
	switch (section) {
		
		case SIX_SECTION_NUMBER:			// The Six
		{
			if ([self.theSixToBeShown count] == 6)
				return 6;
			else
				return [self.theSixToBeShown count] + 1;
			break;
			
		}
		
		case SPECIAL_FOCUS_SECTION_NUMBER:			// Special Focus
			return 1;
			break;
			
		case BEST_SECTION_NUMBER:			// Best of Day
			return [self.bestOfDaySorted count] + 1;
			break;
			
		case WORST_SECTION_NUMBER:			// Worst of Day
			return [self.worstOfDaySorted count] + 1;
			
		default:
			break;
	}
	return 0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case SIX_SECTION_NUMBER:
			return @"The Six";
			break;
			
		case SPECIAL_FOCUS_SECTION_NUMBER:
			return @"Special Focus";
			break;
			
		case BEST_SECTION_NUMBER:
			return @"Best of Day";
			break;
			
		case WORST_SECTION_NUMBER:
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
			case SIX_SECTION_NUMBER:
				return @"Every 2 hours, review how you have been following one of these 6 guidelines.";
				break;
				
			case SPECIAL_FOCUS_SECTION_NUMBER:
				return @"Any time during the day, review how you have been doing with this guideline that you have chosen to given extra attention.";
				break;
				
			case BEST_SECTION_NUMBER:
				return @"At the end of the day, list the 3 best things that you did today.";
				break;
				
			case WORST_SECTION_NUMBER:
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
	
	
    switch (indexPath.section) {
		case SIX_SECTION_NUMBER:
		{
			BOOL isAGuideline	= (indexPath.row < [self.theSixToBeShown count]);
			
			// Get data for the cell
			NSLog(@"row is %i", indexPath.row);
			LESixOfDay *sixOfDayEntry	= (isAGuideline) ? [self.theSixToBeShown	objectAtIndex:[indexPath row]] : nil;

			// Configure the cell...
			NSString *labelText			= (isAGuideline) ? sixOfDayEntry.advice.name : [NSString stringWithFormat:@"%i Guidelines Updated", [[self.selectedDay getTheSixThatHaveUserEntriesSorted] count]];
			
			CGSize constraint			= CGSizeMake(CELL_CONTENT_WIDTH, 20000.0f);
			
			CGSize labelSize			= [labelText sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE+1] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];  // Adding +1 to the FONT_SIZE helps to ensure that the last word of a single line entry doesn't get clipped. It is used for sizing puposes only.
			
			// Effectively, the MIN() will make sure that the height of the label will either 1 or 2 lines.
			// We add 10 to the height to give it some padding within the cell, to make sure that the tails of g and y are not clipped.
			CGFloat labelHeight			= MIN(labelSize.height, 37.0f);
			
			theSixEntryCell.guidelineLabel.text	= labelText;

			if (self.debug)
				NSLog(@"The height of the guideline text and the label is %g and %g", labelHeight, CGRectGetHeight(theSixEntryCell.guidelineLabel.bounds));
			
			if (isAGuideline) {				
				if (sixOfDayEntry.timeLastUpdated) {
					theSixEntryCell.timeLabel.text	= [NSString stringWithFormat:@"Updated %@", sixOfDayEntry.timeLastUpdated.time];
					theSixEntryCell.timeLabel.font	= [UIFont italicSystemFontOfSize:13.0];
				} else {
					theSixEntryCell.timeLabel.text	= sixOfDayEntry.timeScheduled.time;
				}
			}

			theSixEntryCell.guidelineLabel.frame	= CGRectMake(CELL_CONTENT_LEFT_MARGIN, CELL_CONTENT_VERTICAL_MARGIN, CELL_CONTENT_WIDTH, labelHeight);

			if (isAGuideline) {
				theSixEntryCell.timeLabel.frame		= CGRectMake(CELL_CONTENT_LEFT_MARGIN, CELL_CONTENT_VERTICAL_MARGIN + labelHeight - 2, CELL_CONTENT_WIDTH, CGRectGetHeight(theSixEntryCell.timeLabel.frame));
			} else
				theSixEntryCell.timeLabel.hidden	= YES;
			
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
	if (indexPath.section == SIX_SECTION_NUMBER) {
		if (indexPath.row < [self.theSixToBeShown count]) {
			// Get data for the cell
			LESixOfDay *sixOfDayEntry	= [self.theSixToBeShown objectAtIndex:[indexPath row]];
			
			// Configure the cell...
			NSString *labelText			= sixOfDayEntry.advice.name;
			
			CGSize constraint			= CGSizeMake(CELL_CONTENT_WIDTH, 20000.0f);
			
			CGSize labelSize			= [labelText sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE+1] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
			
			// Effectively, the MIN() will make sure that the height of the label will either 1 or 2 lines.
			// We add 10 to the height to give it some padding within the cell, to make sure that the tails of g and y are not clipped.
			CGFloat labelHeight			= MIN(labelSize.height, 37.0f);
			CGFloat timeLabelHeight		= (indexPath.row < [self.theSixToBeShown count]) ? 21.0 : 0;
			
			CGFloat rowHeight			= CELL_CONTENT_VERTICAL_MARGIN + labelHeight + timeLabelHeight + CELL_CONTENT_VERTICAL_MARGIN - 2.;
			
			if (self.debug)
				NSLog(@"The height of the lable and row [%i, %i] is %g and %g", indexPath.section, indexPath.row, labelHeight, rowHeight);
			return rowHeight;
		} else {
			return 37.0;
		}
	} else {
		return 40.0;
	}
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Trigger the apporpriate segue
	switch (indexPath.section) {
		case SIX_SECTION_NUMBER:
		{
			BOOL isAGuideline	= (indexPath.row < [self.theSixToBeShown count]);
			if (isAGuideline) {
				[self performSegueWithIdentifier:@"logEntrySixOfDaySegue" sender:self];
			} else {
				[self onlyShowTheSixWithoutUserEntries:NO];
				[self.tableView reloadData];
			}
			break;
			
		}
			
		case SPECIAL_FOCUS_SECTION_NUMBER:
			[self performSegueWithIdentifier:@"logEntrySpecialFocusSegue" sender:self];
			break;
			
		case BEST_SECTION_NUMBER:
			[self performSegueWithIdentifier:@"logEntryBestOfDaySegue" sender:self];
			break;
			
		case WORST_SECTION_NUMBER:
			[self performSegueWithIdentifier:@"logEntryWorstOfDaySegue" sender:self];
			break;

		default:
			break;
	}
}


#pragma mark - UI Interactions

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	// Get the index path of the currently selected row
	NSIndexPath *indexPath	= [self.tableView indexPathForSelectedRow];
	
	if ([[segue identifier] isEqualToString:@"logEntrySixOfDaySegue"]) {
		// Get the destination view controller and...
		STLogEntrySixOfDayTVC *leSixOfDayTVC	= segue.destinationViewController;
		
		// ...pass along the managed object context we're working with.
		leSixOfDayTVC.managedObjectContext		= self.managedObjectContext;
		// Also pass along the selected guideline from the Six of Day section of the table
		leSixOfDayTVC.leSixOfDay				= [self.theSixToBeShown	objectAtIndex:[indexPath row]];

	} else if ([[segue identifier] isEqualToString:@"logEntrySpecialFocusSegue"]) {
		STLogEntrySpecialFocusCell *leSpecialFocusTVC	= segue.destinationViewController;
		
	
	} else if ([[segue identifier] isEqualToString:@"logEntryBestOfDaySegue"]) {
		STLogEntryBestOfDayTVC *leBestOfDayTVC			= segue.destinationViewController;
		

	} else if ([[segue identifier] isEqualToString:@"logEntryWorstOfDaySegue"]) {
		STLogEntryWorstOfDayTVC *leWorstOfDayTVC		= segue.destinationViewController;

	}
}

@end
