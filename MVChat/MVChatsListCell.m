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
#import "MVChatsListCellViewModel.h"
#import <ReactiveObjC.h>

static NSDateFormatter *defaultDateFormatter;
static NSDateFormatter *todayDateFormatter;

@interface MVChatsListCell ()
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UIButton *unreadCountButton;
@property (strong, nonatomic) MVChatModel *chatModel;
@end

@implementation MVChatsListCell
#pragma mark - Lifecycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.avatarImageView.layer.cornerRadius = 30;
    self.avatarImageView.layer.borderWidth = 0.3f;
    self.avatarImageView.layer.borderColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.4].CGColor;
    self.avatarImageView.layer.masksToBounds = YES;
    self.unreadCountButton.layer.cornerRadius = 9;
    self.unreadCountButton.layer.masksToBounds = YES;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.avatarImageView.image = nil;
}

#pragma mark - Fill with data
- (void)fillWithModel:(MVChatsListCellViewModel *)model {
    self.titleLabel.text = model.title;
    self.messageLabel.text = model.message;
    if (![model.updateDate isKindOfClass:[NSString class]]) {
        NSString *b;
    }
    self.dateLabel.text = model.updateDate;
    
    if (model.unreadCount) {
        [self.unreadCountButton setTitle:model.unreadCount forState:UIControlStateNormal];
        self.unreadCountButton.hidden = NO;
    } else {
        self.unreadCountButton.hidden = YES;
    }
    
    RAC(self.avatarImageView, image) = [[RACObserve(model, avatar) deliverOnMainThread] takeUntil:self.rac_prepareForReuseSignal];
    
    self.chatModel = model.chat;
}
@end
