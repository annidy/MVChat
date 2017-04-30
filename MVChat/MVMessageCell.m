//
//  MVMessageCell.m
//  MVChat
//
//  Created by Mark Vasiv on 01/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVMessageCell.h"

@implementation MVMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)build {
    
    UIImageView *bubble = [UIImageView new];
    self.label = [UILabel new];
    self.label.numberOfLines = 0;
    [self.contentView addSubview:bubble];
    [self.contentView addSubview:self.label];
    
    bubble.translatesAutoresizingMaskIntoConstraints = NO;
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    [[bubble.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:5] setActive:YES];
    [[bubble.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-5] setActive:YES];
    [[bubble.leftAnchor constraintEqualToAnchor:self.label.leftAnchor constant:-10] setActive:YES];
    [[bubble.rightAnchor constraintEqualToAnchor:self.label.rightAnchor constant:15] setActive:YES];
    
    [[self.label.topAnchor constraintEqualToAnchor:bubble.topAnchor constant:5] setActive:YES];
    [[self.label.leftAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.leftAnchor constant:50] setActive:YES];
    [[self.label.rightAnchor constraintEqualToAnchor:self.contentView.rightAnchor constant:-25] setActive:YES];
    [[self.label.bottomAnchor constraintEqualToAnchor:bubble.bottomAnchor constant:-5] setActive:YES];
    
    
    UIImage *image = [UIImage imageNamed:@"bubble"];
    UIImage *resizedImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(15, 25, 25, 25) resizingMode:UIImageResizingModeStretch];
    resizedImage = [resizedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    bubble.image = resizedImage;
    
    [bubble setTintColor:[UIColor colorWithRed:0.5 green:0.8 blue:0.8 alpha:0.4]];
    
    
    
}
@end
