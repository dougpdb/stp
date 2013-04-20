//
//  STNotificationController.m
//  Six Times Path
//
//  Created by Doug on 4/15/13.
//  Copyright (c) 2013 A Great Highway. All rights reserved.
//

#import "STNotificationController.h"
#import "LESixOfDay+ST.h"
#import "Advice.h"
#import "NSDate+ST.h"
#import "NSDate+ES.h"
#import "Day+ST.h"


static NSString *kLogEntryTimeScheduled				= @"logEntryTimeScheduled";
static NSString *kLogEntryAdviceText				= @"logEntryAdviceText";
static NSString *kLogEntryOrderNumberInSetOfEntries	= @"logEntryOrderNumberInSetOfEntries";

@implementation STNotificationController

+(STNotificationController *)new
{
	return [[STNotificationController alloc] init];
}

- (UILocalNotification *)newNotification:(LESixOfDay *)sixOfDayLogEntry
{
	
	NSDictionary *userInfo	= @{
		kLogEntryTimeScheduled				: sixOfDayLogEntry.timeScheduled.timeAndDate,
		kLogEntryAdviceText					: sixOfDayLogEntry.advice.name,
		kLogEntryOrderNumberInSetOfEntries	: sixOfDayLogEntry.orderNumberForType
	};
	
    UILocalNotification *localNotification	= [[UILocalNotification alloc] init]; //Create the localNotification object
    
	localNotification.fireDate				= sixOfDayLogEntry.timeScheduled; //Set the date when the alert will be launched using the date adding the time the user selected on the timer
    localNotification.alertAction			= @"OK";							//The button's text that launches the application and is shown in the alert
	localNotification.alertBody				= sixOfDayLogEntry.advice.name;		//Set the message in the notification from the textField's text
    localNotification.hasAction				= YES;								//Set that pushing the button will launch the application
																						//    localNotification.applicationIconBadgeNumber	= 1; //Set the Application Icon Badge Number of the application's icon to the current Application Icon Badge Number plus 1
	localNotification.soundName				= UILocalNotificationDefaultSoundName;
	localNotification.userInfo				= userInfo;
	
	return localNotification;
}

- (void)addNotification:(LESixOfDay *)sixOfDayLogEntry
{
	UIApplication *STApplication			= [UIApplication sharedApplication];

    [STApplication scheduleLocalNotification:[self newNotification:sixOfDayLogEntry]]; 
}

-(void)addNotification:(LESixOfDay *)sixOfDayLogEntry withApplicationIconBadgeNumber:(NSInteger)badgeNumber
{
	UIApplication *STApplication				= [UIApplication sharedApplication];
	
	UILocalNotification *newNotification		= [self newNotification:sixOfDayLogEntry];
	
	newNotification.applicationIconBadgeNumber	= badgeNumber;
	
    [STApplication scheduleLocalNotification:newNotification];
	
}

-(void)addNotifications:(NSArray *)remainingSixOfDayLogEntries
{
	NSInteger badgeNumber					= 0;
	for (LESixOfDay *remainingEntry in remainingSixOfDayLogEntries)
		[self addNotification:remainingEntry withApplicationIconBadgeNumber:++badgeNumber];
}

-(void)cancelNotification:(UILocalNotification *)notification
{
	UIApplication *STApplication				= [UIApplication sharedApplication];
	
	if ([self notificationHasFired:notification])
		STApplication.applicationIconBadgeNumber	= STApplication.applicationIconBadgeNumber - 1;
	
	[STApplication cancelLocalNotification:notification];
	
	[self setApplicationIconBadgeNumbersForAllNotifications];
}

-(void)cancelNotificationFor:(LESixOfDay *)sixOfDayLogEntry
{
	UIApplication *STApplication				= [UIApplication sharedApplication];
	NSArray *allSTScheduledNotifications		= STApplication.scheduledLocalNotifications;
	
	for (UILocalNotification *notification in allSTScheduledNotifications) {
		if ([sixOfDayLogEntry.timeScheduled.timeAndDate isEqualToString:[notification.userInfo valueForKey:kLogEntryTimeScheduled]]) {
			
			if ([self notificationHasFired:notification]) {
				STApplication.applicationIconBadgeNumber	= STApplication.applicationIconBadgeNumber - 1;
			}
			
			[self cancelNotification:notification];
			
			break;
			
		}
	}
}

-(void)cancelAllNotifications
{
	UIApplication *STApplication				= [UIApplication sharedApplication];

	STApplication.applicationIconBadgeNumber	= 0;

	[STApplication cancelAllLocalNotifications];
	
	NSLog(@"All local notifications have been cancelled. The remaining local notifications are %i.", [STApplication.scheduledLocalNotifications count]);
}

-(void)descriptionOfNotification:(UILocalNotification *)notification
{
	NSLog(@"LOCAL NOTIFICATION RECEVIED\nfireDate: %@\ntimeScheduled: %@\nadvice text: %@\norder number in set: %@\nnotification.applicationIconBadgeNumber: %i\n.application.applicationIconBadgeNumber: %@\n",
		  [self fireDateForNotification:notification],
		  [self timeScheduledForNotification:notification],
		  [self adviceTextForNotification:notification],
		  [self orderNumberInSetOfEntriesForNotification:notification],
		  notification.applicationIconBadgeNumber,
		  [[UIApplication sharedApplication] valueForKey:@"applicationIconBadgeNumber"]);
}

-(LESixOfDay *)entryFromNotification:(UILocalNotification *)notification forDay:(Day *)day
{
	NSNumber *orderNumberInSetOfEntries			= [notification.userInfo valueForKey:kLogEntryOrderNumberInSetOfEntries];
		
	return (LESixOfDay *)[day entrySixOfDay:orderNumberInSetOfEntries];
}

-(BOOL)notificationHasFired:(UILocalNotification *)notifcation
{
	return ([[NSDate date] isLaterThanDate:notifcation.fireDate]);
}

-(void)setApplicationIconBadgeNumbersForAllNotifications
{
	UIApplication *STApplication				= [UIApplication sharedApplication];

	NSInteger applicationIconBadgeNumber		= STApplication.applicationIconBadgeNumber;

	NSArray *allSTScheduledNotifications		= STApplication.scheduledLocalNotifications;

	for (UILocalNotification *notification in allSTScheduledNotifications) {

		notification.applicationIconBadgeNumber	= ++applicationIconBadgeNumber;
		
		NSLog(@"The applicationIconBadgeNumber for \"%@\" is %i.", [self adviceTextForNotification:notification], notification.applicationIconBadgeNumber);
	}

}


-(NSString *)adviceTextForNotification:(UILocalNotification *)notification
{
	return [notification.userInfo valueForKey:kLogEntryAdviceText];
}

-(NSString *)timeScheduledForNotification:(UILocalNotification *)notification
{
	return [notification.userInfo valueForKey:kLogEntryTimeScheduled];
}

-(NSString *)fireDateForNotification:(UILocalNotification *)notification
{
	return notification.fireDate.timeAndDate;
}

-(NSNumber *)orderNumberInSetOfEntriesForNotification:(UILocalNotification *)notification
{
	return [notification.userInfo valueForKey:kLogEntryOrderNumberInSetOfEntries];
}

//-(void)goToScreenForSixOfDayLogEntryFromNotification:(UILocalNotification *)notification
//{
//	
//}
@end
