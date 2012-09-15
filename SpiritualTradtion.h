//
//  SpiritualTradtion.h
//  Six Times Path
//
//  Created by Doug on 7/27/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SetOfAdvice;

@interface SpiritualTradtion : NSManagedObject

@property (nonatomic, retain) NSNumber * baseInstall;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *adheresToSetOfAdvice;
@end

@interface SpiritualTradtion (CoreDataGeneratedAccessors)

- (void)addAdheresToSetOfAdviceObject:(SetOfAdvice *)value;
- (void)removeAdheresToSetOfAdviceObject:(SetOfAdvice *)value;
- (void)addAdheresToSetOfAdvice:(NSSet *)values;
- (void)removeAdheresToSetOfAdvice:(NSSet *)values;

@end
