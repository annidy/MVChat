//
//  MVDatabaseManager.m
//  MVChat
//
//  Created by Mark Vasiv on 30/06/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVDatabaseManager.h"
#import "MVContactModel.h"
#import "MVChatModel.h"
#import "MVMessageModel.h"
#import "MVJsonHelper.h"
#import "MVRandomGenerator.h"

static NSString *contactsFile = @"contacts";
static NSString *chatsFile = @"chats";
static NSString *messagesFile = @"messages";

@interface MVDatabaseManager()
@property (strong, nonatomic) NSString *lastContactId;
@property (strong, nonatomic) NSString *lastChatId;
@property (strong, nonatomic) NSString *lastMessageId;
@property (strong, nonatomic) dispatch_queue_t managerQueue;
@end

@implementation MVDatabaseManager

static MVDatabaseManager *instance;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [MVDatabaseManager new];
    });
    
    return instance;
}

-(instancetype)init {
    if (self = [super init]) {
        _managerQueue = dispatch_queue_create("com.markvasiv.databaseManager", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

#pragma mark - Ids
- (NSString *)lastContactId {
    if (!_lastContactId) _lastContactId = [[[self allContactsSync] lastObject] id];
    
    return _lastContactId;
}

- (NSString *)lastChatId {
    if (!_lastChatId) _lastChatId = [[[self allChatsSync] lastObject] id];
    
    return _lastChatId;
}

- (NSString *)lastMessageId {
    if (!_lastMessageId) _lastMessageId = [[[self allMessagesSync] lastObject] id];
    
    return _lastMessageId;
}

- (NSString *)incrementId:(NSString *)oldId {
    return [NSString stringWithFormat:@"%d", [oldId intValue] + 1];
}

#pragma mark - Select
- (NSArray <MVContactModel *> *)allContactsSync {
    NSArray *contacts = [MVJsonHelper parseEnitiesWithClass:[MVContactModel class] fromJson:[MVJsonHelper loadJsonFromFileWithName:contactsFile]];
    if (!contacts) contacts = [NSArray new];
    return contacts;
}

- (NSArray <MVChatModel *> *)allChatsSync {
    NSArray *chats = [MVJsonHelper parseEnitiesWithClass:[MVChatModel class] fromJson:[MVJsonHelper loadJsonFromFileWithName:chatsFile]];
    if (!chats) chats = [NSArray new];
    return chats;
}

- (NSArray <MVMessageModel *> *)allMessagesSync {
    NSArray *chats = [MVJsonHelper parseEnitiesWithClass:[MVMessageModel class] fromJson:[MVJsonHelper loadJsonFromFileWithName:messagesFile]];
    if (!chats) chats = [NSArray new];
    return chats;
}

- (void)allContacts:(void (^)(NSArray <MVContactModel *> *))completion {
    dispatch_async(self.managerQueue, ^{
        completion([self allContactsSync]);
    });
}

- (void)allChats:(void (^)(NSArray <MVChatModel *> *))completion {
    dispatch_async(self.managerQueue, ^{
        completion([self allChatsSync]);
    });
}

#pragma mark - Select with condition
- (void)contactWithId:(NSString *)id completion:(void (^)(MVContactModel *))completion {
    dispatch_async(self.managerQueue, ^{
        BOOL found = NO;
        for (MVContactModel *contact in [self allContactsSync]) {
            if ([contact.id isEqualToString:id]) {
                found = YES;
                completion(contact);
            }
        }
        if (!found) {
            completion(nil);
        }
    });
}

- (void)chatWithId:(NSString *)id completion:(void (^)(MVChatModel *))completion {
    dispatch_async(self.managerQueue, ^{
        BOOL found = NO;
        for (MVChatModel *chat in [self allChatsSync]) {
            if ([chat.id isEqualToString:id]) {
                found = YES;
                completion(chat);
            }
        }
        if (!found) {
            completion(nil);
        }
    });
}

- (void)messageWithId:(NSString *)id completion:(void (^)(MVMessageModel *))completion {
    dispatch_async(self.managerQueue, ^{
        BOOL found = NO;
        for (MVMessageModel *message in [self allMessagesSync]) {
            if ([message.id isEqualToString:id]) {
                found = YES;
                completion(message);
            }
        }
        if (!found) {
            completion(nil);
        }
    });
}

- (void)messagesFromChatWithId:(NSString *)chatId completion:(void (^)(NSArray <MVMessageModel *> *))completion {
    dispatch_async(self.managerQueue, ^{
        NSMutableArray *messages = [NSMutableArray new];
        for (MVMessageModel *message in [self allMessagesSync]) {
            [messages addObject:message];
        }
        completion([messages copy]);
    });
}

#pragma mark - Insert
- (void)insertContacts:(NSArray <MVContactModel *> *)contacts withCompletion:(void (^)(BOOL success))completion {
    dispatch_async(self.managerQueue, ^{
        NSMutableArray *existingContacts = [[self allContactsSync] mutableCopy];
        for (MVContactModel *contact in contacts) {
            if (!contact.id) {
                contact.id = [self incrementId:self.lastContactId];
            }
            self.lastContactId = contact.id;
            [existingContacts addObject:contact];
        }
        BOOL success = [MVJsonHelper writeData:[MVJsonHelper parseArrayToJson:existingContacts] toFileWithName:contactsFile];
        if (completion) {
            completion(success);
        }
    });
}

- (void)insertChats:(NSArray <MVChatModel *> *)chats withCompletion:(void (^)(BOOL success))completion {
    dispatch_async(self.managerQueue, ^{
        NSMutableArray *existingChats = [[self allChatsSync] mutableCopy];
        for (MVChatModel *chat in chats) {
            if (!chat.id) {
                chat.id = [self incrementId:self.lastChatId];
            }
            self.lastChatId = chat.id;
            [existingChats addObject:chat];
        }
        
        BOOL success = [MVJsonHelper writeData:[MVJsonHelper parseArrayToJson:existingChats] toFileWithName:chatsFile];
        if (completion) {
            completion(success);
        }
    });
}

- (void)insertMessages:(NSArray <MVMessageModel *> *)messages withCompletion:(void (^)(BOOL success))completion {
    dispatch_async(self.managerQueue, ^{
        NSMutableArray *existingMessages = [[self allMessagesSync] mutableCopy];
        for (MVMessageModel *message in messages) {
            if (!message.id) {
                message.id = [self incrementId:self.lastMessageId];
            }
            [existingMessages addObject:message];
            self.lastMessageId = message.id;
        }
        
        BOOL success = [MVJsonHelper writeData:[MVJsonHelper parseArrayToJson:existingMessages] toFileWithName:messagesFile];
        if (completion) {
            completion(success);
        }
    });
}

#pragma mark - Helpers
-(MVContactModel *)myContact {
    MVContactModel *me = [MVContactModel new];
    me.id = @"0";
    me.name = @"Mark";
    me.iam = YES;
    me.status = ContactStatusOnline;
    return me;
}

//test
- (void)generateData {
    //Contacts
    NSMutableArray *mutableContacts = [NSMutableArray new];
    NSArray <MVContactModel *> *contacts = [[MVRandomGenerator sharedInstance] generateContacts];
    NSString *lastContactId = self.lastContactId;
    for (MVContactModel *contact in contacts) {
        lastContactId = [self incrementId:lastContactId];
        contact.id = lastContactId;
        [mutableContacts addObject:contact];
    }
    [self insertContacts:[mutableContacts copy] withCompletion:nil];
    
    //Chats
    NSMutableArray *mutableChats = [NSMutableArray new];
    NSArray <MVChatModel *> *chats = [[MVRandomGenerator sharedInstance] generateChatsWithContacts:[mutableContacts copy]];
    NSString *lastChatId = self.lastChatId;
    for (MVChatModel *chat in chats) {
        lastChatId = [self incrementId:lastChatId];
        chat.id = lastChatId;
        [mutableChats addObject:chat];
    }
    
    //Messages
    NSMutableArray *allMessages = [NSMutableArray new];
    NSString *lastMessageId = self.lastMessageId;
    for (MVChatModel *chat in mutableChats) {
        NSArray <MVMessageModel *> *messages = [[MVRandomGenerator sharedInstance] generateMessagesForChat:chat];
        messages = [self sortMessages:messages];
        for (MVMessageModel *message in messages) {
            lastMessageId = [self incrementId:lastMessageId];
            message.id = lastMessageId;
            message.chatId = chat.id;
            [allMessages addObject:message];
        }
        chat.lastMessage = [messages lastObject];
        chat.lastUpdateDate = [[messages lastObject] sendDate];
    }
    
    [self insertChats:[mutableChats copy] withCompletion:nil];
    [self insertMessages:[allMessages copy] withCompletion:nil];
}

- (NSArray <MVMessageModel *> *)sortMessages:(NSArray<MVMessageModel *> *)messages {
    return [messages sortedArrayUsingComparator:^NSComparisonResult(MVMessageModel *obj1, MVMessageModel *obj2) {
        NSTimeInterval first = obj1.sendDate.timeIntervalSinceReferenceDate;
        NSTimeInterval second = obj2.sendDate.timeIntervalSinceReferenceDate;
        
        if (first == second) {
            return NSOrderedSame;
        } else if (first > second) {
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    }];
}

@end
