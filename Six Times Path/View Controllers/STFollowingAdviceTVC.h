//
//  STFollowingAdviceTVC.h
//  Six Times Path
//
//  Created by Doug on 7/30/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"


@interface STFollowingAdviceTVC : CoreDataTableViewController

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@property (strong, nonatomic) NSMutableArray *followingAdvice;

-(void)initFollowingAdvice; 

@end
