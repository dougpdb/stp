//
//  Advice.h
//  Six Times Path
//
//  Created by Doug on 7/27/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AdviceReference, Insight, LogEntry, SetOfAdvice;

@interface Advice : NSManagedObject

@property (nonatomic, retain) NSNumber * isASpecialFocus;
@property (nonatomic, retain) NSNumber * isBaseInstall;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * orderNumberInSet;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) Insight *basisForInsight;
@property (nonatomic, retain) SetOfAdvice *containedWithinSetOfAdvice;
@property (nonatomic, retain) NSSet *logEntry;
@property (nonatomic, retain) NSSet *reference;
@end

@interface Advice (CoreDataGeneratedAccessors)

- (void)addLogEntryObject:(LogEntry *)value;
- (void)removeLogEntryObject:(LogEntry *)value;
- (void)addLogEntry:(NSSet *)values;
- (void)removeLogEntry:(NSSet *)values;

- (void)addReferenceObject:(AdviceReference *)value;
- (void)removeReferenceObject:(AdviceReference *)value;
- (void)addReference:(NSSet *)values;
- (void)removeReference:(NSSet *)values;

@end
