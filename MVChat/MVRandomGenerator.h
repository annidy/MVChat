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

typedef enum : NSUInteger {
    MVUpdateTypeChats,
    MVUpdateTypeMessages
} MVUpdateType;

@protocol AppListener
- (void)updateWithType:(MVUpdateType)type andObjects:(NSArray *)objects;
@end

@interface MVRandomGenerator : NSObject
@property (weak, nonatomic) id <AppListener> updatesListener;
+(instancetype)sharedInstance;
- (NSArray <MVContactModel *> *)generateContacts;
- (NSArray <MVChatModel *> *)generateChatsWithContacts:(NSArray<MVContactModel *> *)contacts;

- (NSUInteger)randomUIntegerWithMin:(NSUInteger)min andMax:(NSUInteger)max;
@end
