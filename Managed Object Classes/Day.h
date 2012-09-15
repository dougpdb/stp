//
//  Day.h
//  Six Times Path
//
//  Created by Doug on 7/27/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LESixOfDay, Meditation;

@interface Day : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSSet *bestOfDay;
@property (nonatomic, retain) Meditation *meditation;
@property (nonatomic, retain) NSManagedObject *specialFocus;
@property (nonatomic, retain) NSSet *theSix;
@property (nonatomic, retain) NSSet *worstOfDay;
@end

@interface Day (CoreDataGeneratedAccessors)

- (void)addBestOfDayObject:(NSManagedObject *)value;
- (void)removeBestOfDayObject:(NSManagedObject *)value;
- (void)addBestOfDay:(NSSet *)values;
- (void)removeBestOfDay:(NSSet *)values;

- (void)addTheSixObject:(LESixOfDay *)value;
- (void)removeTheSixObject:(LESixOfDay *)value;
- (void)addTheSix:(NSSet *)values;
- (void)removeTheSix:(NSSet *)values;

- (void)addWorstOfDayObject:(NSManagedObject *)value;
- (void)removeWorstOfDayObject:(NSManagedObject *)value;
- (void)addWorstOfDay:(NSSet *)values;
- (void)removeWorstOfDay:(NSSet *)values;

@end
