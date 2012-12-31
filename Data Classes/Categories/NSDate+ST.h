//
//  NSDate+ST.h
//  Six Times Path
//
//  Created by Doug on 8/9/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (ST)

+(id)dateWithHour:(NSInteger)hour andMinute:(NSInteger)minute;
+(id)dateWithMonth:(NSInteger)month andDate:(NSInteger)date andYear:(NSInteger)year;

-(NSDate *)setHour:(NSInteger)hour andMinute:(NSInteger)minute;

-(NSString *)time;
-(NSString *)date;
-(NSString *)timeAndDate;


@end
