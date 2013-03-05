//
//  STTraditionsFollowedTVC.m
//  Six Times Path
//
//  Created by ICE - Doug on 6/28/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "STSetsOfAdviceTVC.h"
#import "STSetOfAdviceTVC.h"
#import "STAddFollowingSetOfAdviceTVC.h"
#import "SpiritualTradtion.h"
#import "TestFlight.h"
#import "SetOfAdvice.h"

@interface STSetsOfAdviceTVC ()
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property BOOL isFilteredForFollowingSetsOfAdvice;

@property (nonatomic) NSArray *allSetsOfAdvice;
@property (nonatomic) NSMutableArray *selectedSetsOfAdvice;
@property (nonatomic) NSArray *followingSetsOfAdvice;
@property (nonatomic) NSArray *notFollowingSetsOfAdvice;

@end

@implementation STSetsOfAdviceTVC



#pragma mark - View loading and appearing

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self setupAllSetsOfAdviceFetchedResultsController];
	self.allSetsOfAdvice		= self.fetchedResultsController.fetchedObjects;
	
	[self refreshFollowingSetsOfAdvice];
	
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

-(void)refreshFollowingSetsOfAdvice
{
	for (SetOfAdvice *setOfAdvice in self.allSetsOfAdvice) {
		NSLog(@"Set of Advice, orderNumberInFollowedSets: %@ [%i]", setOfAdvice.name, [setOfAdvice.orderNumberInFollowedSets intValue]);
	}
	
	NSPredicate *predicate;
	predicate								= [NSPredicate predicateWithFormat:@"self.orderNumberInFollowedSets > 0"];
	NSArray *unsortedfollowingSetsOfAdvice	= [self.allSetsOfAdvice filteredArrayUsingPredicate:predicate];
	NSArray *sortDescriptors				= @[[[NSSortDescriptor alloc] initWithKey:@"orderNumberInFollowedSets" ascending:YES]];
	self.followingSetsOfAdvice				= [unsortedfollowingSetsOfAdvice sortedArrayUsingDescriptors:sortDescriptors];

	predicate								= [NSPredicate predicateWithFormat:@"self.orderNumberInFollowedSets == %@ or self.orderNumberInFollowedSets == 0", [NSNull null]];
	self.notFollowingSetsOfAdvice			= [self.allSetsOfAdvice filteredArrayUsingPredicate:predicate];
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
	self.navigationItem.leftBarButtonItem	= nil;
	self.navigationItem.rightBarButtonItem	= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																						   target:self
																						   action:@selector(endEditFollowingSetsOfGuidelines:)];
	
	[self setSuspendAutomaticTrackingOfChangesInManagedObjectContext:YES];
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
	[self.tableView reloadData];
}

-(void)setEditAllSetsOfAdviceButtons
{
	
}

-(void)returnToDay:(id)sender
{
	[self.navigationController popToRootViewControllerAnimated:YES];
	[self.tableView setEditing:NO animated:YES];
}

//-(void)addSetOfGuidelinesToFollowing:(id)sender
//{
//	UIActionSheet *addSetOfGuidelinesActionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose a Set of Guidelines You Want to Follow."
//																			   delegate:self
//																	  cancelButtonTitle:nil
//																 destructiveButtonTitle:nil
//																	  otherButtonTitles:nil];
//	
//	for (SetOfAdvice *setOfAdvice in self.notFollowingSetsOfAdvice)
//		[addSetOfGuidelinesActionSheet addButtonWithTitle:setOfAdvice.name];
//	
//	[addSetOfGuidelinesActionSheet addButtonWithTitle:@"Cancel"];
//	
//	addSetOfGuidelinesActionSheet.cancelButtonIndex		= [self.notFollowingSetsOfAdvice count];
//	
//    [addSetOfGuidelinesActionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
//
//}



#pragma mark - Editing rows

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.isFilteredForFollowingSetsOfAdvice)
		if (indexPath.row < [self.followingSetsOfAdvice count])
			return UITableViewCellEditingStyleDelete;
		else
			return UITableViewCellEditingStyleInsert;
		else
			if (indexPath.row < [self.allSetsOfAdvice count])
				return UITableViewCellEditingStyleNone;			//	FUTURE: Allow user added sets of guidelines to be deleted
			else
				return UITableViewCellEditingStyleInsert;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleInsert) {
        if (self.isFilteredForFollowingSetsOfAdvice)
			[self addFollowingSetsOfAdvice];
    }
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		if (self.isFilteredForFollowingSetsOfAdvice)
			[self removeFollowingSetsOfAdviceAtIndexPath:indexPath];
	}
	
}

#pragma mark Add Set

-(void)addFollowingSetsOfAdvice
{
	[self performSegueWithIdentifier:@"addFollowingSetsOfGuidelines" sender:self];
}

-(void)addFollowingSetOfAdviceTVC:(STAddFollowingSetOfAdviceTVC *)addFollowingSetOfAdviceTVC didAddSetOfAdvice:(SetOfAdvice *)setOfAdvice
{
	NSInteger lastOrderNumberInFollowedSets		= [[(SetOfAdvice *)[self.followingSetsOfAdvice lastObject] orderNumberInFollowedSets] intValue];
	if (setOfAdvice) {
		setOfAdvice.orderNumberInFollowedSets	= [NSNumber numberWithInt:lastOrderNumberInFollowedSets + 1];
	}
	[self.managedObjectContext save:nil];
	[self refreshFollowingSetsOfAdvice];
	
	for (SetOfAdvice *aSetOfAdvice in self.allSetsOfAdvice) {
		NSLog(@"%i: %@", [aSetOfAdvice.orderNumberInFollowedSets intValue], aSetOfAdvice.name);
	}
	
	NSIndexPath *indexPath						= [NSIndexPath indexPathForRow:[self.followingSetsOfAdvice count]-1 inSection:0];
    UITableViewRowAnimation animationStyle		= UITableViewRowAnimationFade;
	[self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:animationStyle];
}

#pragma mark Remove Set

-(void)removeFollowingSetsOfAdviceAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableArray *tempFollowingSetsOfAdviceArray	= [NSMutableArray arrayWithArray:self.followingSetsOfAdvice];
	
	SetOfAdvice *setOfAdviceToRemove				= [self.followingSetsOfAdvice objectAtIndex:[indexPath indexAtPosition:1]]; // works
	setOfAdviceToRemove.orderNumberInFollowedSets	= 0;
	
	[tempFollowingSetsOfAdviceArray removeObjectIdenticalTo:setOfAdviceToRemove];
	
	for (SetOfAdvice *setOfAdvice in tempFollowingSetsOfAdviceArray) {
		setOfAdvice.orderNumberInFollowedSets		= [NSNumber numberWithInt:[tempFollowingSetsOfAdviceArray indexOfObject:setOfAdvice] + 1];
	}
	
	[self.managedObjectContext save:nil];
	[self refreshFollowingSetsOfAdvice];
	
	UITableViewRowAnimation animationStyle			= UITableViewRowAnimationFade;
	[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animationStyle];
}

#pragma mark Reorder Set

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.isFilteredForFollowingSetsOfAdvice && (indexPath.row < [self.followingSetsOfAdvice count]))
		return YES;
	else
		return NO;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
	NSMutableArray *tempFollowingSetsOfAdviceArray	= [NSMutableArray arrayWithArray:self.followingSetsOfAdvice];
	
	SetOfAdvice *setOfAdviceToMove					= [tempFollowingSetsOfAdviceArray objectAtIndex:sourceIndexPath.row];
	[tempFollowingSetsOfAdviceArray removeObjectAtIndex:sourceIndexPath.row];
	[tempFollowingSetsOfAdviceArray insertObject:setOfAdviceToMove atIndex:destinationIndexPath.row];
	
	[self setSuspendAutomaticTrackingOfChangesInManagedObjectContext:NO];
	for (SetOfAdvice *setOfAdvice in tempFollowingSetsOfAdviceArray) {
		setOfAdvice.orderNumberInFollowedSets		= [NSNumber numberWithInt:[tempFollowingSetsOfAdviceArray indexOfObject:setOfAdvice] + 1];
	}
	[self setSuspendAutomaticTrackingOfChangesInManagedObjectContext:YES];
	[self refreshFollowingSetsOfAdvice];
}


-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
	if (proposedDestinationIndexPath.row >= [self.followingSetsOfAdvice count] - 1)
		return [NSIndexPath indexPathForRow:[self.followingSetsOfAdvice count] - 1 inSection:sourceIndexPath.section];
	else
		return proposedDestinationIndexPath;
}



-(NSMutableArray *)resetOrderingOfFollowedSetsOfAdvice:(NSMutableArray *)setsOfAdvice
{
	// TO DO
	
}



-(void)editFollowingSetsOfGuidelines:(id)sender
{
	[self setEditFollowingSetsOfAdviceButtons];
	[self.tableView setEditing:YES animated:YES];
	[self.tableView reloadData];					// replace this with something more visually elegant, such as inserting last row with animation
}

-(void)endEditFollowingSetsOfGuidelines:(id)sender
{
	[self.managedObjectContext save:nil];
	[self setViewFollowingSetsOfAdviceButtons];
	[self.tableView setEditing:NO animated:YES];
	[self refreshFollowingSetsOfAdvice];
	[self.tableView reloadData];					// replace this with something more visually elegant, such as deleting last row with animation
}

//-(void)setEditing:(BOOL)editing animated:(BOOL)animated
//{
//	[super setEditing:editing animated:animated];
//
//}





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
	
	NSLog(@"prepareForSegue Triggered: %@", segue.identifier);
	
	if ([segue.identifier isEqualToString:@"addFollowingSetsOfGuidelines"]) {
		
		STAddFollowingSetOfAdviceTVC *addFollowingSetOfAdviceTVC	= [[segue.destinationViewController viewControllers] objectAtIndex:0];
		addFollowingSetOfAdviceTVC.delegate							= self;
		addFollowingSetOfAdviceTVC.managedObjectContext				= self.managedObjectContext;
		addFollowingSetOfAdviceTVC.notFollowingSetsOfAdvice			= self.notFollowingSetsOfAdvice;
		
		NSLog(@"notFollowingSetsOfAdvice count: %i", [self.notFollowingSetsOfAdvice count]);
		
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
	if (self.isFilteredForFollowingSetsOfAdvice) {
		if ([tableView isEditing])
			return [self.followingSetsOfAdvice count] + 1;
		else
			return [self.followingSetsOfAdvice count];
	} else {
		if ([tableView isEditing])
			return [self.allSetsOfAdvice count] + 1;
		else
			return [self.allSetsOfAdvice count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEditing] &&
		(
		 (self.isFilteredForFollowingSetsOfAdvice && indexPath.row == [self.followingSetsOfAdvice count]) ||
		 (!self.isFilteredForFollowingSetsOfAdvice && indexPath.row == [self.allSetsOfAdvice count])
		 )
		) {
		static NSString *addCellIdentifier	= @"addSetOfGuidelines";
		UITableViewCell *addCell			= [tableView dequeueReusableCellWithIdentifier:addCellIdentifier];
		
		if (self.isFilteredForFollowingSetsOfAdvice && indexPath.row == [self.followingSetsOfAdvice count])
			addCell.textLabel.text			= @"Choose Set of Guidelines...";
		else
			addCell.textLabel.text			= @"Add New Set of Guidelines...";
		
		return addCell;
	} else {
		SetOfAdvice	*setOfAdvice;
		static NSString *setOfAdviceCellIdentifier	= @"setOfAdviceName";
		UITableViewCell *setOfAdviceCell			= [tableView dequeueReusableCellWithIdentifier:setOfAdviceCellIdentifier];
		   
		if (self.isFilteredForFollowingSetsOfAdvice)
			setOfAdvice								= [self.followingSetsOfAdvice objectAtIndex:indexPath.row];
		else
			setOfAdvice								= [self.allSetsOfAdvice objectAtIndex:indexPath.row];

		setOfAdviceCell.textLabel.text				= setOfAdvice.name;
			
		return setOfAdviceCell;
	}
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
