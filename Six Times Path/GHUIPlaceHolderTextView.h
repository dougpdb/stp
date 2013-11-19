//
//  GHUIPlaceHolderTextView.h
//  TextView w Placeholder Test
//
//  Created by Doug on 7/19/13.
//  Copyright (c) 2013 A Great Highway. All rights reserved.
//	http://stackoverflow.com/questions/1328638/placeholder-in-uitextview

#import <UIKit/UIKit.h>

@interface GHUIPlaceHolderTextView : UITextView


@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic, strong) UIColor *inputTextColor;
@property BOOL placeholderIsShowing;


//-(void)textChanged:(NSNotification *)notification;
-(void)updateShouldShowPlaceholder;
-(void)setShowPlaceholder:(BOOL)showPlaceholder;
-(BOOL)isPlaceholderShowing;
-(void)moveCursorToBeginningOfContent;

@end
