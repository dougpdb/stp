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

//- (void) layoutSubviews {
//	
//    // Let the super class UITableViewCell do whatever layout it wants.
//    // Just don't use the built-in textLabel or detailTextLabel properties
//    [super layoutSubviews];
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
