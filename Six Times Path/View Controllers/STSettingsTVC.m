//
//  STSettingsTVCViewController.m
//  Six Times
//
//  Created by Doug on 4/5/14.
//  Copyright (c) 2014 A Great Highway. All rights reserved.
//

#import "STSettingsTVC.h"
#import "STTodayTVC.h"
#import "NSUserDefaults+ST.h"

@interface STSettingsTVC ()

@property (nonatomic) NSUserDefaults *sixTimesUserDefaults;
@property BOOL originalAppBadgeSetting;
@property BOOL originalNotificationsSetting;
@property BOOL originalStaggerGuidelinesSetting;

@end

@implementation STSettingsTVC

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

	self.sixTimesUserDefaults = [NSUserDefaults standardUserDefaults];
	
}

-(void)viewWillAppear:(BOOL)animated
{
	[self.sixTimesUserDefaults showLogOfAllSettings];
	
	self.originalAppBadgeSetting = [self.sixTimesUserDefaults isAppBadgeOn];
	self.originalNotificationsSetting = [self.sixTimesUserDefaults isNotificationsOn];
	self.originalStaggerGuidelinesSetting = [self.sixTimesUserDefaults isStaggerDailyGuidelinesOn];

	
	self.appBadgeSwitch.on = self.originalAppBadgeSetting;
	self.notificationsSwitch.on = self.originalNotificationsSetting;
	self.staggerGuidelinesSwitch.on = self.originalStaggerGuidelinesSetting;
}

-(void)viewWillDisappear:(BOOL)animated
{
	if (self.originalStaggerGuidelinesSetting != [self.sixTimesUserDefaults isStaggerDailyGuidelinesOn]) {
	
		[self.todayTVC resetFollowedEntries];
		
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (section == 1) ? 2 : 1;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)toggleAppBadgeSetting:(id)sender {
	UISwitch *switchControl = (UISwitch *)sender;
	(switchControl.on) ? [self.sixTimesUserDefaults turnOnAppBadge] : [self.sixTimesUserDefaults turnOffAppBadge];
}

- (IBAction)toggleNotificationsSetting:(id)sender {
	UISwitch *switchControl = (UISwitch *)sender;
	(switchControl.on) ? [self.sixTimesUserDefaults turnOnNotifications] : [self.sixTimesUserDefaults turnOffNotifications];
}

- (IBAction)toggleStaggerGuidelinesSetting:(id)sender {
	UISwitch *switchControl = (UISwitch *)sender;
	(switchControl.on) ? [self.sixTimesUserDefaults turnOnStaggerDailyGuidelines] : [self.sixTimesUserDefaults turnOffStaggerDailyGuidelines];
}
@end
