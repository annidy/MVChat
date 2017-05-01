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
@property (strong, nonatomic) NSLayoutConstraint *rightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *leftConstraint;
@property (strong, nonatomic) NSLayoutConstraint *timeLeftConstraint;
@property (assign, nonatomic) MessageDirection direction;
@end

@implementation MVMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

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
    UIImageView *bubble = [UIImageView new];
    self.label = [UILabel new];
    
    [self.contentView addSubview:bubble];
    [self.contentView addSubview:self.label];
    
    self.label.numberOfLines = 0;
    bubble.translatesAutoresizingMaskIntoConstraints = NO;
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    
    [[bubble.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:5] setActive:YES];
    [[bubble.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-5] setActive:YES];
    
    [[bubble.leftAnchor constraintEqualToAnchor:self.label.leftAnchor constant:-10] setActive:YES];
    [[bubble.rightAnchor constraintEqualToAnchor:self.label.rightAnchor constant:15] setActive:YES];
    
    [[self.label.topAnchor constraintEqualToAnchor:bubble.topAnchor constant:5] setActive:YES];
    
    if (self.direction == MessageDirectionOutgoing) {
        self.leftConstraint = [self.label.leftAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.leftAnchor constant:90];
        [self.leftConstraint setActive:YES];
        self.rightConstraint = [self.label.rightAnchor constraintEqualToAnchor:self.contentView.rightAnchor constant:-25];
        [self.rightConstraint setActive:YES];
        [[self.label.bottomAnchor constraintEqualToAnchor:bubble.bottomAnchor constant:-5] setActive:YES];
    } else {
        self.rightConstraint = [self.label.rightAnchor constraintLessThanOrEqualToAnchor:self.contentView.rightAnchor constant:-90];
        [self.rightConstraint setActive:YES];
        self.leftConstraint = [self.label.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor constant:25];
        [self.leftConstraint setActive:YES];
        [[self.label.bottomAnchor constraintEqualToAnchor:bubble.bottomAnchor constant:-5] setActive:YES];
    }
    
    
    UIImage *image;
    UIColor *color;
    if (self.direction == MessageDirectionOutgoing) {
        color = [UIColor colorWithRed:0.5 green:0.8 blue:0.8 alpha:0.4];
        image = [UIImage imageNamed:@"bubbleOutgoing"];
    } else {
        color = [UIColor colorWithRed:0.4 green:0.8 blue:0.9 alpha:0.4];
        image = [UIImage imageNamed:@"bubbleIncoming"];
    }
    
    UIImage *resizedImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(15, 25, 25, 25) resizingMode:UIImageResizingModeStretch];
    resizedImage = [resizedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    bubble.image = resizedImage;
    
    [bubble setTintColor:color];
    
    UILabel *time = [UILabel new];
    time.font = [UIFont systemFontOfSize:12];
    
    [self.contentView addSubview:time];
    self.timeLeftConstraint = [time.leftAnchor constraintEqualToAnchor:self.contentView.rightAnchor constant:0];
    [self.timeLeftConstraint setActive:YES];
    [[time.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:5] setActive:YES];
    [[time.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-5] setActive:YES];
    [time setText:@"12:23"];
    time.translatesAutoresizingMaskIntoConstraints = NO;
    if (self.direction == MessageDirectionOutgoing) {
        [[self.label.rightAnchor constraintLessThanOrEqualToAnchor:time.leftAnchor constant:-20] setActive:YES];
    }
}

- (void) prepareToSlide {
    if (self.direction == MessageDirectionOutgoing) {
        self.leftConstraint.active = NO;
        self.rightConstraint.active = NO;
        
    } else {
        
    }
    
}

- (void)setSlidingConstraint:(CGFloat)constant {
    self.timeLeftConstraint.constant = constant;
}

- (void)finishSliding {
    self.leftConstraint.active = YES;
    self.rightConstraint.active = YES;
}
-(CGFloat)slidingConstraint {
    return self.timeLeftConstraint.constant;
}
@end
