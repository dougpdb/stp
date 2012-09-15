//
//  STSetOfAdviceDetailTVC.m
//  Six Times Path
//
//  Created by ICE - Doug on 7/20/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "STSetOfAdviceDetailTVC.h"
#import "SetOfAdvice.h"
#import "Advice.h"

@interface STSetOfAdviceDetailTVC ()

@end

@implementation STSetOfAdviceDetailTVC

@synthesize fetchedResultsController    = __fetchedResultsController;
@synthesize managedObjectContext        = __managedObjectContext;
@synthesize selectedSetOfAdvice         = _selectedSetOfAdvice;

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
    NSLog(@"The name of the selectedSetOfAdvice is %@", self.selectedSetOfAdvice.name);
    [self setupFetchedResultsController];
//    Advice *tmpAdvice = [[self.fetchedResultsController fetchedObjects] objectAtIndex:0];
    NSLog(@"The name of the selectedSetOfAdvice is %@", self.selectedSetOfAdvice.name);
    self.title  = self.selectedSetOfAdvice.name;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




#pragma mark - Core Data

- (void)setupFetchedResultsController
{
    // 1 - Decide what Entity you want
    NSString *entityName        = @"Advice";
    NSLog(@"Setting up a Fetched Results Controller for the Entity named %@", entityName);
    
    // 2 - Request that Entity
    NSFetchRequest *request     = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    // 3 - Filter it if you want
    // REMEMBER: When comparing a collection (like practicedWithinTradition), you need to either use a collection comparator (CONTAINS), or use a predicate modifier (ANY/ALL/SOME, etc). 
    request.predicate           = [NSPredicate predicateWithFormat:@"containedWithinSetOfAdvice.name = %@", self.selectedSetOfAdvice.name];
    
    // 4 - Sort it if you want
    request.sortDescriptors     = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"orderNumberInSet"
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
    static NSString *CellIdentifier = @"adviceCell";
    UITableViewCell *cell           = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cells for the advice rows...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Get the detail for the advice rows
    Advice *advice      = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@. %@", advice.orderNumberInSet, advice.name];
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
