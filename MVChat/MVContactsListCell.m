//
//  MVContactsListCell.m
//  MVChat
//
//  Created by Mark Vasiv on 25/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVContactsListCell.h"
#import "MVContactModel.h"
#import "MVContactManager.h"

@interface MVContactsListCell()
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@end

@implementation MVContactsListCell

- (void)fillWithContact:(MVContactModel *)contact {
    self.nameLabel.text = contact.name;
    self.avatarImageView.image = nil;
    [[MVContactManager sharedInstance] loadAvatarThumbnailForContact:contact completion:^(UIImage *image) {
        self.avatarImageView.image = image;
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.avatarImageView.layer.cornerRadius = 24;
    self.avatarImageView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
