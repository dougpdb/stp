//
//  TimeAndDate.h
//  Data Test - Catching Arrows
//
//  Created by ICE - Doug on 5/6/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeAndDate : NSObject

@property (nonatomic, strong) NSDate *theDate;
@property (nonatomic, strong) NSString *time, *timeAndDate, *date;

-(id)initWithDate:(NSDate *)date;
-(id)initTodayWithHour:(NSInteger)hour andMinute:(NSInteger)minute;
-(id)initWithMonth:(NSInteger)month andDate:(NSInteger)date andYear:(NSInteger)year;

-(void)setHour:(NSInteger)hour andMinute:(NSInteger)minute;





@end
