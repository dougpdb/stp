//
//  UIFont+ST.h
//  Six Times
//
//  Created by Doug on 4/15/14.
//  Copyright (c) 2014 A Great Highway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (ST)

+(UIFont *)preferredSerifFontForTextStyle:(NSString *)textStyle;

+(UIFont *)preferredFontForActionIcon;
+(UIFont *)preferredFontForActionText;
+(UIFont *)preferredFontForAdviceNameInEntry;
+(UIFont *)preferredFontForAdviceNameInSetOfAdviceListing;
+(UIFont *)preferredFontForSetOfAdviceName;
+(UIFont *)preferredFontForTraditionName;

+(UIFont *)preferredFontForTimeForNextEntry;
+(UIFont *)preferredFontForTimeForRemaingScheduledEntry;
+(UIFont *)preferredFontForTimeForUpdatedEntry;

+(UIFont *)preferredFontForMainMessageBody;
+(UIFont *)preferredFontForMainMessageHeadline;

+(UIFont *)preferredFontForUILabel;
+(UIFont *)preferredFontBoldForUILabel;


+(UIFont *)fontFrom:(UIFont *)font withModifiedSize:(CGFloat)pointSize;
@end
