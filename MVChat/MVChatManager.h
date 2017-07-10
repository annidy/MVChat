//
//  MVChatManager.h
//  MVChat
//
//  Created by Mark Vasiv on 01/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MVMessageModel;
@class MVChatModel;

@protocol MessagesUpdatesListener <NSObject>
- (void)handleNewMessage:(MVMessageModel *)message;
- (NSString *)chatId;
@end

@protocol ChatsUpdatesListener <NSObject>
- (void)handleChatsUpdate;
@end

@interface MVChatManager : NSObject
@property (weak, nonatomic) id <MessagesUpdatesListener> messagesListener;
@property (weak, nonatomic) id <ChatsUpdatesListener> chatsListener;
+ (instancetype) sharedInstance;

- (void)handleUpdatedChats:(NSArray<MVChatModel *> *)updatedChats removedChats:(NSArray<MVChatModel *> *)removedChats;
- (void)handleNewMessages:(NSArray <MVMessageModel *> *)messages;
- (NSArray <MVChatModel *> *)chatsList;
- (MVChatModel *)chatWithId:(NSString *)chatId;
- (NSArray <MVMessageModel *> *)messagesForChatWithId:(NSString *)chatId;
- (void)sendMessage:(MVMessageModel *)message;

- (void)loadAllChats;
- (void)loadMessagesForChatWithId:(NSString *)chatId;
@end
