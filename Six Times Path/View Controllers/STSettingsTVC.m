//
//  STSettingsTVCViewController.m
//  Six Times
//
//  Created by Doug on 4/5/14.
//  Copyright (c) 2014 A Great Highway. All rights reserved.
//

#import "STSettingsTVC.h"
#import "STTodayTVC.h"
#import "STNotificationController.h"
#import "NSUserDefaults+ST.h"
#import "UIFont+ST.h"

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
	
	[self setPreferredContentSizes];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(preferredContentSizeChanged:)
												 name:UIContentSizeCategoryDidChangeNotification
											   object:nil];
	
}

-(void)setPreferredContentSizes
{
	self.aboutSixTimesLabel.font = [UIFont preferredFontForUILabel];
	self.notifyWhenGuidelineIsDueLabel.font = [UIFont preferredFontForUILabel];
	self.showAppBadgeLabel.font = [UIFont preferredFontForUILabel];
	self.staggerDailyGuidelinesLabel.font = [UIFont preferredFontForUILabel];
}

- (void)preferredContentSizeChanged:(NSNotification *)aNotification {
    [self setPreferredContentSizes];
	[self.tableView reloadData];
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
	
	if (self.originalAppBadgeSetting != [self.sixTimesUserDefaults isAppBadgeOn]) {
		
		STNotificationController *notificationController = [STNotificationController new];
		if ([self.sixTimesUserDefaults isAppBadgeOn]) {
			
			[notificationController setApplicationIconBadgeNumbersForAllNotifications];
			[notificationController setApplicationIconBadgeNumberForPastDueEntries:self.todayTVC.thisDay];
			
		} else {
		
			[notificationController hideApplicationIconBadgeNumbers];
			
		}
		
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


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UILabel *placeholderLabel = [UILabel new];
	placeholderLabel.font = [UIFont preferredFontForUILabel];
	
	if (placeholderLabel.font.pointSize < 15) {
		return 44.0;
	}
	
	return placeholderLabel.font.pointSize * 1.3 + 24;
}

#pragma mark - Managing Cell and Label Heights
-(CGFloat)heightForLabel:(UILabel *)label withText:(NSString *)text labelWidth:(CGFloat)labelWidth
{
	if (text != nil) {
		
		UIFont *font = label.font;
		NSAttributedString *attributedText	= [ [NSAttributedString alloc]
											   initWithString:text
											   attributes: @{NSFontAttributeName: font}
											   ];
		CGRect rect = [attributedText boundingRectWithSize:(CGSize){labelWidth, CGFLOAT_MAX}
												   options:NSStringDrawingUsesLineFragmentOrigin
												   context:nil];
		CGSize size = rect.size;
		CGFloat height = ceilf(size.height);
		return height;
		
	} else {
		
		return 0;
		
	}
}


/**/

#pragma mark - Toggle Settings

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
