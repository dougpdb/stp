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

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) Day *thisDay;
@property (strong, nonatomic) LESixOfDay *nextEntry;
@property (strong, nonatomic) LESixOfDay *entryFromNotification;
@property (strong, nonatomic) NSArray *remainingScheduledEntries;
@property (strong, nonatomic) NSArray *updatedEntries;
@property (strong, nonatomic) NSDate *mostRecentlyAddedDate;
@property NSInteger orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay;
@property (strong, nonatomic) NSMutableArray *allAdviceFollowedByUser;
@property (nonatomic) NSInteger countOfTheSixWithoutUserEntries;

@property (nonatomic, strong) NSMutableArray *tableViewSections;
@property BOOL showRemainingScheduledEntries;
@property BOOL showUpdatedEntries;
@property BOOL noSetsOfGuidelinesBeingFollowed;


#pragma mark - Setup and Manage Data
-(void)setupDayAndAdviceData;
-(void)setupDaysFetchedResultsController;
-(BOOL)isTimeToAddDay;
-(void)addDay;
-(void)setTheSixFor:(Day *)day withIndexOfFirstFollowedAdvice:(NSInteger)indexOfFirstFollowedAdvice inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
-(void)resetTheSixToBeShown;

#pragma mark - Managing Notifications
-(void)addNotification:(LESixOfDay *)sixOfDayLogEntry;

#pragma mark - Managing Cell and Label Heights
-(CGFloat)heightForLabel:(UILabel *)label withText:(NSString *)text labelWidth:(CGFloat)labelWidth;
-(void)resizeHeightToFitForLabel:(UILabel *)label labelWidth:(CGFloat)labelWidth;

#pragma mark - Managing the Start of the Day
- (IBAction)doneAction:(id)sender;	

@end
