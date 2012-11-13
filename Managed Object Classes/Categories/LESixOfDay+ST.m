//
//  LESixOfDay+ST.m
//  Six Times Path
//
//  Created by Doug on 8/19/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "LESixOfDay+ST.h"
#import "NSDate+ST.h"
#import "Day.h"
#import "Advice.h"
#import "ToDo.h"
#import "ActionTaken.h"

@implementation LESixOfDay (ST)

+(id)logEntryWithAdvice:(Advice *)advice withOrderNumber:(NSInteger)orderNumberForType onDay:(Day *)day inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	LESixOfDay *oneOfSixLogEntries			= [NSEntityDescription insertNewObjectForEntityForName:@"LESixOfDay"
																			inManagedObjectContext:managedObjectContext];
	// Set the advice to the log entry, and the order of the log entry in the sequence of log entries for the day 
	oneOfSixLogEntries.advice				= advice;
	oneOfSixLogEntries.orderNumberForType	= [NSNumber numberWithInt:orderNumberForType];
	
	// Set relationship to the Day entity
	oneOfSixLogEntries.dayOfSix				= day;
	
	// Set the scheduled time for the new log entry
	
	// Get the waking hour and minutes for the day.
	// TEMP
	NSInteger wakingHour	= 5;
	NSInteger wakingMinute	= 45;
	
	// The scheduled time for each log entry is at regular intervals of 2 hours. The first log entry should come at 2 hours after waking, the 2nd 2 hours after that, and so on.
	NSInteger hourInterval	= 2;
	NSDate *date						= day.date;
	date								=[date setHour:wakingHour + (hourInterval * orderNumberForType) andMinute:wakingMinute];
	oneOfSixLogEntries.timeScheduled	= date;
	
	return oneOfSixLogEntries;
}


#pragma mark - Actions Taken

-(NSSet *)getPositiveActionsTaken
{
	return [self.action objectsPassingTest:^(id obj,BOOL *stop){
        ActionTaken *action	= (ActionTaken *)obj;
		return [action.isPositive boolValue];
    }];
}

-(NSSet *)getNegativeActionsTaken
{
	return [self.action objectsPassingTest:^(id obj,BOOL *stop){
        ActionTaken *action	= (ActionTaken *)obj;
		BOOL isNegative		= ([action.isPositive boolValue] == NO);
		return isNegative;
    }];
}


#pragma mark - Logging in Console

-(void)logValuesOfLogEntry
{
	NSLog(@"\n\tDay at timeScheduled: orderNumberForType) Advice:\n\t%@ at %@: %@) %@", self.dayOfSix.date.date, self.timeScheduled.time, self.orderNumberForType, self.advice.name);
	
	NSLog(@"LogEntry.timeFirstUpdated: %@", self.timeFirstUpdated.time);
	NSLog(@"LogEntry.timeLastUpdated: %@", self.timeLastUpdated.time);
	NSLog(@"LogEntry.action: %@", self.action.description);
	NSLog(@"LogEntry.toDo: %@", self.toDo.description);

}
@end
