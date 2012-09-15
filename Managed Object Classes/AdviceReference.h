//
//  AdviceReference.h
//  Six Times Path
//
//  Created by Doug on 7/27/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Advice, SetOfAdvice;

@interface AdviceReference : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSSet *advice;
@property (nonatomic, retain) NSSet *setOfAdvice;
@end

@interface AdviceReference (CoreDataGeneratedAccessors)

- (void)addAdviceObject:(Advice *)value;
- (void)removeAdviceObject:(Advice *)value;
- (void)addAdvice:(NSSet *)values;
- (void)removeAdvice:(NSSet *)values;

- (void)addSetOfAdviceObject:(SetOfAdvice *)value;
- (void)removeSetOfAdviceObject:(SetOfAdvice *)value;
- (void)addSetOfAdvice:(NSSet *)values;
- (void)removeSetOfAdvice:(NSSet *)values;

@end
