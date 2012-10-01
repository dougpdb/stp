//
//  STLogEntryWorstOfDayTVC.h
//  Six Times Path
//
//  Created by Doug on 10/1/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"


@class LEWorstOfDay;

@interface STLogEntryWorstOfDayTVC : CoreDataTableViewController

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, atomic) LEWorstOfDay *leWorstOfDay;

@end
