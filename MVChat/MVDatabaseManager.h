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

typedef NS_ENUM(NSUInteger, MVMessageType);

@interface MVDatabaseManager : NSObject
+ (instancetype)sharedInstance;

- (void)allContacts:(void (^)(NSArray <MVContactModel *> *))completion;
- (void)allChats:(void (^)(NSArray <MVChatModel *> *))completion;
- (void)messagesFromChatWithId:(NSString *)chatId completion:(void (^)(NSArray <MVMessageModel *> *))completion;
- (void)messagesFromChatWithId:(NSString *)chatId withType:(MVMessageType)type completion:(void (^)(NSArray <MVMessageModel *> *))completion;

- (void)insertContacts:(NSArray <MVContactModel *> *)contacts withCompletion:(void (^)(BOOL success))completion;
- (void)insertChats:(NSArray <MVChatModel *> *)chats withCompletion:(void (^)(BOOL success))completion;
- (void)insertMessages:(NSArray <MVMessageModel *> *)messages withCompletion:(void (^)(BOOL success))completion;

- (void)deleteChat:(MVChatModel *)chatModel withCompletion:(void (^)(BOOL success))completion;

- (void)generateData;
- (void)deleteAllData;
@end
