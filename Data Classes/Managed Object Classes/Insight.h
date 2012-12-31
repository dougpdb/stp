//
//  Insight.h
//  Six Times Path
//
//  Created by Doug on 7/27/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Advice;

@interface Insight : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) Advice *intoAdvice;

@end
