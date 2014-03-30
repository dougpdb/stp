//
//  LESixOfDay+ST.m
//  Six Times Path
//
//  Created by Doug on 8/19/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//




#import "LESixOfDay+ST.h"
#import "NSDate+ST.h"
#import "NSDate+ES.h"
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
	
	// The scheduled time for each log entry is at regular intervals of 2 hours. The first log entry should come at 2 hours after waking, the 2nd 2 hours after that, and so on.
	NSInteger hourInterval	= 2;
	NSDate *date						= day.date;
	oneOfSixLogEntries.timeScheduled	= [date setHour:[day.startHour intValue] + (hourInterval * orderNumberForType)
										   andMinute:[day.startMinute intValue]];
	
	return oneOfSixLogEntries;
}

// DEPRECATED
+(id)logEntryWithAdvice:(Advice *)advice withOrderNumber:(NSInteger)orderNumberForType onDay:(Day *)day withWakingHour:(NSInteger)wakingHour andWakingMinute:(NSInteger)wakingMinute inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	LESixOfDay *oneOfSixLogEntries			= [NSEntityDescription insertNewObjectForEntityForName:@"LESixOfDay"
																			inManagedObjectContext:managedObjectContext];
	// Set the advice to the log entry, and the order of the log entry in the sequence of log entries for the day 
	oneOfSixLogEntries.advice				= advice;
	oneOfSixLogEntries.orderNumberForType	= [NSNumber numberWithInt:orderNumberForType];
	
	// Set relationship to the Day entity
	oneOfSixLogEntries.dayOfSix				= day;
	
	// The scheduled time for each log entry is at regular intervals of 2 hours. The first log entry should come at 2 hours after waking, the 2nd 2 hours after that, and so on.
	NSInteger hourInterval	= 2;
	NSDate *date						= day.date;
	date								=[date setHour:wakingHour + (hourInterval * orderNumberForType) andMinute:wakingMinute];
	oneOfSixLogEntries.timeScheduled	= date;
	
	return oneOfSixLogEntries;
}


#pragma mark - Time Adjustments

-(void)resetScheduledTime
{
	[self resetScheduledTimeAtHourInterval:[self.orderNumberForType intValue]];
//	NSInteger hourInterval	= 2;
//	self.timeScheduled		= [self.dayOfSix.date setHour:[self.dayOfSix.startHour intValue] + (hourInterval * [self.orderNumberForType intValue])
//												andMinute:[self.dayOfSix.startMinute intValue]];
}

-(void)resetScheduledTimeAtHourInterval:(NSInteger)orderNumber
{
	NSInteger hourInterval	= 2;
	self.timeScheduled		= [self.dayOfSix.date setHour:[self.dayOfSix.startHour intValue] + (hourInterval * orderNumber)
												andMinute:[self.dayOfSix.startMinute intValue]];
}

-(void)resetScheduledTimeAtHourInterval:(NSInteger)orderNumber startHour:(NSInteger)startHour startMinute:(NSInteger)startMinute
{
	NSInteger hourInterval	= 2;
	NSDate *date			= [NSDate dateWithMonth:[self.dayOfSix.date month]
											andDate:[self.dayOfSix.date day]
											andYear:[self.dayOfSix.date year]];
	self.timeScheduled		= [date setHour:startHour + (hourInterval * orderNumber)
								  andMinute:startMinute];		
}

-(void)setTimeUpdatedToNow
{
	NSDate *now	= [NSDate date];
	
	if (self.timeFirstUpdated == nil)
		self.timeFirstUpdated	= now;
	
	self.timeLastUpdated		= now;
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


-(BOOL)hasPositiveActionWithText
{
	ActionTaken *action		= [[self getPositiveActionsTaken] anyObject];
	NSInteger lengthOfText	= [[action.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length];
	BOOL hasText			= (lengthOfText > 0) ? YES : NO;
	return hasText;
}

-(BOOL)hasNegativeActionWithText{
	ActionTaken *action		= [[self getNegativeActionsTaken] anyObject];
	NSInteger lengthOfText	= [[action.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length];
	BOOL hasText			= (lengthOfText > 0) ? YES : NO;
	return hasText;
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
