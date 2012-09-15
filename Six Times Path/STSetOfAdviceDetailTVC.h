//
//  STSetOfAdviceDetailTVC.h
//  Six Times Path
//
//  Created by ICE - Doug on 7/20/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "SetOfAdvice.h"
#import "SpiritualTradtion.h"

@interface STSetOfAdviceDetailTVC : CoreDataTableViewController

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) SetOfAdvice *selectedSetOfAdvice;



@end
