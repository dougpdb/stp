//
//  STSettingsTVCViewController.h
//  Six Times
//
//  Created by Doug on 4/5/14.
//  Copyright (c) 2014 A Great Highway. All rights reserved.
//

#import "CoreDataTableViewController.h"

@class STTodayTVC;

@interface STSettingsTVC : CoreDataTableViewController

@property (strong) STTodayTVC *todayTVC;
@property (weak, nonatomic) IBOutlet UISwitch *appBadgeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *notificationsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *staggerGuidelinesSwitch;
@property (weak, nonatomic) IBOutlet UILabel *aboutSixTimesLabel;
@property (weak, nonatomic) IBOutlet UILabel *notifyWhenGuidelineIsDueLabel;
@property (weak, nonatomic) IBOutlet UILabel *showAppBadgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *staggerDailyGuidelinesLabel;

- (IBAction)toggleAppBadgeSetting:(id)sender;
- (IBAction)toggleNotificationsSetting:(id)sender;
- (IBAction)toggleStaggerGuidelinesSetting:(id)sender;

@end
