//
//  STAddTraditionTVC.h
//  Six Times Path
//
//  Created by ICE - Doug on 6/28/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STAddTraditionTVC;

@protocol STAddTraditionTVCDelegate <NSObject>
-(void)saveWasTappedOnAddTradition:(STAddTraditionTVC *)controller;
@end

@interface STAddTraditionTVC : UITableViewController

@property (nonatomic, weak) id <STAddTraditionTVCDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITextField *traditionNameTextField;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


-(IBAction)save:(id)sender;

@end
