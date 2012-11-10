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

@interface STTraditionsFollowedTVC ()

@end

@implementation STTraditionsFollowedTVC

@synthesize fetchedResultsController	= __fetchedResultsController;
@synthesize managedObjectContext		= __managedObjectContext;

@synthesize selectedTradition			= _selectedTradition;



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
    NSString *entityName = @"SpiritualTradition";
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
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    [self performFetch];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupFetchedResultsController];
	NSLog(@"Setup complete");
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
    static NSString *CellIdentifier = @"tradition name cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    SpiritualTradtion *tradition = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"The name found for the tradition is: %@", tradition.name);
    cell.textLabel.text = tradition.name;
    
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

@end
