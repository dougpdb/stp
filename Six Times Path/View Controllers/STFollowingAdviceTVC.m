//
//  STFollowingAdviceTVC.m
//  Six Times Path
//
//  Created by Doug on 7/30/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "STFollowingAdviceTVC.h"
#import "Advice.h"
#import "SetOfAdvice.h"

@interface STFollowingAdviceTVC ()

@end

@implementation STFollowingAdviceTVC

@synthesize fetchedResultsController    = _fetchedResultsController;
@synthesize managedObjectContext        = _managedObjectContext;
@synthesize followingAdvice             = _followingAdvice;

#pragma mark - View loading and appearing

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setupFetchedResultsController];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)setupFetchedResultsController
{
    // 1 - Decide what Entity you want
    NSString *entityName = @"Advice";
    NSLog(@"Setting up a Fetched Results Controller for the Entity named %@", entityName);
    NSLog(@"entityName: %@", entityName);
    
    // 2 - Request that Entity
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSLog(@"fetchRequestWithEntityName completed.");
    
    // 3 - Filter it if you want
    // REMEMBER: When comparing a collection (like practicedWithinTradition), you need to either use a collection comparator (CONTAINS), or use a predicate modifier (ANY/ALL/SOME, etc).
    request.predicate = [NSPredicate predicateWithFormat:@"containedWithinSetOfAdvice.orderNumberInFollowedSets > 0", [NSNumber numberWithBool:YES]];
    NSLog(@"a predicate has been set.");
    
    // 4 - Sort it if you want
    request.sortDescriptors = [NSArray arrayWithObjects:
                                [NSSortDescriptor sortDescriptorWithKey:@"containedWithinSetOfAdvice.orderNumberInFollowedSets"
                                                                                      ascending:YES
                                                                                       selector:@selector(localizedCaseInsensitiveCompare:)],
                                [NSSortDescriptor sortDescriptorWithKey:@"orderNumberInSet"
                                                             ascending:YES],
                               nil];
    NSLog(@"sortDescriptors have been set on the request.");
    
    // 5 - Fetch it
    // Set attribute name to sectionNameKeyPath
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:@"containedWithinSetOfAdvice.name"
                                                                                   cacheName:nil];
    [self performFetch];
    
    NSLog(@"Fetch performed. Number of objects fetched: %u", [self.fetchedResultsController.fetchedObjects count]);
}

- (void)viewWillAppear:(BOOL)animated
{
    self.debug  = YES; // turn on debugging
    
    [super viewWillAppear:animated];
//    [self initFollowingAdvice];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"adviceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Advice *advice      = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = advice.name;
    
    return cell;
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
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
