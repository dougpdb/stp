//
//  ActionTaken+ST.h
//  Six Times Path
//
//  Created by Doug on 10/28/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "ActionTaken.h"


@interface ActionTaken (ST)

+(id)actionTakenWithText:(NSString *)text isPositive:(BOOL)isPositive withRating:(NSInteger)rating forLogEntry:(LogEntry*)logEntry inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

-(void)updateText:(NSString *)text andRating:(NSInteger)rating;
@end
