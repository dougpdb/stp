//
//  NSUserDefaults+ST.h
//  Six Times
//
//  Created by Doug on 4/7/14.
//  Copyright (c) 2014 A Great Highway. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (ST)


-(BOOL)noSettingValuesHaveBeenSet;

-(BOOL)isAppBadgeOn;
-(BOOL)isNotificationsOn;
-(BOOL)isStaggerDailyGuidelinesOn;

-(void)turnOnAppBadge;
-(void)turnOffAppBadge;

-(void)turnOnNotifications;
-(void)turnOffNotifications;

-(void)turnOnStaggerDailyGuidelines;
-(void)turnOffStaggerDailyGuidelines;

-(void)setDefaultSettingValues;

-(void)showLogOfAllSettings;

@end
