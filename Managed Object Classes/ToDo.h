//
//  ToDo.h
//  Six Times Path
//
//  Created by Doug on 7/27/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LogEntry;

@interface ToDo : NSManagedObject

@property (nonatomic, retain) NSDate * due;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) LogEntry *logEntry;

@end
