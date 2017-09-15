//
//  MVMessageCell.m
//  MVChat
//
//  Created by Mark Vasiv on 01/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVMessageTextCell.h"

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
    messageLabel.font = [UIFont systemFontOfSize:18];
    messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    messageLabel.textColor = [UIColor darkTextColor];
    [messageLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [messageLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    return messageLabel;
}

#pragma mark - Offsets
- (CGFloat)contentLeftOffset {
    return [MVMessageCellModel contentOffsetForMessageType:MVMessageCellModelTypeTextMessage
                                                  tailType:self.tailType
                                                  tailSide:(self.direction == MVMessageCellModelDirectionIncoming)];
}

- (CGFloat)contentRightOffset {
    return [MVMessageCellModel contentOffsetForMessageType:MVMessageCellModelTypeTextMessage
                                                  tailType:self.tailType
                                                  tailSide:(self.direction == MVMessageCellModelDirectionOutgoing)];
}

#pragma mark - MVMessageCell protocol
- (void)fillWithModel:(MVMessageCellModel *)model {
    [super fillWithModel:model];
    self.messageLabel.text = model.text;
}

@end
