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
	
	BOOL entryAlreadyHasNotification			= NO;
	
	for (UILocalNotification *notification in STApplication.scheduledLocalNotifications) {
		entryAlreadyHasNotification				= [sixOfDayLogEntry.advice.name isEqualToString:[self adviceTextForNotification:notification]];
		if (entryAlreadyHasNotification)
			break;
	}
	
	if (!entryAlreadyHasNotification) {
		UILocalNotification *newNotification		= [self newNotification:sixOfDayLogEntry];
		newNotification.applicationIconBadgeNumber	= badgeNumber;
		[STApplication scheduleLocalNotification:newNotification];
	}
	
}

-(void)addNotifications:(NSArray *)remainingSixOfDayLogEntries
{
	NSInteger badgeNumber						= 0;
	for (LESixOfDay *remainingEntry in remainingSixOfDayLogEntries)
		[self addNotification:remainingEntry withApplicationIconBadgeNumber:++badgeNumber];
}

-(void)cancelNotification:(UILocalNotification *)notification
{
	UIApplication *STApplication				= [UIApplication sharedApplication];
	
	if ([self notificationHasFired:notification])
		[self decrementApplicationIconBadgeNumber];
	
	NSLog(@"A notification should be cancelled with adviceText \"%@\" and fireDate %@.", [self adviceTextForNotification:notification], notification.fireDate.timeAndDate);
	[STApplication cancelLocalNotification:notification];
	
	//	NSLog(@"The notification should be cancelled. There are now %i scheduled local notifications.", [STApplication.scheduledLocalNotifications count]);
	
	[self setApplicationIconBadgeNumbersForAllNotifications];
}

-(void)cancelNotificationFor:(LESixOfDay *)sixOfDayLogEntry
{
	UIApplication *STApplication				= [UIApplication sharedApplication];
	NSArray *allSTScheduledNotifications		= STApplication.scheduledLocalNotifications;
	
	NSLog(@"A notification should be cancelled for the entry with advice \"%@\" that is scheduled at %@.", sixOfDayLogEntry.advice.name, sixOfDayLogEntry.timeScheduled.date);
	
	for (UILocalNotification *notification in allSTScheduledNotifications) {
		
		if ([sixOfDayLogEntry.advice.name isEqualToString:[self adviceTextForNotification:notification]])
			[self cancelNotification:notification];
						
	}
}

-(void)cancelAllNotifications
{
	UIApplication *STApplication				= [UIApplication sharedApplication];

	STApplication.applicationIconBadgeNumber	= 0;

	[STApplication cancelAllLocalNotifications];
	
	NSLog(@"All local notifications have been cancelled. The remaining local notifications are %i.", [STApplication.scheduledLocalNotifications count]);
}

-(void)decrementApplicationIconBadgeNumber
{
	UIApplication *STApplication			= [UIApplication sharedApplication];
	STApplication.applicationIconBadgeNumber--;
}

-(void)descriptionOfNotification:(UILocalNotification *)notification
{
	NSLog(@"LOCAL NOTIFICATION\nfireDate: %@\ntimeScheduled: %@\nadvice text: %@\norder number in set: %@\nnotification.applicationIconBadgeNumber: %i\napplication.applicationIconBadgeNumber: %@\n",
		  [self fireDateForNotification:notification],
		  [self timeScheduledForNotification:notification],
		  [self adviceTextForNotification:notification],
		  [self orderNumberInSetOfEntriesForNotification:notification],
		  notification.applicationIconBadgeNumber,
		  [[UIApplication sharedApplication] valueForKey:@"applicationIconBadgeNumber"]);
}

-(void)descriptionOfAllNotifications
{
	UIApplication *STApplication			= [UIApplication sharedApplication];

	for (UILocalNotification *notification in STApplication.scheduledLocalNotifications)
		[self descriptionOfNotification:notification];
}

-(LESixOfDay *)entryFromNotification:(UILocalNotification *)notification forDay:(Day *)day
{
//	NSNumber *orderNumberInSetOfEntries			= [notification.userInfo valueForKey:kLogEntryOrderNumberInSetOfEntries];
//	
	NSString *adviceName					= [self adviceTextForNotification:notification];
		
	return (LESixOfDay *)[day entrySixOfDayWithAdviceName:adviceName];
}

-(BOOL)notificationHasFired:(UILocalNotification *)notifcation
{
	return ([[NSDate date] isLaterThanDate:notifcation.fireDate]);
}

-(void)setApplicationIconBadgeNumbersForAllNotifications
{
	UIApplication *STApplication				= [UIApplication sharedApplication];
	NSDate *now									= [NSDate date];

	NSInteger applicationIconBadgeNumber		= 0; // STApplication.applicationIconBadgeNumber;

	NSArray *allSTScheduledNotifications		= STApplication.scheduledLocalNotifications;

	for (UILocalNotification *notification in allSTScheduledNotifications) {
		if ([notification.fireDate isLaterThanDate:now]) {
			notification.applicationIconBadgeNumber	= ++applicationIconBadgeNumber;
		
			NSLog(@"The applicationIconBadgeNumber for \"%@\" is %i.", [self adviceTextForNotification:notification], notification.applicationIconBadgeNumber);
		}
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
