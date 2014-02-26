//
//  GHUIPlaceHolderTextView.m
//  TextView w Placeholder Test
//
//  Created by Doug on 7/19/13.
//  Copyright (c) 2013 A Great Highway. All rights reserved.
//

#import "GHUIPlaceHolderTextView.h"

//@implementation GHUIPlaceHolderTextView ()
//
//@end

@interface GHUIPlaceHolderTextView ()

//@property (nonatomic, strong) UILabel *placeHolderLabel;
-(void)_initialize;
-(void)_textChanged:(NSNotification *)notification;

@property BOOL wasPlaceholderShowing;
@end


@implementation GHUIPlaceHolderTextView {
    BOOL _shouldShowPlaceholder;
}


#pragma mark - Accessors

@synthesize placeholder			= _placeholder;
@synthesize placeholderColor	= _placeholderColor;


- (void)setPlaceholder:(NSString *)string {
    if ([string isEqual:_placeholder]) {
        return;
    }
	
	_placeholder	= string;
	
	if ([_placeholder length] > 0)
		_shouldShowPlaceholder	= YES;
}


#pragma mark - NSObject

- (void)dealloc {
	//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
//	
//    [_placeholder release];
//    [_placeholderColor release];
//    [super dealloc];
}


#pragma mark - UIView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self _initialize];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self _initialize];
    }
    return self;
}


#pragma mark - Private

- (void)_initialize
{
    self.placeholderColor							= [UIColor lightGrayColor];
	self.inputTextColor								= [UIColor blackColor];
	self.placeholderIsShowing						= NO;
	self.shouldShowPlaceholderWhenFirstResponder	= NO;
    _shouldShowPlaceholder							= NO;
	self.textContainerInset							= UIEdgeInsetsZero;
	
}


- (void)updateShouldShowPlaceholder {
	if (self.isFirstResponder && !self.shouldShowPlaceholderWhenFirstResponder)
	{
		if (self.placeholderIsShowing)
			[self setShowPlaceholder:NO];
		
		return;
	}
    
	BOOL prev = _shouldShowPlaceholder;
    _shouldShowPlaceholder = self.placeholder && self.placeholderColor && ( self.text.length == 0 || [self.text isEqualToString:self.placeholder] );
	
	if (prev != _shouldShowPlaceholder || (_shouldShowPlaceholder && !_wasPlaceholderShowing))
		[self setShowPlaceholder:_shouldShowPlaceholder];
}


-(void)setShowPlaceholder:(BOOL)showPlaceholder
{
	if (showPlaceholder)
	{
		self.text					= self.placeholder;
		self.textColor				= self.placeholderColor;
		self.wasPlaceholderShowing	= YES;
		
		[self moveCursorToBeginningOfContent];
	}
	else
	{
		if (self.wasPlaceholderShowing)
			[self removePlaceholderFromContent];
		self.textColor				= self.inputTextColor;
		self.wasPlaceholderShowing	= NO;
	}
	self.placeholderIsShowing		= showPlaceholder;
}

-(void)removePlaceholderFromContent
{
	// This will only remove the placeholder from the content of the UITextView if the placeholder text is at the end of the content
	NSRange rangeOfPlaceholder	= [self.text rangeOfString:self.placeholder];

	if ([self.text length] - rangeOfPlaceholder.location == [self.placeholder length])
		self.text				= [self.text substringToIndex:rangeOfPlaceholder.location];
}

-(BOOL)isPlaceholderShowing
{
	return [self.text isEqualToString:self.placeholder];
}

-(void)moveCursorToBeginningOfContent
{
	dispatch_async(dispatch_get_main_queue(), ^{
		self.selectedRange = NSMakeRange(0, 0);
	});
}


@end
