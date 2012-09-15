//
//  STTraditionDetailTVC.h
//  Six Times Path
//
//  Created by ICE - Doug on 7/6/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpiritualTradtion.h"

@class STTraditionDetailTVC;

@protocol STTraditionDetailTVCDelegate <NSObject>
-(void)saveWasTappedOnAddTradition:(STTraditionDetailTVC *)controller;
@end

@interface STTraditionDetailTVC : UITableViewController

@property (nonatomic, weak) id <STTraditionDetailTVCDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITextField *traditionNameTextField;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) SpiritualTradtion *tradition;


-(IBAction)save:(id)sender;
@end
