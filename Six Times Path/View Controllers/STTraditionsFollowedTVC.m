//
//  STTraditionsFollowedTVC.m
//  Six Times Path
//
//  Created by ICE - Doug on 6/28/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "STTraditionsFollowedTVC.h"
#import "STSetOfAdviceTVC.h"
#import "SpiritualTradtion.h"
#import "TestFlight.h"

@interface STTraditionsFollowedTVC ()

@end

@implementation STTraditionsFollowedTVC

@synthesize fetchedResultsController	= __fetchedResultsController;
@synthesize managedObjectContext		= __managedObjectContext;

@synthesize selectedTradition			= _selectedTradition;

@synthesize selectedSetsOfAdvice		= _selectedSetsOfAdvice;
@synthesize allSetsOfAdvice				= _allSetsOfAdvice;



#pragma mark - View loading and appearing

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)setupFetchedResultsController
{
    // 1 - Decide what Entity you want
    NSString *entityName = @"SetOfAdvice";
    NSLog(@"Setting up a Fetched Results Controller for the Entity named %@", entityName);
    
    // 2 - Request that Entity
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    // 3 - Filter it if you want
    //request.predicate = [NSPredicate predicateWithFormat:@"Role.name = Blah"];
    
    // 4 - Sort it if you want
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                     ascending:YES
                                                                                      selector:@selector(localizedCaseInsensitiveCompare:)]];
    // 5 - Fetch it
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:@"practicedWithinTradition.name" //nil
                                                                                   cacheName:nil];
    [self performFetch];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupFetchedResultsController];
	self.allSetsOfAdvice	= [self.fetchedResultsController fetchedObjects];
	self.selectedSetsOfAdvice	= [[NSMutableArray alloc] init];
	[self updateSelectedSetsOfAdvice];
	NSLog(@"Setup complete. %i sets of advice fetched.", [self.allSetsOfAdvice count]);
}

-(void)updateSelectedSetsOfAdvice
{
	[self.selectedSetsOfAdvice removeAllObjects];
	
	for (SetOfAdvice *setOfAdvice in self.allSetsOfAdvice) {
		if ([setOfAdvice.orderNumberInFollowedSets intValue]> 0) {
			[self.selectedSetsOfAdvice addObject:setOfAdvice];
			setOfAdvice.orderNumberInFollowedSets	= [NSNumber numberWithInt:[self.selectedSetsOfAdvice count]];
		}
		NSLog(@"[%@] is order number %@", setOfAdvice.name, setOfAdvice.orderNumberInFollowedSets);
	}
    [self.managedObjectContext save:nil];
	NSLog(@"There are %i sets of advices that have been selected", [self.selectedSetsOfAdvice count]);
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UI Interactions

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Add Tradition Segue"]) {
        NSLog(@"Setting STTRaditionsFollowedTVC as a delegate of STAddTraditionTVC.");
        
        STAddTraditionTVC *addTraditionTVC  = segue.destinationViewController;
        addTraditionTVC.delegate            = self;
        addTraditionTVC.managedObjectContext= self.managedObjectContext;
    } else if ([segue.identifier isEqualToString:@"Role Detail Segue"]) {
        NSLog(@"Setting STTraditionsFollowedTVC as a delegate of STTraditionDetailTVC.");
        STTraditionDetailTVC *traditionDetailTVC        = segue.destinationViewController;
        traditionDetailTVC.delegate                     = self;
        traditionDetailTVC.managedObjectContext         = self.managedObjectContext;
        
        // Store the selected SpiritualTradition in selectedTradition property
        NSIndexPath *indexPath  = [self.tableView indexPathForSelectedRow];
        self.selectedTradition  = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        NSLog(@"Passing selected role (%@} to STTraditionDetailTVC.", self.selectedTradition.name);
        traditionDetailTVC.tradition    = self.selectedTradition;
    } else if ([segue.identifier isEqualToString:@"viewTraditionAdviceSegue"]) {
        NSLog(@"Segue triggered: viewTraditionAdviceSegue to %@", segue.destinationViewController);
        STSetOfAdviceTVC *setOfAdviceTVC                = segue.destinationViewController;
        NSLog(@"setOfAdvice has been set.");
        setOfAdviceTVC.managedObjectContext             = self.managedObjectContext;
        NSLog(@"The tradition has been set.");
        
//        STTraditionDetailTVC *traditionDetailTVC        = segue.destinationViewController;
//        traditionDetailTVC.delegate                     = self;
//        traditionDetailTVC.managedObjectContext         = self.managedObjectContext;

        // Store the selected SpiritualTradition in selectedTradition property
        NSIndexPath *indexPath  = [self.tableView indexPathForSelectedRow];
        self.selectedTradition  = [self.fetchedResultsController objectAtIndexPath:indexPath];

        NSLog(@"Passing selected role (%@} to STSetOfAdviceTVC.", self.selectedTradition.name);
        setOfAdviceTVC.selectedTradition    = self.selectedTradition;
        
    }else {
        NSLog(@"Unidentified segue attempted!");
    }
}

#pragma mark - Delegation

-(void)saveWasTappedOnAddTradition:(STAddTraditionTVC *)controller
{
    // do something
    
    // close the delegated view
    [controller.navigationController popViewControllerAnimated:YES];
}

-(void)saveWasTappedOnTraditionDetail:(STTraditionDetailTVC *)controller
{
    // do something
    
    // close the delegated view
    [controller.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"setOfAdviceName";
    
    UITableViewCell *cell			= [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
       
    // Configure the cell...
	SetOfAdvice	*setOfAdvice	= [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text			= setOfAdvice.name;
	
	if ([self.selectedSetsOfAdvice containsObject:setOfAdvice])
		cell.accessoryType		= UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType		= UITableViewCellAccessoryNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.tableView beginUpdates];  // Avoid NSInternalInconsistencyException
        
        // Delete the tradition object that was swiped
        SpiritualTradtion *traditionToDelete    = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSLog(@"Deleting (%@)", traditionToDelete.name);
        [self.managedObjectContext deleteObject:traditionToDelete];
        [self.managedObjectContext save:nil];
        
        // Delet the (now empty) row on the table
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self performFetch];
        
        [self.tableView endUpdates];
    }
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    UITableViewCell *thisCell = [tableView cellForRowAtIndexPath:indexPath];
	
	NSLog(@"text of cell: %@", thisCell.textLabel.text);
    if (thisCell.accessoryType == UITableViewCellAccessoryNone) {
        thisCell.accessoryType = UITableViewCellAccessoryCheckmark;
		
		for (SetOfAdvice *setOfAdvice in self.allSetsOfAdvice) {
			if ([thisCell.textLabel.text isEqualToString:setOfAdvice.name]) {
				setOfAdvice.orderNumberInFollowedSets	= [NSNumber numberWithInt:[self.selectedSetsOfAdvice count] + 1];
				break;
			}
		}		
    } else {
    	thisCell.accessoryType = UITableViewCellAccessoryNone;
		
		for (SetOfAdvice *setOfAdvice in self.allSetsOfAdvice) {
			if ([thisCell.textLabel.text isEqualToString:setOfAdvice.name]) {
				setOfAdvice.orderNumberInFollowedSets	= [NSNumber numberWithInt:0];
				break;
			}
		}
    }
	
	[self updateSelectedSetsOfAdvice];
}

- (IBAction)greatHIghwayExplorerFeedback:(id)sender {
	[TestFlight openFeedbackView];
}
@end
