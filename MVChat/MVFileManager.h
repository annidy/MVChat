//
//  MVFileManager.h
//  MVChat
//
//  Created by Mark Vasiv on 15/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//


#import <UIKit/UIKit.h>
@class MVContactModel;
@class MVChatModel;
@class MVMessageModel;
@class DBAttachment;
@class RACSignal;

typedef enum : NSUInteger {
    MVAvatarUpdateTypeContact,
    MVAvatarUpdateTypeChat,
} MVAvatarUpdateType;

@interface MVAvatarUpdate : NSObject
@property (assign, nonatomic) MVAvatarUpdateType type;
@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) UIImage *avatar;
- (instancetype)initWithType:(MVAvatarUpdateType)type id:(NSString *)id avatar:(UIImage *)avatar;
@end

@interface MVFileManager : NSObject
#pragma mark - Initialization
+ (instancetype)sharedInstance;

#pragma mark - Signals
@property (strong, nonatomic) RACSignal *avatarUpdateSignal;

#pragma mark - Caching
- (NSArray <DBAttachment *> *)attachmentsForChatWithId:(NSString *)chatId;

#pragma mark - Save Attachments
- (void)saveChatAvatar:(MVChatModel *)chat attachment:(DBAttachment *)attachment;
- (void)saveContactAvatar:(MVContactModel *)contact attachment:(DBAttachment *)attachment;
- (void)saveMediaMesssage:(MVMessageModel *)message attachment:(DBAttachment *)attachment completion:(void (^)(void))completion;

#pragma mark - Load Attachments
- (void)loadThumbnailAvatarForContact:(MVContactModel *)contact maxWidth:(CGFloat)maxWidth completion:(void (^)(UIImage *image))completion;
- (void)loadThumbnailAvatarForChat:(MVChatModel *)chat maxWidth:(CGFloat)maxWidth completion:(void (^)(UIImage *image))completion;
- (void)loadThumbnailAttachmentForMessage:(MVMessageModel *)message maxWidth:(CGFloat)maxWidth completion:(void (^)(UIImage *image))completion;
- (void)loadOriginalAttachmentForMessage:(MVMessageModel *)message completion:(void (^)(UIImage *image))completion;
- (void)loadAttachmentForMessage:(MVMessageModel *)message completion:(void (^)(DBAttachment *attachment))completion;

#pragma mark - Generating images
- (void)generateAvatarsForChats:(NSArray <MVChatModel *> *)chats;
- (void)generateAvatarsForContacts:(NSArray <MVContactModel *> *)contacts;

#pragma mark - Helpers
- (CGSize)sizeOfAttachmentForMessage:(MVMessageModel *)message;
+ (NSString *)documentsPath;
- (void)deleteAllFiles;
- (void)clearAllCache;
@end
