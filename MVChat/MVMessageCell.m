//
//  MVMessageCell.m
//  MVChat
//
//  Created by Mark Vasiv on 01/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVMessageCell.h"

@interface MVMessageCell ()

@end

@implementation MVMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self build];
    }
    
    return self;
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
    self.leftConstraint = [self.label.leftAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.leftAnchor constant:90];
    [self.leftConstraint setActive:YES];
    
    
    self.rightConstraint = [self.label.rightAnchor constraintEqualToAnchor:self.contentView.rightAnchor constant:-25];
    [self.rightConstraint setActive:YES];
    [[self.label.bottomAnchor constraintEqualToAnchor:bubble.bottomAnchor constant:-5] setActive:YES];
    
    
    
    UIImage *image = [UIImage imageNamed:@"bubble"];
    UIImage *resizedImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(15, 25, 25, 25) resizingMode:UIImageResizingModeStretch];
    resizedImage = [resizedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    bubble.image = resizedImage;
    
    [bubble setTintColor:[UIColor colorWithRed:0.5 green:0.8 blue:0.8 alpha:0.4]];
    
    UILabel *time = [UILabel new];
    [self.contentView addSubview:time];
    [[time.leftAnchor constraintEqualToAnchor:self.label.rightAnchor constant:25]setActive:YES];
    [[time.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:5] setActive:YES];
    [[time.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-5] setActive:YES];
    [time setText:@"12:23"];
    time.translatesAutoresizingMaskIntoConstraints = NO;
}
@end
