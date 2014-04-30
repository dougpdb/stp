//
//  STAppDelegate.m
//  Six Times Path
//
//  Created by ICE - Doug on 6/20/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "STAppDelegate.h"
#import <Crashlytics/Crashlytics.h>
#import "TestFlight.h"

#import "SpiritualTradtion.h"
#import "SetOfAdvice.h"
#import "Day+ST.h"
#import "Advice.h"
#import "LESixOfDay.h"
#import "STTodayTVC.h"
#import "STLogEntrySixOfDayTVC.h"
#import "NSDate+ST.h"
#import "NSUserDefaults+ST.h"
#import "Advice.h"

#import "STNotificationController.h"
#import "STApplicationBaseDataController.h"




static NSString *kTestFlightAPIKey	= @"a8e8bc8c4f06c2d6ae5584599aa9a8af_MTc3NTE1MjAxMy0wMS0yMSAwNjo1Nzo1OS45NDcyOTk";
static NSString *kCrashlyticsAPIKey	= @"404953fc9bd6c37e14f978a53ec8dabf001f82bf";

@implementation STAppDelegate

@synthesize window					= _window;
@synthesize debug					= debug;
@synthesize baseDataController		= _baseDataController;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[Crashlytics startWithAPIKey:kCrashlyticsAPIKey];
	
	self.debug							= YES;
	
	self.baseDataController				= [[STApplicationBaseDataController alloc] init];
	
	BOOL spiritualTraditionsAreInCoreData	= [self.baseDataController thereAreCoreDataRecordsForEntity:@"SpiritualTradition"];
	BOOL daysOfLogEntriesAreInCoreData		= [self.baseDataController thereAreCoreDataRecordsForEntity:@"Day"];
	 
	NSUserDefaults *sixTimePathSettings = [NSUserDefaults standardUserDefaults];
	
	if ([sixTimePathSettings noSettingValuesHaveBeenSet]) {
		
		[sixTimePathSettings setDefaultSettingValues];
		
	}

	
    if (!spiritualTraditionsAreInCoreData)
        [self.baseDataController importDefaultCoreData];

    // Override point for customization after application launch.
    UILocalNotification *notification	=	[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (notification) {
		STNotificationController *notificationController	= [STNotificationController new];
		
		[notificationController descriptionOfNotification:notification];
		
		[TestFlight passCheckpoint:@"LAUNCH APP WITH NOTIFICATION"];
    }

/*
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		UISplitViewController *splitViewController		= (UISplitViewController *)self.window.rootViewController;
		UINavigationController *navigationController	= [splitViewController.viewControllers lastObject];
		splitViewController.delegate					= (id)navigationController.topViewController;
		
		UINavigationController *masterNavigationController	= [splitViewController.viewControllers objectAtIndex:0];
		STTodayTVC *controller								= (STTodayTVC *)masterNavigationController.topViewController;
		controller.managedObjectContext						= self.managedObjectContext;
	} else {
*/		UINavigationController *navigationController		= (UINavigationController *)self.window.rootViewController;
		STTodayTVC *todayTVC								= (STTodayTVC *)navigationController.topViewController;
		todayTVC.managedObjectContext						= self.baseDataController.managedObjectContext;
		todayTVC.databaseWasJustCreatedForFirstTime			= !spiritualTraditionsAreInCoreData;
		todayTVC.thereAreCoreDataRecordsForDay				= daysOfLogEntriesAreInCoreData;
	
		if (notification) {
			[self navigateToLogEntryFromNotification:notification forToday:todayTVC];
		}
	//	}
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	
	UINavigationController *navigationController	= (UINavigationController *)self.window.rootViewController;
		
	if ([navigationController.visibleViewController isMemberOfClass:[STTodayTVC class]]) {
		
		STTodayTVC *todayTVC = (STTodayTVC *)navigationController.visibleViewController;
		
		if ([todayTVC isTimeToAddDay]) {
			
			[todayTVC setupDayAndAdviceData];
			[todayTVC.tableView reloadData];
			
		}
	}	
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self.baseDataController saveContext];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
	
    STNotificationController *notificationController	= [STNotificationController new];
	
	[notificationController descriptionOfNotification:notification];

	//----- VIEW NOTIFICATION -----
	UIApplicationState state = [application applicationState];
	if (state == UIApplicationStateInactive) {
		
		//----- APPLICATION WAS IN BACKGROUND - USER HAS SEEN NOTIFICATION AND PRESSED THE ACTION BUTTON -----
		NSLog(@"Local noticiation - App was in background and user pressed action button - \n\"%@\" scheduled at %@", [notificationController adviceTextForNotification:notification], [notificationController timeScheduledForNotification:notification]);
		
		
		UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;

		if ([navigationController.visibleViewController isMemberOfClass:[STLogEntrySixOfDayTVC class]]) {
			
			[(STLogEntrySixOfDayTVC *)navigationController.visibleViewController saveEntry];
			
		}
		
		[navigationController popToRootViewControllerAnimated:NO];
		
		STTodayTVC *todayTVC = (STTodayTVC *)navigationController.topViewController;
		
		if (![todayTVC isTimeToAddDay]) {
			
			[self navigateToLogEntryFromNotification:notification forToday:todayTVC];
			
		}
		
		[notificationController cancelNotification:notification];

		[TestFlight passCheckpoint:@"LAUNCH FROM BACKGROUND FROM NOTIFICATION"];
	
	} else {
		
		//----- APPLICATION IS IN FOREGROUND - USER HAS NOT BEEN PRESENTED WITH THE NOTIFICATION -----
		NSLog(@"Local noticiation - App was in foreground");
		
	}
}

- (void)navigateToLogEntryFromNotification:(UILocalNotification *)notification forToday:(STTodayTVC *)todayTVC
{
    STNotificationController *notificationController = [STNotificationController new];
	[todayTVC setupDaysFetchedResultsController];
	
	todayTVC.entryFromNotification = [notificationController entryFromNotification:notification forDay:todayTVC.thisDay];
	
	if (todayTVC.entryFromNotification != (LESixOfDay *)[NSNull null]) {
	
		[todayTVC performSegueWithIdentifier:@"Guideline Entry" sender:self];
	
	}
}


#pragma mark - Application State Changes



@end
