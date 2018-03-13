//
//  MVMessagePlainCell.m
//  MVChat
//
//  Created by Mark Vasiv on 06/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVMessagePlainCell.h"
#import "MVMessageCellModel.h"

@interface MVMessagePlainCell ()
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIView *container;
@property (strong, nonatomic) MVMessageCellModel *model;
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
    
    [[container.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:MVPlainCellContainerVerticalOffset] setActive:YES];
    [[container.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-MVPlainCellContainerVerticalOffset] setActive:YES];
    [[container.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor] setActive:YES];
    [[container.leftAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.leftAnchor constant:MVPlainCellContainerHorizontalOffset] setActive:YES];
    [[self.contentView.rightAnchor constraintGreaterThanOrEqualToAnchor:container.rightAnchor constant:MVPlainCellContainerHorizontalOffset] setActive:YES];
    
    UILabel *label = [self buildLabel];
    self.titleLabel = label;
    [container addSubview:label];
    [[label.leftAnchor constraintEqualToAnchor:container.leftAnchor constant:MVPlainCellContentHorizontalOffset] setActive:YES];
    [[label.rightAnchor constraintEqualToAnchor:container.rightAnchor constant:-MVPlainCellContentHorizontalOffset] setActive:YES];
    [[label.topAnchor constraintEqualToAnchor:container.topAnchor constant:MVPlainCellContentVerticalOffset] setActive:YES];
    [[label.bottomAnchor constraintEqualToAnchor:container.bottomAnchor constant:-MVPlainCellContentVerticalOffset] setActive:YES];
    
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

#pragma mark - Message cell protocol
- (void)fillWithModel:(MVMessageCellModel *)model {
    self.model = model;
    self.titleLabel.text = model.text;
}

- (UITapGestureRecognizer *)tapRecognizer {
    return nil;
}
@end
