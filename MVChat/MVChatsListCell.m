//
//  MVChatsListCell.m
//  MVChat
//
//  Created by Mark Vasiv on 21/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVChatsListCell.h"
#import "MVChatModel.h"
#import "MVMessageModel.h"
#import "MVRandomGenerator.h"
#import "MVJsonHelper.h"

static NSDateFormatter *dateFormatter;

@interface MVChatsListCell ()
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;

@end

@implementation MVChatsListCell

- (NSDateFormatter *)dateFormatter {
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    }
    
    return dateFormatter;
}
- (void)fillWithChat:(MVChatModel *)chat {
    self.titleLabel.text = chat.title;
    self.messageLabel.text = chat.lastMessage.text;
    self.dateLabel.text = [self.dateFormatter stringFromDate:chat.lastUpdateDate];
    
    UIImage *avatar;
    if (chat.avatarName && chat.avatarName.length) {
        avatar = [UIImage imageNamed:chat.avatarName];
    }
    
    if (!avatar) {
        NSData *imgData = [MVJsonHelper dataFromFileWithName:[@"chat" stringByAppendingString:chat.id] extenssion:@"png"];
        avatar = [UIImage imageWithData:imgData];
    }

    self.avatarImageView.image = avatar;
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
