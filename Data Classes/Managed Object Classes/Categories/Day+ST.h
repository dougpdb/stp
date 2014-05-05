//
//  Day+ST.h
//  Six Times Path
//
//  Created by Doug on 8/12/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "Day.h"

@interface Day (ST)

-(NSArray *)getAdviceLogEntriesSorted;
-(NSArray *)getAdviceLogEntriesWithUserInputSorted;
-(NSArray *)getAdviceLogEntriesWithoutUserInputSorted;
-(NSArray *)getBestOfDaySorted;
-(NSArray *)getWorstOfDaySorted;

-(BOOL)hasAdviceLogEntries;
-(BOOL)isAllAdviceLogEntriesWithUserInput;

-(LESixOfDay *)entrySixOfDay:(NSNumber *)orderNumberInSetOfEntries;
-(LESixOfDay *)entrySixOfDayWithAdviceName:(NSString *)adviceName;
-(LESixOfDay *)entrySixOfDayFromTimeScheduled:(NSDate *)timeScheduled;

@end
