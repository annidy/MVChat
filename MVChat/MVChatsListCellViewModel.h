//
//  MVChatsListCellViewModel.h
//  MVChat
//
//  Created by Mark Vasiv on 11/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MVChatModel;
@class UIImage;

@interface MVChatsListCellViewModel : NSObject
@property (strong, nonatomic) MVChatModel *chat;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *message;
@property (assign, nonatomic) NSString *unreadCount;
@property (assign, nonatomic) NSString *updateDate;
@property (strong, nonatomic) UIImage *avatar;
@end
