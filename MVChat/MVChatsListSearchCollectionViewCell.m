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
#import <ReactiveObjC.h>
#import "MVChatsListCellViewModel.h"

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
    self.avatarImageView.layer.borderWidth = 0.3f;
    self.avatarImageView.layer.borderColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.4].CGColor;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.avatarImageView.image = nil;
}

- (void)fillWithModel:(MVChatsListCellViewModel *)model {    
    self.titleLabel.text = model.title;
    RAC(self.avatarImageView, image) = [[RACObserve(model, avatar) deliverOnMainThread] takeUntil:self.rac_prepareForReuseSignal];
}

@end
