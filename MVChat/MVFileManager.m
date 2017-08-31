////
//  MVFileManager.m
//  MVChat
//
//  Created by Mark Vasiv on 15/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVFileManager.h"
#import "MVJsonHelper.h"
#import "MVContactModel.h"
#import "MVChatModel.h"
#import <DBAttachment.h>

#import <CoreImage/CoreImage.h>
#import <CoreText/CoreText.h>

#import "MVRandomGenerator.h"
#import "MVMessageModel.h"
#import <ImageIO/ImageIO.h>
#import "MVChatManager.h"

@interface MVFileManager()
@property (strong, nonatomic) dispatch_queue_t managerQueue;
@property (strong, nonatomic) NSCache *imagesCache;
@property (strong, nonatomic) NSMutableDictionary *messageAttachments;
@end

@implementation MVFileManager
#pragma mark - Lifecycle
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
        [self cacheMessageAttachments];
    }
    
    return self;
}

#pragma mark - Saving images
//TODO: IMPROVE CAHCE (cache url attachments)
- (void)saveAttachment:(DBAttachment *)attachment withFileName:(NSString *)fileName directory:(NSString *)directory completion:(void (^)(void))completion {
    dispatch_async(self.managerQueue, ^{
        NSString *fullPath;
        if (directory) {
            fullPath = [directory stringByAppendingPathComponent:fileName];
        } else {
            fullPath = fileName;
        }
        [attachment loadOriginalImageWithCompletion:^(UIImage *resultImage) {
            [MVJsonHelper writeData:UIImagePNGRepresentation(resultImage) toFileWithName:fullPath extenssion:@"png"];
            if (completion) {
                completion();
            }
        }];
        
        [self.imagesCache setObject:attachment forKey:fileName];
    });
}

- (void)saveAttachment:(DBAttachment *)attachment asChatAvatar:(MVChatModel *)chat {
    [self saveAttachment:attachment withFileName:[@"chat" stringByAppendingString:chat.id] directory:nil completion:nil];
    NSNotification *notification = [[NSNotification alloc] initWithName:@"ChatAvatarUpdate" object:nil userInfo:@{@"Id" : chat.id, @"Image" : [attachment loadOriginalImageSync]}];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)saveAttachment:(DBAttachment *)attachment asContactAvatar:(MVContactModel *)contact {
    [self saveAttachment:attachment withFileName:[@"contact" stringByAppendingString:contact.id] directory:nil completion:nil];
    NSNotification *notification = [[NSNotification alloc] initWithName:@"ContactAvatarUpdate" object:nil userInfo:@{@"Id" : contact.id, @"Image" : [attachment loadOriginalImageSync]}];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)saveAttachment:(DBAttachment *)attachment asMessage:(MVMessageModel *)message completion:(void (^)(void))completion {
    [self saveAttachment:attachment withFileName:message.id directory:message.chatId completion:completion];
    @synchronized (self.messageAttachments) {
        NSMutableArray *attachments = [self.messageAttachments objectForKey:message.chatId];
        if (!attachments) {
            attachments = [NSMutableArray new];
            [self.messageAttachments setObject:attachments forKey:message.chatId];
        }
        [attachments addObject:attachment];
    }
}

#pragma mark - Loading images
- (void)loadAttachmentForFileNamed:(NSString *)fileName completion:(void (^)(DBAttachment *attachment))completion {
    dispatch_async(self.managerQueue, ^{
        if ([self.imagesCache objectForKey:fileName]) {
            completion([self.imagesCache objectForKey:fileName]);
        } else {
            NSURL *fileUrl = [MVJsonHelper urlToFileWithName:fileName extenssion:@"png"];
            DBAttachment *attachment = [DBAttachment attachmentFromDocumentURL:fileUrl];
            completion(attachment);
            [self.imagesCache setObject:attachment forKey:fileName];
        }
    });
}

- (void)loadAvatarAttachmentForChat:(MVChatModel *)chat completion:(void (^)(DBAttachment *attachment))completion {
    NSString *fileName = [@"chat" stringByAppendingString:chat.id];
    [self loadAttachmentForFileNamed:fileName completion:completion];
}

- (void)loadAvatarAttachmentForContact:(MVContactModel *)contact completion:(void (^)(DBAttachment *attachment))completion {
    NSString *fileName = [@"contact" stringByAppendingString:contact.id];
    [self loadAttachmentForFileNamed:fileName completion:completion];
}

- (void)loadAttachmentForMessage:(MVMessageModel *)message completion:(void (^)(DBAttachment *attachment))completion {
    NSString *fileName = [message.chatId stringByAppendingPathComponent:message.id];
    [self loadAttachmentForFileNamed:fileName completion:completion];
}


- (CGSize)sizeOfAttachmentForMessage:(MVMessageModel *)message {
    NSString *fileName = [message.chatId stringByAppendingPathComponent:message.id];
    NSURL *url = [MVJsonHelper urlToFileWithName:fileName extenssion:@"png"];
    return [self sizeOfImageAtURL:url];
}

- (CGSize)sizeOfImageAtURL:(NSURL *)imageURL {
    CGSize imageSize = CGSizeZero;
    CGImageSourceRef source = CGImageSourceCreateWithURL((CFURLRef)imageURL, NULL);
    if (source) {
        NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCGImageSourceShouldCache];
        CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(source, 0, (CFDictionaryRef)options);
        
        if (properties) {
            NSDictionary *pr = (__bridge NSDictionary *)properties;
            NSNumber *width = [pr objectForKey:(NSString *)kCGImagePropertyPixelWidth];
            NSNumber *height = [pr objectForKey:(NSString *)kCGImagePropertyPixelHeight];
            if ((width != nil) && (height != nil))
                imageSize = CGSizeMake(width.floatValue, height.floatValue);
            CFRelease(properties);
        }
        CFRelease(source);
    }
    
    return imageSize;
}

#pragma mark - Generating images
- (void)generateImagesForChats:(NSArray <MVChatModel *> *)chats {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (MVChatModel *chat in chats) {
            if (chat.isPeerToPeer) {
                continue;
            }
            NSString *letter = [[chat.title substringToIndex:1] uppercaseString];
            UIImage *image = [self generateGradientImageForLetter:letter];
            [MVJsonHelper writeData:UIImagePNGRepresentation(image) toFileWithName:[@"chat" stringByAppendingString:chat.id] extenssion:@"png"];
        }
    });
}

- (void)generateImagesForContacts:(NSArray <MVContactModel *> *)contacts {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (MVContactModel *contact in contacts) {
            NSString *letter = [[contact.name substringToIndex:1] uppercaseString];
            UIImage *image = [self generateGradientImageForLetter:letter];
            [MVJsonHelper writeData:UIImagePNGRepresentation(image) toFileWithName:[@"contact" stringByAppendingString:contact.id] extenssion:@"png"];
        }
    });
}

//TODO: release
- (UIImage *)generateGradientImageForLetter:(NSString *)letter {
    CGFloat imageScale = (CGFloat)1.0;
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
    //CFRelease(font);
    //CFRelease(string);
    //CFRelease(attributes);
    //CFRelease(attrString);
    //CFRelease(line);
    
    return [UIImage imageWithCGImage:cgImage];
}

- (void)cacheMessageAttachments {
    dispatch_async(self.managerQueue, ^{
        NSArray *chats = [[MVChatManager sharedInstance] chatsList];
        NSString *documentsPath = [MVJsonHelper documentsPath];
        for (MVChatModel *chat in chats) {
            NSString *chatFolder = [documentsPath stringByAppendingPathComponent:chat.id];
            NSFileManager *fm = [NSFileManager defaultManager];
            if ([fm fileExistsAtPath:chatFolder]) {
                NSArray *files = [fm contentsOfDirectoryAtPath:chatFolder error:nil];
                @synchronized (self.messageAttachments) {
                    NSMutableArray *paths = [self.messageAttachments objectForKey:chat.id];
                    if (!paths) {
                        paths = [NSMutableArray new];
                        [self.messageAttachments setObject:paths forKey:chat.id];
                    }
                    for (NSString *file in files) {
                        NSString *fullFilePath = [chatFolder stringByAppendingPathComponent:file];
                        DBAttachment *attachment = [DBAttachment attachmentFromDocumentURL:[NSURL fileURLWithPath:fullFilePath]];
                        [paths addObject:attachment];
                    }
                }
            }
        }
    });
}

- (NSArray <DBAttachment *> *)attachmentsForChatWithId:(NSString *)chatId {
    @synchronized (self.messageAttachments) {
        return [self.messageAttachments objectForKey:chatId];
    }
}
@end
