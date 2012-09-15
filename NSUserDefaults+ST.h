//
//  NSUserDefaults+ST.h
//  Six Times Path
//
//  Created by Doug on 8/12/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (ST)

-(BOOL)showHelpText;
-(BOOL)cycleThroughAdviceSequentially;

-(void)showHelpText:(BOOL)helpTextShouldBeShown;
-(void)cycleThroughAdviceSeqentially:(BOOL)alwaysCycleThroughAdviceSequentially;

@end
