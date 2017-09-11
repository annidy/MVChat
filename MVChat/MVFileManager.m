////
//  MVFileManager.m
//  MVChat
//
//  Created by Mark Vasiv on 15/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVFileManager.h"
#import "MVContactModel.h"
#import "MVChatModel.h"
#import <DBAttachment.h>

#import <CoreImage/CoreImage.h>
#import <CoreText/CoreText.h>

#import "MVRandomGenerator.h"
#import "MVMessageModel.h"
#import <ImageIO/ImageIO.h>
#import "MVChatManager.h"
#import "MVDatabaseManager.h"
#import <ReactiveObjC.h>

@implementation MVAvatarUpdate
- (instancetype)initWithType:(MVAvatarUpdateType)type id:(NSString *)id avatar:(UIImage *)avatar {
    if (self = [super init]) {
        _type = type;
        _id = id;
        _avatar = avatar;
    }
    
    return self;
}
@end

@interface MVFileManager()
@property (strong, nonatomic) dispatch_queue_t managerQueue;
@property (strong, nonatomic) NSCache *imagesCache;
@property (strong, nonatomic) NSMutableDictionary *messageAttachments;
@property (strong, nonatomic) RACSubject *avatarUpdateSubject;
@end

@implementation MVFileManager
#pragma mark - Initialization
static MVFileManager *instance;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [MVFileManager new];
    });
    
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _managerQueue = dispatch_queue_create("com.markvasiv.fileManager", DISPATCH_QUEUE_SERIAL);
        _imagesCache = [NSCache new];
        _messageAttachments = [NSMutableDictionary new];
        _avatarUpdateSubject = [RACSubject subject];
        _avatarUpdateSignal = [_avatarUpdateSubject deliverOnMainThread];
        [self cacheMediaMessages];
    }
    
    return self;
}

#pragma mark - Caching
- (void)cacheMediaMessages {
    dispatch_async(self.managerQueue, ^{
        [[MVDatabaseManager sharedInstance] allChats:^(NSArray <MVChatModel *> *chats) {
            for (MVChatModel *chat in chats) {
                NSString *chatFolder = [self globalPathFromRelative:[self relativePathForMediaMessagesFolder:chat]];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:chatFolder]) {
                    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:chatFolder error:nil];
                    
                    NSMutableArray *attachments = [self.messageAttachments objectForKey:chat.id];
                    if (!attachments) {
                        attachments = [NSMutableArray new];
                        [self.messageAttachments setObject:attachments forKey:chat.id];
                    }
                    
                    for (NSString *file in files) {
                        NSString *fullFilePath = [chatFolder stringByAppendingPathComponent:file];
                        DBAttachment *attachment = [DBAttachment attachmentFromDocumentURL:[NSURL fileURLWithPath:fullFilePath]];
                        [attachments addObject:attachment];
                    }
                }
            }
        }];
    });
}

- (NSArray <DBAttachment *> *)attachmentsForChatWithId:(NSString *)chatId {
    @synchronized (self.messageAttachments) {
        return [self.messageAttachments objectForKey:chatId];
    }
}

#pragma mark - Save Attachments
- (void)saveAttachment:(DBAttachment *)attachment atRelativePath:(NSString *)relativePath completion:(void (^)(DBAttachment *urlAttachment))completion {
    dispatch_async(self.managerQueue, ^{
        [attachment loadOriginalImageWithCompletion:^(UIImage *resultImage) {
            [self writeData:UIImagePNGRepresentation(resultImage) toFileAtRelativePath:relativePath];
            DBAttachment *attachmentFromUrl = [DBAttachment attachmentFromDocumentURL:[self urlToFileAtRelativePath:relativePath]];
            @synchronized (self.imagesCache) {
                [self.imagesCache setObject:attachmentFromUrl forKey:relativePath];
            }
            if (completion) completion(attachmentFromUrl);
        }];
    });
}

- (void)saveChatAvatar:(MVChatModel *)chat attachment:(DBAttachment *)attachment {
    [self saveAttachment:attachment atRelativePath:[self relativePathForChatAvatar:chat] completion:^(DBAttachment *urlAttachment) {
        [attachment originalImageWithCompletion:^(UIImage *resultImage) {
            MVAvatarUpdate *update = [[MVAvatarUpdate alloc] initWithType:MVAvatarUpdateTypeChat id:chat.id avatar:resultImage];
            [self.avatarUpdateSubject sendNext:update];
        }];
    }];
}

- (void)saveContactAvatar:(MVContactModel *)contact attachment:(DBAttachment *)attachment {
    [self saveAttachment:attachment atRelativePath:[self relativePathForContactAvatar:contact] completion:^(DBAttachment *urlAttachment) {
        [attachment originalImageWithCompletion:^(UIImage *resultImage) {
            MVAvatarUpdate *update = [[MVAvatarUpdate alloc] initWithType:MVAvatarUpdateTypeContact id:contact.id avatar:resultImage];
            [self.avatarUpdateSubject sendNext:update];
        }];
    }];
}

- (void)saveMediaMesssage:(MVMessageModel *)message attachment:(DBAttachment *)attachment completion:(void (^)(void))completion {
    [self saveAttachment:attachment atRelativePath:[self relativePathForMediaMessage:message] completion:^(DBAttachment *urlAttachment){
        NSMutableArray *attachments = [self.messageAttachments objectForKey:message.chatId];
        if (!attachments) {
            attachments = [NSMutableArray new];
            [self.messageAttachments setObject:attachments forKey:message.chatId];
        }
        [attachments addObject:urlAttachment];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completion) completion();
        });
    }];
}

#pragma mark - Load Attachments
- (void)loadAttachmentAtRelativePath:(NSString *)relativePath completion:(void (^)(DBAttachment *attachment))completion {
    dispatch_async(self.managerQueue, ^{
        DBAttachment *attachment = [self.imagesCache objectForKey:relativePath];
        if (!attachment) {
            NSURL *fileUrl = [self urlToFileAtRelativePath:relativePath];
            attachment = [DBAttachment attachmentFromDocumentURL:fileUrl];
            [self.imagesCache setObject:attachment forKey:relativePath];
        }
        completion(attachment);
    });
}

- (void)loadAvatarForChat:(MVChatModel *)chat completion:(void (^)(DBAttachment *attachment))completion {
    if (chat.isPeerToPeer) {
        [self loadAttachmentAtRelativePath:[self relativePathForContactAvatar:chat.getPeer] completion:completion];
    } else {
        [self loadAttachmentAtRelativePath:[self relativePathForChatAvatar:chat] completion:completion];
    }
}

- (void)loadAvatarForContact:(MVContactModel *)contact completion:(void (^)(DBAttachment *attachment))completion {
    [self loadAttachmentAtRelativePath:[self relativePathForContactAvatar:contact] completion:completion];
}

- (void)loadAttachmentForMessage:(MVMessageModel *)message completion:(void (^)(DBAttachment *attachment))completion {
    [self loadAttachmentAtRelativePath:[self relativePathForMediaMessage:message] completion:completion];
}

- (void)loadThumbnailAvatarForContact:(MVContactModel *)contact maxWidth:(CGFloat)maxWidth completion:(void (^)(UIImage *image))completion {
    [self loadAvatarForContact:contact completion:^(DBAttachment *attachment) {
        [attachment thumbnailImageWithMaxWidth:maxWidth completion:completion];
    }];
}

- (void)loadThumbnailAvatarForChat:(MVChatModel *)chat maxWidth:(CGFloat)maxWidth completion:(void (^)(UIImage *image))completion {
    [self loadAvatarForChat:chat completion:^(DBAttachment *attachment) {
        [attachment thumbnailImageWithMaxWidth:maxWidth completion:completion];
    }];
}

- (void)loadThumbnailAttachmentForMessage:(MVMessageModel *)message maxWidth:(CGFloat)maxWidth completion:(void (^)(UIImage *image))completion {
    [self loadAttachmentForMessage:message completion:^(DBAttachment *attachment) {
        [attachment thumbnailImageWithMaxWidth:maxWidth completion:completion];
    }];
}

- (void)loadOriginalAttachmentForMessage:(MVMessageModel *)message completion:(void (^)(UIImage *image))completion {
    [self loadAttachmentForMessage:message completion:^(DBAttachment *attachment) {
        [attachment originalImageWithCompletion:completion];
    }];
}

#pragma mark - Generating images
- (void)generateAvatarsForChats:(NSArray <MVChatModel *> *)chats {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (MVChatModel *chat in chats) {
            if (chat.isPeerToPeer) {
                continue;
            }
            NSString *letter = [[chat.title substringToIndex:1] uppercaseString];
            UIImage *image = [self generateGradientImageForLetter:letter];
            DBAttachment *attachment = [DBAttachment attachmentFromCameraImage:image];
            [self saveChatAvatar:chat attachment:attachment];
        }
    });
}

- (void)generateAvatarsForContacts:(NSArray <MVContactModel *> *)contacts {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (MVContactModel *contact in contacts) {
            NSString *letter = [[contact.name substringToIndex:1] uppercaseString];
            UIImage *image = [self generateGradientImageForLetter:letter];
            DBAttachment *attachment = [DBAttachment attachmentFromCameraImage:image];
            [self saveContactAvatar:contact attachment:attachment];
        }
    });
}

- (UIImage *)generateGradientImageForLetter:(NSString *)letter {
    CGFloat imageScale = 1;
    CGFloat width = (CGFloat)180.0;
    CGFloat height = (CGFloat)180.0;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, width * imageScale, height * imageScale, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    
    NSArray <UIColor *> *uiColors = [[MVRandomGenerator sharedInstance] randomGradientColors];
    NSArray *colors = @[(__bridge id)uiColors[0].CGColor, (__bridge id)uiColors[1].CGColor];
    CGFloat locations[] = {0.0, 0.7};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
    
    CGColorSpaceRelease(colorSpace);
    
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointMake(180, 180);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
    CGGradientRelease(gradient);
    
    CTFontRef font = CTFontCreateWithName((CFStringRef)@"HelveticaNeue-Light", 100, NULL);
    CFStringRef string = (__bridge CFStringRef)letter;
    
    CFStringRef keys[] = {kCTFontAttributeName, kCTForegroundColorAttributeName};
    CFTypeRef values[] = {font, [UIColor whiteColor].CGColor};
    
    CFDictionaryRef attributes = CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys, (const void**)&values, sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFAttributedStringRef attrString = CFAttributedStringCreate(kCFAllocatorDefault, string, attributes);
    
    CTLineRef line = CTLineCreateWithAttributedString(attrString);
    
    CGRect bounds = CTLineGetBoundsWithOptions(line, kCTLineBoundsUseGlyphPathBounds);
    
    CGContextSetTextPosition(context, (180 - bounds.size.width)/2 - bounds.origin.x, (180 - bounds.size.height)/2 - bounds.origin.y);
    CTLineDraw(line, context);
    
    
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    CFRelease(font);
    CFRelease(attributes);
    CFRelease(attrString);
    CFRelease(line);
    
    UIImage *image =  [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return image;
}

#pragma Heleprs
- (CGSize)sizeOfAttachmentForMessage:(MVMessageModel *)message {
    return [self sizeOfImageAtURL:[self urlToFileAtRelativePath:[self relativePathForMediaMessage:message]]];
}

- (CGSize)sizeOfImageAtURL:(NSURL *)imageURL {
    CGSize imageSize = CGSizeZero;
    CGImageSourceRef source = CGImageSourceCreateWithURL((CFURLRef)imageURL, NULL);
    if (source) {
        NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCGImageSourceShouldCache];
        CFDictionaryRef cfproperties = CGImageSourceCopyPropertiesAtIndex(source, 0, (CFDictionaryRef)options);
        
        if (cfproperties) {
            NSDictionary *properties = (__bridge NSDictionary *)cfproperties;
            NSNumber *width = [properties objectForKey:(NSString *)kCGImagePropertyPixelWidth];
            NSNumber *height = [properties objectForKey:(NSString *)kCGImagePropertyPixelHeight];
            if (width && height) {
                imageSize = CGSizeMake(width.floatValue, height.floatValue);
            }
            CFRelease(cfproperties);
        }
        CFRelease(source);
    }
    
    return imageSize;
}
- (NSString *)documentsPath {
    return [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path];
}

- (NSString *)relativePathForChatAvatar:(MVChatModel *)chat {
    return [[@"chat" stringByAppendingString:chat.id] stringByAppendingPathExtension:@"png"];
}

- (NSString *)relativePathForContactAvatar:(MVContactModel *)contact {
    return [[@"contact" stringByAppendingString:contact.id] stringByAppendingPathExtension:@"png"];
}

- (NSString *)relativePathForMediaMessage:(MVMessageModel *)message {
    return [[message.chatId stringByAppendingPathComponent:message.id] stringByAppendingPathExtension:@"png"];
}

- (NSString *)relativePathForMediaMessagesFolder:(MVChatModel *)chat {
    return chat.id;
}

- (BOOL)writeData:(NSData *)data toFileAtRelativePath:(NSString *)relativePath{
    NSString *path = [self globalPathFromRelative:relativePath];
    [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    return [data writeToFile:path options:NSDataWritingAtomic error:nil];
}

- (NSString *)globalPathFromRelative:(NSString *)relativePath {
    return [[self documentsPath] stringByAppendingPathComponent:relativePath];
}

- (NSURL *)urlToFileAtRelativePath:(NSString *)relativePath {
    return [NSURL fileURLWithPath:[self globalPathFromRelative:relativePath]];
}

- (void)deleteAllFiles {
    dispatch_async(self.managerQueue, ^{
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self documentsPath] error:nil];
        for (NSString *file in files) {
            if ([file containsString:@"yap"]) {
                continue;
            }
            [[NSFileManager defaultManager] removeItemAtPath:[self globalPathFromRelative:file] error:nil];
        }
    });
}

- (void)clearAllCache {
    dispatch_async(self.managerQueue, ^{
        self.messageAttachments = [NSMutableDictionary new];
        self.imagesCache = [NSCache new];
    });
}
@end
