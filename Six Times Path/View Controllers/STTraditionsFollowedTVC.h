//
//  STTraditionsFollowedTVC.h
//  Six Times Path
//
//  Created by ICE - Doug on 6/28/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface STTraditionsFollowedTVC : CoreDataTableViewController 

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic) NSMutableArray *selectedSetsOfAdvice;
@property (nonatomic) NSArray *allSetsOfAdvice;

- (IBAction)greatHIghwayExplorerFeedback:(id)sender;
@end
