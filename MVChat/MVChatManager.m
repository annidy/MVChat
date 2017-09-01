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
#import "MVFileManager.h"
#import <DBAttachment.h>

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
        @synchronized (self.chats) {
            [self.chats addObjectsFromArray:chats];
        }
        [self.chatsListener handleChatsUpdate];
    }];
}

- (void)loadMessagesForChatWithId:(NSString *)chatId withCallback:(void (^)(BOOL))callback {
    dispatch_async(self.managerQueue, ^{
        @synchronized (self.chatsMessages) {
            if ([self.chatsMessages objectForKey:chatId]) {
                if (callback) {
                    callback(YES);
                }
                return;
            }
        }
        
        [[MVDatabaseManager sharedInstance] messagesFromChatWithId:chatId completion:^(NSArray<MVMessageModel *> *messages) {
            dispatch_async(self.managerQueue, ^{
                NSUInteger numberOfPages = messages.count/MVMessagesPageSize;
                if (messages.count%MVMessagesPageSize != 0) {
                    numberOfPages++;
                }
                
                @synchronized (self.chatsMessages) {
                    [self.chatsMessages setObject:[[messages reverseObjectEnumerator] allObjects] forKey:chatId];
                    [self.chatsMessagesPages setObject:@(numberOfPages) forKey:chatId];
                }
                
                if (callback) {
                    callback(YES);
                }
            });
        }];
    });
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
        
        [self sortChats];
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
            NSUInteger messagesCount = [[self.chatsMessages objectForKey:chatId] count];
            NSUInteger numberOfPages = messagesCount/MVMessagesPageSize;
            if (messagesCopy.count%MVMessagesPageSize != 0) {
                numberOfPages++;
            }
            [self.chatsMessagesPages setObject:@(numberOfPages) forKey:chatId];
        }
    
        if ([self.messagesListener.chatId isEqualToString:chatId]) {
            for (MVMessageModel *message in messagesCopy) {
                [self.messagesListener handleNewMessage:[MVMessageUpdateModel updateModelWithMessage:message andPosition:MessageUpdatePositionEnd]];
            }
        }
        
        MVChatModel *chat = [self chatWithId:chatId];
        chat.lastUpdateDate = [messages lastObject].sendDate;
        chat.lastMessage = [messages lastObject];
        [self handleUpdatedChats:@[chat] removedChats:nil];
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
//    MVRandomGenerator *random = [MVRandomGenerator sharedInstance];
//    
//    MVChatModel *chat = [self chatWithId:chatId];
//    MVMessageModel *message = [random randomIncomingMessageWithChat:chat];
//    message.sendDate = [NSDate new];
//    
//    MVDatabaseManager *db = [MVDatabaseManager sharedInstance];
//    message.id = [db incrementId:db.lastMessageId];
//    [db insertMessages:@[message] withCompletion:nil];
//    
//    [self handleNewMessages:@[message]];
}

- (void)sendTextMessage:(NSString *)text toChatWithId:(NSString *)chatId{
    MVMessageModel *message = [MVMessageModel new];
    message.type = MVMessageTypeText;
    message.text = text;
    [self sendMessage:message toChatWithId:chatId];
}

- (void)sendSystemMessageWithText:(NSString *)text toChatWithId:(NSString *)chatId {
    MVMessageModel *message = [MVMessageModel new];
    message.type = MVMessageTypeSystem;
    message.text = text;
    [self sendMessage:message toChatWithId:chatId];
}

- (void)sendMediaMessageWithAttachment:(DBAttachment *)attachment toChatWithId:(NSString *)chatId {
//    MVMessageModel *message = [MVMessageModel new];
//    message.type = MVMessageTypeMedia;
//    message.id = [[MVDatabaseManager sharedInstance] incrementId:[MVDatabaseManager sharedInstance].lastMessageId];
//    message.chatId = chatId;
//    [[MVFileManager sharedInstance] saveAttachment:attachment asMessage:message completion:^{
//        [self sendMessage:message toChatWithId:chatId];
//    }];
}

- (void)sendMessage:(MVMessageModel *)message toChatWithId:(NSString *)chatId {
    MVDatabaseManager *db = [MVDatabaseManager sharedInstance];
    if (!message.id) {
        message.id = [NSUUID UUID].UUIDString;
    }
    message.contact = [db myContact];
    message.direction = MessageDirectionOutgoing;
    message.chatId = chatId;
    message.sendDate = [NSDate new];
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
//    dispatch_async(self.managerQueue, ^{
//        MVDatabaseManager *db = [MVDatabaseManager sharedInstance];
//        MVChatModel *chat = [[MVChatModel alloc] initWithId:[db incrementId:db.lastChatId] andTitle:title];
//        chat.participants = [contacts arrayByAddingObject:db.myContact];
//        chat.lastUpdateDate = [NSDate new];
//        [[MVFileManager sharedInstance] generateImagesForChats:@[chat]];
//        
//        @synchronized (self.chats) {
//            [self.chats insertObject:chat atIndex:0];
//        }
//        
//        @synchronized (self.chatsMessages) {
//            [self.chatsMessages setObject:[NSMutableArray new] forKey:chat.id];
//        }
//        
//        [db insertChats:@[chat] withCompletion:nil];
//        [self.chatsListener handleChatsUpdate];
//        callback(chat);
//        
//        [self sendSystemMessageWithText:[NSString stringWithFormat:@"%@ has created chat", db.myContact.name] toChatWithId:chat.id];
//    });
}

- (void)updateChat:(MVChatModel *)chat {
    MVChatModel *oldChat = [self chatWithId:chat.id];
    [self handleUpdatedChats:@[chat] removedChats:nil];
    [[MVDatabaseManager sharedInstance] insertChats:@[chat] withCompletion:nil];
    
    if (![chat.title isEqualToString:oldChat.title]) {
        NSString *messageText = [NSString stringWithFormat:@"%@ changed title to %@", [MVDatabaseManager sharedInstance].myContact.name, chat.title];
        [self sendSystemMessageWithText:messageText toChatWithId:chat.id];
    }
    
    NSMutableArray *addContacts = [NSMutableArray new];
    for (MVContactModel *contact in chat.participants) {
        BOOL found = NO;
        for (MVContactModel *oldContact in oldChat.participants) {
            if ([contact.id isEqualToString:oldContact.id]) {
                found = YES;
                break;
            }
        }
        if (!found) {
            [addContacts addObject:contact];
        }
    }
    NSMutableArray *removedContacts = [NSMutableArray new];
    for (MVContactModel *oldContact in oldChat.participants) {
        BOOL found = NO;
        for (MVContactModel *contact in chat.participants) {
            if ([contact.id isEqualToString:oldContact.id]) {
                found = YES;
                break;
            }
        }
        if (!found) {
            [removedContacts addObject:oldContact];
        }
    }
    
    if (removedContacts.count) {
        NSMutableString *messageText = [NSMutableString new];
        [messageText appendString:[MVDatabaseManager sharedInstance].myContact.name];
        [messageText appendString:@" "];
        if (removedContacts.count == 1) {
            [messageText appendString:@"removed contact: "];
        } else {
            [messageText appendString:@"removed contacts: "];
        }
        for (MVContactModel *removedContact in removedContacts) {
            [messageText appendString:removedContact.name];
            if (removedContacts.lastObject != removedContact) {
                [messageText appendString:@", "];
            }
        }
        [self sendSystemMessageWithText:[messageText copy] toChatWithId:chat.id];
    }
    
    if (addContacts.count) {
        NSMutableString *messageText = [NSMutableString new];
        [messageText appendString:[MVDatabaseManager sharedInstance].myContact.name];
        [messageText appendString:@" "];
        if (addContacts.count == 1) {
            [messageText appendString:@"add contact: "];
        } else {
            [messageText appendString:@"add contacts: "];
        }
        for (MVContactModel *addContact in addContacts) {
            [messageText appendString:addContact.name];
            if (addContacts.lastObject != addContact) {
                [messageText appendString:@", "];
            }
        }
        [self sendSystemMessageWithText:[messageText copy] toChatWithId:chat.id];
    }
}

- (void)exitAndDeleteChat:(MVChatModel *)chat {
    [self handleUpdatedChats:nil removedChats:@[chat]];
    [[MVDatabaseManager sharedInstance] deleteChat:chat withCompletion:nil];
}

- (void)messagesPage:(NSUInteger)pageIndex forChatWithId:(NSString *)chatId withCallback:(void (^)(NSArray <MVMessageModel *> *))callback {
    dispatch_async(self.managerQueue, ^{
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

- (void)loadAvatarThumbnailForChat:(MVChatModel *)chat completion:(void (^)(UIImage *))callback {
    [[MVFileManager sharedInstance] loadAvatarAttachmentForChat:chat completion:^(DBAttachment *attachment) {
        [attachment loadOriginalImageWithCompletion:^(UIImage *resultImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(resultImage);
            });
        }];
    }];
}

- (void)loadAttachmentForMessage:(MVMessageModel *)message completion:(void (^)(UIImage *))callback {
    [[MVFileManager sharedInstance] loadAttachmentForMessage:message completion:^(DBAttachment *attachment) {
        [attachment loadOriginalImageWithCompletion:^(UIImage *resultImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(resultImage);
            });
        }];
    }];
}

#pragma mark - Helpers
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

static NSDateFormatter *timeFormatter;
- (NSDateFormatter *)timeFormatter {
    if (!timeFormatter) {
        timeFormatter = [NSDateFormatter new];
        timeFormatter.dateFormat = @"HH:mm";
    }
    
    return timeFormatter;
}

- (NSString *)timeFromDate:(NSDate *)date {
    return [self.timeFormatter stringFromDate:date];
}
@end
