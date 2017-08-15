//
//  DBAssetImageView.h
//  DBAttachmentPickerControllerExample
//
//  Created by Denis Bogatyrev on 30.03.16.
//  Copyright © 2016 Denis Bogatyrev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/PhotosTypes.h>

@interface DBAssetImageView : UIImageView

- (void)configureWithAssetMediaType:(PHAssetMediaType)mediaType subtype:(PHAssetMediaSubtype)mediaSubtype;
- (void)configureCollectionSubtype:(PHAssetCollectionSubtype)collectionSubtype;

@end
