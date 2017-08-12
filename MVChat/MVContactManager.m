//
//  MVContactManager.m
//  MVChat
//
//  Created by Mark Vasiv on 05/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVContactManager.h"
#import "MVContactModel.h"
#import "MVJsonHelper.h"
#import "MVDatabaseManager.h"

@interface MVContactManager()
@property (strong, nonatomic) dispatch_queue_t managerQueue;
@property (strong, nonatomic) NSArray <MVContactModel *> *contacts;

@end
@implementation MVContactManager


+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static MVContactManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [MVContactManager new];
    });
    
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _managerQueue = dispatch_queue_create("com.markvasiv.contactsManager", DISPATCH_QUEUE_SERIAL);
        _contacts = [NSArray new];
    }
    
    return self;
}

- (void)loadContacts {
    [[MVDatabaseManager sharedInstance] allContacts:^(NSArray<MVContactModel *> *allContacts) {
        NSMutableArray *sortedContacts = [allContacts mutableCopy];
        [self sortContacts:sortedContacts];
        
        @synchronized (self.contacts) {
            self.contacts = [sortedContacts copy];
        }
        
        [self.updatesListener handleContactsUpdate];
    }];
}

- (NSArray <MVContactModel *> *)getAllContacts {
    @synchronized (self.contacts) {
        return self.contacts;
    }
}

- (void)sortContacts:(NSMutableArray *)contacts {
    [contacts sortUsingComparator:^NSComparisonResult(MVContactModel *contact1, MVContactModel *contact2) {
        NSString *first = [[contact1.name substringToIndex:1] uppercaseString];
        NSString *second = [[contact2.name substringToIndex:1] uppercaseString];
        
        return [first compare:second];
    }];
}

+ (UIImage *)avatarForContact:(MVContactModel *)contact {
    UIImage *avatar = [UIImage imageNamed:contact.avatarName];;
    if (!avatar) {
        NSData *imgData = [MVJsonHelper dataFromFileWithName:[@"contact" stringByAppendingString:contact.id] extenssion:@"png"];
        avatar = [UIImage imageWithData:imgData];
    }
    
    return avatar;
}

//Legacy
+ (void)startSendingStatusUpdates {
    NSNotification *status = [[NSNotification alloc] initWithName:@"ContactStatusUpdate" object:nil userInfo:@{@"Id" : [self getRandomContactId], @"Status" : @([self getRandomStatus])}];
    [[NSNotificationCenter defaultCenter] postNotification:status];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([self getRandomDelay] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startSendingStatusUpdates];
    });
}

+ (void)startSendingAvatarUpdates {
    NSNotification *status = [[NSNotification alloc] initWithName:@"ContactAvatarUpdate" object:nil userInfo:@{@"Id" : [self getRandomContactId], @"Avatar" : [self getRandomAvatarName]}];
    [[NSNotificationCenter defaultCenter] postNotification:status];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([self getRandomDelay] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startSendingAvatarUpdates];
    });
}

+ (ContactStatus)getRandomStatus {
    int value = arc4random_uniform(2);
    return (ContactStatus)value;
}

+ (NSString *)getRandomContactId {
    int value = arc4random_uniform(2);
    return [NSString stringWithFormat:@"%d", value];
}

+ (int)getRandomDelay {
    return arc4random_uniform(10);
}

+ (NSString *)getRandomAvatarName {
    int value = arc4random_uniform(5);
    return [NSString stringWithFormat:@"avatar0%d", value+1];
}

- (void) readJson {
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:@""];
    NSArray *contacts = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
}
@end
