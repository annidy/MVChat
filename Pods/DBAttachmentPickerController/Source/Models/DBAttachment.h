//
//  DBAttachment.h
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

#import <Foundation/Foundation.h>
#import "DBAttachmentPickerController.h"

typedef NS_ENUM(NSInteger, DBAttachmentSourceType) {
    DBAttachmentSourceTypeUnknown = 0,
    DBAttachmentSourceTypePHAsset,
    DBAttachmentSourceTypeImage,
    DBAttachmentSourceTypeDocumentURL,
};

@class PHAsset;
@interface DBAttachment : NSObject

/*!
 @brief The name of the file. Can be empty.
 */
@property (strong, nonatomic, readonly, nullable) NSString *fileName;

/*!
 @brief Creation date of the file. Can be nil.
 */
@property (strong, nonatomic, readonly, nullable) NSDate *creationDate;

/*!
 @brief Size of the file in byte. Available only for existing files.
 @attention If you want get file size for PHAsset or something like that, you should calculate it after getting file data.
 @see fileSizeStr
 */
@property (assign, nonatomic, readonly) NSUInteger fileSize;

/*!
 @brief Formatted string of file size. Can be empty.
 @see fileSize
 */
@property (readonly, nullable) NSString *fileSizeStr;

/*!
 @brief Attachment source type
 */
@property (assign, nonatomic, readonly) DBAttachmentSourceType sourceType;

/*!
 @brief Attachment media type
 */
@property (assign, nonatomic, readonly) DBAttachmentMediaType mediaType;

NS_ASSUME_NONNULL_BEGIN

/*!
 @brief Creates and returns an attachment on the basis of PHAsset
 @see attachmentFromCameraImage:
 @see attachmentFromDocumentURL:
 @param asset PHAsset object
 @return An instance attachment object
 */
+ (instancetype)attachmentFromPHAsset:(PHAsset *)asset;

/*!
 @brief Creates and returns an attachment on the basis of UIImage
 @see attachmentFromPHAsset:
 @see attachmentFromDocumentURL:
 @param image UIImage object
 @return An instance attachment object
 */
+ (instancetype)attachmentFromCameraImage:(UIImage *)image;

/*!
 @brief Creates and returns an attachment on the basis of NSURL
 @see attachmentFromPHAsset:
 @see attachmentFromCameraImage:
 @param url NSURL object
 @return An instance attachment object
 */
+ (instancetype)attachmentFromDocumentURL:(NSURL *)url;


/*!
 @brief Load thumbnail image for specified size. Resultant image size can differ from the specified size.
 @see loadOriginalImageWithCompletion:
 @param targetSize The desired image size
 @param completion result block
 */
- (void)loadThumbnailImageWithTargetSize:(CGSize)targetSize completion:(void(^)(UIImage * _Nullable resultImage))completion;

/*!
 @brief Load original image
 @see loadThumbnailImageWithTargetSize:completion:
 @param completion result block
 */
- (void)loadOriginalImageWithCompletion:(void(^)(UIImage * _Nullable resultImage))completion;

/*!
 @brief Get original resource
 @return Can be return PHAsset, UIImage or local file path (NSString)
 */
- (id)originalFileResource;

NS_ASSUME_NONNULL_END

@end
