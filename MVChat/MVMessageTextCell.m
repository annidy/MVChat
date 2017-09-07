//
//  MVMessageCell.m
//  MVChat
//
//  Created by Mark Vasiv on 01/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVMessageTextCell.h"

static CGFloat MVTextContentVerticalOffset = 6;
static CGFloat MVTextContentHorizontalOffset = 9;

@interface MVMessageTextCell ()
@property (strong, nonatomic) UILabel *messageLabel;
@end

@implementation MVMessageTextCell
#pragma mark - Build views
- (void)setupViews {
    [super setupViews];

    self.messageLabel = [self buildMessageLabel];
    [self.contentView addSubview:self.messageLabel];
    
    [[self.messageLabel.topAnchor constraintEqualToAnchor:self.bubbleImageView.topAnchor constant:MVTextContentVerticalOffset] setActive:YES];
    [[self.messageLabel.bottomAnchor constraintEqualToAnchor:self.bubbleImageView.bottomAnchor constant:-MVTextContentVerticalOffset] setActive:YES];
    [[self.messageLabel.leftAnchor constraintEqualToAnchor:self.bubbleImageView.leftAnchor constant:[self contentLeftOffset]] setActive:YES];
    [[self.messageLabel.rightAnchor constraintEqualToAnchor:self.bubbleImageView.rightAnchor constant:-[self contentRightOffset]] setActive:YES];
}

- (UILabel *)buildMessageLabel {
    UILabel *messageLabel = [UILabel new];
    messageLabel.numberOfLines = 0;
    messageLabel.font = [UIFont systemFontOfSize:17];
    messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    messageLabel.textColor = [UIColor darkTextColor];
    [messageLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [messageLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    return messageLabel;
}

#pragma mark - Offsets
- (CGFloat)contentLeftOffset {
    return [[self class] contentOffsetForTailType:self.tailType tailSide:(self.direction == MessageDirectionIncoming)];
}

- (CGFloat)contentRightOffset {
    return [[self class] contentOffsetForTailType:self.tailType tailSide:(self.direction == MessageDirectionOutgoing)];
}

+ (CGFloat)contentOffsetForTailType:(MVMessageCellTailType)tailType tailSide:(BOOL)tailSide {
    CGFloat offset = MVTextContentHorizontalOffset;
    if (tailSide && (tailType == MVMessageCellTailTypeDefault || tailType == MVMessageCellTailTypeLastTailess)) {
        offset += MVBubbleTailSize;
    }
    
    return offset;
}

#pragma mark - Helpers
static UILabel *referenceMessageLabel;
+ (UILabel *)referenceMessageLabel {
    if (!referenceMessageLabel) {
        referenceMessageLabel = [UILabel new];
        referenceMessageLabel.font = [UIFont systemFontOfSize:17];
        referenceMessageLabel.numberOfLines = 0;
    }
    
    return referenceMessageLabel;
}

#pragma mark - MVMessageCell protocol
+ (CGFloat)heightWithTailType:(MVMessageCellTailType)tailType direction:(MessageDirection)direction andModel:(MVMessageModel *)model{
    CGFloat maxContentWidth = [super maxContentWidthWithDirection:direction] - [self contentOffsetForTailType:tailType tailSide:YES] - [self contentOffsetForTailType:tailType tailSide:NO];
    CGFloat height = [super heightWithTailType:tailType direction:direction andModel:model] + 2 * MVTextContentVerticalOffset;
    
    [self.referenceMessageLabel setText:model.text];
    height += [self.referenceMessageLabel sizeThatFits:CGSizeMake(maxContentWidth, CGFLOAT_MAX)].height;
    
    return height;
}

- (void)fillWithModel:(MVMessageModel *)messageModel {
    [super fillWithModel:messageModel];
    self.messageLabel.text = messageModel.text;
}

@end
