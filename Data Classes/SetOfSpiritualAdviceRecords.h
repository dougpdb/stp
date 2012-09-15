//
//  SetOfSpiritualAdviceRecords.h
//  Ethics Diary
//
//  Created by ICE - Doug on 4/1/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <UIKit/UIKit.h>
//@class TimeAndDate;

@class SetOfSpiritualAdvice;
@class SpiritualAdviceRecord;

@interface SetOfSpiritualAdviceRecords : NSObject

@property (nonatomic, strong) NSMutableArray *listOfRecords;

-(NSInteger)countOfListOfRecords;
-(SpiritualAdviceRecord *)recordInListAtIndex:(NSUInteger)index;


#pragma mark - Add and Remove Records

-(void)addNewRecordToListWithAdviceDescription:(NSString *)description;
-(void)createSetOfSpiritualAdviceRecords:(SetOfSpiritualAdvice *)setOfAdvice;
-(void)removeRecordFromListAtIndex:(NSUInteger)index;




#pragma mark - Unit Tests

-(void)UTaddNewRecordToListWithAdviceDescription:(NSString *)description;
-(void)UTcountOfListOfRecords;
-(void)UTrecordInListAtIndex:(NSUInteger)index;
-(void)UTremoveRecordFromListAtIndex:(NSUInteger)index;



@end
