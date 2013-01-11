//
//  NSDate+ST.m
//  Six Times Path
//
//  Created by Doug on 8/9/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "NSDate+ST.h"

@implementation NSDate (ST)

+(id)dateWithHour:(NSInteger)hour andMinute:(NSInteger)minute
{
    NSCalendar *cal                 = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *now                     = [NSDate date];
    
    // required components for theDate
    NSDateComponents *components    = [cal components:( NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit )
                                             fromDate:now];
    
    // adjust time
    [components setHour:hour];
    [components setMinute:minute];
    
    // construct new date and return
    NSDate *newDate                 = [cal dateFromComponents:components];
        
    return newDate;
}

+(id)dateWithMonth:(NSInteger)month andDate:(NSInteger)date andYear:(NSInteger)year
{
    NSCalendar *cal                 = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *now                     = [NSDate date];
    
    // required components for theDate
    NSDateComponents *components    = [cal components:( NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit )
                                             fromDate:now];
    
    // adjust time
    [components setMonth:month];
    [components setDay:date];
    [components setYear:year];
    [components setHour:0];
    [components setMinute:0];
    
    // construct new date and return
    NSDate *newDate                 = [cal dateFromComponents:components];
    return newDate;
}

-(NSDate *)setHour:(NSInteger)hour andMinute:(NSInteger)minute
{
    NSCalendar *cal                 = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    // required components for theDate
    NSDateComponents *components    = [cal components:( NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit )
                                             fromDate:self];
    
    // adjust time
    [components setHour:hour];
    [components setMinute:minute];
    
    // construct new date and return
    NSDate *newDate                 = [cal dateFromComponents:components];
    return newDate;
}


#pragma mark - Get Messages

-(NSString *)time
{
    NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	//    [dateFormatter setDateFormat:@"h:mm a"];
    
	return [dateFormatter stringFromDate:self];
}

-(NSString *)date
{
    NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	//    [dateFormatter setDateFormat:@"MMM d, YYYY"];
    
	return [dateFormatter stringFromDate:self];
}

-(NSString *)weekday
{
    NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"eeee"];
        
    return [dateFormatter stringFromDate:self];
}

-(NSString *)timeAndDate
{
    NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a 'on' MMM d"];
        
    return [dateFormatter stringFromDate:self];
}

-(NSInteger)hour
{
	NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"H"];
    return [[dateFormatter stringFromDate:self] intValue];
}

-(NSInteger)minute
{
	NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"m"];
    return [[dateFormatter stringFromDate:self] intValue];	
}
@end
