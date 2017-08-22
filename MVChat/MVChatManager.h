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
@class MVContactModel;
@class UIImage;

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
- (void)generateMessageForChatWithId:(NSString *)chatId;
- (void)sendTextMessage:(NSString *)text toChatWithId:(NSString *)chatId;
- (void)loadAllChats;
- (void)messagesPage:(NSUInteger)pageIndex forChatWithId:(NSString *)chatId withCallback:(void (^)(NSArray <MVMessageModel *> *))callback;
- (NSUInteger)numberOfPagesInChatWithId:(NSString *)chatId;
- (void)chatWithContact:(MVContactModel *)contact andCompeltion:(void (^)(MVChatModel *))callback;
- (void)createChatWithContacts:(NSArray <MVContactModel *> *)contacts title:(NSString *)title andCompeltion:(void (^)(MVChatModel *))callback;
- (void)updateChat:(MVChatModel *)chat;
- (void)exitAndDeleteChat:(MVChatModel *)chat;
- (void)loadAvatarThumbnailForChat:(MVChatModel *)chat completion:(void (^)(UIImage *))callback;

- (NSString *)timeFromDate:(NSDate *)date;
@end
