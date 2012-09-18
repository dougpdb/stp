//
//  STLogEntryTimedCell.m
//  Six Times Path
//
//  Created by Doug on 9/7/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "STLogEntryTimedCell.h"

@implementation STLogEntryTimedCell

@synthesize guidelineLabel	= _guidelineLabel;
@synthesize timeLabel		= _timeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.guidelineLabel					= [[UILabel alloc] initWithFrame:CGRectZero];
		self.guidelineLabel.numberOfLines	= 0;
        [self.contentView addSubview: self.guidelineLabel];
		
        self.timeLabel						= [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview: self.timeLabel];    }
    return self;
}

- (void) layoutSubviews {
	
    // Let the super class UITableViewCell do whatever layout it wants.
    // Just don't use the built-in textLabel or detailTextLabel properties
    [super layoutSubviews];
	
    // Now do the layout of your custom views
	
    // Let the labels size themselves to accommodate their text
//    [self.guidelineLabel sizeToFit];
//    [self.timeLabel sizeToFit];
//	
//	NSString *labelText			= sixOfDayEntry.advice.name;
//	
//	CGSize constraint			= CGSizeMake(CELL_CONTENT_WIDTH, 20000.0f);
//	
//	CGSize labelSize			= [labelText sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	
    // Position the labels at the top of the table cell
    CGRect newFrame		= self.guidelineLabel.frame;
    newFrame.origin.x	= CGRectGetMinX (self.contentView.bounds) + 8.;
    newFrame.origin.y	= CGRectGetMinY (self.contentView.bounds);
    [self.guidelineLabel setFrame: newFrame];
	
    // Put the detail text label immediately to the right
	// w/10 pixel gap between them
    newFrame			= self.timeLabel.frame;
    newFrame.origin.x	= CGRectGetMinX (self.contentView.bounds) + 8.;
    newFrame.origin.y	= CGRectGetMaxY (self.guidelineLabel.bounds) + 3.;
    [self.timeLabel setFrame: newFrame];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
