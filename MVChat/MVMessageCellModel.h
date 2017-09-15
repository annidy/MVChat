//
//  MVChatCellViewModel.h
//  MVChat
//
//  Created by Mark Vasiv on 13/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MVMessageModel;

typedef enum : NSUInteger {
    MVMessageCellModelTypeHeader,
    MVMessageCellModelTypeSystemMessage,
    MVMessageCellModelTypeTextMessage,
    MVMessageCellModelTypeMediaMessage
} MVMessageCellModelType;

typedef enum : NSUInteger {
    MVMessageCellTailTypeDefault,
    MVMessageCellTailTypeTailess,
    MVMessageCellTailTypeFirstTailess,
    MVMessageCellTailTypeLastTailess
} MVMessageCellTailType;

typedef enum : NSUInteger {
  MVMessageCellModelDirectionIncoming,
    MVMessageCellModelDirectionOutgoing
} MVMessageCellModelDirection;


static CGFloat MVBubbleWidthMultiplierOutgoing = 0.8;
static CGFloat MVBubbleWidthMultiplierIncoming = 0.7;
static CGFloat MVBubbleVerticalOffsetDefault = 3;
static CGFloat MVBubbleVerticalOffsetTailess = 0.5f;
static CGFloat MVAvatarImageSide = 40;
static CGFloat MVAvatarImageOffset = 5;
static CGFloat MVBubbleDefaultHorizontalOffset = 10;
static CGFloat MVBubbleMinSize = 45;
static CGFloat MVBubbleTailSize = 5;
static CGFloat MVTextContentVerticalOffset = 6;
static CGFloat MVTextContentHorizontalOffset = 9;
static CGFloat MVMediaContentVerticalOffset = 2;
static CGFloat MVMediaContentHorizontalOffset = 2;
static CGFloat MVPlainCellContainerVerticalOffset = 5;
static CGFloat MVPlainCellContainerHorizontalOffset = 10;
static CGFloat MVPlainCellContentHorizontalOffset = 10;
static CGFloat MVPlainCellContentVerticalOffset = 3;


@interface MVMessageCellModel : NSObject
@property (assign, nonatomic) MVMessageCellModelType type;
@property (assign, nonatomic) MVMessageCellTailType tailType;
@property (assign, nonatomic) MVMessageCellModelDirection direction;
@property (strong, nonatomic) MVMessageModel *message;
@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) CGFloat width;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *sendDateString;
@property (strong, nonatomic) UIImage *avatar;
@property (strong, nonatomic) UIImage *mediaImage;
- (void)calculateSize;
- (NSString *)cellId;

+ (CGFloat)bubbleWidthMultiplierForDirection:(MVMessageCellModelDirection)direction;
+ (CGFloat)bubbleBottomOffsetForTailType:(MVMessageCellTailType)tailType;
+ (CGFloat)bubbleTopOffsetForTailType:(MVMessageCellTailType)tailType;
+ (CGFloat)contentOffsetForMessageType:(MVMessageCellModelType)type tailType:(MVMessageCellTailType)tailType tailSide:(BOOL)tailSide;
+ (MVMessageCellModelDirection)directionForReuseIdentifier:(NSString *)reuseId;
+ (MVMessageCellTailType)tailTypeForReuseIdentifier:(NSString *)reuseId;
@end
