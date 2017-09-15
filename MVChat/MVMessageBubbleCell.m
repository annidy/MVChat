//
//  MVMessageBubbleCell.m
//  MVChat
//
//  Created by Mark Vasiv on 04/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVMessageBubbleCell.h"
#import "MVMessageModel.h"
#import "NSString+Helpers.h"
#import "MVFileManager.h"
#import <ReactiveObjC.h>

#define MVCacheBubbleImageDef(name, incoming, fileName) \
    static UIImage *name() \
    { \
        static UIImage *image = nil; \
        static dispatch_once_t onceToken; \
        dispatch_once(&onceToken, ^ \
        { \
            image = [[UIImage imageNamed:fileName] stretchableImageWithLeftCapWidth:incoming ? 23 : (40 - 23) topCapHeight:16]; \
        }); \
        return image; \
    }

MVCacheBubbleImageDef(incomingImage, true, @"bubbleIncoming")
MVCacheBubbleImageDef(incomingTaillessImage, true, @"bubbleIncomingTailless")
MVCacheBubbleImageDef(outgoingImage, false, @"bubbleOutgoing")
MVCacheBubbleImageDef(outgoingTaillessImage, false, @"bubbleOutgoingTailless")

@interface MVMessageBubbleCell()
@property (strong, nonatomic) NSLayoutConstraint *timeLeftConstraint;
@property (strong, nonatomic) NSLayoutConstraint *bubbleWidthConstraint;
@property (strong, nonatomic) UIImageView *avatarImage;
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;
@end

@implementation MVMessageBubbleCell
#pragma mark - Lifecycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _direction = [MVMessageCellModel directionForReuseIdentifier:reuseIdentifier];
        _tailType = [MVMessageCellModel tailTypeForReuseIdentifier:reuseIdentifier];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupViews];
        [self setupTapRecognizers];
    }
    
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.avatarImage.image = nil;
}

#pragma mark - Build views
- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];
    self.bubbleImageView = [self buildBubbleImageView];
    self.timeLabel = [self buildTimeLabel];
    
    [self.contentView addSubview:self.bubbleImageView];
    [self.contentView addSubview:self.timeLabel];
        
    [self.bubbleWidthConstraint = [self.bubbleImageView.widthAnchor constraintEqualToConstant:100] setActive:YES];
    [[self.bubbleImageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:[self bubbleTopOffset]] setActive:YES];
    [[self.bubbleImageView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-[self bubbleBottomOffset]] setActive:YES];
    
    [[self.timeLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor] setActive:YES];
    [self.timeLeftConstraint = [self.timeLabel.leftAnchor constraintEqualToAnchor:self.contentView.rightAnchor] setActive:YES];
    
    if (self.direction == MessageDirectionIncoming && (self.tailType == MVMessageCellTailTypeDefault || self.tailType == MVMessageCellTailTypeLastTailess)) {
        self.avatarImage = [self buildAvatarImageView];
        UIView *avatarContainer = [self buildAvatarImageViewContainer];
        [self.contentView addSubview:avatarContainer];
        [avatarContainer addSubview:self.avatarImage];
        [[avatarContainer.widthAnchor constraintEqualToConstant:MVAvatarImageSide] setActive:YES];
        [[avatarContainer.heightAnchor constraintEqualToConstant:MVAvatarImageSide] setActive:YES];
        [[self.avatarImage.leftAnchor constraintEqualToAnchor:avatarContainer.leftAnchor] setActive:YES];
        [[self.avatarImage.rightAnchor constraintEqualToAnchor:avatarContainer.rightAnchor] setActive:YES];
        [[self.avatarImage.topAnchor constraintEqualToAnchor:avatarContainer.topAnchor] setActive:YES];
        [[self.avatarImage.bottomAnchor constraintEqualToAnchor:avatarContainer.bottomAnchor] setActive:YES];
        [[avatarContainer.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor constant:MVAvatarImageOffset] setActive:YES];
        [[avatarContainer.bottomAnchor constraintEqualToAnchor:self.bubbleImageView.bottomAnchor] setActive:YES];
    }
    
    if (self.direction == MessageDirectionOutgoing) {
        [[self.bubbleImageView.rightAnchor constraintEqualToAnchor:self.timeLabel.leftAnchor constant:-[self bubbleHorizontalOffset]] setActive:YES];
    } else {
        [[self.bubbleImageView.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor constant:[self bubbleHorizontalOffset]] setActive:YES];
    }
}

- (void)setupTapRecognizers {
    self.tapRecognizer = [UITapGestureRecognizer new];
    self.bubbleImageView.userInteractionEnabled = YES;
    [self.bubbleImageView addGestureRecognizer:self.tapRecognizer];
}

- (UIImageView *)buildBubbleImageView {
    UIImageView *bubbleImageView = [UIImageView new];
    bubbleImageView.image = [self bubbleImage];
    bubbleImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    return bubbleImageView;
}

- (UILabel *)buildTimeLabel {
    UILabel *timeLabel = [UILabel new];
    timeLabel.font = [UIFont systemFontOfSize:11];
    timeLabel.textColor = [UIColor darkGrayColor];
    timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    return timeLabel;
}

- (UIImageView *)buildAvatarImageView {
    UIImageView *avatarImageView = [UIImageView new];
    avatarImageView.layer.cornerRadius = 20;
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    avatarImageView.layer.borderWidth = 0.3f;
    avatarImageView.layer.borderColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.4].CGColor;
    
    return avatarImageView;
}

- (UIView *)buildAvatarImageViewContainer {
    UIView *container = [UIView new];
    container.translatesAutoresizingMaskIntoConstraints = NO;
    container.layer.cornerRadius = 20;
    
    return container;
}

- (UIImage *)bubbleImage {
    
    if (self.tailType == MVMessageCellTailTypeTailess || self.tailType == MVMessageCellTailTypeFirstTailess) {
        if (self.direction == MessageDirectionIncoming) {
            return incomingTaillessImage();
        } else {
            return outgoingTaillessImage();
        }
        
    } else if (self.direction == MessageDirectionOutgoing) {
        return outgoingImage();
    } else {
        return incomingImage();
    }
}

#pragma mark - Offsets
- (CGFloat)bubbleTopOffset {
    return [MVMessageCellModel bubbleTopOffsetForTailType:self.tailType];
}

- (CGFloat)bubbleBottomOffset {
    return [MVMessageCellModel bubbleBottomOffsetForTailType:self.tailType];
}

- (CGFloat)bubbleWidthMultiplier {
    return [MVMessageCellModel bubbleWidthMultiplierForDirection:self.direction];
}

- (CGFloat)bubbleHorizontalOffset {
    if (self.direction == MessageDirectionIncoming) {
        return MVAvatarImageSide + 2 * MVAvatarImageOffset;
    } else {
        return MVBubbleDefaultHorizontalOffset;
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
- (void)fillWithModel:(MVMessageCellModel *)model {
    self.model = model;
    self.timeLabel.text = model.sendDateString;
    
    self.bubbleWidthConstraint.constant = self.model.width;
    @weakify(self);
    [[[RACObserve(model, width) distinctUntilChanged] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *width) {
        @strongify(self);
        self.bubbleWidthConstraint.constant = width.floatValue;
    }];
    
    if (self.direction == MessageDirectionIncoming) {
        RAC(self.avatarImage, image) = [RACObserve(self.model, avatar) takeUntil:self.rac_prepareForReuseSignal];
    }
}
@end
