//
//  MVContactManager.h
//  MVChat
//
//  Created by Mark Vasiv on 05/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MVContactModel;

@protocol MVContactsUpdatesListener <NSObject>
- (void)handleContactsUpdate;
@end

@interface MVContactManager : NSObject
@property (weak, nonatomic) id <MVContactsUpdatesListener> updatesListener;
+ (instancetype)sharedInstance;
- (void)loadContacts;
- (NSArray <MVContactModel *> *)getAllContacts;
+ (MVContactModel *)myContact;
@end
