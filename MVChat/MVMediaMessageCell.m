//
//  MVMediaMessageCell.m
//  MVChat
//
//  Created by Mark Vasiv on 27/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVMediaMessageCell.h"
#import "MVContactManager.h"
#import "MVChatManager.h"
#import "MVMessageModel.h"
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

@interface MVMediaMessageCell ()
@property (strong, nonatomic) NSLayoutConstraint *timeLeftConstraint;
@property (assign, nonatomic) MessageDirection direction;
@property (strong, nonatomic) UIImageView *avatarImage;
@property (strong, nonatomic) UIImageView *bubbleImageView;
@property (strong, nonatomic) UILabel *timeLabel;
@end
@implementation MVMediaMessageCell

#pragma mark - Lifecycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _direction = [MVMediaMessageCell directionForReuseIdentifier:reuseIdentifier];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self buildViewHierarchy];
        [self buildTapRecognizers];
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
- (void)buildTapRecognizers {
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleTapped:)];
    self.mediaImageView.userInteractionEnabled = YES;
    [self.mediaImageView addGestureRecognizer:tapRecognizer];
}

- (void)buildViewHierarchy {
    self.bubbleImageView = [self buildBubbleImageView];
    self.mediaImageView = [self buildMediaImageView];
    self.timeLabel = [self buildTimeLabel];
    
    [self.contentView addSubview:self.bubbleImageView];
    [self.contentView addSubview:self.mediaImageView];
    [self.contentView addSubview:self.timeLabel];
    
    [[self.bubbleImageView.widthAnchor constraintLessThanOrEqualToAnchor:self.contentView.widthAnchor multiplier:[self bubbleWidthMultiplier]] setActive:YES];
    [[self.bubbleImageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:[self bubbleTopOffset]] setActive:YES];
    [[self.bubbleImageView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-[self bubbleBottomOffset]] setActive:YES];
    
    [[self.mediaImageView.topAnchor constraintEqualToAnchor:self.bubbleImageView.topAnchor constant:2] setActive:YES];
    [[self.mediaImageView.bottomAnchor constraintEqualToAnchor:self.bubbleImageView.bottomAnchor constant:-2] setActive:YES];
    [[self.mediaImageView.leftAnchor constraintEqualToAnchor:self.bubbleImageView.leftAnchor constant:2] setActive:YES];
    [[self.mediaImageView.rightAnchor constraintEqualToAnchor:self.bubbleImageView.rightAnchor constant:-2] setActive:YES];
    
    //[[self.mediaImageView.widthAnchor constraintEqualToConstant:200] setActive:YES];
    //[[self.mediaImageView.heightAnchor constraintEqualToConstant:100] setActive:YES];
    
    [[self.timeLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor] setActive:YES];
    [self.timeLeftConstraint = [self.timeLabel.leftAnchor constraintEqualToAnchor:self.contentView.rightAnchor] setActive:YES];
    
    if (self.direction == MessageDirectionOutgoing) {
        [[self.mediaImageView.rightAnchor constraintEqualToAnchor:self.timeLabel.leftAnchor constant:-MVMessageLabelOffsetOutgoing] setActive:YES];
    } else {
        [[self.mediaImageView.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor constant:MVMessageLabelOffsetIncoming] setActive:YES];
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

- (UIImageView *)buildMediaImageView {
    UIImageView *bubbleImageView = [UIImageView new];
    bubbleImageView.translatesAutoresizingMaskIntoConstraints = NO;
    bubbleImageView.layer.cornerRadius = 15;
    bubbleImageView.layer.masksToBounds = YES;
    
    return bubbleImageView;
}
- (UIImageView *)buildBubbleImageView {
    UIImageView *bubbleImageView = [UIImageView new];
    bubbleImageView.image = [self bubbleImage];
    bubbleImageView.tintColor = [self bubbleColor];
    bubbleImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    return bubbleImageView;
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
    UIImage *bubbleImage = [UIImage imageNamed:@"bubbleTailess"];
    bubbleImage = [[bubbleImage resizableImageWithCapInsets:UIEdgeInsetsMake(15, 25, 25, 25) resizingMode:UIImageResizingModeStretch] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    return bubbleImage;
}

#pragma mark - Offsets
- (CGFloat)bubbleTopOffset {
    return MVBubbleVerticalOffsetDefault;
}

- (CGFloat)bubbleBottomOffset {
    return MVBubbleVerticalOffsetDefault;
}

- (CGFloat)bubbleWidthMultiplier {
    if (self.direction == MessageDirectionOutgoing) {
        return MVBubbleWidthMultiplierOutgoing;
    } else {
        return MVBubbleWidthMultiplierIncoming;
    }
}

- (CGFloat)messageLabelLeftOffset {
    return MVBubbleTailessSideOffset;
}

- (CGFloat)messageLabelRightOffset {
    return MVBubbleTailessSideOffset;
}

#pragma mark - Helpers

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
+ (CGFloat)heightWithTailType:(MVMessageCellTailType)tailType direction:(MessageDirection)direction andModel:(MVMessageModel *)model {
    MVMediaMessageCell *cell = [MVMediaMessageCell new];
    cell.direction = direction;
    
    CGFloat height = [cell bubbleTopOffset] + [cell bubbleBottomOffset] + 4;
    CGFloat maxContentWidth = UIScreen.mainScreen.bounds.size.width * [cell bubbleWidthMultiplier] - 4;
    
    CGSize actualSize = [[MVFileManager sharedInstance] sizeOfAttachmentForMessage:model];
    CGSize scaledSize;
    if (maxContentWidth > actualSize.width) {
        scaledSize.width = actualSize.width;
        scaledSize.height = actualSize.height;
    } else {
        CGFloat scale = maxContentWidth/actualSize.width;
        scaledSize.width = maxContentWidth;
        scaledSize.height = actualSize.height * scale;
    }
    
    
    CGFloat imageHeight = scaledSize.height;
    height += imageHeight;
    
    return height;
}

- (void)fillWithModel:(MVMessageModel *)messageModel {
    self.timeLabel.text = [[MVChatManager sharedInstance] timeFromDate:messageModel.sendDate];
    CGFloat maxContentWidth = UIScreen.mainScreen.bounds.size.width * [self bubbleWidthMultiplier] - 4;
    
    [[MVFileManager sharedInstance] loadAttachmentForMessage:messageModel completion:^(DBAttachment *attachment) {
        [attachment thumbnailImageWithMaxWidth:maxContentWidth completion:^(UIImage *image) {
            self.mediaImageView.image = image;
        }];
    }];
}

- (void)bubbleTapped:(UITapGestureRecognizer *)recognizer {
    [self.delegate cellTapped:self];
}

@end
