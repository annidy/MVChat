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
#import "MVMessageCellProtocol.h"

static CGFloat MVBubbleWidthMultiplierOutgoing = 0.8;
static CGFloat MVBubbleWidthMultiplierIncoming = 0.7;
static CGFloat MVBubbleVerticalOffsetDefault = 7;
static CGFloat MVBubbleVerticalOffsetTailess = 2;
static CGFloat MVAvatarImageSide = 40;
static CGFloat MVAvatarImageOffset = 5;
static CGFloat MVBubbleDefaultHorizontalOffset = 10;
static CGFloat MVBubbleMinSize = 36;
static CGFloat MVBubbleMinTailessSize = 30;

@interface MVMessageBubbleCell()
@property (strong, nonatomic) NSLayoutConstraint *timeLeftConstraint;
@property (strong, nonatomic) UIImageView *avatarImage;
@end

@implementation MVMessageBubbleCell
#pragma mark - Lifecycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _direction = [[self class] directionForReuseIdentifier:reuseIdentifier];
        _tailType = [[self class] tailTypeForReuseIdentifier:reuseIdentifier];
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Build views
- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];
    self.bubbleImageView = [self buildBubbleImageView];
    self.timeLabel = [self buildTimeLabel];
    
    [self.contentView addSubview:self.bubbleImageView];
    [self.contentView addSubview:self.timeLabel];
    
    [[self.bubbleImageView.widthAnchor constraintLessThanOrEqualToAnchor:self.contentView.widthAnchor multiplier:[self bubbleWidthMultiplier]] setActive:YES];
    CGFloat minBubbleWidth = (self.tailType == MVMessageCellTailTypeTailess || self.tailType == MVMessageCellTailTypeFirstTailess)? MVBubbleMinTailessSize : MVBubbleMinSize;
    [[self.bubbleImageView.widthAnchor constraintGreaterThanOrEqualToConstant:minBubbleWidth] setActive:YES];
    
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
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleTapped:)];
    self.bubbleImageView.userInteractionEnabled = YES;
    [self.bubbleImageView addGestureRecognizer:tapRecognizer];
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
    timeLabel.textColor = [UIColor darkTextColor];
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
    UIImage *bubbleImage;
    UIEdgeInsets insets;
    if (self.tailType == MVMessageCellTailTypeTailess || self.tailType == MVMessageCellTailTypeFirstTailess) {
        if (self.direction == MessageDirectionIncoming) {
            bubbleImage = [UIImage imageNamed:@"bubbleNewIncomingTailess"];
        } else {
            bubbleImage = [UIImage imageNamed:@"bubbleNewOutgoingTailess"];
        }
        
        insets = UIEdgeInsetsMake(6, 6, 6, 6);
    } else if (self.direction == MessageDirectionOutgoing) {
        bubbleImage = [UIImage imageNamed:@"bubbleNewOutgoing"];
        insets = UIEdgeInsetsMake(6, 6, 6, 11);
    } else {
        bubbleImage = [UIImage imageNamed:@"bubbleNewIncoming"];
        insets = UIEdgeInsetsMake(6, 11, 6, 6);
    }
    CGFloat scale = [UIScreen mainScreen].scale;
    insets.top *= scale;
    insets.left *= scale;
    insets.right *= scale;
    insets.bottom *= scale;
    
    bubbleImage = [[bubbleImage resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    return bubbleImage;
}

#pragma mark - Offsets
- (CGFloat)bubbleTopOffset {
    return [[self class] bubbleTopOffsetForTailType:self.tailType];
}

+ (CGFloat)bubbleTopOffsetForTailType:(MVMessageCellTailType)tailType {
    if (tailType == MVMessageCellTailTypeTailess || tailType == MVMessageCellTailTypeLastTailess) {
        return MVBubbleVerticalOffsetTailess;
    } else {
        return MVBubbleVerticalOffsetDefault;
    }
}

- (CGFloat)bubbleBottomOffset {
    return [[self class] bubbleBottomOffsetForTailType:self.tailType];
}

+ (CGFloat)bubbleBottomOffsetForTailType:(MVMessageCellTailType)tailType {
    if (tailType == MVMessageCellTailTypeTailess || tailType == MVMessageCellTailTypeFirstTailess) {
        return MVBubbleVerticalOffsetTailess;
    } else {
        return MVBubbleVerticalOffsetDefault;
    }
}

- (CGFloat)bubbleWidthMultiplier {
    return [[self class] bubbleWidthMultiplierForDirection:self.direction];
}

+ (CGFloat)bubbleWidthMultiplierForDirection:(MessageDirection)direction {
    if (direction == MessageDirectionOutgoing) {
        return MVBubbleWidthMultiplierOutgoing;
    } else {
        return MVBubbleWidthMultiplierIncoming;
    }
}

- (CGFloat)bubbleHorizontalOffset {
    CGFloat margin = 0;
    if (self.direction == MessageDirectionIncoming) {
        margin = MVAvatarImageSide + 2 * MVAvatarImageOffset;
    } else {
        margin = MVBubbleDefaultHorizontalOffset;
    }
    
    if (self.tailType == MVMessageCellTailTypeDefault || self.tailType == MVMessageCellTailTypeLastTailess) {
        margin -= MVBubbleTailSize;
    }
    
    return margin;
}

#pragma mark - Helpers
+ (MessageDirection)directionForReuseIdentifier:(NSString *)reuseId {
    if ([reuseId containsString:@"Outgoing"]) {
        return MessageDirectionOutgoing;
    } else {
        return MessageDirectionIncoming;
    }
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

+ (CGFloat)maxContentWidthWithDirection:(MessageDirection)direction {
    return UIScreen.mainScreen.bounds.size.width * [self bubbleWidthMultiplierForDirection:direction];
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
    return [self bubbleTopOffsetForTailType:tailType] + [self bubbleBottomOffsetForTailType:tailType];
}

- (void)fillWithModel:(MVMessageModel *)messageModel {
    self.timeLabel.text = [NSString messageTimeFromDate:messageModel.sendDate];
    if (self.direction == MessageDirectionIncoming) {
        [[MVFileManager sharedInstance] loadThumbnailAvatarForContact:messageModel.contact maxWidth:50 completion:^(UIImage *image) {
            self.avatarImage.image = image;
        }];
    }
    
    __weak typeof(self) weakCell = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ContactAvatarUpdate" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSString *avatarId = note.userInfo[@"Id"];
        if ([avatarId isEqualToString:messageModel.contact.id]) {
            [[MVFileManager sharedInstance] loadThumbnailAvatarForContact:messageModel.contact maxWidth:50 completion:^(UIImage *image) {
                weakCell.avatarImage.image = image;
            }];
        }
    }];
}

- (void)bubbleTapped:(UITapGestureRecognizer *)recognizer {
    [self.delegate cellTapped:self];
}
@end
