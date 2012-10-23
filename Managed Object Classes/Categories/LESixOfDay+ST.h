//
//  LESixOfDay+ST.h
//  Six Times Path
//
//  Created by Doug on 8/19/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "LESixOfDay.h"



@interface LESixOfDay (ST)


+(id)logEntryWithAdvice:(Advice *)advice withOrderNumber:(NSInteger)orderNumberForType onDay:(Day *)day inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

-(NSSet *)getPositiveActionsTaken;
-(NSSet *)getNegativeActionsTaken;


// For logging in the XCode console
-(void)logValuesOfLogEntry;


@end
