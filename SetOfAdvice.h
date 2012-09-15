//
//  SetOfAdvice.h
//  Six Times Path
//
//  Created by Doug on 7/27/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Advice, AdviceReference, SpiritualTradtion;

@interface SetOfAdvice : NSManagedObject

@property (nonatomic, retain) NSNumber * baseInstall;
@property (nonatomic, retain) NSNumber * currentlyBeingPracticed;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * overview;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSSet *containsAdvice;
@property (nonatomic, retain) NSSet *practicedWithinTradition;
@property (nonatomic, retain) NSSet *reference;
@end

@interface SetOfAdvice (CoreDataGeneratedAccessors)

- (void)addContainsAdviceObject:(Advice *)value;
- (void)removeContainsAdviceObject:(Advice *)value;
- (void)addContainsAdvice:(NSSet *)values;
- (void)removeContainsAdvice:(NSSet *)values;

- (void)addPracticedWithinTraditionObject:(SpiritualTradtion *)value;
- (void)removePracticedWithinTraditionObject:(SpiritualTradtion *)value;
- (void)addPracticedWithinTradition:(NSSet *)values;
- (void)removePracticedWithinTradition:(NSSet *)values;

- (void)addReferenceObject:(AdviceReference *)value;
- (void)removeReferenceObject:(AdviceReference *)value;
- (void)addReference:(NSSet *)values;
- (void)removeReference:(NSSet *)values;

@end
