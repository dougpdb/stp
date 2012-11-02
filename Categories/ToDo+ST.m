//
//  ToDo+ST.m
//  Six Times Path
//
//  Created by Doug on 11/2/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "ToDo+ST.h"
#import "LogEntry.h"

@implementation ToDo (ST)

+(id)toDoWithText:(NSString *)text withDueDateAndTime:(NSDate *)date forLogEntry:(LogEntry *)logEntry inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
{
	ToDo *aToDo		= [NSEntityDescription insertNewObjectForEntityForName:@"ToDo"
												 inManagedObjectContext:managedObjectContext];
	aToDo.due		= date;
	
	// set relationships and reciprical relationships between core data objects
	aToDo.logEntry	= logEntry;
	logEntry.toDo	= aToDo;
	
	return aToDo;
}

-(void)updateText:(NSString *)text andDueDateAndTime:(NSDate *)date
{
	self.text		= text;
	self.due		= date;
}

@end
