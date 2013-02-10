//
//  STTraditionsFollowedTVC.m
//  Six Times Path
//
//  Created by ICE - Doug on 6/28/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "STSetsOfAdviceTVC.h"
#import "STSetOfAdviceTVC.h"
#import "SpiritualTradtion.h"
#import "TestFlight.h"
#import "SetOfAdvice.h"

@interface STSetsOfAdviceTVC ()
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property BOOL isFilteredForFollowingSetsOfAdvice;

@property (nonatomic) NSArray *allSetsOfAdvice;
@property (nonatomic) NSMutableArray *selectedSetsOfAdvice;
@property (nonatomic) NSArray *followingSetsOfAdvice;

@end

@implementation STSetsOfAdviceTVC



#pragma mark - View loading and appearing

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self setupAllSetsOfAdviceFetchedResultsController];
	self.allSetsOfAdvice		= self.fetchedResultsController.fetchedObjects;
	
	NSPredicate *predicate		= [NSPredicate predicateWithFormat:@"self.orderNumberInFollowedSets > 0"];
	self.followingSetsOfAdvice	= [self.allSetsOfAdvice filteredArrayUsingPredicate:predicate];
	
	[self initSetOfAdviceSegmentedControlFilter];
	[self setViewFollowingSetsOfAdviceButtons];
	
	[self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.selectedSetsOfAdvice	= nil;
	self.allSetsOfAdvice		= nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	self.selectedSetsOfAdvice	= [[NSMutableArray alloc] init];
	//	[self updateSelectedSetsOfAdvice];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Core Data Setup
-(void)setupAllSetsOfAdviceFetchedResultsController
{
	NSString *entityName			= @"SetOfAdvice";
	NSFetchRequest *request			= [NSFetchRequest fetchRequestWithEntityName:entityName];
	request.sortDescriptors			= @[[NSSortDescriptor sortDescriptorWithKey:@"practicedWithinTradition.name"
																ascending:YES
																 selector:@selector(localizedCaseInsensitiveCompare:)],
							   [NSSortDescriptor sortDescriptorWithKey:@"name"
															 ascending:YES
															  selector:@selector(localizedCaseInsensitiveCompare:)]];
	self.fetchedResultsController	= [[NSFetchedResultsController alloc] initWithFetchRequest:request
																		managedObjectContext:self.managedObjectContext
																		  sectionNameKeyPath:nil
																				   cacheName:nil];
}


#pragma mark - Navigation Item Buttons and Actions

-(void)setViewFollowingSetsOfAdviceButtons
{
	self.navigationItem.leftBarButtonItem	= [[UIBarButtonItem alloc] initWithTitle:@"Done"
																			 style:UIBarButtonItemStyleBordered
																			target:self
																			action:@selector(returnToDay:)];
	self.navigationItem.rightBarButtonItem	= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
																						   target:self
																						   action:@selector(editFollowingSetsOfGuidelines:)];
	
}

-(void)setEditFollowingSetsOfAdviceButtons
{
	self.navigationItem.leftBarButtonItem	= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																						  target:self
																						  action:@selector(addSetsOfGuidelinesToFollowing:)];
	self.navigationItem.rightBarButtonItem	= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																						   target:self
																						   action:@selector(endEditFollowingSetsOfGuidelines:)];
}

-(void)setViewAllSetsOfAdviceButtons
{
	self.navigationItem.leftBarButtonItem	= [[UIBarButtonItem alloc] initWithTitle:@"Done"
																			 style:UIBarButtonItemStyleBordered
																			target:self
																			action:@selector(returnToDay:)];
	self.navigationItem.rightBarButtonItem	= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																						  target:self
																						  action:@selector(addNewSetOfGuidelines:)];
	
}

-(void)setEditAllSetsOfAdviceButtons
{
	
}

-(void)returnToDay:(id)sender
{
	[self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)editFollowingSetsOfGuidelines:(id)sender
{
	[self setEditFollowingSetsOfAdviceButtons];
}

-(void)addSetsOfGuidelinesToFollowing:(id)sender
{
	
}

-(void)endEditFollowingSetsOfGuidelines:(id)sender
{
	[self setViewFollowingSetsOfAdviceButtons];
}



#pragma mark - Segmented Control Filter

-(void)initSetOfAdviceSegmentedControlFilter
{
	NSArray *buttonNames	= @[@"Following",@"All"];
	UISegmentedControl *segmentedControl	= [[UISegmentedControl alloc] initWithItems:buttonNames];
	segmentedControl.segmentedControlStyle	= UISegmentedControlStyleBar;
	segmentedControl.selectedSegmentIndex	= 0;
	self.isFilteredForFollowingSetsOfAdvice	= YES;
	[segmentedControl addTarget:self
						 action:@selector(setSetOfAdviceViewFilter:)
			   forControlEvents:UIControlEventValueChanged];
	
	self.navigationItem.titleView			= segmentedControl;
}

-(void)setSetOfAdviceViewFilter:(UISegmentedControl *)segmentedControl
{
	if (segmentedControl.selectedSegmentIndex == 0) {
		self.isFilteredForFollowingSetsOfAdvice	= YES;
		[self setViewFollowingSetsOfAdviceButtons];
	} else {
		self.isFilteredForFollowingSetsOfAdvice = NO;
		[self setViewAllSetsOfAdviceButtons];
	}

	[self.tableView reloadData];
}


#pragma mark - UI Interactions

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"addFollowingSetsOfGuidelines"]) {
		 
	} else {		
		NSIndexPath *indexPath					= [self.tableView indexPathForSelectedRow];
		
		STSetOfAdviceTVC *setOfAdviceTVC		= segue.destinationViewController;
		
		setOfAdviceTVC.managedObjectContext		= self.managedObjectContext;
		
		if (self.isFilteredForFollowingSetsOfAdvice)
			setOfAdviceTVC.selectedSetOfAdvice	= [self.followingSetsOfAdvice objectAtIndex:indexPath.row];
		else
			setOfAdviceTVC.selectedSetOfAdvice	= [self.allSetsOfAdvice objectAtIndex:indexPath.row];
	}
}


#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (self.isFilteredForFollowingSetsOfAdvice)
		return [self.followingSetsOfAdvice count];
	else
		return [self.allSetsOfAdvice count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SetOfAdvice	*setOfAdvice;
	static NSString *CellIdentifier = @"setOfAdviceName";
    UITableViewCell *cell			= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
       
	if (self.isFilteredForFollowingSetsOfAdvice)
		setOfAdvice					= [self.followingSetsOfAdvice objectAtIndex:indexPath.row];
	else
		setOfAdvice					= [self.allSetsOfAdvice objectAtIndex:indexPath.row];

    cell.textLabel.text				= setOfAdvice.name;
	    
    return cell;
}




#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
//    UITableViewCell *thisCell = [tableView cellForRowAtIndexPath:indexPath];
//	
//	NSLog(@"text of cell: %@", thisCell.textLabel.text);
//    if (thisCell.accessoryType == UITableViewCellAccessoryNone) {
//        thisCell.accessoryType = UITableViewCellAccessoryCheckmark;
//		
//		for (SetOfAdvice *setOfAdvice in self.allSetsOfAdvice) {
//			if ([thisCell.textLabel.text isEqualToString:setOfAdvice.name]) {
//				setOfAdvice.orderNumberInFollowedSets	= [NSNumber numberWithInt:[self.selectedSetsOfAdvice count] + 1];
//				break;
//			}
//		}		
//    } else {
//    	thisCell.accessoryType = UITableViewCellAccessoryNone;
//		
//		for (SetOfAdvice *setOfAdvice in self.allSetsOfAdvice) {
//			if ([thisCell.textLabel.text isEqualToString:setOfAdvice.name]) {
//				setOfAdvice.orderNumberInFollowedSets	= [NSNumber numberWithInt:0];
//				break;
//			}
//		}
//    }
//	
//	[self updateSelectedSetsOfAdvice];
}

- (IBAction)greatHIghwayExplorerFeedback:(id)sender {
	[TestFlight openFeedbackView];
}
@end
