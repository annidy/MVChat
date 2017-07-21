//
//  MVRandomGenerator.m
//  MVChat
//
//  Created by Mark Vasiv on 12/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVRandomGenerator.h"
#import "MVChatModel.h"
#import "MVContactModel.h"
#import "MVMessageModel.h"
#import "MVJsonHelper.h"
#import "MVNameGenerator.h"
#import "MVTextGenerator.h"
#import "MVDatabaseManager.h"
#import <UIKit/UIKit.h>

static NSUInteger minContactsCount = 20;
static NSUInteger maxContactsCount = 50;
static NSUInteger minChatsCount = 20;
static NSUInteger maxChatsCount = 50;
static NSUInteger minMessagesCount = 30;
static NSUInteger maxMessagesCount = 70;

@interface MVRandomGenerator()
@property (strong, nonatomic) NSCache *generatorsCache;
@end

@implementation MVRandomGenerator
static MVRandomGenerator *singleton;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [MVRandomGenerator new];
    });
    
    return singleton;
}

- (instancetype)init {
    if (self = [super init]) {
        _generatorsCache = [NSCache new];
    }
    
    return self;
}

#pragma mark - Cache
- (MVNameGenerator *)nameGenerator {
    if (![self.generatorsCache objectForKey:@"name"]) {
        [self.generatorsCache setObject:[MVNameGenerator new] forKey:@"name"];
    }
    
    return (MVNameGenerator *)[self.generatorsCache objectForKey:@"name"];
}

- (MVTextGenerator *)textGenerator {
    if (![self.generatorsCache objectForKey:@"text"]) {
        [self.generatorsCache setObject:[MVTextGenerator new] forKey:@"text"];
    }
    
    return (MVTextGenerator *)[self.generatorsCache objectForKey:@"text"];
}

#pragma mark - Randoms
- (NSUInteger)randomUIntegerWithMin:(NSUInteger)min andMax:(NSUInteger)max {
    NSAssert(max > min, @"max must be > than min");
    return min + (NSUInteger) arc4random_uniform((uint32_t)(max - min + 1));
}

- (NSDate *)randomDateAfter:(NSDate *)afterDate {
    __block NSDate *date = [NSDate new];
    
    void (^generate)() = ^void() {
        double time = arc4random_uniform(5000000);
        date = [date dateByAddingTimeInterval:-time];
    };
    
    generate();
    
    
    if (afterDate) {
        while (date.timeIntervalSinceReferenceDate < afterDate.timeIntervalSinceReferenceDate) {
            generate();
        }
    }
    
    return date;
}

- (NSString *)randomUserName {
    return [[self nameGenerator] getName];
}

- (NSString *)randomChatTitle {
    return [[self textGenerator] words:[self randomUIntegerWithMin:1 andMax:3]];
}

- (NSString *)randomAvatarName {
    return [NSString stringWithFormat:@"avatar0%lu", (unsigned long)[self randomUIntegerWithMin:1 andMax:5]];
}

- (MVContactModel *)randomContact {
    return [[MVContactModel alloc] initWithId:nil name:[self randomUserName] iam:NO status:ContactStatusOffline andAvatarName:[self randomAvatarName]];
}

- (MVContactModel *)randomContactFromArray:(NSArray *)contacts {
    return contacts[[self randomUIntegerWithMin:0 andMax:contacts.count - 1]];
}

- (MVChatModel *)randomChatWithContacts:(NSArray <MVContactModel *> *)contacts {
    MVChatModel *chat = [[MVChatModel alloc] initWithId:nil andTitle:[self randomChatTitle]];
    NSMutableArray *chatContacts = [NSMutableArray new];
    NSMutableSet *indices = [NSMutableSet new];
    for (int i = 0; i < [self randomUIntegerWithMin:1 andMax:contacts.count]; i++) {
        NSUInteger index;
        do {
            index = [self randomUIntegerWithMin:0 andMax:contacts.count - 1];
        }
        while ([indices containsObject:@(index)]);
        
        [indices addObject:@(index)];
        [chatContacts addObject:contacts[index]];
    }
    [chatContacts addObject:[[MVDatabaseManager sharedInstance] myContact]];
    chat.participants = [chatContacts copy];
    
    return chat;
}

- (UIColor *)randomColor {
    return [UIColor colorWithRed:(CGFloat)[self randomUIntegerWithMin:0 andMax:255]/255 green:(CGFloat)[self randomUIntegerWithMin:0 andMax:255]/255 blue:(CGFloat)[self randomUIntegerWithMin:0 andMax:255]/255 alpha:1];
}

- (MVMessageModel *)randomMessageWithChatId:(NSString *)chatId sender:(MVContactModel *)sender afterDate:(NSDate *)date {
    MVMessageModel *message = [MVMessageModel new];
    message.chatId = chatId;
    message.text = [[self textGenerator] sentences:[self randomUIntegerWithMin:1 andMax:5]];
    message.contact = sender;
    
    if ([sender.id isEqualToString:[[MVDatabaseManager new] myContact].id]) {
        message.direction = MessageDirectionOutgoing;
    } else {
        message.direction = MessageDirectionIncoming;
    }
    message.sendDate = [self randomDateAfter:date];
    
    return message;
}

#pragma mark - Generators
- (NSArray <MVContactModel *> *)generateContacts {
    return [self generateContactsWithCount:[self randomUIntegerWithMin:minContactsCount andMax:maxContactsCount]];
}

- (NSArray <MVContactModel *> *)generateContactsWithCount:(NSUInteger)count {
    NSMutableArray *contacts = [NSMutableArray new];
    for (int i = 0; i<count; i++) {
        [contacts addObject:[self randomContact]];
    }
    return [contacts copy];
}

- (NSArray <MVChatModel *> *)generateChatsWithCount:(NSUInteger)count andContacts:(NSArray<MVContactModel *> *)contacts {
    NSMutableArray *chats = [NSMutableArray new];
    for (int i = 0; i<count; i++) {
        [chats addObject:[self randomChatWithContacts:contacts]];
    }
    
    return [chats copy];
}

- (NSArray <MVChatModel *> *)generateChatsWithContacts:(NSArray<MVContactModel *> *)contacts {
    return [self generateChatsWithCount:[self randomUIntegerWithMin:minChatsCount andMax:maxChatsCount] andContacts:contacts];
}

- (NSArray <MVMessageModel *> *)generateMessagesForChat:(MVChatModel *)chat {
    NSMutableArray *messages = [NSMutableArray new];
    
    NSDate *lastMessageDate = [[NSDate new] dateByAddingTimeInterval:-10000000];
    for (int i = 0; i < [self randomUIntegerWithMin:minMessagesCount andMax:maxMessagesCount]; i++) {
        MVMessageModel *message = [self randomMessageWithChatId:chat.id sender:[self randomContactFromArray:chat.participants] afterDate:nil];
        lastMessageDate = message.sendDate;
        [messages addObject:message];
    }
    
    return messages;
}

@end
