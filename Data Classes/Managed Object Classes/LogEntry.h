//
//  LogEntry.h
//  Six Times Path
//
//  Created by Doug on 7/27/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ActionTaken, Advice, ToDo;

@interface LogEntry : NSManagedObject

@property (nonatomic, retain) NSNumber * orderNumberForType;
@property (nonatomic, retain) NSDate * timeFirstUpdated;
@property (nonatomic, retain) NSDate * timeLastUpdated;
@property (nonatomic, retain) NSDate * timeScheduled;
@property (nonatomic, retain) NSSet *action;
@property (nonatomic, retain) Advice *advice;
@property (nonatomic, retain) ToDo *toDo;
@end

@interface LogEntry (CoreDataGeneratedAccessors)

- (void)addActionObject:(ActionTaken *)value;
- (void)removeActionObject:(ActionTaken *)value;
- (void)addAction:(NSSet *)values;
- (void)removeAction:(NSSet *)values;


@end
