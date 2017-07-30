//
//  MVChatsListStackViewItem.m
//  MVChat
//
//  Created by Mark Vasiv on 28/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVChatsListSearchCollectionViewCell.h"
#import "MVChatModel.h"
#import "MVJsonHelper.h"

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

- (void)build {
    //self.translatesAutoresizingMaskIntoConstraints = NO;
    //[[self.heightAnchor constraintEqualToConstant:30] setActive:YES];
    //[[self.widthAnchor constraintEqualToConstant:40] setActive:YES];
    //self.backgroundColor = [UIColor redColor];
//    self.avatarImageView = [UIImageView new];
//    self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
//    [self addSubview:self.avatarImageView];
//    [[self.avatarImageView.widthAnchor constraintEqualToConstant:20] setActive:YES];
//    [[self.avatarImageView.heightAnchor constraintEqualToConstant:20] setActive:YES];
//    [[self.avatarImageView.topAnchor constraintEqualToAnchor:self.topAnchor constant:5] setActive:YES];
//    [[self.avatarImageView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:5] setActive:YES];
//    [[self.avatarImageView.rightAnchor constraintEqualToAnchor:self.leftAnchor constant:5] setActive:YES];
//    
//    self.titleLabel = [UILabel new];
//    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    [self addSubview:self.titleLabel];
//    [[self.titleLabel.topAnchor constraintEqualToAnchor:self.avatarImageView.bottomAnchor constant:10] setActive:YES];
//    [[self.titleLabel.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:5] setActive:YES];
//    [[self.titleLabel.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:5] setActive:YES];
//    [[self.titleLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:5] setActive:YES];
//    
//    self.avatarImageView.layer.cornerRadius = 10;
//    self.avatarImageView.layer.masksToBounds = YES;
}

- (void)fillWithChat:(MVChatModel *)chat {
    UIImage *avatar;
    if (chat.avatarName) {
        avatar = [UIImage imageNamed:chat.avatarName];
    }
    
    if (!avatar) {
        NSData *imgData = [MVJsonHelper dataFromFileWithName:[@"chat" stringByAppendingString:chat.id] extenssion:@"png"];
        avatar = [UIImage imageWithData:imgData];
    }
    
    self.avatarImageView.image = avatar;
    self.titleLabel.text = chat.title;
}

@end
