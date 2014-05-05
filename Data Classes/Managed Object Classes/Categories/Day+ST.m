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
//@dynamic theSixSorted;
//@dynamic bestOfDaySorted;
//@dynamic worstOfDaySorted;


#pragma mark - Custom Set and Get
- (void)setTheSixSorted:(NSArray *)theSixSorted {
	[self setValue:theSixSorted forKey: @"theSixSorted"];
}

//-(void)setBestOfDaySorted:(NSArray *)bestOfDaySorted
//{
//	[self setValue:bestOfDaySorted forKey:@"bestOfDaySorted"];
//}
//
//-(void)setWorstOfDaySorted:(NSArray *)worstOfDaySorted
//{
//	[self setValue:worstOfDaySorted forKey:@"worstOfDaySorted"];
//}

//-(NSArray *)theSixSorted
//{
//	return [self valueForKey:@"theSixSorted"];
//}
//
//-(NSArray *)bestOfDaySorted
//{
//	return [self valueForKey:@"bestOfDaySorted"];
//}
//
//-(NSArray *)worstOfDaySorted
//{
//	return [self valueForKey:@"worstOfDaySorted"];
//}

/*
-(id)firstGuidelineOrderNumber
{
    
    NSArray *sortedArray                    = [NSArray array];
    
    NSSortDescriptor *orderNumberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderNumberForType"
                                                                          ascending:YES];
    
    NSArray *descriptors                    = [NSArray arrayWithObjects:orderNumberDescriptor, nil];
    
    sortedArray                             = [self.theSix sortedArrayUsingDescriptors:descriptors];
    
    return [[sortedArray objectAtIndex:0] valueForKey:@"orderNumberForType"];
}
*/

#pragma mark - Sorting

-(NSArray *)getAdviceLogEntriesSorted
{
    NSArray *unsortedArray	= [self.theSix allObjects];
	return [self sortByOrderNumberForType:unsortedArray];
}

-(NSArray *)getAdviceLogEntriesWithUserInputSorted
{
	NSArray *unsortedArray	= [self.theSix allObjects];
	NSPredicate *predicate	= [NSPredicate predicateWithFormat:@"SELF.timeFirstUpdated != nil"];	// the item has been updated at least once, thus it has a user entry
	return [self sortByOrderNumberForType:[unsortedArray filteredArrayUsingPredicate:predicate]];
}

-(NSArray *)getAdviceLogEntriesWithoutUserInputSorted
{
	NSArray *unsortedArray	= [self.theSix allObjects];
	NSPredicate *predicate	= [NSPredicate predicateWithFormat:@"SELF.timeFirstUpdated = nil"];		// the item has not been updated
	return [self sortByOrderNumberForType:[unsortedArray filteredArrayUsingPredicate:predicate]];
}

-(NSArray *)getBestOfDaySorted
{
    NSArray *unsortedArray	= [self.bestOfDay allObjects];
	return [self sortByOrderNumberForType:unsortedArray];
}

-(NSArray *)getWorstOfDaySorted
{
    NSArray *unsortedArray	= [self.worstOfDay allObjects];
	return [self sortByOrderNumberForType:unsortedArray];
}


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
#pragma mark - Private Sort

-(NSArray *)sortByOrderNumberForType:(NSArray *)unsortedArray
{
    NSArray *sortedArray                    = [NSArray array];
    
    NSSortDescriptor *orderNumberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderNumberForType"
                                                                          ascending:YES];
    
    NSArray *descriptors                    = [NSArray arrayWithObjects:orderNumberDescriptor, nil];
    
    sortedArray                             = [unsortedArray sortedArrayUsingDescriptors:descriptors];
    
	return sortedArray;	
}
//	for (LESixOfDay *oneOfSix in unsortedArray) {
//		NSLog(@"Unsorted Array - Index [%i], Order Number in of the Six [%@], Name [%@]", [unsortedArray indexOfObject:oneOfSix], oneOfSix.orderNumberForType, oneOfSix.advice.name);
//	}
//	
//    ...
//    
//	for (LESixOfDay *oneOfSix in sortedArray) {
//		NSLog(@"Sorted Array - Index [%i], Order Number in of the Six [%@], Name [%@]", [sortedArray indexOfObject:oneOfSix], oneOfSix.orderNumberForType, oneOfSix.advice.name);
//	}


@end
