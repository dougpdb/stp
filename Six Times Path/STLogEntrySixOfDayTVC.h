//
//  STAdviceEntryTVC.h
//  Six Times Path
//
//  Created by Doug on 8/7/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@class LESixOfDay, ActionTaken;

@interface STLogEntrySixOfDayTVC : CoreDataTableViewController <UITextViewDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@property (nonatomic) LESixOfDay *leSixOfDay;
@property (nonatomic) ActionTaken *aPositiveActionTaken;
@property (nonatomic) ActionTaken *aNegativeActionTaken;

@property BOOL *showHints;

- (IBAction)saveEntry:(id)sender;

@end
