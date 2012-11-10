//
//  STSettingsViewController.m
//  Six Times Path
//
//  Created by Doug on 11/9/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "STSettingsTVC.h"
#import "STTraditionsFollowedTVC.h"

@interface STSettingsTVC ()

@end

@implementation STSettingsTVC

@synthesize fetchedResultsController	= _fetchedResultsController;
@synthesize managedObjectContext		= _managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"traditionsFollowedSegue"]) {
//		if (self.debug)
//			NSLog(@"Segue triggered: traditionsFollowedSegue");
		STTraditionsFollowedTVC *traditionsFollowedTVC	= segue.destinationViewController;
		traditionsFollowedTVC.managedObjectContext		= self.managedObjectContext;
	}

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
