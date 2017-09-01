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
#import "MVFileManager.h"

#import <YapDatabase.h>
#import <YapDatabaseViewTypes.h>
#import <YapDatabaseAutoView.h>

static NSString *contactsCollection = @"contacts";
static NSString *chatsCollection = @"chats";
static NSString *messagesCollection = @"messages";

@interface MVDatabaseManager()
@property (strong, nonatomic) dispatch_queue_t managerQueue;
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
        _managerQueue = dispatch_queue_create("com.markvasiv.databaseManager", DISPATCH_QUEUE_SERIAL);
        _db = [[YapDatabase alloc] initWithPath:[[MVJsonHelper documentsPath] stringByAppendingPathComponent:@"yap"]];
        _contactsConnection = [_db newConnection];
        _chatsConnection = [_db newConnection];
        _messagesConnection = [_db newConnection];
        [self setupDatabase];
    }
    
    return self;
}

- (void)setupDatabase {
    //secondary index
//    YapDatabaseSecondaryIndexSetup *messagesSecondaryIndexSetup = [[YapDatabaseSecondaryIndexSetup alloc] init];
//    [messagesSecondaryIndexSetup addColumn:@"messageChatId" withType:YapDatabaseSecondaryIndexTypeText];
//    [messagesSecondaryIndexSetup addColumn:@"messageType" withType:YapDatabaseSecondaryIndexTypeInteger];
//    
//    YapDatabaseSecondaryIndexHandler *messagesSecondaryIndexHandler = [YapDatabaseSecondaryIndexHandler withObjectBlock:^(YapDatabaseReadTransaction *transaction, NSMutableDictionary *dict, NSString *collection, NSString *key, id object) {
//        if ([collection isEqualToString:@"messages"]) {
//            MVMessageModel *message = (MVMessageModel *)object;
//            dict[@"messageChatId"] = message.chatId;
//            dict[@"messageType"] = @(message.type);
//        }
//    }];
//    
//    YapDatabaseSecondaryIndex *messageSecondaryIndex = [[YapDatabaseSecondaryIndex alloc] initWithSetup:messagesSecondaryIndexSetup handler:messagesSecondaryIndexHandler];
//    [self.db registerExtension:messageSecondaryIndex withName:@"secondaryIndex"];
    
    //views
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
    
    
//    YapDatabaseViewFiltering *filt = [YapDatabaseViewFiltering withObjectBlock:^BOOL(YapDatabaseReadTransaction *transaction, NSString *group, NSString *collection, NSString *key, id object) {
//        return YES;
//    }];
    
//    self.mesagesFilteredView = [[YapDatabaseFilteredView alloc] initWithParentViewName:@"orderedMessages" filtering:filt versionTag:@"0"];
//    self.mesagesFilteredView.options.isPersistent = NO;
//    
//    [self.db registerExtension:self.mesagesFilteredView withName:@"filteredMessages"];
    //[self.db unregisterExtensionWithName:@"orderedMessages"];
    //[self.db unregisterExtensionWithName:@"orderedChats"];
}

#pragma mark - Select
- (void)allContacts:(void (^)(NSArray <MVContactModel *> *))completion {
    dispatch_async(self.managerQueue, ^{
        __block NSMutableArray *contacts = [NSMutableArray new];
        [self.contactsConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            [[transaction ext:@"orderedContacts"] enumerateKeysAndObjectsInGroup:@"contacts" usingBlock:^(NSString *collection, NSString *key, id object, NSUInteger index, BOOL *stop) {
                [contacts addObject:object];
            }];
        }];
        
        completion([contacts copy]);
    });
}

- (void)allChats:(void (^)(NSArray <MVChatModel *> *))completion {
    dispatch_async(self.managerQueue, ^{
        __block NSMutableArray *chats = [NSMutableArray new];
        [self.chatsConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            [[transaction ext:@"orderedChats"] enumerateKeysAndObjectsInGroup:@"chats" usingBlock:^(NSString *collection, NSString *key, id object, NSUInteger index, BOOL *stop) {
                [chats addObject:object];
            }];
        }];
        
        completion([chats copy]);
    });
}

- (void)messagesFromChatWithId:(NSString *)chatId completion:(void (^)(NSArray <MVMessageModel *> *))completion {
    dispatch_async(self.managerQueue, ^{
        __block NSMutableArray *messages = [NSMutableArray new];
        
        [self.messagesConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            [[transaction extension:@"orderedMessages"] enumerateKeysAndObjectsInGroup:chatId usingBlock:^(NSString *collection, NSString *key, id object, NSUInteger index, BOOL *stop) {
                [messages addObject:object];
            }];
        }];
    
        completion([messages copy]);
    });
}

- (void)messagesFromChatWithId:(NSString *)chatId withType:(MVMessageType)type completion:(void (^)(NSArray <MVMessageModel *> *))completion {
    dispatch_async(self.managerQueue, ^{
        __block NSMutableArray *messages = [NSMutableArray new];
        
        [self.messagesConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            [[transaction extension:@"orderedMessages"] enumerateKeysAndObjectsInGroup:chatId usingBlock:^(NSString *collection, NSString *key, id object, NSUInteger index, BOOL *stop) {
                MVMessageModel *message = (MVMessageModel *)object;
                if (message.type == type) {
                    [messages addObject:message];
                }
            }];
        }];
        
        completion([messages copy]);
    });
}

//- (void)lastMessageFromChatWithId:(NSString *)chatId completion:(void (^)(MVMessageModel *))completion {
//    dispatch_async(self.managerQueue, ^{
//        __block MVMessageModel *lastMessage;
//        [self.messagesConnection readWithBlock:^(YapDatabaseReadTransaction *transaction){
//            NSUInteger count = [[transaction ext:@"orderedMessages"] numberOfItemsInGroup:chatId];
//            lastMessage = [[transaction ext:@"orderedMessages"] objectAtIndex:count - 1 inGroup:chatId];
//        }];
//        
//        completion(lastMessage);
//    });
//}

#pragma mark - Insert
- (void)insertContacts:(NSArray <MVContactModel *> *)contacts withCompletion:(void (^)(BOOL success))completion {
    dispatch_async(self.managerQueue, ^{
        [self.contactsConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            for (MVContactModel *contact in contacts) {
                [transaction setObject:contact forKey:contact.id inCollection:contactsCollection];
            }
            if (completion) completion(YES);
        }];
    });
}

- (void)insertChats:(NSArray <MVChatModel *> *)chats withCompletion:(void (^)(BOOL success))completion {
    dispatch_async(self.managerQueue, ^{
        [self.chatsConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            for (MVChatModel *chat in chats) {
                [transaction setObject:chat forKey:chat.id inCollection:chatsCollection];
            }
            if (completion) completion(YES);
        }];
    });
}

- (void)insertMessages:(NSArray <MVMessageModel *> *)messages withCompletion:(void (^)(BOOL success))completion {
    dispatch_async(self.managerQueue, ^{
        [self.messagesConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            for (MVMessageModel *message in messages) {
                [transaction setObject:message forKey:message.id inCollection:messagesCollection];
                MVChatModel *chat = [transaction objectForKey:message.chatId inCollection:chatsCollection];
                chat.lastMessage = message;
                chat.lastUpdateDate = message.sendDate;
                [transaction setObject:chat forKey:chat.id inCollection:chatsCollection];
            }
        }];
        
        if (completion) completion(YES);
    });
}

- (void)deleteChat:(MVChatModel *)chatModel withCompletion:(void (^)(BOOL success))completion {
    dispatch_async(self.managerQueue, ^{
        [self.chatsConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [transaction removeObjectForKey:chatModel.id inCollection:chatsCollection];
        }];
    });
}

#pragma mark - Helpers

//test
- (void)generateData {
    NSArray <MVContactModel *> *contacts = [[MVRandomGenerator sharedInstance] generateContacts];
    [self insertContacts:contacts withCompletion:^(BOOL success) {
        [[MVFileManager sharedInstance] generateImagesForContacts:contacts];
    }];
    
    NSArray <MVChatModel *> *chats = [[MVRandomGenerator sharedInstance] generateChatsWithContacts:contacts];
    NSArray *allMessages = [NSArray new];
    
    for (MVChatModel *chat in chats) {
        NSArray <MVMessageModel *> *messages = [[MVRandomGenerator sharedInstance] generateMessagesForChat:chat];
        allMessages = [allMessages arrayByAddingObjectsFromArray:messages];
    }
    
    [self insertChats:chats withCompletion:^(BOOL success) {
        [[MVFileManager sharedInstance] generateImagesForChats:chats];
    }];
    
    [self insertMessages:allMessages withCompletion:nil];
}

@end
