//
//  Day+ST.m
//  Six Times Path
//
//  Created by Doug on 8/12/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "Day+ST.h"
#import "LESixOfDay.h"
#import "LEBestOfDay.h"
#import "LEWorstOfDay.h"
#import "Advice.h"

@implementation Day (ST)


#pragma mark - Custom Set and Get
- (void)setTheSixSorted:(NSArray *)theSixSorted {
	[self setValue:theSixSorted forKey: @"theSixSorted"];
}


#pragma mark - Sorting

-(NSArray *)getAdviceLogEntriesSorted
{
    NSArray *unsortedArray = [self.theSix allObjects];
	return [self sortByOrderNumberForType:unsortedArray];
}

-(NSArray *)getAdviceLogEntriesWithUserInputSorted
{
	NSArray *unsortedArray = [self.theSix allObjects];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.timeFirstUpdated != nil"];	// the item has been updated at least once, thus it has a user entry
	return [self sortByOrderNumberForType:[unsortedArray filteredArrayUsingPredicate:predicate]];
}

-(NSArray *)getAdviceLogEntriesWithoutUserInputSorted
{
	NSArray *unsortedArray = [self.theSix allObjects];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.timeFirstUpdated = nil"];		// the item has not been updated
	return [self sortByOrderNumberForType:[unsortedArray filteredArrayUsingPredicate:predicate]];
}

-(NSArray *)getBestOfDaySorted
{
    NSArray *unsortedArray = [self.bestOfDay allObjects];
	return [self sortByOrderNumberForType:unsortedArray];
}

-(NSArray *)getWorstOfDaySorted
{
    NSArray *unsortedArray	= [self.worstOfDay allObjects];
	return [self sortByOrderNumberForType:unsortedArray];
}


-(LESixOfDay *)entrySixOfDay:(NSNumber *)orderNumberInSetOfEntries
{
	for (LESixOfDay *entry in [self.theSix allObjects]) {
		if (entry.orderNumberForType == orderNumberInSetOfEntries) {
			return entry;
			break;
		}
	}
	return nil;
}

-(LESixOfDay *)entrySixOfDayWithAdviceName:(NSString *)adviceName
{
	for (LESixOfDay *entry in [self.theSix allObjects]) {
		if ([entry.advice.name isEqual:adviceName]) {
			return entry;
			break;
		}
	}
	return nil;
}

-(LESixOfDay *)entrySixOfDayFromTimeScheduled:(NSDate *)timeScheduled
{
	for (LESixOfDay *entry in [self.theSix allObjects]) {
		if ([entry.timeScheduled isEqual:timeScheduled]) {
			return entry;
			break;
		}
	}
	return nil;
}

#pragma mark - Test conditions

-(BOOL)hasAdviceLogEntries
{
	return ([[self.theSix allObjects] count] > 0);
}

-(BOOL)isAllAdviceLogEntriesWithUserInput
{
	NSUInteger countOfAdviceLogEntries = [[self.theSix allObjects] count];
	NSUInteger countOfAdviceLogEntriesWithUserInputSorted = [[self getAdviceLogEntriesWithUserInputSorted] count];
	return (countOfAdviceLogEntries == countOfAdviceLogEntriesWithUserInputSorted);
}

#pragma mark - Private Sort

-(NSArray *)sortByOrderNumberForType:(NSArray *)unsortedArray
{
    NSArray *sortedArray = [NSArray array];
    
    NSSortDescriptor *orderNumberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderNumberForType"
                                                                          ascending:YES];
    
    NSArray *descriptors = [NSArray arrayWithObjects:orderNumberDescriptor, nil];
    
    sortedArray = [unsortedArray sortedArrayUsingDescriptors:descriptors];
    
	return sortedArray;	
}



@end
