//
//  STApplicationBaseData.m
//  Six Times Path
//
//  Created by Doug on 5/9/13.
//  Copyright (c) 2013 A Great Highway. All rights reserved.
//

#import "STApplicationBaseDataController.h"
#import "SpiritualTradtion.h"
#import "SetOfAdvice.h"
#import "Day+ST.h"
#import "Advice.h"
#import "LESixOfDay.h"
#import "STTodayTVC.h"
#import "STLogEntrySixOfDayTVC.h"
#import "NSDate+ST.h"
#import "Advice.h"


@implementation STApplicationBaseDataController


@synthesize managedObjectContext		= __managedObjectContext;
@synthesize managedObjectModel			= __managedObjectModel;
@synthesize persistentStoreCoordinator	= __persistentStoreCoordinator;
@synthesize fetchedResultsController	= __fetchedResultsController;

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
								  @"Give to others",
								  @"Honor others' and your own relationships",
								  @"Speak truthfully",
								  @"Speak to promote agreement and to bring people together",
								  @"Speak kind words",
								  @"Speak meaningfully",
								  @"Be content with what you have",
								  @"Wish others well and feel for them when they experience misfortune",
								  @"Examine and learn to understand"];
	
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
	/*
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
	 */
	NSArray *adviceTenCommandments			= @[@"Worship no god but the Lord your God",
									  @"Do not make or bow down to any idol",
									  @"Do not misuse God's name to curse others or for other evil purposes",
									  @"Observe the Sabbath day to keep it holy; rest",
									  @"Respect your father and your mother",
									  @"Do not commit murder",
									  @"Do not commit adultery",
									  @"Do not steal",
									  @"Do not lie about anyone",
									  @"Do not desire to possess for yourself another person's spouse or property"];
    
    NSArray *adviceBeatitudes       = [NSArray arrayWithObjects:@"Blessed are the poor in spirit, for theirs is the kingdom of heaven.",
									   @"Blessed are those who mourn, for they will be comforted.",
									   @"Blessed are the meek, for they will inherit the earth.",
									   @"Blessed are those who hunger and thirst for righteousness, for they will be filled.",
									   @"Blessed are the merciful for they will be shown mercy.",
									   @"Blessed are the pure in heart, for they will see God.",
									   @"Blessed are the peacemakers, for they will be called children of God.",
									   @"Blessed are those who are persecuted because of righteousness, for theirs is the kingdom of heaven.",
									   @"Blessed are you when people insult you, persecute you and falsely say all kinds of evil against you because of me.  Rejoice and be glad, because great is your reward in heaven. ",
									   nil];
    
	NSArray *prayerStFrancis		= @[@"Seek to be an instrument of the Lord’s peace.",
							   @"Where there is hatred, let me sow love.",
							   @"Where there is injury, let me sow pardon.",
							   @"Where there is doubt, let me sow faith.",
							   @"Where there is despair, let me sow hope.",
							   @"Where there is darkness, let me sow light.",
							   @"Where where there is sadness, let me sow joy.",
							   @"Grant that I may not so much seek to be consoled as to console.",
							   @"Grant that I may not so much seek to be understood as to understand.",
							   @"Grant that I may not so much seek to be loved as to love.",
							   @"May I act with the understanding that it is in giving that we receive.",
							   @"May I act with the understanding that it is in pardoning that we are pardoned.",
							   @"May I act with the understanding that it is in pardoning that we are pardoned.",
							   @"Reflect upon how I find the prayer of St. Francis to be true (\"Amen]\") based upon my direct experience of engaging it. Consider how that differs from assumptions I may have made in the past about the prayer."];
	
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
    
    // Islam
	NSArray *moralCommandmentsIslam	= @[@"Worship only Allah",
									 @"Be kind, honorable and humble to your parents",
									 @"Be neither miserly nor wasteful in one's expenditure",
									 @"Do not engage in 'mercy killings' for fear of starvation",
									 @"Do not commit adultery",
									 @"Do not kill unjustly",
									 @"Care for orphaned children",
									 @"Keep your promises",
									 @"Be honest and fair in your interactions",
									 @"Do not be arrogant in one's claims or beliefs"];
    
    
    NSLog(@"Importing default values into Core Data for Traditions.");
    // Set up Buddhist guidelines
    SpiritualTradtion *traditionBuddhism		= [self insertSpiritualTraditionWithName:@"Buddhism"];
    SetOfAdvice *theTenVirtuesSetOfAdvice		= [self insertSetOfAdviceWithAdviceName:@"10 Virtues"
														  andArrayOfGuidelineNames:adviceTenVirtues
																	 intoTradition:traditionBuddhism];
	SetOfAdvice *theTenNonvirtuesSetOfAdvice	= [self insertSetOfAdviceWithAdviceName:@"10 Nonvirtues"
															andArrayOfGuidelineNames:adviceTenNonvirtues
																	   intoTradition:traditionBuddhism];
    
	theTenNonvirtuesSetOfAdvice.orderNumberInFollowedSets = [NSNumber numberWithInt:0];
	theTenVirtuesSetOfAdvice.orderNumberInFollowedSets = [NSNumber numberWithInt:0];
    
    // Set up Christian guidelines
    SpiritualTradtion *traditionChristianity	= [self insertSpiritualTraditionWithName:@"Christianity"];
    SetOfAdvice *tenCommandments                = [self insertSetOfAdviceWithAdviceName:@"The 10 Commandments"
															   andArrayOfGuidelineNames:adviceTenCommandments
																		  intoTradition:traditionChristianity];
	
    SetOfAdvice *beatitudes                     = [self insertSetOfAdviceWithAdviceName:@"The Beatitudes"
															   andArrayOfGuidelineNames:adviceBeatitudes
																		  intoTradition:traditionChristianity];
	
	SetOfAdvice *prayerOfStFrancis				= [self insertSetOfAdviceWithAdviceName:@"Prayer of St. Francis of Assisi"
													 andArrayOfGuidelineNames:prayerStFrancis
																intoTradition:traditionChristianity];
	
    
	tenCommandments.orderNumberInFollowedSets	= [NSNumber numberWithInt:0];
	beatitudes.orderNumberInFollowedSets        = [NSNumber numberWithInt:0];
	prayerOfStFrancis.orderNumberInFollowedSets	= [NSNumber numberWithInt:0];
    
    // Set up Civic guidelines
    SpiritualTradtion *civicTradition           = [self insertSpiritualTraditionWithName:@"Civic"];
    SetOfAdvice *boyScoutOathAndLaw             = [self insertSetOfAdviceWithAdviceName:@"Boy Scout Oath and Law" andArrayOfGuidelineNames:adviceBoyScoutOath intoTradition:civicTradition];
    SetOfAdvice *girlScoutOathAndPromise        = [self insertSetOfAdviceWithAdviceName:@"Girl Scout Oath and Promise" andArrayOfGuidelineNames:adviceGirlScoutOath intoTradition:civicTradition];
	
    boyScoutOathAndLaw.orderNumberInFollowedSets		= [NSNumber numberWithInt:0];
	girlScoutOathAndPromise.orderNumberInFollowedSets	= [NSNumber numberWithInt:0];
	
	// Set up Islamic guidelines
	SpiritualTradtion *islam					= [self insertSpiritualTraditionWithName:@"Islam"];
	SetOfAdvice *foundationalMoralCommandments	= [self insertSetOfAdviceWithAdviceName:@"Precepts from Al-Israa"
															  andArrayOfGuidelineNames:moralCommandmentsIslam
																		 intoTradition:islam];
	
	foundationalMoralCommandments.orderNumberInFollowedSets	= [NSNumber numberWithInt:0];
	
	NSLog(@"Importing completed for Traditions!");
}



#pragma mark - Core Data

- (BOOL)thereAreCoreDataRecordsForEntity:(NSString *)entityName
{
	NSString *sortDescriptorKey;
	if ([entityName isEqualToString:@"SpiritualTradition"])
		sortDescriptorKey	= @"name";
	else if ([entityName isEqualToString:@"Day"])
		sortDescriptorKey	= @"date";

	NSFetchRequest *request									= [NSFetchRequest fetchRequestWithEntityName:entityName];
    request.sortDescriptors									= @[[NSSortDescriptor sortDescriptorWithKey:sortDescriptorKey
																							ascending:NO]];
    NSFetchedResultsController *fetchedResultsController	= [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    [fetchedResultsController performFetch:nil];
	return ([fetchedResultsController.fetchedObjects count] > 0);
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
 

@end
