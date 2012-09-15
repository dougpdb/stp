//
//  SetOfSpiritualAdvice.h
//  Ethics Diary
//
//  Created by ICE - Doug on 3/23/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SpiritualAdvice;

@interface SetOfSpiritualAdvice : NSObject

@property (nonatomic, copy) NSMutableArray *listOfAdvice;
@property (nonatomic, copy) NSString *nameOfList;

-(NSInteger)countOfListOfAdvice;									// PASSED

-(SpiritualAdvice *)adviceInListAtIndex:(NSUInteger)index;			// PASSED

-(void)addAdviceToList:(SpiritualAdvice *)advice;					// PASSED
-(void)addNewAdviceToListWithDescription:(NSString *)description;	// PASSED
-(void)removeAdviceFromListAtIndex:(NSUInteger)index;				// PASSED







#pragma mark - Unit Test Messages

-(void)unitTestListAllAdvice;

// test adviceInListAtIndex
-(void)unitTestListFirstPieceOfAdvice;
-(void)unitTestListLastPieceOfAdvice;

// test countOfListOfAdvice;
-(void)unitTestHowManyInListOfAdvice;

// test adding and removing pieces of advice
-(void)unitTestAddThisAdvice:(NSString *)description;
-(void)unitTestRemoveFirstPieceOfAdvice;

@end
