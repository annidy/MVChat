//
//  MVFileManager.h
//  MVChat
//
//  Created by Mark Vasiv on 15/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//


#import <UIKit/UIKit.h>
@class MVChatModel;
@class MVContactModel;
@class DBAttachment;
@class MVMessageModel;

@interface MVFileManager : NSObject
+ (instancetype)sharedInstance;
- (void)saveAttachment:(DBAttachment *)attachment asChatAvatar:(MVChatModel *)chat;
- (void)saveAttachment:(DBAttachment *)attachment asContactAvatar:(MVContactModel *)contact;
- (void)saveAttachment:(DBAttachment *)attachment asMessage:(MVMessageModel *)message completion:(void (^)(void))completion;
- (void)loadAvatarAttachmentForChat:(MVChatModel *)chat completion:(void (^)(DBAttachment *attachment))completion;
- (void)loadAvatarAttachmentForContact:(MVContactModel *)contact completion:(void (^)(DBAttachment *attachment))completion;
- (void)loadAttachmentForMessage:(MVMessageModel *)message completion:(void (^)(DBAttachment *attachment))completion;
- (void)generateImagesForChats:(NSArray <MVChatModel *> *)chats;
- (void)generateImagesForContacts:(NSArray <MVContactModel *> *)contacts;
- (CGSize)sizeOfAttachmentForMessage:(MVMessageModel *)message;
@end
