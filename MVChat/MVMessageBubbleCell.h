//
//  MVMessageBubbleCell.h
//  MVChat
//
//  Created by Mark Vasiv on 04/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVSlidingCell.h"
#import "MVMessageCellModel.h"
#import "MVMessageCell.h"

@interface MVMessageBubbleCell : UITableViewCell <MVSlidingCell, MVMessageCell>
@property (assign, nonatomic) MVMessageCellTailType tailType;
@property (assign, nonatomic) MVMessageCellModelDirection direction;
@property (strong, nonatomic) UIImageView *bubbleImageView;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) MVMessageCellModel *model;
- (void)setupViews;
@end
