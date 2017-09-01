//
//  MVChatsListStackViewItem.m
//  MVChat
//
//  Created by Mark Vasiv on 28/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVChatsListSearchCollectionViewCell.h"
#import "MVChatModel.h"
#import "MVChatManager.h"
#import "MVFileManager.h"
#import <DBAttachment.h>

@interface MVChatsListSearchCollectionViewCell ()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;

@end

@implementation MVChatsListSearchCollectionViewCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.avatarImageView.layer.cornerRadius = 27;
    self.avatarImageView.layer.masksToBounds = YES;
}

- (void)fillWithChat:(MVChatModel *)chat {
    self.avatarImageView.image = nil;
    
    if (chat.isPeerToPeer) {
        [[MVFileManager sharedInstance] loadAvatarAttachmentForContact:chat.getPeer completion:^(DBAttachment *attachment) {
            [attachment thumbnailImageWithMaxWidth:50 completion:^(UIImage *resultImage) {
                self.avatarImageView.image = resultImage;
            }];
        }];
    } else {
        [[MVFileManager sharedInstance] loadAvatarAttachmentForChat:chat completion:^(DBAttachment *attachment) {
            [attachment thumbnailImageWithMaxWidth:50 completion:^(UIImage *resultImage) {
                self.avatarImageView.image = resultImage;
            }];
        }];
    }
    
    
    self.titleLabel.text = chat.title;
}

@end
