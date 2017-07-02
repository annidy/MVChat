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
#import "MVJsonHelper.h"
#import "MVRandomGenerator.h"

static NSString *contactsFile = @"contacts";
static NSString *chatsFile = @"chats";

@interface MVDatabaseManager()
@property (strong, nonatomic) NSString *lastContactId;
@property (strong, nonatomic) NSString *lastChatId;
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

- (void)updateLastContactId {
    _lastContactId = [[[self allContacts] lastObject] id];
}

- (void)updateLastChatId {
    _lastChatId = [[[self allChats] lastObject] id];
}

- (void)incrementLastContactId {
    self.lastContactId = [NSString stringWithFormat:@"%ld", [self.lastContactId integerValue] + 1];
}

- (void)incrementLastChatId {
    self.lastChatId = [NSString stringWithFormat:@"%ld", [self.lastChatId integerValue] + 1];
}


//test
- (void)generateData {
    NSArray <MVContactModel *> *contacts = [[MVRandomGenerator sharedInstance] generateContacts];
    NSArray <MVChatModel *> *chats = [[MVRandomGenerator sharedInstance] generateChatsWithContacts:contacts];
    [self insertContacts:contacts];
    [self insertChats:chats];
}



@end
