//
//  SetOfSpiritualAdviceRecords.m
//  Ethics Diary
//
//  Created by ICE - Doug on 4/1/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "SetOfSpiritualAdvice.h"
#import "SetOfSpiritualAdviceRecords.h"
#import "SpiritualAdviceRecord.h"
#import "TimeAndDate.h"

// needed only when doing unit testing
#import "SpiritualAdvice.h"                    

@interface SetOfSpiritualAdviceRecords ()
-(void)initializeDefaultRecordList;
@end

@implementation SetOfSpiritualAdviceRecords


@synthesize listOfRecords = _listOfRecords;


#pragma mark - Initialization of the List

-(void)initializeDefaultRecordList {
//    WAS
    //
//    NSMutableArray *recordList  = [[NSMutableArray alloc] init];
//    _listOfRecords              = recordList;
    _listOfRecords  = [NSMutableArray array];
}

-(id)init
{
    if (self = [super init]) {
        [self initializeDefaultRecordList];
        return self;
    }
    return nil;
}

-(void)setListOfRecords:(NSMutableArray *)aListOfRecords
{
    if (_listOfRecords != aListOfRecords) {
        _listOfRecords = [aListOfRecords mutableCopy];
    }
}


#pragma mark - Information about the List

-(NSInteger)countOfListOfRecords {
    return [self.listOfRecords count];
}

-(SpiritualAdviceRecord *)recordInListAtIndex:(NSUInteger)index
{
    return [self.listOfRecords objectAtIndex:index];
}


#pragma mark - Adding Records to the List

-(void)addNewRecordToListWithAdviceDescription:(NSString *)description
{
    SpiritualAdviceRecord *newRecord  = [[SpiritualAdviceRecord alloc] initWithAdviceDescription:description];
    [self.listOfRecords addObject:newRecord];
}

-(void)createSetOfSpiritualAdviceRecords:(SetOfSpiritualAdvice *)setOfAdvice
{
    // For each advice in the set, create a record a record; add each record to the list of records
    for (SpiritualAdvice *advice in setOfAdvice.listOfAdvice)
        [self addNewRecordToListWithAdviceDescription:advice.description];
}


#pragma mark - Removing a Record from the List

-(void)removeRecordFromListAtIndex:(NSUInteger)index
{
    [self.listOfRecords removeObjectAtIndex:index];
}









#pragma mark - Unit tests

-(void)UTaddNewRecordToListWithAdviceDescription:(NSString *)description
{
    NSLog(@"-- UTaddNewRecordToListWithAdviceDescription --");
    [self addNewRecordToListWithAdviceDescription:description];
    NSLog(@"This Record was just added: %@", [[[self.listOfRecords lastObject] advice] description]);
}

-(void)UTcreateSetOfSpiritualAdviceRecords:(SetOfSpiritualAdvice *)setOfAdvice
{
    NSLog(@"-- UTcreateSetOfSpiritualAdviceRecords --");
    [self createSetOfSpiritualAdviceRecords:setOfAdvice];
    for (SpiritualAdviceRecord *record in self.listOfRecords)
        NSLog(@"Advice in listOfRecords: %@", record.advice.description);
}

-(void)UTcountOfListOfRecords
{
    NSLog(@"-- UTcountOfListOfRecords --");
    NSLog(@"The number of records in the list is %i", [self.listOfRecords count]);
    
}

-(void)UTrecordInListAtIndex:(NSUInteger)index
{
    NSLog(@"-- UTrecordInListAtIndex --");
    NSLog(@"The record at the index [%i] is %@", index, [[[self recordInListAtIndex:index] advice] description]);
    
}

-(void)UTremoveRecordFromListAtIndex:(NSUInteger)index
{
    NSLog(@"-- UTremoveRecordFromListAtIndex --");
    NSLog(@"Here is a list of all records in the list:");
    for (SpiritualAdviceRecord *record in self.listOfRecords)
        NSLog(@"--%@", record.advice.description);

    NSLog(@"Now removing record at index [%i]: %@", index, [[[self recordInListAtIndex:index] advice] description]);
    [self removeRecordFromListAtIndex:index];
    NSLog(@"Here is the updated list of records in the list:");
    for (SpiritualAdviceRecord *record in self.listOfRecords)
        NSLog(@"--%@", record.advice.description);
}

@end







