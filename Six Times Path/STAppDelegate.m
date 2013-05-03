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

#import "STNotificationController.h"


#import "Advice.h"

#define TESTING	1

static NSString *kTestFlightAPIKey	= @"a8e8bc8c4f06c2d6ae5584599aa9a8af_MTc3NTE1MjAxMy0wMS0yMSAwNjo1Nzo1OS45NDcyOTk";
static NSString *kCrashlyticsAPIKey	= @"404953fc9bd6c37e14f978a53ec8dabf001f82bf";

@implementation STAppDelegate

@synthesize window						= _window;
@synthesize managedObjectContext		= __managedObjectContext;
@synthesize managedObjectModel			= __managedObjectModel;
@synthesize persistentStoreCoordinator	= __persistentStoreCoordinator;
@synthesize fetchedResultsController	= __fetchedResultsController;
@synthesize debug						= debug;


#pragma mark - Database set up

-(SpiritualTradtion *)insertSpiritualTraditionWithName:(NSString *)traditionName
{
    SpiritualTradtion *tradition    = [NSEntityDescription insertNewObjectForEntityForName:@"SpiritualTradition"
                                                                    inManagedObjectContext:self.managedObjectContext];
    tradition.name                  = traditionName;
    tradition.isBaseInstall         = [NSNumber numberWithBool:YES];
    
    [self.managedObjectContext save:nil];

    return tradition;
}

-(Advice *)insertAdviceWithName:(NSString *)adviceName
{
    Advice *advice					= [NSEntityDescription insertNewObjectForEntityForName:@"Advice"
                                                    inManagedObjectContext:self.managedObjectContext];
    advice.name						= adviceName;
    
    [self.managedObjectContext save:nil];
    
    return advice;
}

-(SetOfAdvice *)insertSetOfAdviceWithName:(NSString *)setOfAdviceName
{
    SetOfAdvice *setOfAdvice                = [NSEntityDescription insertNewObjectForEntityForName:@"SetOfAdvice"
                                                                            inManagedObjectContext:self.managedObjectContext];
    setOfAdvice.name                        = setOfAdviceName;
    setOfAdvice.isBaseInstall               = [NSNumber numberWithBool:YES];
    
    return setOfAdvice;
}

-(SetOfAdvice *)insertSetOfAdviceWithAdviceName:(NSString *)setOfAdviceName andArrayOfGuidelineNames:(NSArray *)arrayOfGuidelineNames intoTradition:(SpiritualTradtion *)tradition
{           
    SetOfAdvice *setOfAdvice                = [self insertSetOfAdviceWithName:setOfAdviceName];
    
    setOfAdvice.isBaseInstall               = [NSNumber numberWithBool:YES];
    setOfAdvice.name                        = setOfAdviceName;
    setOfAdvice.orderNumberInFollowedSets   = 0;
    NSLog(@"The name of a set of advice has been set: %@", setOfAdvice.name);
    
    // set up relationships
    setOfAdvice.practicedWithinTradition	= tradition;
    [tradition addAdheresToSetOfAdviceObject:setOfAdvice];

    for (NSString *adviceName in arrayOfGuidelineNames) {
        [self insertAdviceWithName:adviceName intoSetOfAdvice:setOfAdvice withOrderNumber:[NSNumber numberWithInteger:[arrayOfGuidelineNames indexOfObject:adviceName]+1]];
    }
    
    
    return setOfAdvice;
}

-(Advice *)insertAdviceWithName:(NSString *)adviceName intoSetOfAdvice:(SetOfAdvice *)setOfAdvice withOrderNumber:(NSNumber *)orderNumber
{
    Advice *advice                      = [NSEntityDescription insertNewObjectForEntityForName:@"Advice"
                                                                inManagedObjectContext:self.managedObjectContext];
    
    // set properties of advice
    advice.isBaseInstall                = [NSNumber numberWithBool:YES];
    advice.name                         = adviceName;
    advice.summary                      = @"";
    advice.orderNumberInSet             = orderNumber;
    
    // set up relationships
    advice.containedWithinSetOfAdvice   = setOfAdvice;
    [setOfAdvice addContainsAdviceObject:advice];
    
    NSLog(@"New advice inserted into %@:\nname: %@\norderNumberInSet: %@", setOfAdvice.name, advice.name, advice.orderNumberInSet);
    return advice;
}

-(void)importDefaultCoreData 
{
    // Buddhist Tradition
    NSArray *adviceTenVirtues		=@[@"Protect and nuture life",
									   @"Honor others' property",
									   @"Honor others' and your own relationships",
									   @"Speak truthfully",
									   @"Speak to promote agreement and to bring people together",
									   @"Speak kind words",
									   @"Speak meaningfully",
									   @"Be happy for others when things go well for them",
									   @"Feel for others when they experience misfortune",
									   @"Maintain correct view"];
	
	NSArray *adviceTenNonvirtues	= @[@"Refrain from killing",
										@"Refrain from stealing",
										@"Refrain from sexual misconduct",
										@"Refrain from lying",
										@"Refrain from divisive speech",
										@"Refrain from harsh words",
										@"Refrain from meaningless talk",
										@"Refrain from craving",
										@"Refrain from illwill",
										@"Refrain from wrong views"];
    
    // Christian Tradition
    NSArray *adviceTenCommandmentsPositive  = [NSArray arrayWithObjects:@"Honor the Lord thy God",
                                               @"Worship God and what is Holy",
                                               @"Speak with love and respect about God and God’s creation",
                                               @"Observe the Sabbath day by keeping it Holy",
                                               @"Honor your father and your mother",
                                               @"Protect and nurture life",
                                               @"Honor others' and your own relationships",
                                               @"Honor other people’s property",
                                               @"Speak truthfully",
                                               @"Be happy for the fortune of others",
                                               nil];
    
    NSArray *adviceBeatitudes       = [NSArray arrayWithObjects:@"Blessed are the poor in spirit, for theirs in the kingdom of heaven.",
                                     @"Blessed are those who mourn, for they will be comforted.",
                                     @"Blessed are the meek, for they will inherit the earth.",
                                     @"Blessed are those who hunger and thirst for righteousness, for they will be filled.",
                                     @"Blessed are the merciful for they will be shown mercy.",
                                     @"Blessed are the pure in heart, for they will see God.",
                                     @"Blessed are the peacemakers, for they will be called children of God.",
                                     @"Blessed are those who are persecuted because of righteousness, for theirs is the kingdom of heaven.",
                                     @"Blessed are you when people insult you, persecute you and falsely say all kinds of evil against you because of me.  Rejoice and be glad, because great is your reward in heaven. ",
                                     nil];
    
    // Civic/secular Tradition
    NSArray *adviceBoyScoutOath     = [NSArray arrayWithObjects:@"Do my duty to God",
                                       @"Do my duty to my country",
                                       @"Help other people at all times",
                                       @"Keep myself physically strong",
                                       @"Keep myself mentally awake",
                                       @"Keep myself morally straight",
                                       @"A scout is trustworthy",
                                       @"A scout is loyal",
                                       @"A scout is helpful",
                                       @"A scout is friendly",
                                       @"A scout is courteous",
                                       @"A scout is kind",
                                       @"A scout is obedient",
                                       @"A scout is cheerful",
                                       @"A scout is thrifty",
                                       @"A scout is brave",
                                       @"A scout is clean",
                                       @"A scout is reverent",
                                       nil];
    NSArray *adviceGirlScoutOath    = [NSArray arrayWithObjects:@"Serve God",
                                       @"Serve my country",
                                       @"Help people at all times",
                                       @"Be honest and fair",
                                       @"Be friendly and helpful",
                                       @"Be considerate and caring",
                                       @"Be courageous and strong",
                                       @"Be responsibile for what I say and do",
                                       @"Respect myself and others",
                                       @"Respect authority",
                                       @"Use resources wisely",
                                       @"Make the world a better place",
                                       @"Be a sister to every Girl Scout",
                                       nil];
    
    
    
    
    NSLog(@"Importing default values into Core Data for Traditions.");
    // Set up Buddhist guidelines
    SpiritualTradtion *traditionBuddhism		= [self insertSpiritualTraditionWithName:@"Buddhism"];
    SetOfAdvice *theTenVirtuesSetOfAdvice		= [self insertSetOfAdviceWithAdviceName:@"10 Virtues"
															  andArrayOfGuidelineNames:adviceTenVirtues
																		 intoTradition:traditionBuddhism];
	SetOfAdvice *theTenNonvirtuesSetOfAdvice	= [self insertSetOfAdviceWithAdviceName:@"10 Nonvirtues"
																andArrayOfGuidelineNames:adviceTenNonvirtues
																		   intoTradition:traditionBuddhism];
    
	theTenNonvirtuesSetOfAdvice.orderNumberInFollowedSets = [NSNumber numberWithInt:1];
	theTenVirtuesSetOfAdvice.orderNumberInFollowedSets = [NSNumber numberWithInt:2];
    
    // Set up Christian guidelines
    SpiritualTradtion *traditionChristianity	= [self insertSpiritualTraditionWithName:@"Christianity"];
    SetOfAdvice *tenCommandments                = [self insertSetOfAdviceWithAdviceName:@"The 10 Commandments (Positively Stated)"
															   andArrayOfGuidelineNames:adviceTenCommandmentsPositive
																		  intoTradition:traditionChristianity];
    SetOfAdvice *beatitudes                     = [self insertSetOfAdviceWithAdviceName:@"The Beatitudes"
															   andArrayOfGuidelineNames:adviceBeatitudes
																		  intoTradition:traditionChristianity];
    
	tenCommandments.orderNumberInFollowedSets	= [NSNumber numberWithInt:0];
	beatitudes.orderNumberInFollowedSets        = [NSNumber numberWithInt:0];
    
    
    // Set up Civic guidelines
    SpiritualTradtion *civicTradition           = [self insertSpiritualTraditionWithName:@"Civic"];
    SetOfAdvice *boyScoutOathAndLaw             = [self insertSetOfAdviceWithAdviceName:@"Boy Scout Oath and Law" andArrayOfGuidelineNames:adviceBoyScoutOath intoTradition:civicTradition];
    SetOfAdvice *girlScoutOathAndPromise        = [self insertSetOfAdviceWithAdviceName:@"Girl Scout Oath and Promise" andArrayOfGuidelineNames:adviceGirlScoutOath intoTradition:civicTradition];

    boyScoutOathAndLaw.orderNumberInFollowedSets		= [NSNumber numberWithInt:0];
	girlScoutOathAndPromise.orderNumberInFollowedSets	= [NSNumber numberWithInt:0];
	
	NSLog(@"Importing completed for Traditions!");
}



#pragma mark - Core Data

- (void)setupFetchedResultsController
{
    NSString *entityName			= @"SpiritualTradition"; // Put your entity name here
    
    NSFetchRequest *request			= [NSFetchRequest fetchRequestWithEntityName:entityName];

    // 3 - Filter it if you want
    //request.predicate = [NSPredicate predicateWithFormat:@"Person.name = Blah"];
    
    // 4 - Sort it if you want
    request.sortDescriptors			= [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                     ascending:YES
                                                                                      selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    // 5 - Fetch it
    self.fetchedResultsController	= [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    [self.fetchedResultsController performFetch:nil];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
	#ifdef TESTING
	//		[TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
	[TestFlight takeOff:kTestFlightAPIKey];
	#endif

	[Crashlytics startWithAPIKey:kCrashlyticsAPIKey];
	
	self.debug	= YES;
	
    [self setupFetchedResultsController];
	
    if (![[self.fetchedResultsController fetchedObjects] count] > 0 )
        [self importDefaultCoreData];
	

    // Override point for customization after application launch.
    UILocalNotification *notification			=	[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
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
		todayTVC.managedObjectContext						= self.managedObjectContext;
	
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
	
	NSLog(@"The visibleViewController is %@", [[navigationController.visibleViewController class] description]);
	
	if ([navigationController.visibleViewController isMemberOfClass:[STTodayTVC class]]) {
		STTodayTVC *todayTVC						= (STTodayTVC *)navigationController.visibleViewController;
		if ([todayTVC isTimeToAddDay]) {
			[todayTVC setupDayAndAdviceData];
			[todayTVC.tableView reloadData];
		}
	}
	
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
	
    STNotificationController *notificationController	= [STNotificationController new];
	
	[notificationController descriptionOfNotification:notification];

	//----- VIEW NOTIFICATION -----
	UIApplicationState state = [application applicationState];
	if (state == UIApplicationStateInactive)
	{
		//----- APPLICATION WAS IN BACKGROUND - USER HAS SEEN NOTIFICATION AND PRESSED THE ACTION BUTTON -----
		NSLog(@"Local noticiation - App was in background and user pressed action button - \n\"%@\" scheduled at %@", [notificationController adviceTextForNotification:notification], [notificationController timeScheduledForNotification:notification]);
		
		
		UINavigationController *navigationController	= (UINavigationController *)self.window.rootViewController;

		if ([navigationController.visibleViewController isMemberOfClass:[STLogEntrySixOfDayTVC class]]) {
			[(STLogEntrySixOfDayTVC *)navigationController.visibleViewController saveEntry];
		}
		
		[navigationController popToRootViewControllerAnimated:NO];
		
		STTodayTVC *todayTVC							= (STTodayTVC *)navigationController.topViewController;
		
		if (![todayTVC isTimeToAddDay]) {
			[self navigateToLogEntryFromNotification:notification forToday:todayTVC];
		}
		
		[notificationController cancelNotification:notification];

		[TestFlight passCheckpoint:@"LAUNCH FROM BACKGROUND FROM NOTIFICATION"];
	}
	else
	{
		//----- APPLICATION IS IN FOREGROUND - USER HAS NOT BEEN PRESENTED WITH THE NOTIFICATION -----
		NSLog(@"Local noticiation - App was in foreground");
		
	}
}

- (void)navigateToLogEntryFromNotification:(UILocalNotification *)notification forToday:(STTodayTVC *)todayTVC
{
    STNotificationController *notificationController	= [STNotificationController new];
	[todayTVC setupDaysFetchedResultsController];
	todayTVC.entryFromNotification						= [notificationController entryFromNotification:notification forDay:todayTVC.thisDay];
	if (todayTVC.entryFromNotification != (LESixOfDay *)[NSNull null])
		[todayTVC performSegueWithIdentifier:@"Guideline Entry" sender:self];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SixTimesPath.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    // options added to accomodate updated data model
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Application State Changes



@end
