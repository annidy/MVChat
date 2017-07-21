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

static NSDateFormatter *dateFormatter;

@interface MVChatsListCell ()
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UIView *avatarBackgroundView;
@property (strong, nonatomic) IBOutlet UILabel *avatarInitialsLabel;

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
    
    if (avatar) {
        self.avatarImageView.image = avatar;
        [self setAvatarImageVisible:YES];
    } else {
        self.avatarInitialsLabel.text = [[chat.title substringToIndex:1] uppercaseString];
        
        BOOL hadGradient = NO;
        CAGradientLayer *gradient;
        if ([self.avatarBackgroundView.layer.sublayers[0] isKindOfClass:[CAGradientLayer class]]) {
            hadGradient = YES;
            gradient = (CAGradientLayer *)self.avatarBackgroundView.layer.sublayers[0];
        } else {
            gradient = [CAGradientLayer layer];
            gradient.frame = self.avatarBackgroundView.bounds;
        }
        
        gradient.colors = @[(id)[[MVRandomGenerator sharedInstance] randomColor].CGColor, (id)[[MVRandomGenerator sharedInstance] randomColor].CGColor];
        
        if (!hadGradient) {
            [self.avatarBackgroundView.layer insertSublayer:gradient atIndex:0];
        }
        
        [self setAvatarImageVisible:NO];
    }
    
}

- (void)setAvatarImageVisible:(BOOL)visible {
    self.avatarImageView.alpha = visible;
    self.avatarBackgroundView.alpha = !visible;
    self.avatarInitialsLabel.alpha = !visible;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.avatarBackgroundView.layer.cornerRadius = 24;
    self.avatarBackgroundView.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 24;
    self.avatarImageView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
