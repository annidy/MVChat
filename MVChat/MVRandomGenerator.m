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
- (BOOL)randomBool {
    return (BOOL)[self randomUIntegerWithMin:0 andMax:1];
}

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

- (NSDate *)randomDateDuringLast:(NSTimeInterval)timeInterval {
    NSDate *date = [NSDate new];
    
    double time = arc4random_uniform(timeInterval);
    date = [date dateByAddingTimeInterval:-time];
    
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

- (NSDate *)randomLastSeenDate {
    if ([self randomBool]) {
        return [self randomDateDuringLast:10000];
    } else {
        return [NSDate new];
    }
}

- (NSString *)randomPhoneNumber {
    NSMutableString *number = [NSMutableString new];
    NSUInteger firstDigit = [self randomUIntegerWithMin:1 andMax:9];
    [number appendString:[NSString stringWithFormat:@"%lu", (unsigned long)firstDigit]];
    for (int i = 0; i < [self randomUIntegerWithMin:10 andMax:12]; i++) {
        NSUInteger digit = [self randomUIntegerWithMin:0 andMax:9];
        [number appendString:[NSString stringWithFormat:@"%lu", (unsigned long)digit]];
    }
    
    return [@"+" stringByAppendingString:number];
}

- (MVContactModel *)randomContact {
    MVContactModel *contact = [[MVContactModel alloc] initWithId:nil name:[self randomUserName] iam:NO status:ContactStatusOffline andAvatarName:nil];
    NSMutableArray *phoneNumbers = [NSMutableArray new];
    for (int i = 0; i < [self randomUIntegerWithMin:1 andMax:3]; i++) {
        [phoneNumbers addObject:[self randomPhoneNumber]];
    }
    contact.phoneNumbers = [phoneNumbers copy];
    contact.lastSeenDate = [self randomLastSeenDate];
    contact.id = [NSUUID UUID].UUIDString;
    
    return contact;
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
    
    if (chat.isPeerToPeer) {
        chat.title = @"";
    }
    
    chat.id = [NSUUID UUID].UUIDString;
    
    return chat;
}

- (UIColor *)randomColor {
    return [UIColor colorWithRed:(CGFloat)[self randomUIntegerWithMin:0 andMax:255]/255 green:(CGFloat)[self randomUIntegerWithMin:0 andMax:255]/255 blue:(CGFloat)[self randomUIntegerWithMin:0 andMax:255]/255 alpha:1];
}

- (NSArray <UIColor *> *)randomGradientColors {
    NSArray *gradients = @[@"#ff9a9e → #fad0c4", @"#ffecd2 → #fcb69f", @"#ff9a9e → #fecfef", @"#a1c4fd → #c2e9fb", @"#cfd9df → #e2ebf0", @"#f5f7fa → #c3cfe2", @"#667eea → #764ba2", @"#fdfcfb → #e2d1c3", @"#89f7fe → #66a6ff", @"#48c6ef → #6f86d6", @"#feada6 → #f5efef", @"#a3bded → #6991c7", @"#13547a → #80d0c7", @"#ff758c → #ff7eb3", @"#c79081 → #dfa579", @"#96deda → #50c9c3", @"#ee9ca7 → #ffdde1", @"#ffc3a0 → #ffafbd", @"#B7F8DB → #50A7C2"];
    
    NSUInteger index = [self randomUIntegerWithMin:0 andMax:gradients.count - 1];
    NSString *gradientString = gradients[index];
    NSArray *hexStrings = [gradientString componentsSeparatedByString:@" → "];
    NSMutableArray *colors = [NSMutableArray new];
    for (NSString *hexString in hexStrings) {
        [colors addObject:[self colorFromHexString:hexString]];
    }
    
    return [colors copy];
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (MVMessageModel *)randomIncomingMessageWithChat:(MVChatModel *)chat {
    NSMutableArray *otherParticipants = [chat.participants mutableCopy];
    MVContactModel *myContact;
    for (MVContactModel *contact in otherParticipants) {
        if ([contact.id isEqualToString:[MVDatabaseManager sharedInstance].myContact.id]) {
            myContact = contact;
            break;
        }
    }
    
    if (myContact) {
        [otherParticipants removeObject:myContact];
    }
    
    return [self randomMessageWithChatId:chat.id sender:[self randomContactFromArray:otherParticipants] afterDate:nil];
}

- (MVMessageModel *)randomMessageWithChat:(MVChatModel *)chat {
    return [self randomMessageWithChatId:chat.id sender:[self randomContactFromArray:chat.participants] afterDate:nil];
}

- (MVMessageModel *)randomMessageWithChatId:(NSString *)chatId sender:(MVContactModel *)sender afterDate:(NSDate *)date {
    MVMessageModel *message = [MVMessageModel new];
    message.chatId = chatId;
    message.text = [[self textGenerator] sentences:[self randomUIntegerWithMin:1 andMax:5]];
    message.contact = sender;
    message.type = MVMessageTypeText;
    message.id = [NSUUID UUID].UUIDString;
    
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
        MVMessageModel *message = [self randomMessageWithChat:chat];
        message.chatId = chat.id;
        lastMessageDate = message.sendDate;
        [messages addObject:message];
    }
    
    return messages;
}

@end
