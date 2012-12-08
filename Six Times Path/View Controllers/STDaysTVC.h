//
//  STDaysTVC.h
//  Six Times Path
//
//  Created by Doug on 8/7/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@class Day;

@interface STDaysTVC : CoreDataTableViewController <UIActionSheetDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSArray *days;
@property (strong, nonatomic) NSDate *mostRecentlyAddedDate;
@property (strong, nonatomic) NSMutableArray *followedAdvice;
@property NSInteger orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay;
@property (strong, nonatomic) Day *selectedDay;

@property BOOL debug;

//-(void)addDay;
// - (IBAction)whatTimeIsIt:(id)sender;
-(IBAction)addDay:(id)sender;

@end
