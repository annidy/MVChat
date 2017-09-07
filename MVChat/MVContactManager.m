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
        return [self.contacts copy];
    }
}

- (void)handleContactLastSeenTimeUpdate:(MVContactModel *)contact {
    @synchronized (self.contacts) {
        for (MVContactModel *oldContact in self.contacts) {
            if ([oldContact.id isEqualToString:contact.id]) {
                oldContact.lastSeenDate = contact.lastSeenDate;
                NSNotification *update = [[NSNotification alloc] initWithName:@"ContactLastSeenTimeUpdate" object:nil userInfo:@{@"Id" : contact.id, @"LastSeenTime" : contact.lastSeenDate}];
                [[NSNotificationCenter defaultCenter] postNotification:update];
            }
        }
    }
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

- (void)clearAllCache {
    dispatch_async(self.managerQueue, ^{
        @synchronized (self.contacts) {
            self.contacts = [NSArray new];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.updatesListener updateContacts];
        });
    });
}
@end
