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
#import "MVFileManager.h"
#import <DBAttachment.h>
#import "NSString+Helpers.h"

@interface MVContactsListCell()
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *lastSeenLabel;
@end

@implementation MVContactsListCell

- (void)fillWithContact:(MVContactModel *)contact {
    self.nameLabel.text = contact.name;
    self.avatarImageView.image = nil;
    
    [[MVFileManager sharedInstance] loadAvatarAttachmentForContact:contact completion:^(DBAttachment *attachment) {
        [attachment thumbnailImageWithMaxWidth:50 completion:^(UIImage *image) {
            self.avatarImageView.image = image;
        }];
    }];
    
    self.lastSeenLabel.text = [NSString lastSeenTimeStringForDate:contact.lastSeenDate];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ContactLastSeenTimeUpdate" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSString *contactId = note.userInfo[@"Id"];
        if ([contactId isEqualToString:contact.id]) {
            NSDate *lastSeenDate = note.userInfo[@"LastSeenTime"];
            self.lastSeenLabel.text = [NSString lastSeenTimeStringForDate:lastSeenDate];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ContactAvatarUpdate" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSString *contactId = note.userInfo[@"Id"];
        UIImage *image = note.userInfo[@"Image"];
        if ([contact.id isEqualToString:contactId]) {
            self.avatarImageView.image = image;
        }
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
