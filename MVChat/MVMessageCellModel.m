//
//  MVChatCellViewModel.m
//  MVChat
//
//  Created by Mark Vasiv on 13/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVMessageCellModel.h"
#import "MVFileManager.h"
#import <AVFoundation/AVFoundation.h>

@interface MVMessageCellModel()
@property (strong, nonatomic) NSString *cellId;
@end

@implementation MVMessageCellModel
#pragma mark - Height calculation
- (void)calculateSize {
    CGSize size;
    if (self.type == MVMessageCellModelTypeTextMessage || self.type == MVMessageCellModelTypeMediaMessage) {
        size = [self calculateBubbleSize];
    } else {
        size = [self calculatePlainSize];
    }
    
    self.width = size.width;
    self.height = size.height;
}

- (CGSize)calculatePlainSize {
    CGFloat maxWidth = UIScreen.mainScreen.bounds.size.width - 2 * (MVPlainCellContainerHorizontalOffset + MVPlainCellContentHorizontalOffset);
    
    CGFloat contentVerticalOffset = 2 * (MVPlainCellContentVerticalOffset + MVPlainCellContainerVerticalOffset);
    CGSize contentSize = [self plainHeightWithMaxWidth:maxWidth];
    
    CGFloat height = contentSize.height + contentVerticalOffset;
    CGFloat width = contentSize.width + 2 * MVPlainCellContentHorizontalOffset;
    
    return CGSizeMake(width, height);
}

- (CGSize)calculateBubbleSize {
    CGFloat bubbleHeight = [[self class] bubbleTopOffsetForTailType:self.tailType] + [[self class] bubbleBottomOffsetForTailType:self.tailType];
    CGFloat maxBubbleWidth = UIScreen.mainScreen.bounds.size.width * [[self class] bubbleWidthMultiplierForDirection:self.direction];
    if (self.tailType == MVMessageCellTailTypeDefault || self.tailType == MVMessageCellTailTypeLastTailess) maxBubbleWidth += MVBubbleTailSize;
    
    CGFloat contentHorizontalOffset = [[self class] contentOffsetForMessageType:self.type tailType:self.tailType tailSide:YES] + [[self class] contentOffsetForMessageType:self.type tailType:self.tailType tailSide:NO];
    CGFloat maxContentWidth = maxBubbleWidth - contentHorizontalOffset;
    
    CGFloat contentVerticalOffset = 0;
    CGSize contentSize;
    if (self.type == MVMessageCellModelTypeTextMessage) {
        contentSize = [self textHeightWithMaxWidth:maxContentWidth];
        contentVerticalOffset += 2 * MVTextContentVerticalOffset;
    } else if (self.type == MVMessageCellModelTypeMediaMessage) {
        contentSize = [self mediaHeightWithMaxWidth:maxContentWidth];
        contentVerticalOffset += 2 * MVMediaContentVerticalOffset;
    }
    
    CGFloat width = contentSize.width + contentHorizontalOffset;
    CGFloat minWidth = [[self class] minBubbleWidthWithTailType:self.tailType];
    if (width < minWidth) width = minWidth;

    CGFloat height = contentSize.height + contentVerticalOffset + bubbleHeight;
    
    return CGSizeMake(width, height);
}

+ (CGFloat)minBubbleWidthWithTailType:(MVMessageCellTailType)tailType {
    if (tailType == MVMessageCellTailTypeDefault || tailType == MVMessageCellTailTypeLastTailess) {
        return MVBubbleMinSize;
    } else {
        return MVBubbleMinTailessSize;
    }
}

static UILabel *referenceMessageLabel;
- (UILabel *)referenceMessageLabel {
    if (!referenceMessageLabel) {
        referenceMessageLabel = [UILabel new];
        referenceMessageLabel.font = [UIFont systemFontOfSize:17];
        referenceMessageLabel.numberOfLines = 0;
    }
    
    return referenceMessageLabel;
}

- (CGSize)textHeightWithMaxWidth:(CGFloat)maxWidth {
    [self.referenceMessageLabel setText:self.text];
    return [self.referenceMessageLabel sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];
}

- (CGSize)mediaHeightWithMaxWidth:(CGFloat)maxWidth {
    CGFloat maxHeight = 200;
    CGSize actualSize = [[MVFileManager sharedInstance] sizeOfAttachmentForMessage:self.message];
    CGSize scaledSize;
    if (maxWidth > actualSize.width) {
        scaledSize.width = actualSize.width;
        scaledSize.height = actualSize.height;
    } else {
        CGFloat scale = maxWidth/actualSize.width;
        scaledSize.width = maxWidth;
        scaledSize.height = actualSize.height * scale;
    }
    
    return  AVMakeRectWithAspectRatioInsideRect(actualSize, CGRectMake(0, 0, maxWidth, maxHeight)).size;
    
    
    //return scaledSize.height;
}

- (CGSize)plainHeightWithMaxWidth:(CGFloat)maxWidth {
    [self.referencePlainLabel setText:self.text];
    return [self.referencePlainLabel sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];
}

static UILabel *referencePlainLabel;
- (UILabel *)referencePlainLabel {
    if (!referencePlainLabel) {
        referencePlainLabel = [UILabel new];
        referencePlainLabel.font = [UIFont systemFontOfSize:13];
        referencePlainLabel.numberOfLines = 0;
    }
    
    return referencePlainLabel;
}

#pragma mark - Cell helpers
+ (CGFloat)bubbleTopOffsetForTailType:(MVMessageCellTailType)tailType {
    if (tailType == MVMessageCellTailTypeTailess || tailType == MVMessageCellTailTypeLastTailess) {
        return MVBubbleVerticalOffsetTailess;
    } else {
        return MVBubbleVerticalOffsetDefault;
    }
}

+ (CGFloat)bubbleBottomOffsetForTailType:(MVMessageCellTailType)tailType {
    if (tailType == MVMessageCellTailTypeTailess || tailType == MVMessageCellTailTypeFirstTailess) {
        return MVBubbleVerticalOffsetTailess;
    } else {
        return MVBubbleVerticalOffsetDefault;
    }
}

+ (CGFloat)bubbleWidthMultiplierForDirection:(MVMessageCellModelDirection)direction {
    CGFloat defaultMultiplier;
    if (direction == MVMessageCellModelDirectionOutgoing) {
        defaultMultiplier = MVBubbleWidthMultiplierOutgoing;
    } else {
        defaultMultiplier = MVBubbleWidthMultiplierIncoming;
    }
    
    return defaultMultiplier;
}

+ (CGFloat)contentOffsetForMessageType:(MVMessageCellModelType)type tailType:(MVMessageCellTailType)tailType tailSide:(BOOL)tailSide {
    CGFloat defaultOffset = 0;
    if (type == MVMessageCellModelTypeTextMessage) {
        defaultOffset = MVTextContentHorizontalOffset;
    } else if (type == MVMessageCellModelTypeMediaMessage) {
        defaultOffset = MVMediaContentHorizontalOffset;
    }
    
    if (tailSide && (tailType == MVMessageCellTailTypeDefault || tailType == MVMessageCellTailTypeLastTailess)) {
        defaultOffset += MVBubbleTailSize;
    }
    
    return defaultOffset;
}

+ (MVMessageCellModelDirection)directionForReuseIdentifier:(NSString *)reuseId {
    if ([reuseId containsString:@"Outgoing"]) {
        return MVMessageCellModelDirectionOutgoing;
    } else {
        return MVMessageCellModelDirectionIncoming;
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

#pragma mark - Helpers
- (NSString *)cellId {
    if (!_cellId) {
        NSMutableString *cellId = [NSMutableString stringWithString:@"MVMessage"];
        
        switch (self.type) {
            case MVMessageCellModelTypeHeader:
            case MVMessageCellModelTypeSystemMessage:
                [cellId appendString:@"Plain"];
                break;
            case MVMessageCellModelTypeTextMessage:
                [cellId appendString:@"Text"];
                break;
            case MVMessageCellModelTypeMediaMessage:
                [cellId appendString:@"Media"];
                break;
        }
        
        if (self.type == MVMessageCellModelTypeTextMessage || self.type == MVMessageCellModelTypeMediaMessage) {
            [cellId appendString:@"TailType"];
            switch (self.tailType) {
                case MVMessageCellTailTypeDefault:
                    [cellId appendString:@"Default"];
                    break;
                case MVMessageCellTailTypeTailess:
                    [cellId appendString:@"Tailess"];
                    break;
                case MVMessageCellTailTypeLastTailess:
                    [cellId appendString:@"LastTailess"];
                    break;
                case MVMessageCellTailTypeFirstTailess:
                    [cellId appendString:@"FirstTailess"];
                    break;
            }
            
            switch (self.direction) {
                case MVMessageCellModelDirectionOutgoing:
                    [cellId appendString:@"Outgoing"];
                    break;
                case MVMessageCellModelDirectionIncoming:
                    [cellId appendString:@"Incoming"];
                    break;
                    
            }
        }
        
        [cellId appendString:@"Cell"];
        
        _cellId = [cellId copy];
    }
    
    return _cellId;
}

@end
