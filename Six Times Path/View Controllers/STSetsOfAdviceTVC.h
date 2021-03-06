//
//  STTraditionsFollowedTVC.h
//  Six Times Path
//
//  Created by ICE - Doug on 6/28/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "STAddFollowingSetOfAdviceTVC.h"

@class Day;

@interface STSetsOfAdviceTVC : CoreDataTableViewController <AddFollowingSetOfAdviceDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Day *currentDay;


- (IBAction)greatHIghwayExplorerFeedback:(id)sender;
@end
