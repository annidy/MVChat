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
    [self incrementLastContactId];
    contact.id = self.lastContactId;
    NSMutableArray *existingContacts = [[self allContacts] mutableCopy];
    [existingContacts addObject:contact];
    return [MVJsonHelper writeData:[MVJsonHelper parseArrayToJson:existingContacts] toFileWithName:contactsFile];
}

- (BOOL)insertContacts:(NSArray <MVContactModel *> *)contacts {
    NSMutableArray *existingContacts = [[self allContacts] mutableCopy];
    for (MVContactModel *contact in contacts) {
        [self incrementLastContactId];
        contact.id = self.lastContactId;
        [existingContacts addObject:contact];
    }
    
    return [MVJsonHelper writeData:[MVJsonHelper parseArrayToJson:existingContacts] toFileWithName:contactsFile];
}

- (BOOL)insertChat:(MVChatModel *)chat {
    [self incrementLastChatId];
    chat.id = self.lastChatId;
    NSMutableArray *existingChats = [[self allChats] mutableCopy];
    [existingChats addObject:chat];
    return [MVJsonHelper writeData:[MVJsonHelper parseArrayToJson:existingChats] toFileWithName:chatsFile];
}

- (BOOL)insertChats:(NSArray <MVChatModel *> *)chats {
    NSMutableArray *existingChats = [[self allChats] mutableCopy];
    for (MVChatModel *chat in chats) {
        [self incrementLastChatId];
        chat.id = self.lastChatId;
        [existingChats addObject:chat];
    }
    
    return [MVJsonHelper writeData:[MVJsonHelper parseArrayToJson:existingChats] toFileWithName:chatsFile];
}

- (BOOL)insertMessages:(NSArray <MVMessageModel *> *)messages {
    NSMutableArray *existingMessages = [[self allMessages] mutableCopy];
    for (MVMessageModel *message in messages) {
        [self incrementLastMessageId];
        message.id = self.lastMessageId;
        [existingMessages addObject:message];
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

- (void)incrementLastContactId {
    self.lastContactId = [NSString stringWithFormat:@"%ld", [self.lastContactId integerValue] + 1];
}

- (void)incrementLastChatId {
    self.lastChatId = [NSString stringWithFormat:@"%ld", [self.lastChatId integerValue] + 1];
}

- (void)incrementLastMessageId {
    self.lastMessageId = [NSString stringWithFormat:@"%ld", [self.lastMessageId integerValue] + 1];
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
    NSArray <MVContactModel *> *contacts = [[MVRandomGenerator sharedInstance] generateContacts];
    [self insertContacts:contacts];
    
    NSArray <MVChatModel *> *chats = [[MVRandomGenerator sharedInstance] generateChatsWithContacts:contacts];
    [self insertChats:chats];
    
    NSMutableArray *allMessages = [NSMutableArray new];
    for (MVChatModel *chat in chats) {
        NSArray <MVMessageModel *> *messages = [[MVRandomGenerator sharedInstance] generateMessagesForChat:chat];
        messages = [self sortMessages:messages];
        for (MVMessageModel *message in messages) {
            message.chatId = chat.id;
            [allMessages addObject:message];
        }
    }
    
    [self insertMessages:allMessages];
    
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
