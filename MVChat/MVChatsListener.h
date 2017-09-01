//
//  MVChatsListener.h
//  MVChat
//
//  Created by Mark Vasiv on 01/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MVChatModel;
@class MVMessageModel;

@protocol MVMessagesUpdatesListener <NSObject>
- (void)insertNewMessage:(MVMessageModel *)message;
- (NSString *)chatId;
@end

@protocol MVChatsUpdatesListener <NSObject>
- (void)updateChats;
- (void)insertNewChat:(MVChatModel *)chat;
@end
