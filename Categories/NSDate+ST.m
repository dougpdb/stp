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

-(NSString *)time {
    NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a"];
    NSString *tmpString             = [dateFormatter stringFromDate:self];

    //  TO DO: Examine tmpString for @":00" (i.e. to see if the time is right on the hour). If so, then drop the @":00" from the string, so the date will read 8 AM instead of 8:00 AM.
    
    return tmpString;
}

-(NSString *)date {
    NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d, YYYY"];
    return [dateFormatter stringFromDate:self];
}

-(NSString *)timeAndDate {
    NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a 'on' MMM d"];
    
    //  TO DO: Examine tmpString for @":00" (i.e. to see if the time is right on the hour). If so, then drop the @":00" from the string, so the date will read 8 AM instead of 8:00 AM.
    
    return [dateFormatter stringFromDate:self];
}


@end
