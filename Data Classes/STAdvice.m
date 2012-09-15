//
//  STAdvice.m
//  Ethics Diary
//
//  Created by ICE - Doug on 3/23/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "STAdvice.h"

@implementation STAdvice

@synthesize description = _description;

-(id)initWithDescription:(NSString *)description {
    self = [super init];
    if (self) {
        _description = description;
        return self;
    }
    return nil;
}

#pragma mark - Unit Test Messages

-(void)unitTestDescription {
	NSLog(@"SpiritualAdvice.description: %@", self.description);
}

@end
