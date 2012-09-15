//
//  NSUserDefaults+ST.m
//  Six Times Path
//
//  Created by Doug on 8/12/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "NSUserDefaults+ST.h"

@implementation NSUserDefaults (ST)

#pragma mark - Return Values

-(BOOL)showHelpText
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"showHelpText"];
}

-(BOOL)cycleThroughAdviceSequentially
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"cycleThroughAdviceSequentially"];
}

#pragma mark - Set Values

-(void)showHelpText:(BOOL)helpTextShouldBeShown
{
    [[NSUserDefaults standardUserDefaults] setBool:helpTextShouldBeShown forKey:@"showHelpText"];
}

-(void)cycleThroughAdviceSeqentially:(BOOL)alwaysCycleThroughAdviceSequentially
{
    [[NSUserDefaults standardUserDefaults] setBool:alwaysCycleThroughAdviceSequentially forKey:@"cycleThroughAdviceSequentially"];
}

@end
