//
//  MVChatManager.m
//  MVChat
//
//  Created by Mark Vasiv on 01/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVChatManager.h"
#import "MVDatabaseManager.h"
#import "MVContactManager.h"
#import "MVFileManager.h"
#import "MVChatModel.h"
#import "MVMessageModel.h"
#import "MVRandomGenerator.h"
#import "NSString+Helpers.h"

@interface MVChatManager()
@property (strong, nonatomic) NSMutableArray *chats;
@property (strong, nonatomic) NSMutableDictionary *chatsMessages;
@property (strong, nonatomic) NSMutableDictionary *chatsMessagesPages;
@property (strong, nonatomic) dispatch_queue_t managerQueue;
@end

@implementation MVChatManager
#pragma mark - Initialization
static MVChatManager *sharedManager;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [MVChatManager new];
    });
    
    return sharedManager;
}

- (instancetype)init {
    if (self = [super init]) {
        _managerQueue = dispatch_queue_create("com.markvasiv.chatsManager", nil);
        _chats = [NSMutableArray new];
        _chatsMessages = [NSMutableDictionary new];
        _chatsMessagesPages = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark - Caching
- (void)loadAllChats {
    [[MVDatabaseManager sharedInstance] allChats:^(NSArray<MVChatModel *> *chats) {
        @synchronized (self.chats) {
            self.chats = [chats mutableCopy];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.chatsListener updateChats];
        });
    }];
}

- (void)loadMessagesForChatWithId:(NSString *)chatId withCallback:(void (^)())callback {
    dispatch_async(self.managerQueue, ^{
        @synchronized (self.chatsMessages) {
            if ([self.chatsMessages objectForKey:chatId]) {
                if (callback) callback();
                return;
            }
        }
        
        [[MVDatabaseManager sharedInstance] messagesFromChatWithId:chatId completion:^(NSArray<MVMessageModel *> *messages) {
            dispatch_async(self.managerQueue, ^{
                @synchronized (self.chatsMessages) {
                    [self.chatsMessages setObject:[messages mutableCopy] forKey:chatId];
                    [self.chatsMessagesPages setObject:@([self numberOfPages:messages]) forKey:chatId];
                }
                if (callback) callback();
            });
        }];
    });
}

#pragma mark - Fetch
- (NSArray <MVChatModel *> *)chatsList {
    @synchronized (self.chats) {
        return [self.chats copy];
    }
}

- (void)messagesPage:(NSUInteger)pageIndex forChatWithId:(NSString *)chatId withCallback:(void (^)(NSArray <MVMessageModel *> *))callback {
    dispatch_async(self.managerQueue, ^{
        NSMutableArray *messages;
        @synchronized (self.chatsMessages) {
            messages = [self.chatsMessages objectForKey:chatId];
        }
        
        NSArray *pagedMessages;
        
        if (!messages) {
            [self loadMessagesForChatWithId:chatId withCallback:^() {
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
    });
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

#pragma mark - Handle Updates
- (void)addChat:(MVChatModel *)chat {
    @synchronized (self) {
        [self.chats insertObject:chat atIndex:0];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.chatsListener insertNewChat:chat];
    });
}

- (void)replaceChat:(MVChatModel *)chat withSorting:(BOOL)sorting {
    NSInteger oldIndex = [self indexOfChatWithId:chat.id];
    NSInteger newIndex = NSNotFound;
    @synchronized (self.chats) {
        if (!sorting) {
            [self.chats replaceObjectAtIndex:oldIndex withObject:chat];
        } else {
            [self.chats removeObjectAtIndex:oldIndex];
            newIndex = [self.chats indexOfObject:chat inSortedRange:(NSRange){0, self.chats.count} options:NSBinarySearchingInsertionIndex usingComparator:MVChatModel.comparatorByLastUpdateDate];
            [self.chats insertObject:chat atIndex:newIndex];
        }
    };
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.chatsListener updateChat:chat withSorting:sorting newIndex:newIndex];
    });
}

- (void)removeChat:(MVChatModel *)chat {
    NSInteger index = [self indexOfChatWithId:chat.id];
    if (index != NSNotFound) {
        @synchronized (self.chats) {
            [self.chats removeObjectAtIndex:index];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.chatsListener removeChat:chat];
    });
}

- (void)addMessage:(MVMessageModel *)message {
    dispatch_async(self.managerQueue, ^{
        @synchronized (self.chatsMessages) {
            NSMutableArray *messages = [self.chatsMessages objectForKey:message.chatId];
            if (!messages) {
                messages = [NSMutableArray new];
                [self.chatsMessages setObject:messages forKey:message.chatId];
            }
            [messages insertObject:message atIndex:0];
            [self.chatsMessagesPages setObject:@([self numberOfPages:messages]) forKey:message.chatId];
        }
    
        if ([self.messagesListener.chatId isEqualToString:message.chatId]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.messagesListener insertNewMessage:message];
            });
        }
    });
}

- (void)updateMessage:(MVMessageModel *)message {
    dispatch_async(self.managerQueue, ^{
        NSUInteger index = [self indexOfMessage:message];
        if (index != NSNotFound) {
            @synchronized (self.chatsMessages) {
                [[self.chatsMessages objectForKey:message.chatId] replaceObjectAtIndex:index withObject:message];
            }
            if ([self.messagesListener.chatId isEqualToString:message.chatId]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.messagesListener updateMessage:message];
                });
            }
        }
    });
}

#pragma mark - Handle Chats
- (void)chatWithContact:(MVContactModel *)contact andCompeltion:(void (^)(MVChatModel *))callback {
    dispatch_async(self.managerQueue, ^{
        MVChatModel *existingChat = [self chatWithContact:contact];
        if (existingChat) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(existingChat);
            });
        } else {
            [self createChatWithContacts:@[contact] title:contact.name isPeerToPeer:YES andCompletion:callback];
        }
    });
}

- (void)createChatWithContacts:(NSArray <MVContactModel *> *)contacts title:(NSString *)title andCompletion:(void (^)(MVChatModel *))callback {
    [self createChatWithContacts:contacts title:title isPeerToPeer:NO andCompletion:callback];
}

- (void)createChatWithContacts:(NSArray <MVContactModel *> *)contacts title:(NSString *)title isPeerToPeer:(BOOL)peerToPeer andCompletion:(void (^)(MVChatModel *))callback {
    dispatch_async(self.managerQueue, ^{
        MVChatModel *chat = [[MVChatModel alloc] initWithId:[NSUUID UUID].UUIDString andTitle:title];
        chat.participants = [contacts arrayByAddingObject:MVContactManager.myContact];
        chat.lastUpdateDate = [NSDate new];
        chat.isPeerToPeer = peerToPeer;
        if (!peerToPeer) {
            [[MVFileManager sharedInstance] generateAvatarsForChats:@[chat]];
        }
        [self addChat:chat];
        @synchronized (self.chatsMessages) {
            [self.chatsMessages setObject:[NSMutableArray new] forKey:chat.id];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(chat);
        });
        
        [self sendSystemMessageWithText:[NSString stringWithFormat:@"%@ has created chat", MVContactManager.myContact.name] toChatWithId:chat.id];
        [[MVDatabaseManager sharedInstance] insertChats:@[chat] withCompletion:nil];
    });
}

- (void)updateChat:(MVChatModel *)chat {
    dispatch_async(self.managerQueue, ^{
        MVChatModel *oldChat = [self chatWithId:chat.id];
        [self replaceChat:chat withSorting:NO];
        [[MVDatabaseManager sharedInstance] insertChats:@[chat] withCompletion:nil];
        [self sendChatChangeMessagesForOldChat:oldChat newChat:chat];
    });
}


- (void)exitAndDeleteChat:(MVChatModel *)chat {
    dispatch_async(self.managerQueue, ^{
        [self removeChat:chat];
        [[MVDatabaseManager sharedInstance] deleteChat:chat withCompletion:nil];
    });
}

- (void)markChatAsRead:(NSString *)chatId {
    dispatch_async(self.managerQueue, ^{
        MVChatModel *existingChat = [self chatWithId:chatId];
        if (existingChat && existingChat.unreadCount != 0) {
            existingChat.unreadCount = 0;
            [self replaceChat:existingChat withSorting:NO];
            [[MVDatabaseManager sharedInstance] insertChats:@[existingChat] withCompletion:nil];
        }
        
        NSArray *messages;
        @synchronized (self.chatsMessages) {
            messages = [self.chatsMessages objectForKey:chatId];
        }
        
        for (MVMessageModel *message in messages) {
            if (!message.read) {
                MVMessageModel *messageCopy = [message copy];
                messageCopy.read = YES;
                [self updateMessage:messageCopy];
                [[MVDatabaseManager sharedInstance] insertMessages:@[messageCopy] withCompletion:nil];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.chatsListener updateChats];
        });
    });
}

#pragma mark - Send Messages
- (void)sendTextMessage:(NSString *)text toChatWithId:(NSString *)chatId{
    MVMessageModel *message = [[MVMessageModel alloc] initWithId:NSUUID.UUID.UUIDString chatId:chatId type:MVMessageTypeText text:text];
    [self sendMessage:message toChatWithId:chatId];
}

- (void)sendSystemMessageWithText:(NSString *)text toChatWithId:(NSString *)chatId {
    MVMessageModel *message = [[MVMessageModel alloc] initWithId:NSUUID.UUID.UUIDString chatId:chatId type:MVMessageTypeSystem text:text];
    [self sendMessage:message toChatWithId:chatId];
}

- (void)sendMediaMessageWithAttachment:(DBAttachment *)attachment toChatWithId:(NSString *)chatId {
    MVMessageModel *message = [[MVMessageModel alloc] initWithId:NSUUID.UUID.UUIDString chatId:chatId type:MVMessageTypeMedia text:nil];
    [[MVFileManager sharedInstance] saveMediaMesssage:message attachment:attachment completion:^{
        [self sendMessage:message toChatWithId:chatId];
    }];
}

- (void)sendMessage:(MVMessageModel *)message toChatWithId:(NSString *)chatId {
    dispatch_async(self.managerQueue, ^{
        message.contact = MVContactManager.myContact;
        message.direction = MessageDirectionOutgoing;
        message.chatId = chatId;
        message.sendDate = [NSDate new];
        [self addMessage:message];
        [[MVDatabaseManager sharedInstance] insertMessages:@[message] withCompletion:nil];
        
        MVChatModel *chat = [self chatWithId:chatId];
        chat.lastMessage = message;
        chat.lastUpdateDate = message.sendDate;
        [self updateChat:chat];
        [[MVDatabaseManager sharedInstance] insertChats:@[chat] withCompletion:nil];
    });
}

- (void)sendChatChangeMessagesForOldChat:(MVChatModel *)oldChat newChat:(MVChatModel *)chat {
    if (![chat.title isEqualToString:oldChat.title]) {
        NSString *messageText = [NSString titleChangeStringForContactName:MVContactManager.myContact.name andTitle:chat.title];
        [self sendSystemMessageWithText:messageText toChatWithId:chat.id];
    }
    
    
    NSString *removeContacts = [NSString removeContactsStringForName:MVContactManager.myContact.name
                                                         oldContacts:oldChat.participants
                                                         newContacts:chat.participants];
    
    NSString *addContacts = [NSString addContactsStringForName:MVContactManager.myContact.name
                                                         oldContacts:oldChat.participants
                                                         newContacts:chat.participants];
    
    if (removeContacts) {
        [self sendSystemMessageWithText:removeContacts toChatWithId:chat.id];
    }
    
    if (addContacts) {
        [self sendSystemMessageWithText:addContacts toChatWithId:chat.id];
    }
}

#pragma mark - Helpers
- (void)generateMessageForChatWithId:(NSString *)chatId {
    dispatch_async(self.managerQueue, ^{
        MVChatModel *chat = [self chatWithId:chatId];
        MVMessageModel *message = [[MVRandomGenerator sharedInstance] randomIncomingMessageWithChat:chat];
        message.sendDate = [NSDate new];
        message.id = [NSUUID UUID].UUIDString;
        [self addMessage:message];
        [[MVDatabaseManager sharedInstance] insertMessages:@[message] withCompletion:nil];
    
        chat.lastMessage = message;
        chat.lastUpdateDate = message.sendDate;
        chat.unreadCount += 1;
        [self replaceChat:chat withSorting:YES];
        [[MVDatabaseManager sharedInstance] insertChats:@[chat] withCompletion:nil];
    });
    
}

- (NSUInteger)numberOfPages:(NSArray *)messages {
    NSUInteger messagesCount = [messages count];
    NSUInteger numberOfPages = messagesCount/MVMessagesPageSize;
    if (messagesCount%MVMessagesPageSize != 0) {
        numberOfPages++;
    }
    
    return numberOfPages;
}

- (MVChatModel *)chatWithId:(NSString *)chatId {
    @synchronized (self.chats) {
        for (MVChatModel *chat in self.chats) {
            if ([chat.id isEqualToString:chatId]) {
                return [chat copy];
            }
        }
    }
    
    return nil;
}

- (MVChatModel *)chatWithContact:(MVContactModel *)contact {
    @synchronized (self.chats) {
        for (MVChatModel *chat in self.chats) {
            if (chat.isPeerToPeer && [chat.getPeer.id isEqualToString:contact.id]) {
                return [chat copy];
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

- (NSInteger)indexOfMessage:(MVMessageModel *)message {
    @synchronized (self.chatsMessages) {
        for (MVMessageModel *messageModel in [self.chatsMessages objectForKey:message.chatId]) {
            if ([message.id isEqualToString:messageModel.id]) {
                return [self.chats indexOfObject:messageModel];
            }
        }
    }
    
    return NSNotFound;
}
@end
