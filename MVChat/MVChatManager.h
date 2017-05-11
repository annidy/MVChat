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

@interface MVChatManager : NSObject
+ (instancetype) sharedInstance;
//From outside
- (void)handleUpdatedChats:(NSArray<MVChatModel *> *)updatedChats removedChats:(NSArray<MVChatModel *> *)removedChats;
- (void)handleNewMessages:(NSArray <MVMessageModel *> *)messages;
//From inside
@property (weak, nonatomic) id <MessagesUpdatesListener> messagesListener;
- (NSArray <MVChatModel *> *)chatsList;
- (NSArray <MVMessageModel *> *)messagesForChatWithId:(NSString *)chatId;
- (void)sendMessage:(MVMessageModel *)message;

@end
