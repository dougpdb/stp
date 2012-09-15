//
//  LEWorstOfDay.h
//  Six Times Path
//
//  Created by Doug on 7/27/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "LogEntry.h"

@class Day;

@interface LEWorstOfDay : LogEntry

@property (nonatomic, retain) Day *dayOfWorsts;

@end
