//
//  MVMessageCell.h
//  MVChat
//
//  Created by Mark Vasiv on 01/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVSlidingCell.h"
@class MVMessageModel;

static CGFloat innerMargin = 25;
static CGFloat verticalMargin = 7;
static CGFloat tailessVerticalMargin = 1;
static CGFloat bubbleTailMargin = 15;
static CGFloat bubbleTailessMargin = 10;
static CGFloat tailWidth = 5;

@interface MVMessageCell : UITableViewCell <MVSlidingCell>
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIImageView *avatarImage;
@end
