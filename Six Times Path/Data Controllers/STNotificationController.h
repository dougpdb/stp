//
//  STNotificationController.h
//  Six Times Path
//
//  Created by Doug on 4/15/13.
//  Copyright (c) 2013 A Great Highway. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LESixOfDay, Day;

@interface STNotificationController : NSObject

+ (STNotificationController *)new;

- (void)addNotification:(LESixOfDay *)sixOfDayLogEntry;
- (void)addNotification:(LESixOfDay *)sixOfDayLogEntry withApplicationIconBadgeNumber:(NSInteger)badgeNumber;
- (void)addNotifications:(NSArray *)remainingSixOfDayLogEntries;
- (void)cancelNotification:(UILocalNotification *)notification;
- (void)cancelNotificationFor:(LESixOfDay *)sixOfDayLogEntry;
- (void)cancelAllNotifications;
- (void)descriptionOfNotification:(UILocalNotification *)notification;
- (LESixOfDay *)entryFromNotification:(UILocalNotification *)notification forDay:(Day *)day;
- (BOOL)notificationHasFired:(UILocalNotification *)notifcation;
- (void)setApplicationIconBadgeNumbersForAllNotifications;

- (NSString *)adviceTextForNotification:(UILocalNotification *)notification;
- (NSString *)timeScheduledForNotification:(UILocalNotification *)notification;
- (NSString *)fireDateForNotification:(UILocalNotification *)notification;
- (NSNumber *)orderNumberInSetOfEntriesForNotification:(UILocalNotification *)notification;


@end
