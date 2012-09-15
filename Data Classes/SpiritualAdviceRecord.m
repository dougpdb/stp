//
//  SpiritualAdviceRecord.m
//  Ethics Diary
//
//  Created by ICE - Doug on 4/1/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "SpiritualAdviceRecord.h"
#import "SpiritualAdvice.h"
#import "ActionRecord.h"
#import "TimeAndDate.h"

//@interface SpiritualAdviceRecord ()
//-(void)initializeBlankRecord;
//@end

@implementation SpiritualAdviceRecord



@synthesize advice = _advice, actionToTake = _actionToTake, bestActionTaken = _bestActionTaken, lastTimeUpdated = _lastTimeUpdated, originalTimeEntered = _originalTimeEntered, scheduledTimeToEnter = _scheduledTimeToEnter, worstActionTaken = _worstActionTaken;

#pragma mark - Initialization of the Record
    //
    //-(id)initializeBlankRecord {
    //    SpiritualAdvice *newAdvice  = [[SpiritualAdvice alloc] init];
    //    self.advice                 = newAdvice;
    //    return self;
    //}
    //

    //-(id)init {
    //    if (self = [super init]) {
    //        [self initializeBlankRecord];
    //        return self;
    //    }
    //    return nil;
    //}

-(id)initWithAdviceDescription:(NSString *)description {
    self = [super init];
    if (self) {
        self.advice                 = [[SpiritualAdvice alloc] init];
        self.advice.description     = description;
        
        self.bestActionTaken        = [[ActionRecord alloc] init];
        self.worstActionTaken       = [[ActionRecord alloc] init];
        self.actionToTake           = [[ActionRecord alloc] init];
        
        return self;
    }
    return nil;
}

#pragma mark - Times

-(void)setScheduledTimeToEnterWithHour:(NSInteger)hour andMinute:(NSInteger)minute
{
    self.scheduledTimeToEnter = [[TimeAndDate alloc] initTodayWithHour:hour andMinute:minute];
}

-(void)updateTimeToNow {
    // Get this moment
    NSDate *now = [[NSDate alloc] init];    
    
    // If originalTimeEntered has not yet been set, set it
    if (self.originalTimeEntered.theDate == nil) {
        self.originalTimeEntered = [[TimeAndDate alloc] initWithDate:now];
    }
    
    // Set the update time
    self.lastTimeUpdated = [[TimeAndDate alloc] initWithDate:now];
}


#pragma mark - Set Description of Actions

-(void)setDescriptionForBestActionTaken:(NSString *)description {
    // Trim the description of whitespace and new line characters from the beginning and end of the strings
    description = [description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // Set description
    _bestActionTaken.description    = description;
}

-(void)setDescriptionForWorstActionTaken:(NSString *)description {
    // Trim the description of whitespace and new line characters from the beginning and end of the strings
    description = [description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // Set description
    _worstActionTaken.description   = description;
}

-(void)setDescriptionForActionToTake:(NSString *)description {
    // Trim the description of whitespace and new line characters from the beginning and end of the strings
    description = [description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // Set description
    _actionToTake.description       = description;
}


#pragma mark - Unit Test Messages

-(void)unitTestSpiritualAdviceDescriptionFromSpiritualAdviceRecord {
    NSLog(@"-- unitTestSpiritualAdviceDescriptionFromSpiritualAdviceRecord --");
    [self.advice unitTestDescription];    
}

-(void)UTdisplayAllProperties {
    NSLog(@"\n\nAdvice:\t%@\nBest:\t%@\nWorst:\t%@\nTo Do:\t%@\n\nScheduled Time: %@\nOriginal Time: %@\nLast Updated: %@", self.advice.description, self.bestActionTaken.description, self.worstActionTaken.description, self.actionToTake.description, self.scheduledTimeToEnter.time, self.originalTimeEntered.time, self.lastTimeUpdated.time);
}


-(void)unitTestBestActionTakenThisSpiritualAdvice{
    NSLog(@"-- unitTestBestActionTakenThisSpiritualAdvice --");
    ActionRecord *testBestAction    = [[ActionRecord alloc] init];
    testBestAction.description      = @"I took the time to write a simple unit test for SpiritualAdviceRecord.";
    self.bestActionTaken            = testBestAction;
    [self.bestActionTaken unitTestDescription];
}

-(void)unitTestWorstActionTakenThisSpiritualAdvice{
    NSLog(@"-- unitTestWorstActionTakenThisSpiritualAdvice --");
    ActionRecord *testWorstAction    = [[ActionRecord alloc] init];
    testWorstAction.description      = @"At the beginning of the project, I didn't take the time to write a simple unit tests for SpiritualAdviceRecord.";
    self.worstActionTaken            = testWorstAction;
    [self.worstActionTaken unitTestDescription];
}

-(void)unitTestActionToTakeForThisSpiritualAdvice{
    NSLog(@"-- unitTestActionToTakeForThisSpiritualAdvice --");
    ActionRecord *testActionToTake  = [[ActionRecord alloc] init];
    testActionToTake.description    = @"Write some unit tests for the Date methods.";
    self.actionToTake               = testActionToTake;
    [self.actionToTake unitTestDescription];
}

-(void)UTdisplayOriginalTimeEntered {
    
//    NSDateComponents *components = [[NSDateComponents alloc] init];
//    [components setHour:7];
//    [components setMinute:30];
//    NSCalendar *gregorian = [[NSCalendar alloc]
//                             initWithCalendarIdentifier:NSGregorianCalendar];
//    NSDate *date = [gregorian dateFromComponents:components];
//    
//    NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc] init];
//    [dateFormatter set
    
}

-(void)UTdisplayScheduledTimeToEnter {
    NSLog(@"The scheduled time to enter for '%@' is %@", self.advice.description, self.scheduledTimeToEnter.time);
}

-(void)UTdisplayLastTimeUpdated {
}

@end
