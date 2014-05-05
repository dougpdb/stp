//
//  NSUserDefaults+ST.m
//  Six Times
//
//  Created by Doug on 4/7/14.
//  Copyright (c) 2014 A Great Highway. All rights reserved.
//

#import "NSUserDefaults+ST.h"


static NSString *kAppBadgeSetting = @"appBadge";
static NSString *kNotificationSetting = @"notifications";
static NSString *kStaggerDailyGuidelineSetting = @"staggerGuidelines";
static NSString *kDefaultSettingsAreSet = @"defaultSettingsAreSet";

static NSString *kStartHour = @"startHour";
static NSString *kStartMinute = @"startMinute";

static NSString *databaseVersion = @"databaseVersion";
static NSString *databaseHasBeenCreated = @"databaseHasBeenCreated";
static NSString *dayRecordsAreInCoreData = @"dayRecordsAreInCoreData";

@implementation NSUserDefaults (ST)


#pragma mark - Default Setting Values Handling

-(BOOL)noSettingValuesHaveBeenSet
{
	return (([self objectForKey:kDefaultSettingsAreSet] == nil) || ([[self objectForKey:kDefaultSettingsAreSet] isKindOfClass:[NSNull class]]));
}

-(void)setDefaultSettingValues
{
	[self turnOnAppBadge];
	[self turnOnNotifications];
	[self turnOffStaggerDailyGuidelines];
	
	[self setBool:YES forKey:kDefaultSettingsAreSet];
}

#pragma mark - Getting Setting Values

-(BOOL)isAppBadgeOn
{
	return ([self boolForKey:kAppBadgeSetting]);
}

-(BOOL)isNotificationsOn
{
	return ([self boolForKey:kNotificationSetting]);
}

-(BOOL)isStaggerDailyGuidelinesOn
{
	return ([self boolForKey:kStaggerDailyGuidelineSetting]);
}

#pragma mark - Turning Setting Values On and Off;

-(void)turnOnAppBadge
{
	[self setBool:YES forKey:kAppBadgeSetting];
}

-(void)turnOffAppBadge
{
	[self setBool:NO forKey:kAppBadgeSetting];
}

-(void)turnOnNotifications
{
	[self setBool:YES forKey:kNotificationSetting];
}

-(void)turnOffNotifications
{
	[self setBool:NO forKey:kNotificationSetting];
}

-(void)turnOnStaggerDailyGuidelines
{
	[self setBool:YES forKey:kStaggerDailyGuidelineSetting];
}

-(void)turnOffStaggerDailyGuidelines
{
	[self setBool:NO forKey:kStaggerDailyGuidelineSetting];
}



#pragma mark - Log statements

-(void)showLogOfAllSettings
{
	[self isDefaultSettingsValuesOnLog];
	[self isNotificationsOnLog];
	[self isStagggerDailyGuidelinesOnLog];
}

-(void)isDefaultSettingsValuesOnLog
{
	([self boolForKey:kDefaultSettingsAreSet]) ? NSLog(@"Default Setting Values have been set and are On.") : NSLog(@"Default Setting Values have not been set and are Off.");
}

-(void)isAppBadgeOnLog
{
	([self isAppBadgeOn]) ? NSLog(@"App Badge is On.") : NSLog(@"App Badge is Off.");
}

-(void)isNotificationsOnLog
{
	([self isNotificationsOn]) ? NSLog(@"Notifcations is On.") : NSLog(@"Notifications is Off.");
}

-(void)isStagggerDailyGuidelinesOnLog
{
	([self isStaggerDailyGuidelinesOn]) ? NSLog(@"Stagger Guidelines is On.") : NSLog(@"Stagger Guidelines is Off.");
}




@end
