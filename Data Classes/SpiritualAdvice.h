//
//  SpiritualAdvice.h
//  Ethics Diary
//
//  Created by ICE - Doug on 3/23/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpiritualAdvice : NSObject


@property (nonatomic, copy) NSString *description;

-(id)initWithDescription:(NSString *)description;
// works

#pragma mark - Unit Test Messages

-(void)unitTestDescription;

@end
