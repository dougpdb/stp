//
//  SpiritualAdviceRecord.h
//  Ethics Diary
//
//  Created by ICE - Doug on 4/1/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SpiritualAdvice;
@class ActionRecord;
@class TimeAndDate;

@interface SpiritualAdviceRecord : NSObject

@property (strong, nonatomic) SpiritualAdvice *advice;


#pragma mark - Time properties
@property (strong, nonatomic) TimeAndDate *scheduledTimeToEnter;
@property (strong, nonatomic) TimeAndDate *originalTimeEntered;
@property (strong, nonatomic) TimeAndDate *lastTimeUpdated;


#pragma mark - Micro record properties
@property (strong, nonatomic) ActionRecord *bestActionTaken;
@property (strong, nonatomic) ActionRecord *worstActionTaken;

@property (strong, nonatomic) ActionRecord *actionToTake;


#pragma mark - Initialize
-(id)initWithAdviceDescription:(NSString *)description;


#pragma mark - Times
-(void)setScheduledTimeToEnterWithHour:(NSInteger)hour andMinute:(NSInteger)minute;
-(void)updateTimeToNow;

#pragma mark - Set Description of Actions
-(void)setDescriptionForBestActionTaken:(NSString *)description;
-(void)setDescriptionForWorstActionTaken:(NSString *)description;
-(void)setDescriptionForActionToTake:(NSString *)description;


#pragma mark - Unit Test Messages
// basic info on advice itself
-(void)unitTestSpiritualAdviceDescriptionFromSpiritualAdviceRecord;
-(void)UTdisplayAllProperties;

// date displays
-(void)UTdisplayScheduledTimeToEnter;
-(void)UTdisplayOriginalTimeEntered;
-(void)UTdisplayLastTimeUpdated;

// Micro record properties
-(void)unitTestBestActionTakenThisSpiritualAdvice;
-(void)unitTestWorstActionTakenThisSpiritualAdvice;
-(void)unitTestActionToTakeForThisSpiritualAdvice;


@end
