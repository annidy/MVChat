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
#import "MVRandomGenerator.h"

@implementation MVMessageUpdateModel
+ (instancetype)updateModelWithMessage:(MVMessageModel *)message andPosition:(MessageUpdatePosition)position {
    MVMessageUpdateModel *updateModel = [MVMessageUpdateModel new];
    updateModel.message = message;
    updateModel.position = position;
    
    return updateModel;
}
@end

@interface MVChatManager()
@property (strong, nonatomic) NSMutableArray *chats;
@property (strong, nonatomic) NSMutableDictionary *chatsMessages;
@property (strong, nonatomic) NSMutableDictionary *chatsMessagesPages;
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
        _chatsMessagesPages = [NSMutableDictionary new];
    }
    
    return self;
}

- (void)loadAllChats {
    [[MVDatabaseManager sharedInstance] allChats:^(NSArray<MVChatModel *> *chats) {
        NSMutableArray *mutableChats = [chats mutableCopy];
        [self sortChats:mutableChats];
        @synchronized (self.chats) {
            [self.chats addObjectsFromArray:mutableChats];
        }
        [self.chatsListener handleChatsUpdate];
    }];
}

- (void)loadMessagesForChatWithId:(NSString *)chatId withCallback:(void (^)(BOOL))callback {
    [[MVDatabaseManager sharedInstance] messagesFromChatWithId:chatId completion:^(NSArray<MVMessageModel *> *messages) {
        dispatch_async(self.managerQueue, ^{
            NSMutableArray *messagesCopy = [messages mutableCopy];
            [self sortMessages:messagesCopy];
            
            NSUInteger numberOfPages = messagesCopy.count/MVMessagesPageSize;
            if (messagesCopy.count%MVMessagesPageSize != 0) {
                numberOfPages++;
            }
            
            @synchronized (self.chatsMessages) {
                [self.chatsMessages setObject:[[messagesCopy reverseObjectEnumerator] allObjects] forKey:chatId];
                [self.chatsMessagesPages setObject:@(numberOfPages) forKey:chatId];
            }
            
            if (callback) {
                callback(YES);
            }
        });
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
        NSMutableArray *messagesCopy = [messages mutableCopy];
        NSString *chatId = messages[0].chatId;
        [self sortMessages:messagesCopy];
        
        @synchronized (self.chatsMessages) {
            if (![self.chatsMessages objectForKey:chatId]) {
                [self.chatsMessages setObject:[NSMutableArray new] forKey:chatId];
            }
            [[self.chatsMessages objectForKey:chatId] addObjectsFromArray:messagesCopy];
        }
    
        if ([self.messagesListener.chatId isEqualToString:chatId]) {
            for (MVMessageModel *message in messagesCopy) {
                [self.messagesListener handleNewMessage:[MVMessageUpdateModel updateModelWithMessage:message andPosition:MessageUpdatePositionEnd]];
            }
        }
        
        MVChatModel *chat = [self chatWithId:chatId];
        @synchronized (self.chats) {
            NSMutableArray *mutableChats = [self.chats mutableCopy];
            [mutableChats removeObject:chat];
            chat.lastUpdateDate = [messages lastObject].sendDate;
            chat.lastMessage = [messages lastObject];
            [mutableChats insertObject:chat atIndex:0];
            self.chats = [mutableChats mutableCopy];
        }
        
        [[MVDatabaseManager sharedInstance] updateChat:chat withCompletion:nil];
        [self.chatsListener handleChatsUpdate];
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

- (void)generateMessageForChatWithId:(NSString *)chatId {
    MVRandomGenerator *random = [MVRandomGenerator sharedInstance];
    
    MVChatModel *chat = [self chatWithId:chatId];
    MVMessageModel *message = [random randomIncomingMessageWithChat:chat];
    message.sendDate = [NSDate new];
    
    MVDatabaseManager *db = [MVDatabaseManager sharedInstance];
    message.id = [db incrementId:db.lastMessageId];
    [db insertMessages:@[message] withCompletion:nil];
    
    [self handleNewMessages:@[message]];
}

- (void)sendTextMessage:(NSString *)text toChatWithId:(NSString *)chatId{
    MVDatabaseManager *db = [MVDatabaseManager sharedInstance];
    
    MVMessageModel *message = [MVMessageModel new];
    message.id = [db incrementId:db.lastMessageId];
    message.chatId = chatId;
    message.text = text;
    message.direction = MessageDirectionOutgoing;
    message.sendDate = [NSDate new];
    message.contact = [db myContact];
    
    [db insertMessages:@[message] withCompletion:nil];
    
    [self handleNewMessages:@[message]];
}

- (void)chatWithContact:(MVContactModel *)contact andCompeltion:(void (^)(MVChatModel *))callback {
    dispatch_async(self.managerQueue, ^{
        MVChatModel *existingChat;
        
        @synchronized (self.chats) {
            for (MVChatModel *chat in self.chats) {
                if (chat.participants.count == 2) {
                    for (MVContactModel *participant in chat.participants) {
                        if ([participant.id isEqualToString:contact.id]) {
                            existingChat = chat;
                            break;
                        }
                    }
                }
                if (existingChat) {
                    break;
                }
            }
        }
        
        if (existingChat) {
            [self.chatsListener handleChatsUpdate];
            callback(existingChat);
        } else {
            [self createChatWithContacts:@[contact] title:contact.name andCompeltion:callback];
        }
    });
}

- (void)createChatWithContacts:(NSArray <MVContactModel *> *)contacts title:(NSString *)title andCompeltion:(void (^)(MVChatModel *))callback {
    dispatch_async(self.managerQueue, ^{
        MVDatabaseManager *db = [MVDatabaseManager sharedInstance];
        MVChatModel *chat = [[MVChatModel alloc] initWithId:[db incrementId:db.lastChatId] andTitle:title];
        chat.participants = [contacts arrayByAddingObject:db.myContact];
        chat.lastUpdateDate = [NSDate new];
        [db generateImagesForChats:@[chat]];
        
        @synchronized (self.chats) {
            [self.chats insertObject:chat atIndex:0];
        }
        
        @synchronized (self.chatsMessages) {
            [self.chatsMessages setObject:[NSMutableArray new] forKey:chat.id];
        }
        
        [db insertChats:@[chat] withCompletion:nil];
        [self.chatsListener handleChatsUpdate];
        callback(chat);
    });
}

- (void)updateChat:(MVChatModel *)chat {
    [self handleUpdatedChats:@[chat] removedChats:nil];
    [[MVDatabaseManager sharedInstance] updateChat:chat withCompletion:nil];
}

- (void)exitAndDeleteChat:(MVChatModel *)chat {
    [self handleUpdatedChats:nil removedChats:@[chat]];
    [[MVDatabaseManager sharedInstance] deleteChat:chat withCompletion:nil];
}

- (void)messagesPage:(NSUInteger)pageIndex forChatWithId:(NSString *)chatId withCallback:(void (^)(NSArray <MVMessageModel *> *))callback {
    NSMutableArray *messages;
    @synchronized (self.chatsMessages) {
        messages = [self.chatsMessages objectForKey:chatId];
    }
    
    messages = [[[messages reverseObjectEnumerator] allObjects] mutableCopy];
    NSArray *pagedMessages;
    
    if (!messages) {
        [self loadMessagesForChatWithId:chatId withCallback:^(BOOL success) {
            [self messagesPage:pageIndex forChatWithId:chatId withCallback:callback];
        }];
    } else {
        NSUInteger startIndex = MVMessagesPageSize * pageIndex;
        NSUInteger length = MVMessagesPageSize;
        
        if (MVMessagesPageSize * pageIndex + MVMessagesPageSize > messages.count) {
            length = messages.count - MVMessagesPageSize * pageIndex;
        }
        
        pagedMessages = [messages subarrayWithRange:NSMakeRange(startIndex, length)];
        callback(pagedMessages);
    }
}

- (NSUInteger)numberOfPagesInChatWithId:(NSString *)chatId {
    NSUInteger number = 0;
    @synchronized (self.chatsMessages) {
        if ([self.chatsMessagesPages objectForKey:chatId]) {
            number = [[self.chatsMessagesPages objectForKey:chatId] unsignedIntegerValue];
        }
    }
    
    return number;
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
        NSMutableArray *mutableChats = [self.chats mutableCopy];
        [self sortChats:mutableChats];
        self.chats = [mutableChats mutableCopy];
    }
}

- (void)sortChats:(NSMutableArray *)chats {
    [chats sortUsingComparator:^NSComparisonResult(MVChatModel *chat1, MVChatModel *chat2) {
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
