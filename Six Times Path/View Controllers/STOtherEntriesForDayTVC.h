//
//  STOtherEntriesForDayTVC.h
//  Six Times Path
//
//  Created by Doug on 12/13/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "CoreDataTableViewController.h"

@class Day;

@interface STOtherEntriesForDayTVC : CoreDataTableViewController

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) Day *selectedDay;
@property BOOL showGuidelinesWithoutEntries;

@end
