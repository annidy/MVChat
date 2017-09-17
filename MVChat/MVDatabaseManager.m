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
#import "MVRandomGenerator.h"
#import "MVFileManager.h"

#import <YapDatabase.h>
#import <YapDatabaseViewTypes.h>
#import <YapDatabaseAutoView.h>

static NSString *contactsCollection = @"contacts";
static NSString *chatsCollection = @"chats";
static NSString *messagesCollection = @"messages";

@interface MVDatabaseManager()
@property (strong, nonatomic) YapDatabase *db;
@property (strong, nonatomic) YapDatabaseConnection *contactsConnection;
@property (strong, nonatomic) YapDatabaseConnection *chatsConnection;
@property (strong, nonatomic) YapDatabaseConnection *messagesConnection;
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

- (instancetype)init {
    if (self = [super init]) {
        _db = [[YapDatabase alloc] initWithPath:[[MVFileManager documentsPath] stringByAppendingPathComponent:@"yap"]];
        _contactsConnection = [_db newConnection];
        _chatsConnection = [_db newConnection];
        _messagesConnection = [_db newConnection];
        [self setupDatabase];
    }
    
    return self;
}

- (void)setupDatabase {
    YapDatabaseViewGrouping *messagesGrouping = [YapDatabaseViewGrouping withObjectBlock:^NSString * _Nullable(YapDatabaseReadTransaction *transaction, NSString *collection, NSString *key, id object) {
        if ([collection isEqualToString:messagesCollection]) {
            MVMessageModel *message = (MVMessageModel *)object;
            return message.chatId;
        }
        
        return nil;
    }];
    
    YapDatabaseViewSorting *messagesSorting = [YapDatabaseViewSorting withObjectBlock: ^NSComparisonResult (YapDatabaseReadTransaction *transaction, NSString *group, NSString *collection1, NSString *key1, id object1, NSString *collection2, NSString *key2, id object2) {
        MVMessageModel *message = (MVMessageModel *)object1;
        return [message compareMessageBySendDate:object2];
    }];
                                                                            
    YapDatabaseAutoView *messagesView = [[YapDatabaseAutoView alloc] initWithGrouping:messagesGrouping sorting:messagesSorting];
    [self.db registerExtension:messagesView withName:@"orderedMessages"];
    
    
    YapDatabaseViewGrouping *chatsGrouping = [YapDatabaseViewGrouping withObjectBlock:^NSString * _Nullable(YapDatabaseReadTransaction *transaction, NSString *collection, NSString *key, id object) {
        if ([collection isEqualToString:chatsCollection]) {
            return @"chats";
        }
        
        return nil;
    }];
    
    YapDatabaseViewSorting *chatsSorting = [YapDatabaseViewSorting withObjectBlock: ^NSComparisonResult (YapDatabaseReadTransaction *transaction, NSString *group, NSString *collection1, NSString *key1, id object1, NSString *collection2, NSString *key2, id object2) {
        MVChatModel *chat = (MVChatModel *)object1;
        return [chat compareChatByLastUpdateDate:object2];
    }];
    
    YapDatabaseAutoView *chatsView = [[YapDatabaseAutoView alloc] initWithGrouping:chatsGrouping sorting:chatsSorting];
    [self.db registerExtension:chatsView withName:@"orderedChats"];
    
    
    YapDatabaseViewGrouping *contactsGrouping = [YapDatabaseViewGrouping withObjectBlock:^NSString * _Nullable(YapDatabaseReadTransaction *transaction, NSString *collection, NSString *key, id object) {
        if ([collection isEqualToString:contactsCollection]) {
            return @"contacts";
        }
        
        return nil;
    }];
    
    YapDatabaseViewSorting *contactsSorting = [YapDatabaseViewSorting withObjectBlock: ^NSComparisonResult (YapDatabaseReadTransaction *transaction, NSString *group, NSString *collection1, NSString *key1, id object1, NSString *collection2, NSString *key2, id object2) {
        MVContactModel *chat = (MVContactModel *)object1;
        return [chat compareContactsByName:object2];
    }];
    
    YapDatabaseAutoView *contactsView = [[YapDatabaseAutoView alloc] initWithGrouping:contactsGrouping sorting:contactsSorting];
    [self.db registerExtension:contactsView withName:@"orderedContacts"];
}

#pragma mark - Select
- (void)allContacts:(void (^)(NSArray <MVContactModel *> *))completion {
    [self.contactsConnection asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction) {
        NSMutableArray *contacts = [NSMutableArray new];
        [[transaction ext:@"orderedContacts"] enumerateKeysAndObjectsInGroup:@"contacts" usingBlock:^(NSString *collection, NSString *key, id object, NSUInteger index, BOOL *stop) {
            [contacts addObject:object];
        }];
        completion([contacts copy]);
    }];
}

- (void)allChats:(void (^)(NSArray <MVChatModel *> *))completion {
    [self.chatsConnection asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction) {
        NSMutableArray *chats = [NSMutableArray new];
        [[transaction ext:@"orderedChats"] enumerateKeysAndObjectsInGroup:@"chats" usingBlock:^(NSString *collection, NSString *key, id object, NSUInteger index, BOOL *stop) {
            [chats addObject:object];
        }];
        completion([chats copy]);
    }];
}

- (void)messagesFromChatWithId:(NSString *)chatId completion:(void (^)(NSArray <MVMessageModel *> *))completion {
    [self.messagesConnection asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction) {
        NSMutableArray *messages = [NSMutableArray new];
        [[transaction extension:@"orderedMessages"] enumerateKeysAndObjectsInGroup:chatId usingBlock:^(NSString *collection, NSString *key, id object, NSUInteger index, BOOL *stop) {
            [messages addObject:object];
        }];
        completion([messages copy]);
    }];
}

- (void)messagesFromChatWithId:(NSString *)chatId withType:(MVMessageType)type completion:(void (^)(NSArray <MVMessageModel *> *))completion {
    [self.messagesConnection asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction) {
        NSMutableArray *messages = [NSMutableArray new];
        [[transaction extension:@"orderedMessages"] enumerateKeysAndObjectsInGroup:chatId usingBlock:^(NSString *collection, NSString *key, id object, NSUInteger index, BOOL *stop) {
            MVMessageModel *message = (MVMessageModel *)object;
            if (message.type == type) {
                [messages addObject:message];
            }
        }];
        completion([messages copy]);
    }];
}

#pragma mark - Insert
- (void)insertContacts:(NSArray <MVContactModel *> *)contacts withCompletion:(void (^)(BOOL success))completion {
    [self.contactsConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        for (MVContactModel *contact in contacts) {
            [transaction setObject:contact forKey:contact.id inCollection:contactsCollection];
        }
        if (completion) completion(YES);
    }];
}

- (void)insertChats:(NSArray <MVChatModel *> *)chats withCompletion:(void (^)(BOOL success))completion {
    [self.chatsConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        for (MVChatModel *chat in chats) {
            [transaction setObject:chat forKey:chat.id inCollection:chatsCollection];
        }
        if (completion) completion(YES);
    }];
}

- (void)insertMessages:(NSArray <MVMessageModel *> *)messages withCompletion:(void (^)(BOOL success))completion {
    [self.messagesConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        for (MVMessageModel *message in messages) {
            [transaction setObject:message forKey:message.id inCollection:messagesCollection];
            MVChatModel *chat = [transaction objectForKey:message.chatId inCollection:chatsCollection];
            chat.lastMessage = message;
            chat.lastUpdateDate = message.sendDate;
            [transaction setObject:chat forKey:chat.id inCollection:chatsCollection];
        }
    }];
    
    if (completion) completion(YES);
}

- (void)deleteChat:(MVChatModel *)chatModel withCompletion:(void (^)(BOOL success))completion {
    [self.chatsConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction removeObjectForKey:chatModel.id inCollection:chatsCollection];
    }];
}


- (void)deleteAllData {
    [self.chatsConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
        [transaction removeAllObjectsInAllCollections];
    }];
}
//test
- (void)generateData {
    NSArray <MVContactModel *> *contacts = [[MVRandomGenerator sharedInstance] generateContacts];
    [self insertContacts:contacts withCompletion:^(BOOL success) {
        [[MVFileManager sharedInstance] generateAvatarsForContacts:contacts];
    }];
    
    NSArray <MVChatModel *> *chats = [[MVRandomGenerator sharedInstance] generateChatsWithContacts:contacts];
    NSArray *allMessages = [NSArray new];
    
    for (MVChatModel *chat in chats) {
        NSArray <MVMessageModel *> *messages = [[MVRandomGenerator sharedInstance] generateMessagesForChat:chat];
        allMessages = [allMessages arrayByAddingObjectsFromArray:messages];
    }
    
    [self insertChats:chats withCompletion:^(BOOL success) {
        [[MVFileManager sharedInstance] generateAvatarsForChats:chats];
    }];
    
    [self insertMessages:allMessages withCompletion:nil];
}

@end
