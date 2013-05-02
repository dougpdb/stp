//
//  LESixOfDay+ST.h
//  Six Times Path
//
//  Created by Doug on 8/19/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "LESixOfDay.h"
#import <TextExpander/SMTEDelegateController.h>



@interface LESixOfDay (ST)

@property (nonatomic) SMTEDelegateController *textExpander;

+(id)logEntryWithAdvice:(Advice *)advice withOrderNumber:(NSInteger)orderNumberForType onDay:(Day *)day inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

// DEPRECATED
+(id)logEntryWithAdvice:(Advice *)advice withOrderNumber:(NSInteger)orderNumberForType onDay:(Day *)day withWakingHour:(NSInteger)wakingHour andWakingMinute:(NSInteger)wakingMinute inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

-(NSSet *)getPositiveActionsTaken;
-(NSSet *)getNegativeActionsTaken;

-(void)resetScheduledTime;
-(void)resetScheduledTimeAtHourInterval:(NSInteger)orderNumber;
-(void)resetScheduledTimeAtHourInterval:(NSInteger)orderNumber startHour:(NSInteger)startHour startMinute:(NSInteger)startMinute;
-(void)setTimeUpdatedToNow;

// For logging in the XCode console
-(void)logValuesOfLogEntry;


@end
