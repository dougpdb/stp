//
//  STPreviousDaysTVC.h
//  Six Times Path
//
//  Created by Doug on 1/4/13.
//  Copyright (c) 2013 A Great Highway. All rights reserved.
//

#import "CoreDataTableViewController.h"

@class STTodayTVC;

@interface STPreviousDaysTVC : CoreDataTableViewController

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSArray *days;
@property (strong, nonatomic) STTodayTVC *today;

- (IBAction)greatHighwayExplorerFeedback:(id)sender;
@end
