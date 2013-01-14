//
//  STTodayTVC.h
//  Six Times Path
//
//  Created by Doug on 12/5/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "CoreDataTableViewController.h"

@class Day;

@interface STTodayTVC : CoreDataTableViewController

// Core Data
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) Day *thisDay;

// from apple sample code
@property (nonatomic, retain) IBOutlet UIDatePicker *pickerView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic, retain) NSArray *dataArray;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;

- (IBAction)doneAction:(id)sender;	// when the done button is clicked
									//- (IBAction)dateAction:(id)sender;	// when the user has changed the date picke values (m/d/y)

@end
