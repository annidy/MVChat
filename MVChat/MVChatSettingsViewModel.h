//
//  MVChatSettingsViewModel.h
//  MVChat
//
//  Created by Mark Vasiv on 12/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MVChatModel;
@class MVContactModel;
@class MVContactsListCellViewModel;
@class DBAttachmentPickerController;
@class MVContactsListController;
@class RACCommand;
@class UIImage;

typedef enum : NSUInteger {
    MVChatSettingsModeNew,
    MVChatSettingsModeSettings
} MVChatSettingsMode;

typedef enum : NSUInteger {
    MVChatSettingsCellTypeAvatarTitle,
    MVChatSettingsCellTypeAvatar,
    MVChatSettingsCellTypeNewContact,
    MVChatSettingsCellTypeContact,
    MVChatSettingsCellTypeMediaFiles,
    MVChatSettingsCellTypeDeleteChat
} MVChatSettingsCellType;

@interface MVChatSettingsViewModel : NSObject
@property (assign, nonatomic, readonly) MVChatSettingsMode mode;
@property (strong, nonatomic, readonly) MVChatModel *chat;
@property (strong, nonatomic, readonly) NSMutableArray <MVContactModel *> *contacts;
@property (strong, nonatomic, readonly) NSMutableArray <MVContactsListCellViewModel *> *contactModels;
@property (strong, nonatomic, readonly) RACCommand *doneCommand;
@property (strong, nonatomic, readonly) UIImage *avatarImage;
@property (strong, nonatomic) NSString *chatTitle;

- (instancetype)initWithContacts:(NSArray <MVContactModel *> *)contacts;
- (instancetype)initWithChat:(MVChatModel *)chat;

- (void)removeContactAtIndex:(NSUInteger)index;
- (void)deleteChat;

- (DBAttachmentPickerController *)attachmentPicker;
- (MVContactsListController *)contactsSelectController;

- (MVChatSettingsCellType)cellTypeForIndexPath:(NSIndexPath *)indexPath;
- (NSString *)cellIdForCellType:(MVChatSettingsCellType)type;
@end
