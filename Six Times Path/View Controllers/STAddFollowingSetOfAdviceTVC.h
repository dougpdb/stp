
//
//  STAddFollowingSetOfAdviceTVC.h
//  Six Times Path
//
//  Created by Doug on 2/9/13.
//  Copyright (c) 2013 A Great Highway. All rights reserved.
//

#import "CoreDataTableViewController.h"

@class SetOfAdvice;

@interface STAddFollowingSetOfAdviceTVC : CoreDataTableViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *notFollowingSetsOfAdvice;
@property (nonatomic, assign) id delegate;

- (IBAction)cancel:(id)sender;


@end


@protocol AddFollowingSetOfAdviceDelegate <NSObject>

-(void)addFollowingSetOfAdviceTVC:(STAddFollowingSetOfAdviceTVC *)addFollowingSetOfAdviceTVC
				didAddSetOfAdvice:(SetOfAdvice *)setOfAdvice;
@end