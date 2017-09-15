//
//  MVMediaMessageCell.m
//  MVChat
//
//  Created by Mark Vasiv on 27/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVMessageMediaCell.h"
#import "MVMessageModel.h"

#import <ReactiveObjC.h>


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
    mediaImageView.layer.cornerRadius = 14;
    mediaImageView.layer.masksToBounds = YES;
    mediaImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    return mediaImageView;
}

#pragma mark - Offsets
- (CGFloat)contentLeftOffset {
    return [MVMessageCellModel contentOffsetForMessageType:MVMessageCellModelTypeMediaMessage
                                                  tailType:self.tailType
                                                  tailSide:(self.direction == MessageDirectionIncoming)];
}

- (CGFloat)contentRightOffset {
    return [MVMessageCellModel contentOffsetForMessageType:MVMessageCellModelTypeMediaMessage
                                                  tailType:self.tailType
                                                  tailSide:(self.direction == MessageDirectionOutgoing)];
}


#pragma mark - MVMessageCell protocol
- (void)fillWithModel:(MVMessageCellModel *)model {
    [super fillWithModel:model];
    RAC(self.mediaImageView, image) = [RACObserve(self.model, mediaImage) takeUntil:self.rac_prepareForReuseSignal];
}

@end
