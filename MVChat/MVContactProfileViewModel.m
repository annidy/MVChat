//
//  MVContactProfileViewModel.m
//  MVChat
//
//  Created by Mark Vasiv on 13/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVContactProfileViewModel.h"
#import "MVContactModel.h"
#import <ReactiveObjC.h>
#import "NSString+Helpers.h"
#import "MVFileManager.h"
#import "MVContactManager.h"
#import "MVChatManager.h"
#import "MVChatSharedMediaListController.h"
#import "MVChatViewController.h"
#import "MVChatModel.h"
#import "MVChatViewModel.h"

static NSString *ContactCellId = @"MVContactProfileAvatarTitleCell";
static NSString *PhoneCellId = @"MVContactProfilePhoneCell";
static NSString *MediaCellId = @"MVContactProfileMediaCell";
static NSString *ChatCellId = @"MVContactProfileChatCell";

@interface MVContactProfileViewModel()
@property (strong, nonatomic) MVContactModel *contact;
@property (strong, nonatomic, readwrite) NSString *name;
@property (strong, nonatomic, readwrite) NSString *lastSeen;
@property (strong, nonatomic, readwrite) UIImage *avatar;
@property (strong, nonatomic, readwrite) NSArray <NSString *> *phoneNumbers;
@end

@implementation MVContactProfileViewModel
#pragma mark - Initialization
- (instancetype)initWithContact:(MVContactModel *)contact {
    if (self = [super init]) {
        _contact = contact;
        [self setupAll];
    }
    
    return self;
}

- (void)setupAll {
    self.name = self.contact.name;
    self.lastSeen = [NSString lastSeenTimeStringForDate:self.contact.lastSeenDate];
    self.phoneNumbers = self.contact.phoneNumbers;
    
    @weakify(self);
    [[MVFileManager sharedInstance] loadThumbnailAvatarForContact:self.contact maxWidth:40 completion:^(UIImage *image) {
        self.avatar = image;
    }];
    
    RAC(self, avatar) =
    [[[[MVFileManager sharedInstance] avatarUpdateSignal]
        filter:^BOOL(MVAvatarUpdate *update) {
            @strongify(self);
            return (update.type == MVAvatarUpdateTypeContact && [update.id isEqualToString:self.contact.id]);
        }]
        map:^id (MVAvatarUpdate *update) {
            return update.avatar;
        }];
    
    RAC(self, lastSeen) =
    [[[[MVContactManager sharedInstance] lastSeenTimeSignal]
        filter:^BOOL(RACTuple *tuple) {
            @strongify(self);
            return [self.contact.id isEqualToString:tuple.first];
        }]
        map:^id (RACTuple *tuple) {
            return [NSString lastSeenTimeStringForDate:tuple.second];
        }];
}

#pragma mark - Helpers
- (MVContactProfileCellType)cellTypeForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return MVContactProfileCellTypeContact;
    } else if (indexPath.section == 1) {
        return MVContactProfileCellTypePhone;
    } else {
        if (indexPath.row == 0) {
            return MVContactProfileCellTypeSharedMedia;
        } else {
            return MVContactProfileCellTypeChat;
        }
    }
}

- (NSString *)cellIdForCellType:(MVContactProfileCellType)type {
    switch (type) {
        case MVContactProfileCellTypeContact:
            return ContactCellId;
            break;
            
        case MVContactProfileCellTypePhone:
            return PhoneCellId;
            break;
            
        case MVContactProfileCellTypeSharedMedia:
            return MediaCellId;
            break;
            
        case MVContactProfileCellTypeChat:
            return ChatCellId;
            break;
    }
}

#pragma mark - Create controllers
- (void)sharedMediaController:(void (^)(MVChatSharedMediaListController *controller))callback {
    [[MVChatManager sharedInstance] chatWithContact:self.contact andCompeltion:^(MVChatModel *chat) {
        MVChatSharedMediaListController *vc = [MVChatSharedMediaListController loadFromStoryboardWithChatId:chat.id];
        callback(vc);
    }];
}

- (void)chatController:(void (^)(MVChatViewController *controller))callback {
    [[MVChatManager sharedInstance] chatWithContact:self.contact andCompeltion:^(MVChatModel *chat) {
        MVChatViewModel *viewModel = [[MVChatViewModel alloc] initWithChat:chat];
        MVChatViewController *chatVC = [MVChatViewController loadFromStoryboardWithViewModel:viewModel];
        callback(chatVC);
    }];
}
@end
