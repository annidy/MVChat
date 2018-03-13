//
//  MVChatManager.h
//  MVChat
//
//  Created by Mark Vasiv on 01/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MVChatsListener.h"

@class MVMessageModel;
@class MVMessageUpdateModel;
@class MVChatModel;
@class MVContactModel;
@class UIImage;
@class DBAttachment;
@class RACScheduler;
@class RACSignal;

static NSUInteger MVMessagesPageSize = 10;

typedef enum : NSUInteger {
    ChatUpdateTypeReload,
    ChatUpdateTypeInsert,
    ChatUpdateTypeDelete,
    ChatUpdateTypeModify
} ChatUpdateType;

@interface MVChatUpdate : NSObject
@property (assign, nonatomic) ChatUpdateType updateType;
@property (strong, nonatomic) MVChatModel *chat;
@property (assign, nonatomic) BOOL sorting;
@property (assign, nonatomic) NSInteger index;
+ (instancetype)updateWithType:(ChatUpdateType)type chat:(MVChatModel *)chat sorting:(BOOL)sort index:(NSInteger)index;
@end

@interface MVChatManager : NSObject
#pragma mark - Listeners
@property (strong, nonatomic) RACSignal *chatUpdateSignal;
@property (strong, nonatomic) RACSignal *messageUpdateSignal;
@property (strong, nonatomic) RACSignal *messageReloadSignal;

@property (strong, nonatomic) RACScheduler *viewModelScheduler;
@property (strong, nonatomic) dispatch_queue_t viewModelQueue;

#pragma mark - Initialization
+ (instancetype) sharedInstance;

#pragma mark - Caching
- (void)loadAllChats;
- (void)loadMessagesForChatWithId:(NSString *)chatId withCallback:(void (^)())callback;

#pragma mark - Fetch
- (NSArray <MVChatModel *> *)chatsList;
- (void)messagesPage:(NSUInteger)pageIndex forChatWithId:(NSString *)chatId withCallback:(void (^)(NSArray <MVMessageModel *> *))callback;
- (NSUInteger)numberOfPagesInChatWithId:(NSString *)chatId;
- (void)mediaMessagesForChatWithId:(NSString *)chatId withCallback:(void (^)(NSArray <MVMessageModel *> *))callback;
- (RACSignal *)messagesPage:(NSInteger)pageIndex forChatWithId:(NSString *)chatId;

#pragma mark - Handle Chats
- (void)chatWithContact:(MVContactModel *)contact andCompeltion:(void (^)(MVChatModel *))callback;
- (void)createChatWithContacts:(NSArray <MVContactModel *> *)contacts title:(NSString *)title andCompletion:(void (^)(MVChatModel *))callback;
- (void)updateChat:(MVChatModel *)chat;
- (void)exitAndDeleteChat:(MVChatModel *)chat;
- (void)markChatAsRead:(NSString *)chatId;

#pragma mark - Send Messages
- (void)sendTextMessage:(NSString *)text toChatWithId:(NSString *)chatId;
- (void)sendMediaMessageWithAttachment:(DBAttachment *)attachment toChatWithId:(NSString *)chatId;

#pragma mark - Helpers
- (MVChatModel *)chatWithId:(NSString *)chatId;

#pragma mark - External events
- (void)handleNewChats:(NSArray <MVChatModel *> *)chats;
- (void)handleNewMessages:(NSArray <MVMessageModel *> *)messages;
- (void)clearAllCache;
@end
