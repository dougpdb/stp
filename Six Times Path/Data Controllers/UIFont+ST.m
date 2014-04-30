//
//  UIFont+ST.m
//  Six Times
//
//  Created by Doug on 4/15/14.
//  Copyright (c) 2014 A Great Highway. All rights reserved.
//

#import "UIFont+ST.h"



@implementation UIFont (ST)

#pragma mark - Private constructor for main serif font

+(UIFont *)preferredSerifFontForTextStyle:(NSString *)textStyle
{
	UIFont *newFont;
	NSString *fontNameSerif = @"Palatino-Roman";
	NSString *fontNameSerifBold = @"Palatino-Bold";
	CGFloat fontSize = 17.0;
	CGFloat fontSizeModifierHeadline = 3.0;
	CGFloat fontSizeModifierSubHeadline = 1.0;
	CGFloat fontSizeModifierBody = 0.0;
	CGFloat fontSizeModifierCaption1 = -5.0;
	CGFloat fontSizeModifierCaption2 = -6.0;
	CGFloat fontSizeModifierFootnote = -4.0;
	
	NSString *contentSize = [UIApplication sharedApplication].preferredContentSizeCategory;
	
	
	
	if ([contentSize isEqualToString:UIContentSizeCategoryExtraSmall]) {

		fontSize = 14.0;
		fontSizeModifierCaption1 += 2.0;
		fontSizeModifierCaption2 += 3.0;
		fontSizeModifierFootnote += 2.0;
		
	} else if ([contentSize isEqualToString:UIContentSizeCategorySmall]) {

		fontSize = 15.0;
		fontSizeModifierCaption1 += 1.0;
		fontSizeModifierCaption2 += 2.0;
		fontSizeModifierFootnote += 1.0;
		
	} else if ([contentSize isEqualToString:UIContentSizeCategoryMedium]) {
		
		fontSize = 16.0;
		fontSizeModifierCaption2 += 1.0;

		
	} else if ([contentSize isEqualToString:UIContentSizeCategoryLarge]) {

		fontSize = 17.0;
		
	} else if ([contentSize isEqualToString:UIContentSizeCategoryExtraLarge]) {

		fontSize = 18.0;
		
	} else if ([contentSize isEqualToString:UIContentSizeCategoryExtraExtraLarge]) {
		
		fontSize = 19.0;
		
	} else if ([contentSize isEqualToString:UIContentSizeCategoryExtraExtraExtraLarge]) {
		
		fontSize = 20.0;
		
	}
	
	
	
	if ([textStyle isEqualToString:UIFontTextStyleHeadline]) {
		
		newFont = [UIFont fontWithName:fontNameSerif size:fontSize + fontSizeModifierHeadline];
		
	} else if ([textStyle isEqualToString:UIFontTextStyleSubheadline]) {
		
		newFont = [UIFont fontWithName:fontNameSerifBold size:fontSize + fontSizeModifierSubHeadline];
		
	} else if ([textStyle isEqualToString:UIFontTextStyleBody]) {
		
		newFont = [UIFont fontWithName:fontNameSerif size:fontSize + fontSizeModifierBody];

	} else if ([textStyle isEqualToString:UIFontTextStyleCaption1]) {
		
		newFont = [UIFont fontWithName:fontNameSerif size:fontSize + fontSizeModifierCaption1];
		
	} else if ([textStyle isEqualToString:UIFontTextStyleCaption2]) {
		
		newFont	= [UIFont fontWithName:fontNameSerif size:fontSize + fontSizeModifierCaption2];
		
	} else if ([textStyle isEqualToString:UIFontTextStyleFootnote]) {
		
		newFont = [UIFont fontWithName:fontNameSerif size:fontSize + fontSizeModifierFootnote];
		
	}
	
	return newFont;
}


#pragma mark - Public constructors

+(UIFont *)preferredFontForActionIcon
{
	UIFont *newFont = [self preferredFontForTextStyle:UIFontTextStyleBody];
	CGFloat fontSizeModifier = -2.0;
	
	NSString *contentSize = [UIApplication sharedApplication].preferredContentSizeCategory;
	
	if (![contentSize isEqualToString:UIContentSizeCategoryExtraSmall]) {
		
		return newFont = [UIFont fontFrom:newFont withModifiedSize:fontSizeModifier];
		
	}
	
	return newFont;
}


+(UIFont *)preferredFontForActionText
{
	UIFont *newFont = [self preferredFontForTextStyle:UIFontTextStyleBody];
	CGFloat fontSizeModifier = -2.0;
	
	NSString *contentSize = [UIApplication sharedApplication].preferredContentSizeCategory;

	if (![contentSize isEqualToString:UIContentSizeCategoryExtraSmall]) {
		
		return newFont = [UIFont fontFrom:newFont withModifiedSize:fontSizeModifier];
		
	}
	
	return newFont;
}


+(UIFont *)preferredFontForAdviceNameInEntry
{
	UIFont *newFont = [self preferredSerifFontForTextStyle:UIFontTextStyleBody];
	CGFloat fontSizeModifier = 3.0;
	return [self fontFrom:newFont withModifiedSize:fontSizeModifier];
}


+(UIFont *)preferredFontForAdviceNameInSetOfAdviceListing
{
	return [self preferredSerifFontForTextStyle:UIFontTextStyleBody];
}


+(UIFont *)preferredFontForSetOfAdviceName
{
	UIFont *newFont = [self preferredFontForTextStyle:UIFontTextStyleSubheadline];
	UIFontDescriptor *originalDescriptior = [newFont fontDescriptor];
	UIFontDescriptor *descriptorWithBold = [originalDescriptior fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
	UIFont *fontWithBold = [UIFont fontWithDescriptor:descriptorWithBold size:0.0];
	
	CGFloat fontSizeModifier = 3.0;
	return [self fontFrom:fontWithBold withModifiedSize:fontSizeModifier];
}


+(UIFont *)preferredFontForTraditionName
{
	UIFont *newFont = [self preferredFontForTextStyle:UIFontTextStyleFootnote];
	CGFloat fontSizeModifier = 2.0;
	return [self fontFrom:newFont withModifiedSize:fontSizeModifier];
}



+ (UIFont *)preferredFontForTimeForNextEntry
{
	UIFont *newFont = [self preferredFontForTextStyle:UIFontTextStyleCaption1];
	CGFloat fontSizeModifier = 1.0;
	return [self fontFrom:newFont withModifiedSize:fontSizeModifier];
}


+(UIFont *)preferredFontForTimeForRemaingScheduledEntry
{
	UIFont *newFont = [self preferredFontForTextStyle:UIFontTextStyleCaption2];
	CGFloat fontSizeModifier = 1.0;
	return [self fontFrom:newFont withModifiedSize:fontSizeModifier];
}


+(UIFont *)preferredFontForTimeForUpdatedEntry
{
	UIFont *newFont = [self preferredFontForTextStyle:UIFontTextStyleCaption2];
	UIFontDescriptor *originalDescriptor = [newFont fontDescriptor];
	UIFontDescriptor *newDescriptor = [originalDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
	return [UIFont fontWithDescriptor:newDescriptor size:newFont.pointSize + 1.0];
}

+(UIFont *)preferredFontForMainMessageBody
{
	UIFont *newFont = [self preferredFontForTextStyle:UIFontTextStyleBody];
	return newFont;
}


+(UIFont *)preferredFontForMainMessageHeadline
{
	UIFont *newFont = [self preferredFontForTextStyle:UIFontTextStyleSubheadline];
	return newFont;
}


+(UIFont *)preferredFontForUILabel
{
	UIFont *newFont = [self preferredFontForTextStyle:UIFontTextStyleBody];
	CGFloat minimumFontPointSize = 14.0;
	CGFloat fontSizeModifier = -2.0;
	CGFloat newFontPointSize = newFont.pointSize + fontSizeModifier;
	
	if (newFontPointSize > minimumFontPointSize) {
	
		return [self fontFrom:newFont withModifiedSize:fontSizeModifier];
	
	} else {
	
		return [self fontFrom:newFont withModifiedSize:0.0];
	
	}
}

+(UIFont *)preferredFontBoldForUILabel
{
	UIFont *newFont = [self preferredFontForUILabel];
	UIFontDescriptor *originalDescriptor = [newFont fontDescriptor];
	UIFontDescriptor *newDescriptor = [originalDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
	return [UIFont fontWithDescriptor:newDescriptor size:0.0];
}

#pragma mark - Instance method
+(UIFont *)fontFrom:(UIFont *)font withModifiedSize:(CGFloat)pointSize
{
	UIFontDescriptor *originalDescriptor = [font fontDescriptor];
	CGFloat newFontSize = originalDescriptor.pointSize + pointSize;
	
	return [UIFont fontWithDescriptor:originalDescriptor size:newFontSize];
}




@end
