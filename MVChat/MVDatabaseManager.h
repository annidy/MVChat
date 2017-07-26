//
//  MVDatabaseManager.h
//  MVChat
//
//  Created by Mark Vasiv on 30/06/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MVContactModel;
@class MVChatModel;
@class MVMessageModel;

@interface MVDatabaseManager : NSObject
+ (instancetype)sharedInstance;

- (NSString *)lastChatId;
- (NSString *)lastMessageId;
- (NSString *)incrementId:(NSString *)oldId;

- (void)allContacts:(void (^)(NSArray <MVContactModel *> *))completion;
- (void)allChats:(void (^)(NSArray <MVChatModel *> *))completion;

- (void)contactWithId:(NSString *)id completion:(void (^)(MVContactModel *))completion;
- (void)chatWithId:(NSString *)id completion:(void (^)(MVChatModel *))completion;
- (void)messageWithId:(NSString *)id completion:(void (^)(MVMessageModel *))completion;
- (void)messagesFromChatWithId:(NSString *)chatId completion:(void (^)(NSArray <MVMessageModel *> *))completion;

- (void)insertContacts:(NSArray <MVContactModel *> *)contacts withCompletion:(void (^)(BOOL success))completion;
- (void)insertChats:(NSArray <MVChatModel *> *)chats withCompletion:(void (^)(BOOL success))completion;
- (void)insertMessages:(NSArray <MVMessageModel *> *)messages withCompletion:(void (^)(BOOL success))completion;

- (void)updateChat:(MVChatModel *)chatModel withCompletion:(void (^)(BOOL success))completion;

- (MVContactModel *)myContact;
- (void)generateData;
- (void)generateImagesForChats:(NSArray <MVChatModel *> *)chats;
@end
