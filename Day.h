//
//  Day.h
//  Six Times Path
//
//  Created by Doug on 7/27/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LEBestOfDay, LESixOfDay, LESpecialFocus, LEWorstOfDay, Meditation;

@interface Day : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSSet *bestOfDay;
@property (nonatomic, retain) Meditation *meditation;
@property (nonatomic, retain) LESpecialFocus *specialFocus;
@property (nonatomic, retain) NSSet *theSix;
@property (nonatomic, retain) NSSet *worstOfDay;
@end

@interface Day (CoreDataGeneratedAccessors)

- (void)addBestOfDayObject:(LEBestOfDay *)value;
- (void)removeBestOfDayObject:(LEBestOfDay *)value;
- (void)addBestOfDay:(NSSet *)values;
- (void)removeBestOfDay:(NSSet *)values;

- (void)addTheSixObject:(LESixOfDay *)value;
- (void)removeTheSixObject:(LESixOfDay *)value;
- (void)addTheSix:(NSSet *)values;
- (void)removeTheSix:(NSSet *)values;

- (void)addWorstOfDayObject:(LEWorstOfDay *)value;
- (void)removeWorstOfDayObject:(LEWorstOfDay *)value;
- (void)addWorstOfDay:(NSSet *)values;
- (void)removeWorstOfDay:(NSSet *)values;

@end
