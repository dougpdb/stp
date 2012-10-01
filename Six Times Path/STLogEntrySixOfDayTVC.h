//
//  STAdviceEntryTVC.h
//  Six Times Path
//
//  Created by Doug on 8/7/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@class LESixOfDay, LESpecialFocus, LEBestOfDay, LEWorstOfDay;

@interface STLogEntrySixOfDayTVC : CoreDataTableViewController

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@property (strong, atomic) LESixOfDay *leSixOfDay;



@end
