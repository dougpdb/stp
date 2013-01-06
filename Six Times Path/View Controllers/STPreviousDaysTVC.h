//
//  STPreviousDaysTVC.h
//  Six Times Path
//
//  Created by Doug on 1/4/13.
//  Copyright (c) 2013 A Great Highway. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface STPreviousDaysTVC : CoreDataTableViewController

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSArray *days;

@end
