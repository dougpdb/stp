//
//  SetOfAdvice.m
//  Six Times Path
//
//  Created by ICE - Doug on 7/17/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "STSetOfAdviceTVC.h"
#import "STSetOfAdviceDetailTVC.h"
#import "SetOfAdvice.h"

@interface STSetOfAdviceTVC ()

@end

@implementation STSetOfAdviceTVC

@synthesize fetchedResultsController    = __fetchedResultsController;
@synthesize managedObjectContext        = __managedObjectContext;
@synthesize selectedSetOfAdvice         = _selectedSetOfAdvice;
@synthesize selectedTradition           = _selectedTradition;


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupFetchedResultsController];
    self.selectedSetOfAdvice    = [[self.fetchedResultsController fetchedObjects] objectAtIndex:0];
}



#pragma mark - UI Interactions

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"viewGuidelineDetails"]) {        
        STSetOfAdviceDetailTVC *setOfAdviceDetailTVC    = segue.destinationViewController;
        setOfAdviceDetailTVC.managedObjectContext       = self.managedObjectContext;
        NSLog(@"The name of the selectedSetOfAdvice is %@", self.selectedSetOfAdvice.name);
        setOfAdviceDetailTVC.selectedSetOfAdvice        = self.selectedSetOfAdvice;
    } else {
        NSLog(@"Unidentified segue attempted!");
    }
}



#pragma mark - Core Data

- (void)setupFetchedResultsController
{
    // 1 - Decide what Entity you want
    NSString *entityName        = @"SetOfAdvice";
    NSLog(@"Setting up a Fetched Results Controller for the Entity named %@", entityName);
    
    // 2 - Request that Entity
    NSFetchRequest *request     = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    // 3 - Filter it if you want
    // REMEMBER: When comparing a collection (like practicedWithinTradition), you need to either use a collection comparator (CONTAINS), or use a predicate modifier (ANY/ALL/SOME, etc). 
    request.predicate           = [NSPredicate predicateWithFormat:@"ANY practicedWithinTradition.name = %@", self.selectedTradition.name];
    
    // 4 - Sort it if you want
    request.sortDescriptors     = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                     ascending:YES
                                                                                      selector:@selector(localizedCaseInsensitiveCompare:)]];
    // 5 - Fetch it
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    [self performFetch];
}



#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"setOfAdviceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    SetOfAdvice *setOfAdvice    = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text         = setOfAdvice.name;
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
