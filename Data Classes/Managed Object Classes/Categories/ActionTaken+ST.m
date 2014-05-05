//
//  ActionTaken+ST.m
//  Six Times Path
//
//  Created by Doug on 10/28/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "ActionTaken+ST.h"
#import "LogEntry.h"

@implementation ActionTaken (ST)

+(id)actionTakenWithText:(NSString *)text isPositive:(BOOL)isPositive withRating:(NSInteger)rating forLogEntry:(LogEntry *)logEntry inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	ActionTaken *anActionTaken = [NSEntityDescription insertNewObjectForEntityForName:@"ActionTaken"
																inManagedObjectContext:managedObjectContext];
	anActionTaken.text = text;
	anActionTaken.isPositive = [NSNumber numberWithBool:isPositive];
	anActionTaken.rating = [NSNumber numberWithInteger:rating];
	
	// set relationships and reciprical relationships between core data objects
	anActionTaken.logEntry = logEntry;
	[logEntry addActionObject:anActionTaken];
	
	return anActionTaken;
}

-(void)updateText:(NSString *)text andRating:(NSInteger)rating
{
	self.text = text;
	self.rating = [NSNumber numberWithInteger:rating];
}
@end
