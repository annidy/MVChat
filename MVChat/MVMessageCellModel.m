//
//  MVChatCellViewModel.m
//  MVChat
//
//  Created by Mark Vasiv on 13/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVMessageCellModel.h"
#import "MVFileManager.h"

@interface MVMessageCellModel()
@property (strong, nonatomic) NSString *cellId;
@end

@implementation MVMessageCellModel
#pragma mark - Height calculation
- (void)calculateHeight {
    if (self.type == MVMessageCellModelTypeTextMessage || self.type == MVMessageCellModelTypeMediaMessage) {
        [self calculateComplexHeight];
    } else {
        [self calculateSimpleHeight];
    }
}

- (void)calculateSimpleHeight {
    CGFloat width = UIScreen.mainScreen.bounds.size.width - 2 * (MVPlainCellContainerHorizontalOffset + MVPlainCellContentHorizontalOffset);
    CGFloat height = 2 * (MVPlainCellContentVerticalOffset + MVPlainCellContainerVerticalOffset);
    height += [self plainHeightWithMaxWidth:width];
    self.height = height;
}

- (void)calculateComplexHeight {
    CGFloat width = UIScreen.mainScreen.bounds.size.width * [[self class] bubbleWidthMultiplierForDirection:self.direction];
    
    if (self.tailType == MVMessageCellTailTypeDefault || self.tailType == MVMessageCellTailTypeLastTailess) {
        width += MVBubbleTailSize;
    }
    
    width -= [[self class] contentOffsetForMessageType:self.type tailType:self.tailType tailSide:YES];
    width -= [[self class] contentOffsetForMessageType:self.type tailType:self.tailType tailSide:NO];
    
    CGFloat height = [[self class] bubbleTopOffsetForTailType:self.tailType] + [[self class] bubbleBottomOffsetForTailType:self.tailType];
    
    if (self.type == MVMessageCellModelTypeTextMessage) {
        height += 2 * MVTextContentVerticalOffset;
        height += [self textHeightWithMaxWidth:width];
    } else if (self.type == MVMessageCellModelTypeMediaMessage) {
        height += [self mediaHeightWithMaxWidth:width];
        height += 2 * MVMediaContentVerticalOffset;
    }
    
    self.height = height;
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

- (CGFloat)textHeightWithMaxWidth:(CGFloat)maxWidth {
    [self.referenceMessageLabel setText:self.text];
    return [self.referenceMessageLabel sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)].height;
}

- (CGFloat)mediaHeightWithMaxWidth:(CGFloat)maxWidth {
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
    
    return scaledSize.height;
}

- (CGFloat)plainHeightWithMaxWidth:(CGFloat)maxWidth {
    [self.referencePlainLabel setText:self.text];
    return [self.referencePlainLabel sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)].height;
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
