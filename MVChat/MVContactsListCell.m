//
//  MVContactsListCell.m
//  MVChat
//
//  Created by Mark Vasiv on 25/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVContactsListCell.h"
#import "MVContactModel.h"
#import "MVJsonHelper.h"

@interface MVContactsListCell()
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@end

@implementation MVContactsListCell

- (void)fillWithContact:(MVContactModel *)contact {
    self.nameLabel.text = contact.name;
    
    UIImage *avatar;
    if (contact.avatarName) {
        avatar = [UIImage imageNamed:contact.avatarName];
    }
    
    if (!avatar) {
        NSData *imgData = [MVJsonHelper dataFromFileWithName:[@"contact" stringByAppendingString:contact.id] extenssion:@"png"];
        avatar = [UIImage imageWithData:imgData];
    }
    
    self.avatarImageView.image = avatar;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.avatarImageView.layer.cornerRadius = 24;
    self.avatarImageView.layer.masksToBounds = YES;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
