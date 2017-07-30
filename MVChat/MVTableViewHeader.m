//
//  MVTableViewHeader.m
//  MVChat
//
//  Created by Mark Vasiv on 30/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVTableViewHeader.h"

@implementation MVTableViewHeader

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self build];
    }
    
    return self;
}

- (void)build {
    self.contentView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.05];
    UILabel *titleLabel = [UILabel new];
    [titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.contentView addSubview:titleLabel];
    [[titleLabel.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor constant:10] setActive:YES];
    [[titleLabel.rightAnchor constraintEqualToAnchor:self.contentView.rightAnchor constant:10] setActive:YES];
    [[titleLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor] setActive:YES];
    
    self.titleLabel = titleLabel;
    self.titleLabel.textColor = [UIColor darkGrayColor];
    self.titleLabel.font= [UIFont systemFontOfSize:12];
}

@end
