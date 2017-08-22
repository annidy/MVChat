//
//  MVMessageHeader.m
//  MVChat
//
//  Created by Mark Vasiv on 02/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVMessageHeader.h"

@implementation MVMessageHeader
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self build];
    }
    
    return self;
}

- (void) build {
    self.contentView.backgroundColor = [UIColor whiteColor];
    UIView *container = [UIView new];
    container.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    container.layer.cornerRadius = 10;
    container.layer.masksToBounds = YES;
    container.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:container];

    [[container.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:2] setActive:YES];
    [[container.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-2] setActive:YES];
    [[container.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor] setActive:YES];
    
    UILabel *label = [UILabel new];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:12];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:label];
    [[label.leftAnchor constraintEqualToAnchor:container.leftAnchor constant:10] setActive:YES];
    [[label.rightAnchor constraintEqualToAnchor:container.rightAnchor constant:-10] setActive:YES];
    [[label.topAnchor constraintEqualToAnchor:container.topAnchor constant:5] setActive:YES];
    [[label.bottomAnchor constraintEqualToAnchor:container.bottomAnchor constant:-5] setActive:YES];
    
    self.titleLabel = label;
    
}

#pragma mark - MVMessageCell
+ (CGFloat)heightWithTailType:(MVMessageCellTailType)tailType direction:(MessageDirection)direction andText:(NSString *)text {
    return [self heightWithText:text];
}

+ (CGFloat)heightWithText:(NSString *)text {
    CGFloat height = 14;
    
    [self.referenceLabel setText:text];
    
    CGFloat maxLabelWidth = UIScreen.mainScreen.bounds.size.width - 20;
    height += [self.referenceLabel sizeThatFits:CGSizeMake(maxLabelWidth, CGFLOAT_MAX)].height;
    
    return height;
}

#pragma mark - Helpers
static UILabel *referenceLabel;
+ (UILabel *)referenceLabel {
    if (!referenceLabel) {
        referenceLabel = [UILabel new];
        referenceLabel.font = [UIFont systemFontOfSize:12];
        referenceLabel.numberOfLines = 0;
    }
    
    return referenceLabel;
}
@end
