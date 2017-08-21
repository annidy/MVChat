//
//  MVSystemMessageCell.m
//  MVChat
//
//  Created by Mark Vasiv on 21/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVSystemMessageCell.h"

@implementation MVSystemMessageCell

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
    
    [[container.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:5] setActive:YES];
    [[container.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-5] setActive:YES];
    [[container.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor] setActive:YES];
    
    [[container.leftAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.leftAnchor constant:10] setActive:YES];
    [[self.contentView.rightAnchor constraintGreaterThanOrEqualToAnchor:container.rightAnchor constant:10] setActive:YES];
    
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:12];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:label];
    [[label.leftAnchor constraintEqualToAnchor:container.leftAnchor constant:10] setActive:YES];
    [[label.rightAnchor constraintEqualToAnchor:container.rightAnchor constant:-10] setActive:YES];
    [[label.topAnchor constraintEqualToAnchor:container.topAnchor constant:5] setActive:YES];
    [[label.bottomAnchor constraintEqualToAnchor:container.bottomAnchor constant:-5] setActive:YES];
    
    self.titleLabel = label;
    
}

@end
