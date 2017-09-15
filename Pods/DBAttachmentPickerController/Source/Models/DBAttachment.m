//
//  DBAttachment.m
//  DBAttachmentPickerController
//
//  Created by Denis Bogatyrev on 14.03.16.
//
//  The MIT License (MIT)
//  Copyright (c) 2016 Denis Bogatyrev.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

@import Photos;
@import CoreLocation;
#import "DBAttachment.h"
#import "UIImage+DBAssetIcons.h"

@interface DBAttachment ()

@property (strong, nonatomic) NSString *fileName;
@property (assign, nonatomic) NSUInteger fileSize;
@property (strong, nonatomic) NSDate *creationDate;

@property (assign, nonatomic) DBAttachmentSourceType sourceType;
@property (assign, nonatomic) DBAttachmentMediaType mediaType;

@property (strong, nonatomic) PHAsset *photoAsset;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImage *thumbmailImage;
@property (strong, nonatomic) NSString *originalFilePath;
@property (strong, nonatomic) NSCache *imagesCache;

@end

@implementation DBAttachment

- (instancetype)init {
    if (self = [super init]) {
        _imagesCache = [NSCache new];
    }
    
    return self;
}

+ (instancetype)attachmentFromPHAsset:(PHAsset *)asset {
    DBAttachment *model = [[[self class] alloc] init];
    model.sourceType = DBAttachmentSourceTypePHAsset;
    model.photoAsset = asset;
    
    NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
    PHAssetResource *resource = [resources firstObject];
    switch (asset.mediaType) {
        case PHAssetMediaTypeImage:
            model.mediaType = DBAttachmentMediaTypeImage;
            break;
        case PHAssetMediaTypeVideo:
            model.mediaType = DBAttachmentMediaTypeVideo;
            break;
        default:
            model.mediaType = DBAttachmentMediaTypeOther;
            break;
    }
    model.fileName = resource.originalFilename;
    model.creationDate = asset.creationDate;
    
    return model;
}

+ (instancetype)attachmentFromCameraImage:(UIImage *)image {
    DBAttachment *model = [[[self class] alloc] init];
    model.sourceType = DBAttachmentSourceTypeImage;
    model.mediaType = DBAttachmentMediaTypeImage;
    model.image = image;
    
    NSData *imgData = UIImageJPEGRepresentation(image, 1);
    model.fileSize = imgData.length;
    model.creationDate = [NSDate date];
    model.fileName = @"capturedimage";
    
    return model;
}

+ (instancetype)attachmentFromDocumentURL:(NSURL *)url {
    DBAttachment *model = [[[self class] alloc] init];
    model.sourceType = DBAttachmentSourceTypeDocumentURL;
    
    NSString *filePath = [url path];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] ) {
        model.originalFilePath = filePath;
        model.fileName = [filePath lastPathComponent];
        
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        if (attributes) {
            model.creationDate = attributes[NSFileCreationDate];
            model.fileSize = [attributes[NSFileSize] integerValue];
        }
    }
    
    NSString *fileExt = [[[url absoluteString] pathExtension] lowercaseString];
    if ([fileExt isEqualToString:@"png"] || [fileExt isEqualToString:@"jpeg"] || [fileExt isEqualToString:@"jpg"] || [fileExt isEqualToString:@"gif"] || [fileExt isEqualToString:@"tiff"]) {
        model.mediaType = DBAttachmentMediaTypeImage;
        //model.thumbmailImage = [UIImage imageWithContentsOfFile:model.originalFilePath];
    } else if ([fileExt isEqualToString:@"mov"] || [fileExt isEqualToString:@"avi"]) {
        model.mediaType = DBAttachmentMediaTypeVideo;
        //model.thumbmailImage = [model generateThumbnailImageFromURL:url];
    } else {
        model.mediaType = DBAttachmentMediaTypeOther;
        //model.thumbmailImage = [UIImage imageOfFileIconWithExtensionText:[fileExt uppercaseString]];
    }
    
    return model;
}



#pragma mark - Accessors
- (NSString *)fileSizeStr {
    if (self.fileSize == 0) return nil;
    return [NSByteCountFormatter stringFromByteCount:self.fileSize countStyle:NSByteCountFormatterCountStyleFile];
}

#pragma mark -
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

- (CGSize)sizeOfImageWithData:(NSData *)data {
    CGSize imageSize = CGSizeZero;
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)data, NULL);
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

- (void)thumbnailImageWithMaxWidth:(CGFloat)maxWidth completion:(void(^)(UIImage *resultImage))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIImage *image;
        NSNumber *cachesKey = @(ceil(maxWidth));
        
        @synchronized (self.imagesCache) {
            image = [self.imagesCache objectForKey:cachesKey];
        }
        
        if (image && completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(image);
            });
            return;
        }
        
        __block CGImageSourceRef imageSource = NULL;
        PHImageRequestOptions *requestOptions = [PHImageRequestOptions new];
        requestOptions.synchronous = YES;

        switch (self.sourceType) {
            case DBAttachmentSourceTypePHAsset:
                [[PHImageManager defaultManager] requestImageDataForAsset:self.photoAsset
                                                                  options:requestOptions
                                                            resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                                                               imageSource = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
                                                            }];
                break;
            case DBAttachmentSourceTypeDocumentURL:
                if (self.originalFilePath) {
                    imageSource = CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath:self.originalFilePath], nil);
                }
                break;
            default:
                if (self.image) {
                    imageSource = CGImageSourceCreateWithData((CFDataRef)UIImagePNGRepresentation(self.image), NULL);
                }
                break;
        }
        
        if (imageSource == NULL) {
            return;
        }
        
        CGFloat originalHeight = 0;
        CGFloat originalWidth = 0;
        
        NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCGImageSourceShouldCache];
        CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, (CFDictionaryRef)options);
        
        if (properties) {
            NSDictionary *pr = (__bridge NSDictionary *)properties;
            NSNumber *heightNum = [pr objectForKey:(NSString *)kCGImagePropertyPixelHeight];
            NSNumber *widthNum = [pr objectForKey:(NSString *)kCGImagePropertyPixelWidth];
            if (heightNum) {
                originalHeight = [heightNum floatValue];
            }
            if (widthNum) {
                originalWidth = [widthNum floatValue];
            }
            CFRelease(properties);
        }
        
        CGFloat scale = UIScreen.mainScreen.scale;
        CGFloat width = maxWidth * scale;
        CGFloat transform = width / originalWidth;
        CGFloat height = originalHeight * transform;
        
        NSDictionary *dict = @{(id)kCGImageSourceShouldAllowFloat:@YES, (id)kCGImageSourceCreateThumbnailWithTransform:@YES, (id)kCGImageSourceCreateThumbnailFromImageAlways:@YES, (id)kCGImageSourceThumbnailMaxPixelSize:@(MAX(width, height)/2)};
        CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (CFDictionaryRef)dict);
        image = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
        
        @synchronized (self.imagesCache) {
            [self.imagesCache setObject:image forKey:cachesKey];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(image);
            }
        });
        
        CFRelease(imageRef);
        CFRelease(imageSource);
    });
}

- (void)originalImageWithCompletion:(void(^)(UIImage *resultImage))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        PHImageRequestOptions *requestOptions = [PHImageRequestOptions new];
        requestOptions.synchronous = YES;
        __block UIImage *image;
        
        NSNumber *cachesKey = @(0);
        @synchronized (self.imagesCache) {
            image = [self.imagesCache objectForKey:cachesKey];
        }
        
        if (image && completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(image);
            });
            return;
        }
        
        switch (self.sourceType) {
            case DBAttachmentSourceTypePHAsset:
                [[PHImageManager defaultManager] requestImageForAsset:self.photoAsset
                                                           targetSize:PHImageManagerMaximumSize
                                                          contentMode:PHImageContentModeDefault
                                                              options:requestOptions
                                                        resultHandler:^(UIImage *result, NSDictionary *info) {
                                                            image = result;
                                                        }];
                break;
            case DBAttachmentSourceTypeImage:
                image = self.image;
                break;
            case DBAttachmentSourceTypeDocumentURL:
                image = [UIImage imageWithContentsOfFile:self.originalFilePath];
                break;
            default:
                break;
        }
        
        @synchronized (self.imagesCache) {
            [self.imagesCache setObject:image forKey:cachesKey];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(image);
            }
        });
    });
}

- (void)loadThumbnailImageWithTargetSize:(CGSize)targetSize completion:(void(^)(UIImage *resultImage))completion {
    switch (self.sourceType) {
        case DBAttachmentSourceTypePHAsset:
            if (completion) {
                [[PHImageManager defaultManager] requestImageForAsset:self.photoAsset
                                                           targetSize:targetSize
                                                          contentMode:PHImageContentModeDefault
                                                              options:nil
                                                        resultHandler:^(UIImage *result, NSDictionary *info) {
                                                            if (![info[PHImageResultIsDegradedKey] boolValue]) {
                                                                completion(result);
                                                            }
                                                        }];
            }
            break;
        case DBAttachmentSourceTypeDocumentURL: {
            if (self.thumbmailImage) {
                completion(self.thumbmailImage);
            } else {
                [self loadOriginalImageWithCompletion:completion];
            }
        }
            break;
        default:
            [self loadOriginalImageWithCompletion:completion];
            break;
    }
}

- (void)loadOriginalImageWithCompletion:(void(^)(UIImage *resultImage))completion {
    switch (self.sourceType) {
        case DBAttachmentSourceTypePHAsset:
            if (completion) {
                [[PHImageManager defaultManager] requestImageForAsset:self.photoAsset
                                                           targetSize:PHImageManagerMaximumSize
                                                          contentMode:PHImageContentModeDefault
                                                              options:nil
                                                        resultHandler:^(UIImage *result, NSDictionary *info) {
                                                            completion(result);
                                                        }];
            }
            break;
        case DBAttachmentSourceTypeImage: {
            if (completion) {
                completion(self.image);
            }
            break;
        }
        case DBAttachmentSourceTypeDocumentURL: {
            if (!self.image) {
                self.image = [UIImage imageWithContentsOfFile:self.originalFilePath];
            }
            if (completion) {
                completion(self.image);
            }
            break;
        }
        default:
            if (completion) {
                completion(nil);
            }
            break;
    }
}

- (UIImage *)loadOriginalImageSync {
    __block UIImage *resultImg;
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.synchronous = YES;
    
    switch (self.sourceType) {
        case DBAttachmentSourceTypePHAsset:
            
            [[PHImageManager defaultManager] requestImageForAsset:self.photoAsset
                                                       targetSize:PHImageManagerMaximumSize
                                                      contentMode:PHImageContentModeDefault
                                                          options:options
                                                    resultHandler:^(UIImage *result, NSDictionary *info) {
                                                        resultImg = result;
                                                    }];
            
            break;
        case DBAttachmentSourceTypeImage: {
            resultImg = self.image;
            break;
        }
        case DBAttachmentSourceTypeDocumentURL: {
            if (!self.image) {
                self.image = [UIImage imageWithContentsOfFile:self.originalFilePath];
            }
            resultImg = self.image;
            break;
        }
        default:
            break;
    }
    
    return resultImg;
}

- (id)originalFileResource {
    switch (self.sourceType) {
        case DBAttachmentSourceTypePHAsset:
            return self.photoAsset;
            break;
        case DBAttachmentSourceTypeImage:
            return self.image;
            break;
        case DBAttachmentSourceTypeDocumentURL:
            return self.originalFilePath;
            break;
            
        default:
            return nil;
            break;
    }
}

#pragma mark Helpers
- (UIImage *)generateThumbnailImageFromURL:(NSURL *)url {
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = [asset duration];
    time.value = 0;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return thumbnail;
}

@end
