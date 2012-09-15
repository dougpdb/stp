//
//  TimeAndDate.m
//  Data Test - Catching Arrows
//
//  Created by ICE - Doug on 5/6/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "TimeAndDate.h"



@implementation TimeAndDate

@synthesize theDate = _theDate, time = _time, timeAndDate = _timeAndDate, date = _date;

-(id)initWithDate:(NSDate *)date
{
    self = [super init];
    if (self)
        self.theDate = date;
    return self;
}

-(id)initTodayWithHour:(NSInteger)hour andMinute:(NSInteger)minute
{
    self = [super init];
    if (self) {
        NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *now = [NSDate date];

        // required components for theDate
        NSDateComponents *components = [cal components:( NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit ) fromDate:now];

        // adjust time
        [components setHour:hour];
        [components setMinute:minute];

        // construct new date and return
        NSDate *newDate = [cal dateFromComponents:components];
        self.theDate = newDate;
    }

    return self;
        
}

-(id)initWithMonth:(NSInteger)month andDate:(NSInteger)date andYear:(NSInteger)year
{
    self = [super init];
    if (self) {
        NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *now = [NSDate date];
        
        // required components for theDate
        NSDateComponents *components = [cal components:( NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit ) fromDate:now];
        
        // adjust time
        [components setMonth:month];
        [components setDay:date];
        [components setYear:year];
        
        // construct new date and return
        NSDate *newDate = [cal dateFromComponents:components];
        self.theDate = newDate;
    }
    
    return self;
    
}

-(void)setHour:(NSInteger)hour andMinute:(NSInteger)minute
{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    // required components for theDate
    NSDateComponents *components = [cal components:( NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit ) fromDate:self.theDate];
    
    // adjust time
    [components setHour:hour];
    [components setMinute:minute];
    
    // construct new date and return
    NSDate *newDate = [cal dateFromComponents:components];
    self.theDate = newDate;    
}


#pragma mark - Get Messages

-(NSString *)time {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a"];
    _time = [dateFormatter stringFromDate:self.theDate];
    return _time;
}

-(NSString *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d, YYYY"];
    _date = [dateFormatter stringFromDate:self.theDate];
    return _date;
}

-(NSString *)timeAndDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a 'on' MMM d"];
    _timeAndDate = [dateFormatter stringFromDate:self.theDate];
    return _timeAndDate;
}



@end
