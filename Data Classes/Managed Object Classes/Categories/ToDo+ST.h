//
//  ToDo+ST.h
//  Six Times Path
//
//  Created by Doug on 11/2/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "ToDo.h"

@interface ToDo (ST)

+(id)toDoWithText:(NSString *)text withDueDateAndTime:(NSDate *)date forLogEntry:(LogEntry *)logEntry inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

-(void)updateText:(NSString *)text andDueDateAndTime:(NSDate *)date;

@end
