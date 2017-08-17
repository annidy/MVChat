//
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

@interface MVFileManager()
@property (strong, nonatomic) dispatch_queue_t managerQueue;
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
    }
    
    return self;
}

#pragma mark - Saving images
- (void)saveAttachment:(DBAttachment *)attachment withFileName:(NSString *)fileName {
    dispatch_async(self.managerQueue, ^{
        [attachment loadOriginalImageWithCompletion:^(UIImage *resultImage) {
            [MVJsonHelper writeData:UIImagePNGRepresentation(resultImage) toFileWithName:fileName extenssion:@"png"];
        }];
    });
}

- (void)saveAttachment:(DBAttachment *)attachment asChatAvatar:(MVChatModel *)chat {
    [self saveAttachment:attachment withFileName:[@"chat" stringByAppendingString:chat.id]];
}

- (void)saveAttachment:(DBAttachment *)attachment asContactAvatar:(MVContactModel *)contact {
    [self saveAttachment:attachment withFileName:[@"contact" stringByAppendingString:contact.id]];
}

#pragma mark - Loading images
- (void)loadAttachmentForFileNamed:(NSString *)fileName completion:(void (^)(DBAttachment *attachment))completion {
    dispatch_async(self.managerQueue, ^{
        NSURL *fileUrl = [MVJsonHelper urlToFileWithName:fileName extenssion:@"png"];
        DBAttachment *attachment = [DBAttachment attachmentFromDocumentURL:fileUrl];
        completion(attachment);
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

#pragma mark - Generating images
- (void)generateImagesForChats:(NSArray <MVChatModel *> *)chats {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (MVChatModel *chat in chats) {
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
    CFRelease(font);
    CFRelease(string);
    CFRelease(attributes);
    CFRelease(attrString);
    CFRelease(line);
    
    return [UIImage imageWithCGImage:cgImage];
}
@end
