//
//  MVMediaMessageCell.m
//  MVChat
//
//  Created by Mark Vasiv on 27/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVMessageMediaCell.h"
#import "MVMessageModel.h"
#import "MVFileManager.h"

static CGFloat MVMediaContentVerticalOffset = 2;
static CGFloat MVMediaContentHorizontalOffset = 2;

@implementation MVMessageMediaCell
#pragma mark - Lifecycle
- (void)prepareForReuse {
    [super prepareForReuse];
    self.mediaImageView.image = nil;
}

#pragma mark - Build views
- (void)setupViews {
    [super setupViews];
    
    self.mediaImageView = [self buildMediaImageView];
    [self.contentView addSubview:self.mediaImageView];
    
    [[self.mediaImageView.topAnchor constraintEqualToAnchor:self.bubbleImageView.topAnchor constant:MVMediaContentVerticalOffset] setActive:YES];
    [[self.mediaImageView.bottomAnchor constraintEqualToAnchor:self.bubbleImageView.bottomAnchor constant:-MVMediaContentVerticalOffset] setActive:YES];
    [[self.mediaImageView.leftAnchor constraintEqualToAnchor:self.bubbleImageView.leftAnchor constant:[self contentLeftOffset]] setActive:YES];
    [[self.mediaImageView.rightAnchor constraintEqualToAnchor:self.bubbleImageView.rightAnchor constant:-[self contentRightOffset]] setActive:YES];
}

- (UIImageView *)buildMediaImageView {
    UIImageView *mediaImageView = [UIImageView new];
    mediaImageView.translatesAutoresizingMaskIntoConstraints = NO;
    mediaImageView.layer.cornerRadius = 8;
    mediaImageView.layer.masksToBounds = YES;
    mediaImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    return mediaImageView;
}

#pragma mark - Offsets
- (CGFloat)contentLeftOffset {
    return [[self class] contentOffsetForTailType:self.tailType tailSide:(self.direction == MessageDirectionIncoming)];
}

- (CGFloat)contentRightOffset {
    return [[self class] contentOffsetForTailType:self.tailType tailSide:(self.direction == MessageDirectionOutgoing)];
}

+ (CGFloat)contentOffsetForTailType:(MVMessageCellTailType)tailType tailSide:(BOOL)tailSide {
    CGFloat offset = MVMediaContentHorizontalOffset;
    if (tailSide && (tailType == MVMessageCellTailTypeDefault || tailType == MVMessageCellTailTypeLastTailess)) {
        offset += MVBubbleTailSize;
    }
    
    return offset;
}

#pragma mark - MVMessageCell protocol
+ (CGFloat)heightWithTailType:(MVMessageCellTailType)tailType direction:(MessageDirection)direction andModel:(MVMessageModel *)model {
    CGFloat height = [super heightWithTailType:tailType direction:direction andModel:model] + 2 * MVMediaContentVerticalOffset;
    CGFloat maxContentWidth = [super maxContentWidthWithDirection:direction] - [self contentOffsetForTailType:tailType tailSide:YES] - [self contentOffsetForTailType:tailType tailSide:NO];
    
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
    [super fillWithModel:messageModel];
    CGFloat maxContentWidth = [[super class] maxContentWidthWithDirection:messageModel.direction] - MVMediaContentHorizontalOffset * 2 - MVBubbleTailSize;
    [[MVFileManager sharedInstance] loadThumbnailAttachmentForMessage:messageModel maxWidth:maxContentWidth completion:^(UIImage *image) {
        self.mediaImageView.image = image;
    }];
}

@end
