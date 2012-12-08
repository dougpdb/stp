//
//  STTodayTVC.h
//  Six Times Path
//
//  Created by Doug on 12/5/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "CoreDataTableViewController.h"

@class Day;

@interface STTodayTVC : CoreDataTableViewController

// Core Data
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) Day *today;
@end
