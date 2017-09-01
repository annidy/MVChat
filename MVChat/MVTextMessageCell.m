//
//  MVMessageCell.m
//  MVChat
//
//  Created by Mark Vasiv on 01/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVTextMessageCell.h"
#import "MVContactManager.h"
#import "MVChatManager.h"
#import "MVFileManager.h"
#import <DBAttachment.h>

static CGFloat MVBubbleWidthMultiplierOutgoing = 0.8;
static CGFloat MVBubbleWidthMultiplierIncoming = 0.7;
static CGFloat MVBubbleTailSideOffset = 15;
static CGFloat MVBubbleTailessSideOffset = 10;
static CGFloat MVBubbleVerticalOffsetDefault = 7;
static CGFloat MVBubbleVerticalOffsetTailess = 1;
static CGFloat MVMessageLabelOffsetOutgoing = 25;
static CGFloat MVMessageLabelOffsetIncoming = 56;
static CGFloat MVAvatarImageSide = 36;
static CGFloat MVAvatarImageOffset = 5;

@interface MVTextMessageCell ()
@property (strong, nonatomic) NSLayoutConstraint *timeLeftConstraint;
@property (assign, nonatomic) MessageDirection direction;
@property (assign, nonatomic) MVMessageCellTailType tailType;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIImageView *avatarImage;
@property (strong, nonatomic) UIImageView *bubbleImageView;
@end

@implementation MVTextMessageCell
#pragma mark - Lifecycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _direction = [MVTextMessageCell directionForReuseIdentifier:reuseIdentifier];
        _tailType = [MVTextMessageCell tailTypeForReuseIdentifier:reuseIdentifier];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self buildViewHierarchy];
    }
    
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.avatarImage.image = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Build views
- (void)buildViewHierarchy {
    self.bubbleImageView = [self buildBubbleImageView];
    self.messageLabel = [self buildMessageLabel];
    self.timeLabel = [self buildTimeLabel];
    
    [self.contentView addSubview:self.bubbleImageView];
    [self.contentView addSubview:self.messageLabel];
    [self.contentView addSubview:self.timeLabel];
    
    [[self.bubbleImageView.widthAnchor constraintLessThanOrEqualToAnchor:self.contentView.widthAnchor multiplier:[self bubbleWidthMultiplier]] setActive:YES];
    [[self.bubbleImageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:[self bubbleTopOffset]] setActive:YES];
    [[self.bubbleImageView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-[self bubbleBottomOffset]] setActive:YES];
    [[self.messageLabel.topAnchor constraintEqualToAnchor:self.bubbleImageView.topAnchor constant:MVBubbleVerticalOffsetDefault] setActive:YES];
    [[self.messageLabel.bottomAnchor constraintEqualToAnchor:self.bubbleImageView.bottomAnchor constant:-MVBubbleVerticalOffsetDefault] setActive:YES];
    [[self.messageLabel.leftAnchor constraintEqualToAnchor:self.bubbleImageView.leftAnchor constant:[self messageLabelLeftOffset]] setActive:YES];
    [[self.messageLabel.rightAnchor constraintEqualToAnchor:self.bubbleImageView.rightAnchor constant:-[self messageLabelRightOffset]] setActive:YES];
    
    [[self.timeLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor] setActive:YES];
    [self.timeLeftConstraint = [self.timeLabel.leftAnchor constraintEqualToAnchor:self.contentView.rightAnchor] setActive:YES];
    
    if (self.direction == MessageDirectionOutgoing) {
        [[self.messageLabel.rightAnchor constraintEqualToAnchor:self.timeLabel.leftAnchor constant:-MVMessageLabelOffsetOutgoing] setActive:YES];
    } else {
        [[self.messageLabel.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor constant:MVMessageLabelOffsetIncoming] setActive:YES];
    }
    
    if (self.direction == MessageDirectionIncoming) {
        self.avatarImage = [self buildAvatarImageView];
        [self.contentView addSubview:self.avatarImage];
        [[self.avatarImage.widthAnchor constraintEqualToConstant:MVAvatarImageSide] setActive:YES];
        [[self.avatarImage.heightAnchor constraintEqualToConstant:MVAvatarImageSide] setActive:YES];
        [[self.avatarImage.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor constant:MVAvatarImageOffset] setActive:YES];
        [[self.avatarImage.bottomAnchor constraintEqualToAnchor:self.bubbleImageView.bottomAnchor] setActive:YES];
    }
}

- (UIImageView *)buildBubbleImageView {
    UIImageView *bubbleImageView = [UIImageView new];
    bubbleImageView.image = [self bubbleImage];
    bubbleImageView.tintColor = [self bubbleColor];
    bubbleImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    return bubbleImageView;
}

- (UILabel *)buildMessageLabel {
    UILabel *messageLabel = [UILabel new];
    messageLabel.numberOfLines = 0;
    messageLabel.font = [UIFont systemFontOfSize:14];
    messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    return messageLabel;
}

- (UILabel *)buildTimeLabel {
    UILabel *timeLabel = [UILabel new];
    timeLabel.font = [UIFont systemFontOfSize:12];
    timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    return timeLabel;
}

- (UIImageView *)buildAvatarImageView {
    UIImageView *avatarImageView = [UIImageView new];
    avatarImageView.layer.cornerRadius = 18;
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    return avatarImageView;
}

- (UIColor *)bubbleColor {
    if (self.direction == MessageDirectionOutgoing) {
        return [UIColor colorWithRed:0.5 green:0.8 blue:0.8 alpha:0.4];
    } else {
        return [UIColor colorWithRed:0.4 green:0.8 blue:0.9 alpha:0.4];
    }
}

- (UIImage *)bubbleImage {
    UIImage *bubbleImage;
    if (self.tailType == MVMessageCellTailTypeTailess || self.tailType == MVMessageCellTailTypeFirstTailess) {
        bubbleImage = [UIImage imageNamed:@"bubbleTailess"];
    } else if (self.direction == MessageDirectionOutgoing) {
        bubbleImage = [UIImage imageNamed:@"bubbleOutgoing"];
    } else {
        bubbleImage = [UIImage imageNamed:@"bubbleIncoming"];
    }
    bubbleImage = [[bubbleImage resizableImageWithCapInsets:UIEdgeInsetsMake(15, 25, 25, 25) resizingMode:UIImageResizingModeStretch] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    return bubbleImage;
}

#pragma mark - Offsets
- (CGFloat)bubbleTopOffset {
    if (self.tailType == MVMessageCellTailTypeTailess || self.tailType == MVMessageCellTailTypeLastTailess) {
        return MVBubbleVerticalOffsetTailess;
    } else {
        return MVBubbleVerticalOffsetDefault;
    }
}
- (CGFloat)bubbleBottomOffset {
    if (self.tailType == MVMessageCellTailTypeTailess || self.tailType == MVMessageCellTailTypeFirstTailess) {
        return MVBubbleVerticalOffsetTailess;
    } else {
        return MVBubbleVerticalOffsetDefault;
    }
}

- (CGFloat)bubbleWidthMultiplier {
    if (self.direction == MessageDirectionOutgoing) {
        return MVBubbleWidthMultiplierOutgoing;
    } else {
        return MVBubbleWidthMultiplierIncoming;
    }
}

- (CGFloat)bubbleTailOffset {
    if (self.tailType == MVMessageCellTailTypeTailess || self.tailType == MVMessageCellTailTypeFirstTailess) {
        return MVBubbleTailessSideOffset;
    } else {
        return MVBubbleTailSideOffset;
    }
}

- (CGFloat)messageLabelLeftOffset {
    if (self.direction == MessageDirectionIncoming) {
        return [self bubbleTailOffset];
    } else {
        return MVBubbleTailessSideOffset;
    }
}

- (CGFloat)messageLabelRightOffset {
    if (self.direction == MessageDirectionIncoming) {
        return MVBubbleTailessSideOffset;
    } else {
        return [self bubbleTailOffset];
    }
}

#pragma mark - Helpers
static UILabel *referenceMessageLabel;
+ (UILabel *)referenceMessageLabel {
    if (!referenceMessageLabel) {
        referenceMessageLabel = [UILabel new];
        referenceMessageLabel.font = [UIFont systemFontOfSize:14];
        referenceMessageLabel.numberOfLines = 0;
    }
    
    return referenceMessageLabel;
}

+ (MVMessageCellTailType)tailTypeForReuseIdentifier:(NSString *)reuseId {
    if ([reuseId containsString:@"TailTypeLastTailess"]) {
        return MVMessageCellTailTypeLastTailess;
    } else if ([reuseId containsString:@"TailTypeFirstTailess"]) {
        return MVMessageCellTailTypeFirstTailess;
    } else if ([reuseId containsString:@"TailTypeTailess"]) {
        return MVMessageCellTailTypeTailess;
    } else {
        return MVMessageCellTailTypeDefault;
    }
}

+ (MessageDirection)directionForReuseIdentifier:(NSString *)reuseId {
    if ([reuseId containsString:@"Outgoing"]) {
        return MessageDirectionOutgoing;
    } else {
        return MessageDirectionIncoming;
    }
}

#pragma mark - MVSlidingCell protocol
- (void)setSlidingConstraint:(CGFloat)constant {
    self.timeLeftConstraint.constant = constant;
}

- (CGFloat)slidingConstraint {
    return self.timeLeftConstraint.constant;
}

#pragma mark - MVMessageCell protocol
+ (CGFloat)heightWithTailType:(MVMessageCellTailType)tailType direction:(MessageDirection)direction andModel:(MVMessageModel *)model{
    MVTextMessageCell *cell = [MVTextMessageCell new];
    cell.tailType = tailType;
    cell.direction = direction;
    
    CGFloat height = [cell bubbleTopOffset] + [cell bubbleBottomOffset] + MVBubbleVerticalOffsetDefault * 2;
    
    CGFloat maxLabelWidth = UIScreen.mainScreen.bounds.size.width * [cell bubbleWidthMultiplier] - [cell messageLabelLeftOffset] - [cell messageLabelRightOffset];
    
    [self.referenceMessageLabel setText:model.text];
    height += [self.referenceMessageLabel sizeThatFits:CGSizeMake(maxLabelWidth, CGFLOAT_MAX)].height;
    
    return height;
}

- (void)fillWithModel:(MVMessageModel *)messageModel {
    self.messageLabel.text = messageModel.text;
    self.timeLabel.text = [[MVChatManager sharedInstance] timeFromDate:messageModel.sendDate];
    
    if (self.direction == MessageDirectionIncoming) {
        [[MVFileManager sharedInstance] loadAvatarAttachmentForContact:messageModel.contact completion:^(DBAttachment *attachment) {
            [attachment thumbnailImageWithMaxWidth:50 completion:^(UIImage *image) {
                self.avatarImage.image = image;
            }];
        }];
    }
    
    
    __weak MVTextMessageCell *weakCell = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ContactAvatarUpdate" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSString *avatarName = note.userInfo[@"Avatar"];
        weakCell.avatarImage.image = [UIImage imageNamed:avatarName];
    }];
}

@end
