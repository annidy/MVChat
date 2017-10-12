//
//  MVUpdatesProvider.m
//  MVChat
//
//  Created by Mark Vasiv on 01/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVUpdatesProvider.h"
#import "MVChatManager.h"
#import "MVContactManager.h"
#import "MVMessageModel.h"
#import "MVChatModel.h"
#import "MVRandomGenerator.h"
#import "MVDatabaseManager.h"
#import "MVFileManager.h"

@interface MVUpdatesProvider()
@property (strong, nonatomic) dispatch_queue_t managerQueue;
@end

@implementation MVUpdatesProvider
#pragma mark - Lifecycle
static MVUpdatesProvider *instance;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [MVUpdatesProvider new];
    });
    
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _managerQueue = dispatch_queue_create("com.markvasiv.updatesProvider", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

#pragma mark - Avatars
- (void)performAvatarsUpdate {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), self.managerQueue, ^{
        NSArray *contacts = [[MVContactManager sharedInstance] getAllContacts];
        NSArray *chats = [[MVChatManager sharedInstance] chatsList];
        [[MVFileManager sharedInstance] generateAvatarsForContacts:contacts];
        [[MVFileManager sharedInstance] generateAvatarsForChats:chats];
    });
}

- (void)performAvatarsUpdateForContacts:(NSArray *)contacts {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), self.managerQueue, ^{
        [[MVFileManager sharedInstance] generateAvatarsForContacts:contacts];
    });
}

#pragma mark - Contacts
- (void)performLastSeenUpdate {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), self.managerQueue, ^{
        NSArray *contacts = [[MVContactManager sharedInstance] getAllContacts];
        
        for (MVContactModel *contact in contacts) {
            NSDate *lastSeenDate = [[MVRandomGenerator sharedInstance] randomLastSeenDate];
            contact.lastSeenDate = lastSeenDate;
            [[MVContactManager sharedInstance] handleContactLastSeenTimeUpdate:contact];
        }
        
        [[MVDatabaseManager sharedInstance] insertContacts:contacts withCompletion:nil];
    });
}

#pragma mark - Chats
- (void)generateNewChats {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), self.managerQueue, ^{
        NSUInteger chatsCount = [[MVRandomGenerator sharedInstance] randomUIntegerWithMin:1 andMax:5];
        NSArray *contacts = [[MVContactManager sharedInstance] getAllContacts];
        NSArray *chats = [[MVRandomGenerator sharedInstance] generateChatsWithCount:chatsCount andContacts:contacts];
        for (MVChatModel *chat in chats) {
            MVMessageModel *message = [[MVRandomGenerator sharedInstance] randomIncomingMessageWithChat:chat];
            message.read = NO;
            message.sendDate = [NSDate new];
            message.id = [NSUUID UUID].UUIDString;
            chat.lastMessage = message;
            chat.unreadCount = 1;
            chat.lastUpdateDate = message.sendDate;
            [[MVDatabaseManager sharedInstance] insertMessages:@[message] withCompletion:nil];
        }
        [[MVFileManager sharedInstance] generateAvatarsForChats:chats];
        [[MVChatManager sharedInstance] handleNewChats:chats];
    });
}

#pragma mark - Messages
- (void)generateNewMessages {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), self.managerQueue, ^{
        NSArray <MVChatModel *> *chats = [[MVChatManager sharedInstance] chatsList];
        NSUInteger count = [[MVRandomGenerator sharedInstance] randomUIntegerWithMin:1 andMax:5];
        for (NSUInteger i = 0; i < count; i++) {
            NSUInteger index = [[MVRandomGenerator sharedInstance] randomUIntegerWithMin:0 andMax:chats.count - 1];
            NSUInteger count = [[MVRandomGenerator sharedInstance] randomUIntegerWithMin:1 andMax:5];
            [self generateMessagesForChat:chats[index] count:count];
        }
    });
}

- (void)generateMessageForChatWithId:(NSString *)chatId {
    dispatch_async(self.managerQueue, ^{
        MVChatModel *chat = [[MVChatManager sharedInstance] chatWithId:chatId];
        [self generateMessagesForChat:chat count:1];
    });
}

- (void)generateMessagesForChat:(MVChatModel *)chat count:(NSUInteger)count {
    NSMutableArray *messages = [NSMutableArray new];
    
    for (NSUInteger i = 0; i < count; i++) {
        MVMessageModel *message = [[MVRandomGenerator sharedInstance] randomIncomingMessageWithChat:chat];
        message.sendDate = [NSDate new];
        message.id = [NSUUID UUID].UUIDString;
        message.read = NO;
        [messages addObject:message];
        [NSThread sleepForTimeInterval:0.2];
    }
    
    [[MVChatManager sharedInstance] handleNewMessages:messages];
}

#pragma mark - Data generation
- (void)generateData {
    [self deleteAllData];
    NSArray <MVContactModel *> *contacts = [[MVRandomGenerator sharedInstance] generateContacts];
    [[MVDatabaseManager sharedInstance] insertContacts:contacts withCompletion:^(BOOL success) {
        [[MVFileManager sharedInstance] generateAvatarsForContacts:contacts];
    }];
    
    NSArray <MVChatModel *> *chats = [[MVRandomGenerator sharedInstance] generateChatsWithContacts:contacts];
    NSArray *allMessages = [NSArray new];
    
    for (MVChatModel *chat in chats) {
        NSArray <MVMessageModel *> *messages = [[MVRandomGenerator sharedInstance] generateMessagesForChat:chat];
        chat.lastMessage = messages.lastObject;
        chat.lastUpdateDate = messages.lastObject.sendDate;
        allMessages = [allMessages arrayByAddingObjectsFromArray:messages];
    }
    
    [[MVDatabaseManager sharedInstance] insertChats:chats withCompletion:^(BOOL success) {
        [[MVFileManager sharedInstance] generateAvatarsForChats:chats];
    }];
    
    [[MVDatabaseManager sharedInstance] insertMessages:allMessages withCompletion:nil];
    
    [[MVContactManager sharedInstance] loadContacts];
    [[MVChatManager sharedInstance] loadAllChats];
}

- (void)deleteAllData {
    [[MVDatabaseManager sharedInstance] deleteAllData];
    [[MVFileManager sharedInstance] deleteAllFiles];
    [[MVFileManager sharedInstance] clearAllCache];
    [[MVContactManager sharedInstance] clearAllCache];
    [[MVChatManager sharedInstance] clearAllCache];
}
@end
