//
//  MVContactManager.h
//  MVChat
//
//  Created by Mark Vasiv on 05/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MVContactsListener.h"

@class MVContactModel;
@class RACSignal;

@interface MVContactManager : NSObject
@property (weak, nonatomic) id <MVContactsUpdatesListener> updatesListener;
@property (strong, nonatomic) RACSignal *lastSeenTimeSignal;

+ (instancetype)sharedInstance;
- (void)loadContacts;
- (NSArray <MVContactModel *> *)getAllContacts;
+ (MVContactModel *)myContact;
- (void)handleContactLastSeenTimeUpdate:(MVContactModel *)contact;
- (void)clearAllCache;
@end
