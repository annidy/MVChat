//
//  MVChatsListStackViewItem.h
//  MVChat
//
//  Created by Mark Vasiv on 28/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MVChatModel;

@interface MVChatsListSearchCollectionViewCell : UICollectionViewCell
- (void)build;
- (void)fillWithChat:(MVChatModel *)chat;
@end
