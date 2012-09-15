//
//  STTraditionsFollowedTVC.h
//  Six Times Path
//
//  Created by ICE - Doug on 6/28/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "STAddTraditionTVC.h"
#import "STTraditionDetailTVC.h"

@interface STTraditionsFollowedTVC : CoreDataTableViewController <STAddTraditionTVCDelegate, STTraditionDetailTVCDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) SpiritualTradtion *selectedTradition;

@end
