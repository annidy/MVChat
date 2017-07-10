//
//  MVChatManager.m
//  MVChat
//
//  Created by Mark Vasiv on 01/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVChatManager.h"
#import "MVMessageModel.h"
#import "MVChatModel.h"
#import "MVDatabaseManager.h"

@interface MVChatManager()
@property (strong, nonatomic) NSMutableArray *chats;
@property (strong, nonatomic) NSMutableDictionary *chatsMessages;
@property (strong, nonatomic) dispatch_queue_t managerQueue;
@end

@implementation MVChatManager
#pragma mark - Lifecycle
static MVChatManager *sharedManager;
+(instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [MVChatManager new];
    });
    
    return sharedManager;
}

-(instancetype)init {
    if (self = [super init]) {
        _managerQueue = dispatch_queue_create("com.markvasiv.chatsManager", nil);
        _chats = [NSMutableArray new];
        _chatsMessages = [NSMutableDictionary new];
    }
    
    return self;
}

- (void)loadAllChats {
    [[MVDatabaseManager sharedInstance] allChats:^(NSArray<MVChatModel *> *chats) {
        @synchronized (self.chats) {
            [self.chats addObjectsFromArray:chats];
        }
        [self.chatsListener handleChatsUpdate];
    }];
}

- (void)loadMessagesForChatWithId:(NSString *)chatId {
    [[MVDatabaseManager sharedInstance] messagesFromChatWithId:chatId completion:^(NSArray<MVMessageModel *> *messages) {
        @synchronized (self.chatsMessages) {
            [self.chatsMessages setObject:messages forKey:chatId];
        }
        if ([self.messagesListener.chatId isEqualToString:chatId]) {
            //for (MVMessageModel *message in messages) {
                [self.messagesListener handleNewMessage:messages[0]];
            //}
        }
    }];
}

#pragma mark - Handle updates
- (void)handleUpdatedChats:(NSArray<MVChatModel *> *)updatedChats removedChats:(NSArray<MVChatModel *> *)removedChats {
    dispatch_async(self.managerQueue, ^{
        for (MVChatModel *chat in updatedChats) {
            [self addOrReplaceChat:chat];
        }
        for (MVChatModel *chat in removedChats) {
            [self removeChat:chat];
        }
        [self.chatsListener handleChatsUpdate];
    });
}

- (void)addOrReplaceChat:(MVChatModel *)chat {
    NSInteger index = [self indexOfChatWithId:chat.id];
    @synchronized (self.chats) {
        if (index == NSNotFound) {
            [self.chats addObject:chat];
        } else {
            [self.chats replaceObjectAtIndex:index withObject:chat];
        }
    }
}

- (void)removeChat:(MVChatModel *)chat {
    NSInteger index = [self indexOfChatWithId:chat.id];
    if (index != NSNotFound) {
        @synchronized (self.chats) {
            [self.chats removeObjectAtIndex:index];
        }
    }
}

- (void)handleNewMessages:(NSArray <MVMessageModel *> *)messages {
    dispatch_async(self.managerQueue, ^{
        NSMutableSet *changedChatIds = [NSMutableSet new];
        for (MVMessageModel *message in messages) {
            @synchronized (self.chatsMessages) {
                if (![self.chatsMessages objectForKey:message.chatId]) {
                    [self.chatsMessages setObject:[NSMutableArray new] forKey:message.chatId];
                }
                [[self.chatsMessages objectForKey:message.chatId] addObject:message];
            }
            [changedChatIds addObject:message.chatId];
            
            if ([self.messagesListener.chatId isEqualToString:message.chatId]) {
                [self.messagesListener handleNewMessage:message];
            }
        }
        
        [self sortMessagesInChatsWithIds:[changedChatIds allObjects]];
        [self sortChats];
        
    });
}

#pragma mark - Public interface
- (NSArray <MVMessageModel *> *)messagesForChatWithId:(NSString *)chatId {
    NSMutableArray *messages;
    @synchronized (self.chatsMessages) {
         messages = [self.chatsMessages objectForKey:chatId];
    }
    
    return [messages copy];
}

- (NSArray <MVChatModel *> *)chatsList {
    @synchronized (self.chats) {
        return [self.chats copy];
    }
}

- (void)sendMessage:(MVMessageModel *)message {
    
}

#pragma mark - Helpers
- (MVChatModel *)chatWithId:(NSString *)chatId {
    @synchronized (self.chats) {
        for (MVChatModel *chat in self.chats) {
            if ([chat.id isEqualToString:chatId]) {
                
                return chat;
            }
        }
    }
    
    return nil;
}

- (NSInteger)indexOfChatWithId:(NSString *)chatId {
    @synchronized (self.chats) {
        for (MVChatModel *chat in self.chats) {
            if ([chat.id isEqualToString:chatId]) {
                
                return [self.chats indexOfObject:chat];
            }
        }
    }
    
    return NSNotFound;
}

- (void)sortChats {
    @synchronized (self.chats) {
        [self.chats sortUsingComparator:^NSComparisonResult(MVChatModel *chat1, MVChatModel *chat2) {
            NSTimeInterval first = chat1.lastUpdateDate.timeIntervalSinceReferenceDate;
            NSTimeInterval second = chat2.lastUpdateDate.timeIntervalSinceReferenceDate;
            
            if (first > second) {
                return NSOrderedAscending;
            } else if (first < second) {
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }
        }];
    }
}

- (void)sortMessagesInChatsWithIds:(NSArray <NSString *> *)chatIds {
    for (NSString *chatId in chatIds) {
        @synchronized (self.chatsMessages) {
            [self sortMessages:[self.chatsMessages objectForKey:chatId]];
        }
    }
}

- (void)sortMessages:(NSMutableArray *)messages {
    [messages sortUsingComparator:^NSComparisonResult(MVMessageModel *mes1, MVMessageModel *mes2) {
        NSTimeInterval first = mes1.sendDate.timeIntervalSinceReferenceDate;
        NSTimeInterval second = mes2.sendDate.timeIntervalSinceReferenceDate;
        
        if (first > second) {
            return NSOrderedAscending;
        } else if (first < second) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
}

@end
