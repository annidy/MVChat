//
//  MVChatManager.h
//  MVChat
//
//  Created by Mark Vasiv on 01/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MVMessageModel;
@class MVMessageUpdateModel;
@class MVChatModel;

typedef enum : NSUInteger {
    MessageUpdatePositionStart,
    MessageUpdatePositionEnd
} MessageUpdatePosition;

static NSUInteger MVMessagesPageSize = 1000;

@protocol MessagesUpdatesListener <NSObject>
- (void)handleNewMessage:(MVMessageUpdateModel *)messageUpdate;
- (NSString *)chatId;
@end

@protocol ChatsUpdatesListener <NSObject>
- (void)handleChatsUpdate;
@end

@interface MVMessageUpdateModel : NSObject
@property (strong, nonatomic) MVMessageModel *message;
@property (assign, nonatomic) MessageUpdatePosition position;
+ (instancetype)updateModelWithMessage:(MVMessageModel *)message andPosition:(MessageUpdatePosition)position;
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
- (void)sendTextMessage:(NSString *)text toChatWithId:(NSString *)chatId;
- (void)loadAllChats;
- (void)loadMessagesForChatWithId:(NSString *)chatId;
- (void)messagesPage:(NSUInteger)pageIndex forChatWithId:(NSString *)chatId withCallback:(void (^)(NSArray <MVMessageModel *> *))callback;
- (NSUInteger)numberOfPagesInChatWithId:(NSString *)chatId;
@end
