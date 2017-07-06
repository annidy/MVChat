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
@end

@implementation MVDatabaseManager

- (NSArray <MVContactModel *> *)allContacts {
    NSArray *contacts = [MVJsonHelper parseEnitiesWithClass:[MVContactModel class] fromJson:[MVJsonHelper loadJsonFromFileWithName:contactsFile]];
    if (!contacts) contacts = [NSArray new];
    return contacts;
}

- (NSArray <MVChatModel *> *)allChats {
    NSArray *chats = [MVJsonHelper parseEnitiesWithClass:[MVChatModel class] fromJson:[MVJsonHelper loadJsonFromFileWithName:chatsFile]];
    if (!chats) chats = [NSArray new];
    return chats;
}

- (NSArray <MVMessageModel *> *)allMessages {
    NSArray *chats = [MVJsonHelper parseEnitiesWithClass:[MVMessageModel class] fromJson:[MVJsonHelper loadJsonFromFileWithName:messagesFile]];
    if (!chats) chats = [NSArray new];
    return chats;
}

- (BOOL)insertContact:(MVContactModel *)contact {
    if (!contact.id) {
        contact.id = [self incrementId:self.lastContactId];
    }
    self.lastContactId = contact.id;
    NSMutableArray *existingContacts = [[self allContacts] mutableCopy];
    [existingContacts addObject:contact];
    return [MVJsonHelper writeData:[MVJsonHelper parseArrayToJson:existingContacts] toFileWithName:contactsFile];
}

- (BOOL)insertContacts:(NSArray <MVContactModel *> *)contacts {
    NSMutableArray *existingContacts = [[self allContacts] mutableCopy];
    for (MVContactModel *contact in contacts) {
        if (!contact.id) {
            contact.id = [self incrementId:self.lastContactId];
        }
        self.lastContactId = contact.id;
        [existingContacts addObject:contact];
    }
    
    return [MVJsonHelper writeData:[MVJsonHelper parseArrayToJson:existingContacts] toFileWithName:contactsFile];
}

- (BOOL)insertChat:(MVChatModel *)chat {
    if (!chat.id) {
        chat.id = [self incrementId:self.lastChatId];
    }
    self.lastChatId = chat.id;
    NSMutableArray *existingChats = [[self allChats] mutableCopy];
    [existingChats addObject:chat];
    return [MVJsonHelper writeData:[MVJsonHelper parseArrayToJson:existingChats] toFileWithName:chatsFile];
}

- (BOOL)insertChats:(NSArray <MVChatModel *> *)chats {
    NSMutableArray *existingChats = [[self allChats] mutableCopy];
    for (MVChatModel *chat in chats) {
        if (!chat.id) {
            chat.id = [self incrementId:self.lastChatId];
        }
        self.lastChatId = chat.id;
        [existingChats addObject:chat];
    }
    
    return [MVJsonHelper writeData:[MVJsonHelper parseArrayToJson:existingChats] toFileWithName:chatsFile];
}

- (BOOL)insertMessages:(NSArray <MVMessageModel *> *)messages {
    NSMutableArray *existingMessages = [[self allMessages] mutableCopy];
    for (MVMessageModel *message in messages) {
        if (!message.id) {
            message.id = [self incrementId:self.lastMessageId];
        }
        [existingMessages addObject:message];
        self.lastMessageId = message.id;
    }
    
    return [MVJsonHelper writeData:[MVJsonHelper parseArrayToJson:existingMessages] toFileWithName:messagesFile];
}

-(MVContactModel *)contactWithId:(NSString *)id {
    for (MVContactModel *contact in [self allContacts]) {
        if ([contact.id isEqualToString:id]) {
            return contact;
        }
    }
    
    return nil;
}

-(MVChatModel *)chatWithId:(NSString *)id {
    for (MVChatModel *chat in [self allChats]) {
        if ([chat.id isEqualToString:id]) {
            return chat;
        }
    }
    
    return nil;
}

- (NSString *)lastContactId {
    if (!_lastContactId) [self updateLastContactId];
    
    return _lastContactId;
}

- (NSString *)lastChatId {
    if (!_lastChatId) [self updateLastChatId];
    
    return _lastChatId;
}

- (NSString *)lastMessageId {
    if (!_lastMessageId) [self updateLastMessageId];
    
    return _lastMessageId;
}

- (void)updateLastContactId {
    _lastContactId = [[[self allContacts] lastObject] id];
}

- (void)updateLastChatId {
    _lastChatId = [[[self allChats] lastObject] id];
}

- (void)updateLastMessageId {
    _lastMessageId = [[[self allMessages] lastObject] id];
}

- (NSString *)incrementId:(NSString *)oldId {
    return [NSString stringWithFormat:@"%d", [oldId intValue] + 1];
}

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
    [self insertContacts:[mutableContacts copy]];
    
    //Chats
    [mutableContacts addObject:[self myContact]];
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
    
    [self insertChats:[mutableChats copy]];
    [self insertMessages:[allMessages copy]];
    
    NSArray *allContacts = [self allContacts];
    NSArray *allChats = [self allChats];
    NSArray *messages = [self allMessages];
    
    NSString *a;
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
