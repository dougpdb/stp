//
//  STLogEntryTimedCell.h
//  Six Times Path
//
//  Created by Doug on 9/7/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STLogEntryTimedCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *guidelineLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;

-(void)layoutSubviews;

@end
