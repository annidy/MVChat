//
//  MVMessageBubbleCell.h
//  MVChat
//
//  Created by Mark Vasiv on 04/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVMessageCellProtocol.h"
#import "MVSlidingCell.h"
#import "MVMessageCellDelegate.h"

static CGFloat MVBubbleTailSize = 6;

@interface MVMessageBubbleCell : UITableViewCell <MVSlidingCell, MVMessageCellComplexProtocol>
@property (assign, nonatomic) MVMessageCellTailType tailType;
@property (assign, nonatomic) MessageDirection direction;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) UIImageView *bubbleImageView;
@property (strong, nonatomic) UILabel *timeLabel;
@property (weak, nonatomic) id <MVMessageCellDelegate> delegate;
+ (CGFloat)maxContentWidthWithDirection:(MessageDirection)direction;
- (void)setupViews;
@end
