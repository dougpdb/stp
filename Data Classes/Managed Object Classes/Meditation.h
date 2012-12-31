//
//  Meditation.h
//  Six Times Path
//
//  Created by Doug on 7/27/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Advice, Day;

@interface Meditation : NSManagedObject

@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) Advice *advice;
@property (nonatomic, retain) Day *dayOfMeditation;

@end
