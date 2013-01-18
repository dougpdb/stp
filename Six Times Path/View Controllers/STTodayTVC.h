//
//  STTodayTVC.h
//  Six Times Path
//
//  Created by Doug on 12/5/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "CoreDataTableViewController.h"

@class Day, LESixOfDay;

@interface STTodayTVC : CoreDataTableViewController

// Core Data
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) Day *thisDay;


// moved out of implementation category for purposes of subclassing
// maybe move some back in

@property BOOL showRemainingScheduledEntries;
@property BOOL showUpdatedEntries;
@property (strong, nonatomic) LESixOfDay *nextEntry;
@property (strong, nonatomic) NSArray *remainingScheduledEntries;
@property (strong, nonatomic) NSArray *updatedEntries;
@property (strong, nonatomic) NSDate *mostRecentlyAddedDate;
@property NSInteger orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay;
@property (strong, nonatomic) NSMutableArray *allAdviceFollowedByUser;
@property (nonatomic) NSInteger countOfTheSixWithoutUserEntries;

@property (nonatomic, strong) NSMutableArray *tableViewSections;


-(void)determineAndSetTheSixToBeShown;
-(void)addNotification:(LESixOfDay *)sixOfDayLogEntry;
-(void)addDay:(id)sender;
-(void)setTheSixAdvicesFor:(Day *)day withIndexOfFirstFollowedAdvice:(NSInteger)indexOfFirstFollowedAdvice inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;




- (IBAction)doneAction:(id)sender;	// when the done button is clicked
									//- (IBAction)dateAction:(id)sender;	// when the user has changed the date picke values (m/d/y)

@end
