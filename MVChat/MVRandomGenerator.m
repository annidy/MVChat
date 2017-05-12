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

@interface MVRandomGenerator()
//@property (strong, nonatomic) NSMutableArray *contacts;
//@property (strong, nonatomic) NSMutableArray *chats;
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

- (void)generateContacts {
    MVContactModel *contact1 = [[MVContactModel alloc] initWithId:@"0" name:@"Matt" iam:NO status:ContactStatusOffline andAvatarName:nil];
    MVContactModel *contact2 = [[MVContactModel alloc] initWithId:@"1" name:@"Andrew" iam:NO status:ContactStatusOffline andAvatarName:nil];
    MVContactModel *contact3 = [[MVContactModel alloc] initWithId:@"2" name:@"Alex" iam:NO status:ContactStatusOffline andAvatarName:nil];
    MVContactModel *contact4 = [[MVContactModel alloc] initWithId:@"3" name:@"Clark" iam:NO status:ContactStatusOffline andAvatarName:nil];
    MVContactModel *contact5 = [[MVContactModel alloc] initWithId:@"4" name:@"Rob" iam:NO status:ContactStatusOffline andAvatarName:nil];
    MVContactModel *contact6 = [[MVContactModel alloc] initWithId:@"5" name:@"Adam" iam:NO status:ContactStatusOffline andAvatarName:nil];
    MVContactModel *contact7 = [[MVContactModel alloc] initWithId:@"6" name:@"Lucie" iam:NO status:ContactStatusOffline andAvatarName:nil];
    
    self.contacts = [NSMutableArray arrayWithCapacity:7];
    [self.contacts addObject:contact1];
    [self.contacts addObject:contact2];
    [self.contacts addObject:contact3];
    [self.contacts addObject:contact4];
    [self.contacts addObject:contact5];
    [self.contacts addObject:contact6];
    [self.contacts addObject:contact7];
}

- (void)generateChats {
    MVChatModel *chat1 = [[MVChatModel alloc] initWithId:@"0" andTitle:@"Work chat"];
    chat1.participants = [self getRandomContactsWithCount:2 withMe:YES];
    chat1.lastUpdateDate = [NSDate new];
    
    MVChatModel *chat2 = [[MVChatModel alloc] initWithId:@"1" andTitle:@"Design"];
    chat2.participants = [self getRandomContactsWithCount:3 withMe:YES];
    chat2.lastUpdateDate = [NSDate new];
    
    MVChatModel *chat3 = [[MVChatModel alloc] initWithId:@"2" andTitle:@"Dev"];
    chat3.participants = [self getRandomContactsWithCount:4 withMe:YES];
    chat3.lastUpdateDate = [NSDate new];
    
    
    MVChatModel *chat4 = [[MVChatModel alloc] initWithId:@"3" andTitle:@"Friday"];
    chat4.participants = [self getRandomContactsWithCount:3 withMe:YES];
    chat4.lastUpdateDate = [NSDate new];
    
    
    MVChatModel *chat5 = [[MVChatModel alloc] initWithId:@"4" andTitle:@"Cool stuff"];
    chat5.participants = [self getRandomContactsWithCount:5 withMe:YES];
    chat5.lastUpdateDate = [NSDate new];
    
    
    MVChatModel *chat6 = [[MVChatModel alloc] initWithId:@"5" andTitle:@"Yoyoyoy"];
    chat6.participants = [self getRandomContactsWithCount:1 withMe:YES];
    chat6.lastUpdateDate = [NSDate new];
    
    self.chats = [NSMutableArray new];
    [self.chats addObject:chat1];
    [self.chats addObject:chat2];
    [self.chats addObject:chat3];
    [self.chats addObject:chat4];
    [self.chats addObject:chat5];
    [self.chats addObject:chat6];
    
    [self.updatesListener updateWithType:MVUpdateTypeChats andObjects:[self.chats copy]];
}


- (MVContactModel *)getMe {
    return [[MVContactModel alloc] initWithId:@"7" name:@"Mark" iam:YES status:ContactStatusOnline andAvatarName:nil];
}

- (NSArray *)getRandomContactsWithCount:(NSInteger)count withMe:(bool)withMe {
    NSMutableSet *contacts = [NSMutableSet new];
    while (contacts.count < count) {
        [contacts addObject:self.contacts[[self getRandomIndexWithMax:self.contacts.count - 1]]];
    }
    
    if (withMe) {
        [contacts addObject:[self getMe]];
    }
    
    return [contacts allObjects];
}

- (NSInteger)getRandomIndexWithMax:(NSInteger)max {
    return (NSInteger) arc4random_uniform((int)max);
}

@end
