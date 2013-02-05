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

//@synthesize selectedTradition			= _selectedTradition;

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
    NSString *entityName			= @"SetOfAdvice";
    
    NSFetchRequest *request			= [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    // 3 - Filter it if you want
    //request.predicate = [NSPredicate predicateWithFormat:@"Role.name = Blah"];
    
    request.sortDescriptors			= @[[NSSortDescriptor sortDescriptorWithKey:@"practicedWithinTradition.name"
																ascending:YES
																 selector:@selector(localizedCaseInsensitiveCompare:)],
										[NSSortDescriptor sortDescriptorWithKey:@"name"
																	 ascending:YES
																	  selector:@selector(localizedCaseInsensitiveCompare:)]];

    self.fetchedResultsController	= [[NSFetchedResultsController alloc] initWithFetchRequest:request
																		managedObjectContext:self.managedObjectContext
																		  sectionNameKeyPath:@"practicedWithinTradition.name" //nil
																				   cacheName:nil];
    [self performFetch];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupFetchedResultsController];
	self.allSetsOfAdvice		= [self.fetchedResultsController fetchedObjects];
	self.selectedSetsOfAdvice	= [[NSMutableArray alloc] init];
	[self updateSelectedSetsOfAdvice];
}

-(void)updateSelectedSetsOfAdvice
{
	[self.selectedSetsOfAdvice removeAllObjects];
	
	for (SetOfAdvice *setOfAdvice in self.allSetsOfAdvice) {
		if ([setOfAdvice.orderNumberInFollowedSets intValue]> 0) {
			[self.selectedSetsOfAdvice addObject:setOfAdvice];
			setOfAdvice.orderNumberInFollowedSets	= [NSNumber numberWithInt:[self.selectedSetsOfAdvice count]];
		}
	}
    [self.managedObjectContext save:nil];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UI Interactions

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    if ([segue.identifier isEqualToString:@"Add Tradition Segue"]) {
//        NSLog(@"Setting STTRaditionsFollowedTVC as a delegate of STAddTraditionTVC.");
//        
//        STAddTraditionTVC *addTraditionTVC  = segue.destinationViewController;
//        addTraditionTVC.delegate            = self;
//        addTraditionTVC.managedObjectContext= self.managedObjectContext;
//    } else if ([segue.identifier isEqualToString:@"Role Detail Segue"]) {
//        NSLog(@"Setting STTraditionsFollowedTVC as a delegate of STTraditionDetailTVC.");
//        STTraditionDetailTVC *traditionDetailTVC        = segue.destinationViewController;
//        traditionDetailTVC.delegate                     = self;
//        traditionDetailTVC.managedObjectContext         = self.managedObjectContext;
//        
//        // Store the selected SpiritualTradition in selectedTradition property
//        NSIndexPath *indexPath  = [self.tableView indexPathForSelectedRow];
//        self.selectedTradition  = [self.fetchedResultsController objectAtIndexPath:indexPath];
//        
//        NSLog(@"Passing selected role (%@} to STTraditionDetailTVC.", self.selectedTradition.name);
//        traditionDetailTVC.tradition    = self.selectedTradition;
//    } else if ([segue.identifier isEqualToString:@"viewTraditionAdviceSegue"]) {
//        NSLog(@"Segue triggered: viewTraditionAdviceSegue to %@", segue.destinationViewController);
//        STSetOfAdviceTVC *setOfAdviceTVC                = segue.destinationViewController;
//        NSLog(@"setOfAdvice has been set.");
//        setOfAdviceTVC.managedObjectContext             = self.managedObjectContext;
//        NSLog(@"The tradition has been set.");
//        
////        STTraditionDetailTVC *traditionDetailTVC        = segue.destinationViewController;
////        traditionDetailTVC.delegate                     = self;
////        traditionDetailTVC.managedObjectContext         = self.managedObjectContext;
//
//        // Store the selected SpiritualTradition in selectedTradition property
//        NSIndexPath *indexPath  = [self.tableView indexPathForSelectedRow];
//        self.selectedTradition  = [self.fetchedResultsController objectAtIndexPath:indexPath];
//
//        NSLog(@"Passing selected role (%@} to STSetOfAdviceTVC.", self.selectedTradition.name);
//        setOfAdviceTVC.selectedTradition    = self.selectedTradition;
//        
//    }else {
//        NSLog(@"Unidentified segue attempted!");
//    }
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
