//
//  STDayTVC.h
//  Six Times Path
//
//  Created by Doug on 8/7/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@class Day, LESpecialFocus;

@interface STDayTVC : CoreDataTableViewController

// possilby add delegate ?
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) Day *selectedDay;
//@property (strong, nonatomic) NSArray *theSixSorted;
@property (strong, nonatomic) NSArray *bestOfDaySorted;
@property (strong, nonatomic) NSArray *worstOfDaySorted;
@property (strong, nonatomic) LESpecialFocus *specialFocus;

@property BOOL *isTipToBeShown;
//@property BOOL *debug;

-(void)onlyShowTheSixWithoutUserEntries:(BOOL)onlyShowWithoutUserEntries;

@end
