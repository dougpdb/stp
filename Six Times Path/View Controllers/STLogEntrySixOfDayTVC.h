//
//  STAdviceEntryTVC.h
//  Six Times Path
//
//  Created by Doug on 8/7/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "BSKeyboardControls.h"
#import <TextExpander/SMTEDelegateController.h>

@class LESixOfDay, ActionTaken, ToDo;

@interface STLogEntrySixOfDayTVC : CoreDataTableViewController <UITextFieldDelegate, UITextViewDelegate, BSKeyboardControlsDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@property BOOL isRemainingScheduledEntry;
@property (nonatomic) LESixOfDay *leSixOfDay;
@property (nonatomic) ActionTaken *aPositiveActionTaken;
@property (nonatomic) ActionTaken *aNegativeActionTaken;
@property (weak, nonatomic) IBOutlet UILabel *guidelineTime;
@property (weak, nonatomic) IBOutlet UILabel *guidelineText;
@property (weak, nonatomic) IBOutlet UITextView *positiveActionTextView;
@property (weak, nonatomic) IBOutlet UITextView *negativeActionTextView;
@property (nonatomic) SMTEDelegateController *textExpander;


@property BOOL showHints;

- (IBAction)greatHighwayExplorerFeedback:(id)sender;
- (void)saveEntry;

@end
