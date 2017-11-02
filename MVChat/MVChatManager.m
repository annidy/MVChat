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
#import <ReactiveObjC.h>

@interface MVChatManager()
@property (strong, nonatomic) NSMutableArray *chats;
@property (strong, nonatomic) NSMutableDictionary *chatsMessages;
@property (strong, nonatomic) NSMutableDictionary *chatsMessagesPages;
@property (strong, nonatomic) NSMutableSet *cachedChatIds;
@property (strong, nonatomic) dispatch_queue_t managerQueue;
@property (strong, nonatomic) RACScheduler *managerScheduler;

@property (strong, nonatomic) RACSubject *chatUpdateSubject;
@property (strong, nonatomic) RACSubject *messageUpdateSubject;
@end

@implementation MVChatUpdate
+ (instancetype)updateWithType:(ChatUpdateType)type chat:(MVChatModel *)chat sorting:(BOOL)sort index:(NSInteger)index {
    MVChatUpdate *update = [MVChatUpdate new];
    update.updateType = type;
    update.chat = chat;
    update.sorting = sort;
    update.index = index;
    return update;
}
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
        _viewModelQueue = dispatch_queue_create("com.markvasiv.chatsViewModel", nil);
        _chats = [NSMutableArray new];
        _chatsMessages = [NSMutableDictionary new];
        _chatsMessagesPages = [NSMutableDictionary new];
        _cachedChatIds = [NSMutableSet new];
        _viewModelScheduler = [[RACTargetQueueScheduler alloc] initWithName:@"com.vm.Chat" queue:_viewModelQueue];
        _managerScheduler = [[RACTargetQueueScheduler alloc] initWithName:@"com.m.chat" queue:_managerQueue];
        _messageUpdateSubject = [RACSubject new];
        _chatUpdateSubject = [RACSubject new];
        
        [[[MVFileManager sharedInstance].writerSignal deliverOn:_managerScheduler] subscribeNext:^(RACTuple *tuple) {
            RACTupleUnpack(MVMessageModel *message, DBAttachment *attachment) = tuple;
            message.attachment = attachment;
            [self updateMessage:message];
        }];
        
        self.chatUpdateSignal = [self.chatUpdateSubject deliverOn:self.viewModelScheduler];
        _messageUpdateSignal = [_messageUpdateSubject deliverOn:_viewModelScheduler];
    }
    
    return self;
}

#pragma mark - Caching
- (void)loadAllChats {
    [[MVDatabaseManager sharedInstance] allChats:^(NSArray<MVChatModel *> *chats) {
        @synchronized (self.chats) {
            self.chats = [chats mutableCopy];
        }
        
        [self.chatUpdateSubject sendNext:[MVChatUpdate updateWithType:ChatUpdateTypeReload chat:nil sorting:NO index:0]];
    }];
}

- (void)loadMessagesForChatWithId:(NSString *)chatId withCallback:(void (^)())callback {
    [[MVDatabaseManager sharedInstance] messagesFromChatWithId:chatId completion:^(NSArray<MVMessageModel *> *messages) {
        for (MVMessageModel *message in messages) {
            if (message.type == MVMessageTypeMedia) {
                [[MVFileManager sharedInstance] fillMessageAttachment:message];
            }
        }
        dispatch_async(self.managerQueue, ^{
            @synchronized (self.chatsMessages) {
                [self.chatsMessages setObject:[messages mutableCopy] forKey:chatId];
                [self.chatsMessagesPages setObject:@([self numberOfPages:messages]) forKey:chatId];
                [self.cachedChatIds addObject:chatId];
            }
            if (callback) callback();
        });
    }];
}

- (void)syncLoadMessagesForChatWithId:(NSString *)chatId withCallback:(void (^)())callback {
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
                    [self.cachedChatIds addObject:chatId];
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
        [self syncMessagesPage:pageIndex forChatWithId:chatId withCallback:callback];
    });
}

- (void)syncMessagesPage:(NSUInteger)pageIndex forChatWithId:(NSString *)chatId withCallback:(void (^)(NSArray <MVMessageModel *> *))callback {
    NSMutableArray *messages;
    @synchronized (self.chatsMessages) {
        messages = [self.chatsMessages objectForKey:chatId];
    }
    
    NSArray *pagedMessages;
    
    if (!messages) {
        [self loadMessagesForChatWithId:chatId withCallback:^() {
            [self syncMessagesPage:pageIndex forChatWithId:chatId withCallback:callback];
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

- (void)mediaMessagesForChatWithId:(NSString *)chatId withCallback:(void (^)(NSArray <MVMessageModel *> *))callback {
    dispatch_async(self.managerQueue, ^{
        [self syncMediaMessagesForChatWithId:chatId withCallback:callback];
    });
}

- (void)syncMediaMessagesForChatWithId:(NSString *)chatId withCallback:(void (^)(NSArray <MVMessageModel *> *))callback {
    NSMutableArray *messages;
    @synchronized (self.chatsMessages) {
        messages = [self.chatsMessages objectForKey:chatId];
    }
    
    NSArray *pagedMessages;
    
    if (!messages) {
        [self loadMessagesForChatWithId:chatId withCallback:^() {
            [self syncMediaMessagesForChatWithId:chatId withCallback:callback];
        }];
    } else {
        pagedMessages = [messages filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(MVMessageModel *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return evaluatedObject.type == MVMessageTypeMedia;
        }]];
        
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

#pragma mark - Handle Updates
- (void)addChat:(MVChatModel *)chat {
    @synchronized (self) {
        [self.chats insertObject:chat atIndex:0];
    }
    
    [self.chatUpdateSubject sendNext:[MVChatUpdate updateWithType:ChatUpdateTypeInsert chat:chat sorting:NO index:0]];
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
    [self.chatUpdateSubject sendNext:[MVChatUpdate updateWithType:ChatUpdateTypeModify chat:chat sorting:sorting index:newIndex]];
}

- (void)removeChat:(MVChatModel *)chat {
    NSInteger index = [self indexOfChatWithId:chat.id];
    if (index != NSNotFound) {
        @synchronized (self.chats) {
            [self.chats removeObjectAtIndex:index];
        }
    }
    
    [self.chatUpdateSubject sendNext:[MVChatUpdate updateWithType:ChatUpdateTypeDelete chat:chat sorting:NO index:0]];
}

- (void)addMessage:(MVMessageModel *)message {
    @synchronized (self.chatsMessages) {
        if ([self.cachedChatIds containsObject:message.chatId]) {
            NSMutableArray *messages = [self.chatsMessages objectForKey:message.chatId];
            if (!messages) {
                messages = [NSMutableArray new];
                [self.chatsMessages setObject:messages forKey:message.chatId];
            }
            [messages insertObject:message atIndex:0];
            [self.chatsMessagesPages setObject:@([self numberOfPages:messages]) forKey:message.chatId];
        }
    }

    [self.messageUpdateSubject sendNext:message];
}

- (void)updateMessage:(MVMessageModel *)message {
    dispatch_async(self.managerQueue, ^{
        NSUInteger index = [self indexOfMessage:message];
        if (index != NSNotFound) {
            @synchronized (self.chatsMessages) {
                [[self.chatsMessages objectForKey:message.chatId] replaceObjectAtIndex:index withObject:message];
            }
            //TODO: update message
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
            [self.cachedChatIds addObject:chat.id];
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
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.chatsListener updateChats];
//        });
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
    message.attachment = attachment;
    [self sendMessage:message toChatWithId:chatId];
    [[MVFileManager sharedInstance] saveMessageAttachment:message];
    //[[MVFileManager sharedInstance] saveMediaMesssage:message attachment:attachment completion:nil];
}

- (void)sendMessage:(MVMessageModel *)message toChatWithId:(NSString *)chatId {
    dispatch_async(self.managerQueue, ^{
        message.contact = MVContactManager.myContact;
        message.direction = MessageDirectionOutgoing;
        message.chatId = chatId;
        message.sendDate = [NSDate new];
        message.read = YES;
        [self addMessage:message];
        [[MVDatabaseManager sharedInstance] insertMessages:@[message] withCompletion:nil];
        
        MVChatModel *chat = [self chatWithId:chatId];
        chat.lastMessage = message;
        chat.lastUpdateDate = message.sendDate;
        [self replaceChat:chat withSorting:YES];
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
        NSArray *messages = [self.chatsMessages objectForKey:message.chatId];
        for (MVMessageModel *messageModel in messages) {
            if ([message.id isEqualToString:messageModel.id]) {
                return [messages indexOfObject:messageModel];
            }
        }
    }
    
    return NSNotFound;
}

#pragma mark - External events
- (void)handleNewChats:(NSArray <MVChatModel *> *)chats {
    dispatch_async(self.managerQueue, ^{
        for (MVChatModel *chat in chats) {
            [self addChat:chat];
            [[MVDatabaseManager sharedInstance] insertChats:@[chat] withCompletion:nil];
        }
    });
}

- (void)handleNewMessages:(NSArray<MVMessageModel *> *)messages {
    dispatch_async(self.managerQueue, ^{
        for (MVMessageModel *message in messages) {
            MVChatModel *chat = [self chatWithId:message.chatId];
            chat.lastMessage = message;
            chat.lastUpdateDate = message.sendDate;
            chat.unreadCount++;
            [self addMessage:message];
            [self replaceChat:chat withSorting:YES];
            [[MVDatabaseManager sharedInstance] insertMessages:@[message] withCompletion:nil];
            [[MVDatabaseManager sharedInstance] insertChats:@[chat] withCompletion:nil];
        }
    });
}

- (void)clearAllCache {
    dispatch_async(self.managerQueue, ^{
        @synchronized (self.chats) {
            self.chats = [NSMutableArray new];
        }
        @synchronized (self.chatsMessages) {
            self.chatsMessages = [NSMutableDictionary new];
            self.chatsMessagesPages = [NSMutableDictionary new];
            self.cachedChatIds = [NSMutableSet new];
        }
        
        [self.chatUpdateSubject sendNext:[MVChatUpdate updateWithType:ChatUpdateTypeReload chat:nil sorting:NO index:0]];
    });
}
@end
