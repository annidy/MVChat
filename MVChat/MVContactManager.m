//
//  MVContactManager.m
//  MVChat
//
//  Created by Mark Vasiv on 05/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVContactManager.h"
#import "MVContactModel.h"
#import "MVDatabaseManager.h"
#import "MVRandomGenerator.h"

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
        dispatch_async(self.managerQueue, ^{
            [self generateUserActivity];
        });
    }
    
    return self;
}

- (void)loadContacts {
    [[MVDatabaseManager sharedInstance] allContacts:^(NSArray<MVContactModel *> *allContacts) {
        @synchronized (self.contacts) {
            self.contacts = allContacts;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.updatesListener updateContacts];
        });
    }];
}

- (NSArray <MVContactModel *> *)getAllContacts {
    @synchronized (self.contacts) {
        return self.contacts;
    }
}

- (void)generateUserActivity {
    NSArray *contacts;
    @synchronized (self.contacts) {
        contacts = [self.contacts copy];
    }
    
    for (MVContactModel *contact in contacts) {
        NSDate *lastSeenDate = [[MVRandomGenerator sharedInstance] randomLastSeenDate];
        NSNotification *update = [[NSNotification alloc] initWithName:@"ContactLastSeenTimeUpdate" object:nil userInfo:@{@"Id" : contact.id, @"LastSeenTime" : lastSeenDate}];
        [[NSNotificationCenter defaultCenter] postNotification:update];
        contact.lastSeenDate = lastSeenDate;
    }
    
    NSMutableArray *changedContacts = [NSMutableArray new];
    @synchronized (self.contacts) {
        for (MVContactModel *existingContact in self.contacts) {
            for (MVContactModel *updatedContact in contacts) {
                if ([existingContact.id isEqualToString:updatedContact.id]) {
                    existingContact.lastSeenDate = updatedContact.lastSeenDate;
                    [changedContacts addObject:existingContact];
                }
            }
        }
    }
    
    [[MVDatabaseManager sharedInstance] insertContacts:changedContacts withCompletion:^(BOOL success) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([[MVRandomGenerator sharedInstance] randomUIntegerWithMin:5 andMax:20] * NSEC_PER_SEC)), self.managerQueue, ^{
            [self generateUserActivity];
        });
    }];
}

static MVContactModel *myContact;
+ (MVContactModel *)myContact {
    if (!myContact) {
        myContact = [MVContactModel new];
        myContact.id = @"0";
        myContact.name = @"Mark";
        myContact.iam = YES;
        myContact.status = ContactStatusOnline;
    }
    
    return myContact;
}
@end
