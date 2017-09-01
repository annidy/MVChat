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
#import "MVChatManager.h"
#import "MVContactManager.h"
#import "MVFileManager.h"
#import <DBAttachment.h>

static NSDateFormatter *defaultDateFormatter;
static NSDateFormatter *todayDateFormatter;

@interface MVChatsListCell ()
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) MVChatModel *chatModel;

@end

@implementation MVChatsListCell

- (NSDateFormatter *)defaultDateFormatter {
    if (!defaultDateFormatter) {
        defaultDateFormatter = [NSDateFormatter new];
        [defaultDateFormatter setDateStyle:NSDateFormatterShortStyle];
        [defaultDateFormatter setDoesRelativeDateFormatting:YES];
    }
    
    return defaultDateFormatter;
}

- (NSDateFormatter *)todayDateFormatter {
    if (!todayDateFormatter) {
        todayDateFormatter = [NSDateFormatter new];
        [todayDateFormatter setDateStyle:NSDateFormatterNoStyle];
        [todayDateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [todayDateFormatter setDoesRelativeDateFormatting:YES];
    }
    
    return todayDateFormatter;
}

- (void)fillWithChat:(MVChatModel *)chat {
    if (chat.isPeerToPeer) {
        self.titleLabel.text = chat.getPeer.name;
    } else {
        self.titleLabel.text = chat.title;
    }
    
    self.messageLabel.text = chat.lastMessage.text;
    NSDateFormatter *formatter;
    if ([[NSCalendar currentCalendar] isDateInToday:chat.lastUpdateDate]) {
        formatter = self.todayDateFormatter;
    } else {
        formatter = self.defaultDateFormatter;
    }
    self.dateLabel.text = [formatter stringFromDate:chat.lastUpdateDate];

    self.avatarImageView.image = nil;
    
    if (chat.isPeerToPeer) {
        [[MVFileManager sharedInstance] loadAvatarAttachmentForContact:chat.getPeer completion:^(DBAttachment *attachment) {
            [attachment thumbnailImageWithMaxWidth:50 completion:^(UIImage *image) {
                self.avatarImageView.image = image;
            }];
        }];
    } else {
        [[MVChatManager sharedInstance] loadAvatarThumbnailForChat:chat completion:^(UIImage *image) {
            self.avatarImageView.image = image;
        }];
    }
    
    self.chatModel = chat;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.avatarImageView.layer.cornerRadius = 24;
    self.avatarImageView.layer.masksToBounds = YES;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ChatAvatarUpdate" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSString *chatId = note.userInfo[@"Id"];
        UIImage *image = note.userInfo[@"Image"];
        if (!self.chatModel.isPeerToPeer && [self.chatModel.id isEqualToString:chatId]) {
            self.avatarImageView.image = image;
        }
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ContactAvatarUpdate" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSString *contactId = note.userInfo[@"Id"];
        UIImage *image = note.userInfo[@"Image"];
        if (self.chatModel.isPeerToPeer && [self.chatModel.getPeer.id isEqualToString:contactId]) {
            self.avatarImageView.image = image;
        }
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
