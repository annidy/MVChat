//
//  MVMessagePlainCell.m
//  MVChat
//
//  Created by Mark Vasiv on 06/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVMessagePlainCell.h"
#import "MVMessageCellProtocol.h"

@interface MVMessagePlainCell ()
@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation MVMessagePlainCell
#pragma mark - Lifecycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupViews];
    }
    
    return self;
}

#pragma mark - Setup Views
- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];
    UIView *container = [self buildContainer];
    self.container = container;
    [self.contentView addSubview:container];
    
    [[container.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:5] setActive:YES];
    [[container.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-5] setActive:YES];
    [[container.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor] setActive:YES];
    [[container.leftAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.leftAnchor constant:10] setActive:YES];
    [[self.contentView.rightAnchor constraintGreaterThanOrEqualToAnchor:container.rightAnchor constant:10] setActive:YES];
    
    UILabel *label = [self buildLabel];
    self.titleLabel = label;
    [container addSubview:label];
    [[label.leftAnchor constraintEqualToAnchor:container.leftAnchor constant:10] setActive:YES];
    [[label.rightAnchor constraintEqualToAnchor:container.rightAnchor constant:-10] setActive:YES];
    [[label.topAnchor constraintEqualToAnchor:container.topAnchor constant:3] setActive:YES];
    [[label.bottomAnchor constraintEqualToAnchor:container.bottomAnchor constant:-3] setActive:YES];
    
}

- (UIView *)buildContainer {
    UIView *container = [UIView new];
    container.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    container.layer.cornerRadius = 10;
    container.translatesAutoresizingMaskIntoConstraints = NO;
    
    return container;
}

- (UILabel *)buildLabel {
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:13];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    
    return label;
}

#pragma mark - MVMessageCell
+ (CGFloat)heightWithText:(NSString *)text {
    CGFloat height = 20;
    
    [self.referenceLabel setText:text];
    
    CGFloat maxLabelWidth = UIScreen.mainScreen.bounds.size.width - 26;
    height += [self.referenceLabel sizeThatFits:CGSizeMake(maxLabelWidth, CGFLOAT_MAX)].height;
    
    return height;
}

- (void)fillWithText:(NSString *)text {
    self.titleLabel.text = text;
}

#pragma mark - Helpers
static UILabel *referenceLabel;
+ (UILabel *)referenceLabel {
    if (!referenceLabel) {
        referenceLabel = [UILabel new];
        referenceLabel.font = [UIFont systemFontOfSize:13];
        referenceLabel.numberOfLines = 0;
    }
    
    return referenceLabel;
}
@end
