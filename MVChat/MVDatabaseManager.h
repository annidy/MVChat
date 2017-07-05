//
//  MVDatabaseManager.h
//  MVChat
//
//  Created by Mark Vasiv on 30/06/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MVContactModel;
@class MVChatModel;

@interface MVDatabaseManager : NSObject
- (NSArray <MVContactModel *> *)allContacts;
- (NSArray <MVChatModel *> *)allChats;
- (BOOL)insertContact:(MVContactModel *)contact;
- (BOOL)insertChat:(MVChatModel *)chat;
- (MVContactModel *)contactWithId:(NSString *)id;
- (MVChatModel *)chatWithId:(NSString *)id;
- (MVContactModel *)myContact;

- (void)generateData;
@end
