//
//  SetOfSpiritualAdvice.m
//  Ethics Diary
//
//  Created by ICE - Doug on 3/23/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "SetOfSpiritualAdvice.h"
#import "SpiritualAdvice.h"

@interface SetOfSpiritualAdvice ()
-(void)initializeDefaultDataList;
@end

@implementation SetOfSpiritualAdvice

@synthesize listOfAdvice = _listOfAdvice, nameOfList = _nameOfList;

#pragma mark - Initialization of the List

-(void)initializeDefaultDataList {
    NSMutableArray *adviceList  = [[NSMutableArray alloc] init];
    self.listOfAdvice           = adviceList;
}


-(id)init {
    if (self = [super init]) {
        [self initializeDefaultDataList];
        return self;
    }
    return nil;
}

#pragma mark - Information about the List

-(NSInteger)countOfListOfAdvice {
    return [self.listOfAdvice count];
}

-(id)adviceInListAtIndex:(NSUInteger)index {
    return [self.listOfAdvice objectAtIndex:index];
}

#pragma mark - Adding Advice to the List

-(void)setListOfAdvice:(NSMutableArray *)aListOfAdvice {
    if (_listOfAdvice != aListOfAdvice) {
        _listOfAdvice = [aListOfAdvice mutableCopy];
    }
}

-(void)addAdviceToList:(id)advice {
    [self.listOfAdvice addObject:advice];
}

-(void)addNewAdviceToListWithDescription:(NSString *)description {
    SpiritualAdvice *newAdvice  = [[SpiritualAdvice alloc] initWithDescription:description];
    [self addAdviceToList:newAdvice];
}

#pragma mark - Removing Advice from the List

-(void)removeAdviceFromListAtIndex:(NSUInteger)index {
    [self.listOfAdvice removeObjectAtIndex:index];
}






#pragma mark - Unit Test Messages

-(void)unitTestListAllAdvice {
    NSLog(@"-- unitTestListAllAdvice --");
    for (SpiritualAdvice *advice in self.listOfAdvice) {
        NSLog(@"SpiritualAdvice.description in self.listOfAdvice at index %d: %@", [self.listOfAdvice indexOfObject:advice], advice.description);
    }
}

// test adviceInListAtIndex
-(void)unitTestListFirstPieceOfAdvice {
    NSLog(@"-- unitTestListFirstPieceOfAdvice --");
    NSLog(@"First SpiritualAdvice.description in self.listOfAdvice: %@", [self adviceInListAtIndex:0]);
}

-(void)unitTestListLastPieceOfAdvice{
    NSLog(@"-- unitTestListLastPieceOfAdvice --");
    NSLog(@"Last SpiritualAdvice.description in self.listOfAdvice: %@", [self adviceInListAtIndex:[self countOfListOfAdvice]-1]);
    
}

// test countOfListOfAdvice;
-(void)unitTestHowManyInListOfAdvice{
    NSLog(@"-- unitTestHowManyInListOfAdvice --");
    NSLog(@"How many SpiritualAdvice in self.listOfAdvice: %d", [self countOfListOfAdvice]);
}

// test adding and removing pieces of advice
-(void)unitTestAddThisAdvice:(NSString *)description{
    NSLog(@"-- unitTestAddThisAdvice: %@ --", description);
    NSLog(@"== List before adding ==");
    [self unitTestListAllAdvice];
    [self addNewAdviceToListWithDescription:description];
    NSLog(@"== List after adding ==");
    [self unitTestListAllAdvice];
}

-(void)unitTestRemoveFirstPieceOfAdvice {
    NSLog(@"-- unitTestRemoveFirstPieceOfAdvice --");
    NSLog(@"== List before removing ==");
    [self unitTestListAllAdvice];
    NSLog(@"== The advice that will be removed ==");
    [self unitTestListFirstPieceOfAdvice];
    [self removeAdviceFromListAtIndex:0];
    NSLog(@"== List after removing ==");
    [self unitTestListAllAdvice];
}

@end
