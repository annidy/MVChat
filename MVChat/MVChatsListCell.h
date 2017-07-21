//
//  MVChatsListCell.h
//  MVChat
//
//  Created by Mark Vasiv on 21/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MVChatModel;

@interface MVChatsListCell : UITableViewCell
- (void)fillWithChat:(MVChatModel *)chat;
@end
