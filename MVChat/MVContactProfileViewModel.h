//
//  MVContactProfileViewModel.h
//  MVChat
//
//  Created by Mark Vasiv on 13/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIImage;
@class MVChatSharedMediaListController;
@class MVChatViewController;
@class MVContactModel;

typedef enum : NSUInteger {
    MVContactProfileCellTypeContact,
    MVContactProfileCellTypePhone,
    MVContactProfileCellTypeSharedMedia,
    MVContactProfileCellTypeChat
} MVContactProfileCellType;

@interface MVContactProfileViewModel : NSObject
- (instancetype)initWithContact:(MVContactModel *)contact;
- (MVContactProfileCellType)cellTypeForIndexPath:(NSIndexPath *)indexPath;
- (NSString *)cellIdForCellType:(MVContactProfileCellType)type;
- (void)sharedMediaController:(void (^)(MVChatSharedMediaListController *controller))callback;
- (void)chatController:(void (^)(MVChatViewController *controller))callback;

@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) NSString *lastSeen;
@property (strong, nonatomic, readonly) UIImage *avatar;
@property (strong, nonatomic, readonly) NSArray <NSString *> *phoneNumbers;
@end
