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

static NSUInteger MVMessagesPageSize = 15;

@interface MVChatManager : NSObject
#pragma mark - Listeners
@property (weak, nonatomic) id <MVMessagesUpdatesListener> messagesListener;
@property (weak, nonatomic) id <MVChatsUpdatesListener> chatsListener;

#pragma mark - Initialization
+ (instancetype) sharedInstance;

#pragma mark - Caching
- (void)loadAllChats;
- (void)loadMessagesForChatWithId:(NSString *)chatId withCallback:(void (^)())callback;

#pragma mark - Fetch
- (NSArray <MVChatModel *> *)chatsList;
- (void)messagesPage:(NSUInteger)pageIndex forChatWithId:(NSString *)chatId withCallback:(void (^)(NSArray <MVMessageModel *> *))callback;
- (NSUInteger)numberOfPagesInChatWithId:(NSString *)chatId;

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
- (void)generateMessageForChatWithId:(NSString *)chatId;
@end
