//
//  STLogEntryBestWorstOrToDoTextEntryCell.m
//  Six Times Path
//
//  Created by Doug on 10/10/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "STLogEntryBestWorstOrToDoTextEntryCell.h"


@implementation STLogEntryBestWorstOrToDoTextEntryCell
@synthesize textInput	= _textInput;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
