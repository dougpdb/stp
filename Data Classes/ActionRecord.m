//
//  ActionRecord.m
//  Ethics Diary
//
//  Created by ICE - Doug on 4/1/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "ActionRecord.h"

@implementation ActionRecord

@synthesize description = _description;

#pragma mark - Unit Test Messages

-(void)unitTestDescription {
    NSLog(@"ActionRecord.description: %@", self.description);
}


@end
