//
//  Day+ST.h
//  Six Times Path
//
//  Created by Doug on 8/12/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "Day.h"

@interface Day (ST)

//@property (strong, nonatomic) NSArray *theSixSorted;
//@property (strong, nonatomic) NSArray *bestOfDaySorted;
//@property (strong, nonatomic) NSArray *worstOfDaySorted;


//-(id)firstGuidelineOrderNumber;
-(NSArray *)getTheSixSorted;
-(NSArray *)getTheSixThatHaveUserEntriesSorted;
-(NSArray *)getTheSixWithoutUserEntriesSorted;
-(NSArray *)getBestOfDaySorted;
-(NSArray *)getWorstOfDaySorted;

-(LESixOfDay *)entrySixOfDay:(NSNumber *)orderNumberInSetOfEntries;


@end
