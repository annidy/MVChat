//
//  MVContactsListCell.m
//  MVChat
//
//  Created by Mark Vasiv on 25/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVContactsListCell.h"
#import "MVContactsListCellViewModel.h"
#import <ReactiveObjC.h>

@interface MVContactsListCell()
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *lastSeenLabel;
@end

@implementation MVContactsListCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.avatarImageView.image = nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.avatarImageView.layer.cornerRadius = 24;
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.borderWidth = 0.3f;
    self.avatarImageView.layer.borderColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.4].CGColor;
}

- (void)fillWithModel:(MVContactsListCellViewModel *)model {
    self.nameLabel.text = model.name;
    RAC(self.avatarImageView, image) = [[RACObserve(model, avatar) deliverOnMainThread] takeUntil:self.rac_prepareForReuseSignal];
    RAC(self.lastSeenLabel, text) = [[RACObserve(model, lastSeenTime) deliverOnMainThread] takeUntil:self.rac_prepareForReuseSignal];
}
@end
