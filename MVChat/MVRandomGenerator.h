//
//  MVRandomGenerator.h
//  MVChat
//
//  Created by Mark Vasiv on 12/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MVContactModel;
@class MVChatModel;
@class MVMessageModel;
@class UIColor;


@interface MVRandomGenerator : NSObject
+ (instancetype)sharedInstance;
- (NSArray <MVContactModel *> *)generateContacts;
- (NSArray <MVChatModel *> *)generateChatsWithContacts:(NSArray<MVContactModel *> *)contacts;
- (NSArray <MVMessageModel *> *)generateMessagesForChat:(MVChatModel *)chat;
- (MVMessageModel *)randomIncomingMessageWithChat:(MVChatModel *)chat;
- (MVMessageModel *)randomMessageWithChat:(MVChatModel *)chat;
- (NSUInteger)randomUIntegerWithMin:(NSUInteger)min andMax:(NSUInteger)max;
- (UIColor *)randomColor;
- (NSArray <UIColor *> *)randomGradientColors;
- (NSDate *)randomLastSeenDate;
- (NSArray <MVChatModel *> *)generateChatsWithCount:(NSUInteger)count andContacts:(NSArray<MVContactModel *> *)contacts;
@end
