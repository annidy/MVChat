//
//  MVMessageCell.m
//  MVChat
//
//  Created by Mark Vasiv on 01/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVMessageCell.h"
#import "MVMessageModel.h"

@interface MVMessageCell ()
@property (strong, nonatomic) NSLayoutConstraint *timeLeftConstraint;
@property (assign, nonatomic) MessageDirection direction;
@end

static CGFloat innerMargin = 25;
static CGFloat verticalMargin = 7;
static CGFloat bubbleTailMargin = 15;
static CGFloat bubbleTailessMargin = 10;


@implementation MVMessageCell
#pragma mark - Lifecycle
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        if ([reuseIdentifier containsString:@"Incoming"]) {
            _direction = MessageDirectionIncoming;
        } else {
            _direction = MessageDirectionOutgoing;
        }
        
        [self build];
    }
    
    return self;
}

- (void)build {
    UIImageView *bubbleImageView = [UIImageView new];
    self.messageLabel = [UILabel new];
    self.timeLabel = [UILabel new];
    
    [self.contentView addSubview:bubbleImageView];
    [self.contentView addSubview:self.messageLabel];
    [self.contentView addSubview:self.timeLabel];
    
    self.messageLabel.numberOfLines = 0;
    self.timeLabel.font = [UIFont systemFontOfSize:12];
    
    UIImage *bubbleImage;
    UIColor *color;
    if (self.direction == MessageDirectionOutgoing) {
        color = [UIColor colorWithRed:0.5 green:0.8 blue:0.8 alpha:0.4];
        bubbleImage = [UIImage imageNamed:@"bubbleOutgoing"];
    } else {
        color = [UIColor colorWithRed:0.4 green:0.8 blue:0.9 alpha:0.4];
        bubbleImage = [UIImage imageNamed:@"bubbleIncoming"];
    }
    
    bubbleImage = [[bubbleImage resizableImageWithCapInsets:UIEdgeInsetsMake(15, 25, 25, 25) resizingMode:UIImageResizingModeStretch] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    bubbleImageView.image = bubbleImage;
    [bubbleImageView setTintColor:color];
    
    bubbleImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [[bubbleImageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:verticalMargin] setActive:YES];
    [[self.contentView.bottomAnchor constraintEqualToAnchor:bubbleImageView.bottomAnchor constant:verticalMargin] setActive:YES];
    [[self.messageLabel.topAnchor constraintEqualToAnchor:bubbleImageView.topAnchor constant:verticalMargin] setActive:YES];
    [[bubbleImageView.bottomAnchor constraintEqualToAnchor:self.messageLabel.bottomAnchor constant:verticalMargin] setActive:YES];
    [[self.timeLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:verticalMargin] setActive:YES];
    [[self.contentView.bottomAnchor constraintEqualToAnchor:self.timeLabel.bottomAnchor constant:verticalMargin] setActive:YES];
    
    [[bubbleImageView.widthAnchor constraintLessThanOrEqualToAnchor:self.contentView.widthAnchor multiplier:0.8] setActive:YES];
    [self.timeLeftConstraint = [self.timeLabel.leftAnchor constraintEqualToAnchor:self.contentView.rightAnchor] setActive:YES];
    
    if (self.direction == MessageDirectionOutgoing) {
        [[self.timeLabel.leftAnchor constraintLessThanOrEqualToAnchor:self.messageLabel.rightAnchor constant:innerMargin] setActive:YES];
        [[bubbleImageView.rightAnchor constraintEqualToAnchor:self.messageLabel.rightAnchor constant:bubbleTailMargin] setActive:YES];
        [[self.messageLabel.leftAnchor constraintEqualToAnchor:bubbleImageView.leftAnchor constant:bubbleTailessMargin] setActive:YES];
    } else {
        [[self.messageLabel.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor constant:innerMargin] setActive:YES];
        [[self.messageLabel.leftAnchor constraintEqualToAnchor:bubbleImageView.leftAnchor constant:bubbleTailMargin] setActive:YES];
        [[bubbleImageView.rightAnchor constraintEqualToAnchor:self.messageLabel.rightAnchor constant:bubbleTailessMargin] setActive:YES];
    }
}

#pragma mark - MVSlidingCell
- (void)setSlidingConstraint:(CGFloat)constant {
    self.timeLeftConstraint.constant = constant;
}

-(CGFloat)slidingConstraint {
    return self.timeLeftConstraint.constant;
}
@end
