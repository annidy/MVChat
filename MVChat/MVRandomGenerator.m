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

static NSUInteger minContactsCount = 20;
static NSUInteger maxContactsCount = 50;
static NSUInteger minChatsCount = 20;
static NSUInteger maxChatsCount = 50;

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
    return min + (NSUInteger) arc4random_uniform((uint32_t)(max - min));
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
    chat.participants = [chatContacts copy];
    
    return chat;
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


#pragma mark - Obsolete
/*
- (void)generateMessages {
    self.messages = [NSMutableDictionary new];
    
    for (MVChatModel *chat in self.chats) {
        NSMutableArray *messages = [NSMutableArray new];
        for (int i = 0; i < [self randomIndexWithMax:100] + 1; i++) {
            MVMessageModel *message = [MVMessageModel new];
            message.id = [self randomString];
            message.chatId = chat.id;
            message.text = [self randomString];
            message.sendDate = [self randomDate];
            message.contact = self.contacts[[self randomIndexWithMax:self.contacts.count]];
            
            if ([self randomBool]) {
                message.direction = MessageDirectionIncoming;
            } else {
                message.direction = MessageDirectionOutgoing;
            }
            
            [messages addObject:message];
        }
        [self.messages setObject:messages forKey:chat.id];
    }
    
    for (NSArray *messages in self.messages.allValues) {
        [self.updatesListener updateWithType:MVUpdateTypeMessages andObjects:messages];
    }
}

- (MVContactModel *)getMe {
    return [[MVContactModel alloc] initWithId:@"7" name:@"Mark" iam:YES status:ContactStatusOnline andAvatarName:nil];
}

- (NSArray *)getRandomContactsWithCount:(NSInteger)count withMe:(bool)withMe {
    NSMutableSet *contacts = [NSMutableSet new];
    while (contacts.count < count) {
        [contacts addObject:self.contacts[[self randomIndexWithMax:self.contacts.count - 1]]];
    }
    
    if (withMe) {
        [contacts addObject:[self getMe]];
    }
    
    return [contacts allObjects];
}

- (NSInteger)randomIndexWithMax:(NSInteger)max {
    return (NSInteger) arc4random_uniform((int)max);
}

static char *letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

- (NSString *)randomString {
    NSUInteger length = arc4random_uniform(50);
    NSMutableString *randomString = [NSMutableString stringWithCapacity: length];
    
    for (int i = 0; i < length; i++) {
        [randomString appendFormat: @"%c", letters[arc4random_uniform((int)strlen(letters))]];
    }
    
    return randomString;
}

- (NSDate *)randomDate {
    NSDate *date = [NSDate new];
    double time = arc4random_uniform(5000000);
    
    return [date dateByAddingTimeInterval:-time];
}

- (BOOL)randomBool {
    return arc4random_uniform(50) % 2;
}
 */

@end
