//
//  MVChatSettingsViewModel.m
//  MVChat
//
//  Created by Mark Vasiv on 12/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVChatSettingsViewModel.h"
#import "MVContactModel.h"
#import "MVChatModel.h"
#import "MVFileManager.h"
#import "MVContactsListCellViewModel.h"
#import "NSString+Helpers.h"
#import "MVContactManager.h"
#import <DBAttachmentPickerController.h>
#import <DBAttachment.h>
#import "MVContactsListViewModel.h"
#import "MVContactsListController.h"
#import "MVChatManager.h"
#import <ReactiveObjC.h>

static NSString *AvatarTitleCellId = @"MVChatSettingsAvatarTitleCell";
static NSString *AvatarCellId = @"MVChatSettingsAvatarCell";
static NSString *ContactCellId = @"MVChatSettingsContactCell";
static NSString *NewContactCellId = @"MVChatSettingsNewContactCell";
static NSString *DeleteChatCellId = @"MVChatSettingsDeleteCell";
static NSString *MediaFilesCellId = @"MVChatSettingsMediaCell";

@interface MVChatSettingsViewModel ()
@property (strong, nonatomic) RACSubject *contactDeleteSubject;
@property (assign, nonatomic, readwrite) MVChatSettingsMode mode;
@property (strong, nonatomic, readwrite) MVChatModel *chat;
@property (strong, nonatomic, readwrite) NSMutableArray <MVContactModel *> *contacts;
@property (strong, nonatomic, readwrite) NSMutableArray <MVContactsListCellViewModel *> *contactModels;
@property (strong, nonatomic, readwrite) UIImage *avatarImage;
@property (strong, nonatomic, readwrite) RACCommand *doneCommand;
@property (strong, nonatomic) DBAttachment *selectedAvatar;
@end

@implementation MVChatSettingsViewModel
#pragma mark - Initialization
- (instancetype)initWithContacts:(NSArray <MVContactModel *> *)contacts {
    return [self initWithMode:MVChatSettingsModeNew chat:nil contacts:contacts];
}

- (instancetype)initWithChat:(MVChatModel *)chat {
    NSArray *contacts = [[[chat.participants.rac_sequence filter:^BOOL(MVContactModel *contact) {
        return !contact.iam;
    }] signal] toArray];
    
    return [self initWithMode:MVChatSettingsModeSettings chat:chat contacts:contacts];
}

- (instancetype)initWithMode:(MVChatSettingsMode)mode chat:(MVChatModel *)chat contacts:(NSArray <MVContactModel *> *)contacts {
    if (self = [super init]) {
        _contactDeleteSubject = [RACSubject new];
        _mode = mode;
        _chat = chat;
        _chatTitle = chat.title;
        _contacts = [contacts mutableCopy];
        [self setupAll];
    }
    
    return self;
}

#pragma mark - Setup
- (void)setupAll {
    @weakify(self);
    
    if (self.mode == MVChatSettingsModeSettings) {
        [[MVFileManager sharedInstance] loadThumbnailAvatarForChat:self.chat maxWidth:50 completion:^(UIImage *image) {
            self.avatarImage = image;
        }];
        
        RAC(self, avatarImage) =
        [[[[MVFileManager sharedInstance].avatarUpdateSignal
            filter:^BOOL(MVAvatarUpdate *update) {
                @strongify(self);
                if (!self.chat.isPeerToPeer) {
                    return (update.type == MVAvatarUpdateTypeChat && [update.id isEqualToString:self.chat.id]);
                } else {
                    return (update.type == MVAvatarUpdateTypeContact && [update.id isEqualToString:self.chat.getPeer.id]);
                }
            }]
            filter:^BOOL(id  _Nullable value) {
                @strongify(self);
                return (self.selectedAvatar == nil);
            }]
            map:^id(MVAvatarUpdate *update) {
                return update.avatar;
            }];
    }
    
    RAC(self, contactModels) = [RACObserve(self, contacts) map:^id (NSArray *contacts) {
        @strongify(self);
        return [[[[contacts.rac_sequence map:^id (MVContactModel *contact) {
            return [self viewModelForContact:contact];
        }] signal] toArray] mutableCopy];
    }];
    
    [[[RACObserve(self, selectedAvatar) ignore:nil]
        flattenMap:^ __kindof RACSignal *(DBAttachment *avatar) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber>  _Nonnull subscriber) {
                [avatar thumbnailImageWithMaxWidth:50 completion:^(UIImage *resultImage) {
                    [subscriber sendNext:resultImage];
                    [subscriber sendCompleted];
                }];
                return nil;
            }];
        }]
        subscribeNext:^(UIImage *resultImage) {
            @strongify(self);
            self.avatarImage = resultImage;
        }];
    
    self.doneCommand = [self doneCommandBlock];
}

#pragma mark - Data actions
- (RACCommand *)doneCommandBlock {
    @weakify(self);
    
    RACSignal *modeNewSignal = [RACObserve(self, mode) map:^id (NSNumber *modeNumber) {
        MVChatSettingsMode mode = [modeNumber unsignedIntegerValue];
        return @(mode == MVChatSettingsModeNew);
    }];
    
    RACSignal *contactsChangeSignal = [RACObserve(self, contacts) merge:self.contactDeleteSubject];
    
    RACSignal *dataValidSignal = [[contactsChangeSignal combineLatestWith:RACObserve(self, chatTitle)] reduceEach:^id (NSMutableArray *contacts, NSString *title){
        return @(contacts.count > 0 && title.length > 0);
    }];
    
    RACSignal *dataChangedSignal =
    [RACSignal combineLatest:@[contactsChangeSignal, RACObserve(self, chatTitle), RACObserve(self, chat), RACObserve(self, selectedAvatar)]
                      reduce:^id(NSMutableArray *contacts, NSString *title, MVChatModel *chat, DBAttachment *selectedAvatar){
                          
                          BOOL titleChanged = ![title isEqualToString:chat.title];
                          BOOL contactsChanged = NO;
                          NSMutableSet *chatParticipants = [NSMutableSet new];
                          NSMutableSet *selectedContacts = [NSMutableSet new];
                          for (MVContactModel *contact in chat.participants) {
                              if (!contact.iam) {
                                  [chatParticipants addObject:contact.id];
                              }
                          }
                          for (MVContactModel *contact in contacts) {
                              [selectedContacts addObject:contact.id];
                          }
                          
                          if (![chatParticipants isEqualToSet:selectedContacts]) {
                              contactsChanged = YES;
                          }
                          
                          BOOL avatarChanged = (BOOL)selectedAvatar;
                          
                          return @(titleChanged || contactsChanged || avatarChanged);
                      }];
    
    RACSignal *canProceedSignal = [RACSignal if:modeNewSignal then:dataValidSignal else:[[dataValidSignal combineLatestWith:dataChangedSignal] and]];
    
    RACSignal *createChatSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        [[MVChatManager sharedInstance] createChatWithContacts:self.contacts title:self.chatTitle andCompletion:^(MVChatModel *chat) {
            if (self.selectedAvatar) {
                [[MVFileManager sharedInstance] saveChatAvatar:chat attachment:self.selectedAvatar];
            } else {
                [[MVFileManager sharedInstance] generateAvatarsForChats:@[chat]];
            }
            [subscriber sendNext:chat];
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
    
    RACSignal *updateChatSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        self.chat.participants = self.contacts;
        self.chat.title = self.chatTitle;
        if (self.selectedAvatar) {
            [[MVFileManager sharedInstance] saveChatAvatar:self.chat attachment:self.selectedAvatar];
        }
        [[MVChatManager sharedInstance] updateChat:self.chat];
        [subscriber sendNext:self.chat];
        [subscriber sendCompleted];
        return nil;
    }];
    
    return [[RACCommand alloc] initWithEnabled:canProceedSignal signalBlock:^RACSignal *(id input) {
        return [RACSignal if:modeNewSignal then:createChatSignal else:updateChatSignal];
    }];
}

- (void)insertContacts:(NSArray *)contacts {
    NSMutableArray *mutableContacts = [self.contacts mutableCopy];
    [mutableContacts addObjectsFromArray:contacts];
    self.contacts = mutableContacts;
}

- (void)removeContactAtIndex:(NSUInteger)index {
    [self.contacts removeObjectAtIndex:index];
    [self.contactModels removeObjectAtIndex:index];
    [self.contactDeleteSubject sendNext:self.contacts];
}

- (void)deleteChat {
    [[MVChatManager sharedInstance] exitAndDeleteChat:self.chat];
}

#pragma mark - Create controllers
- (MVContactsListController *)contactsSelectController {
    MVContactsListViewModel *viewModel = [[MVContactsListViewModel alloc] initWithMode:MVContactsListModeSelectable excludingContacts:[self.contacts copy]];
    MVContactsListController *controller = [MVContactsListController loadFromStoryboardWithViewModel:viewModel];
    
    @weakify(self);
    [[viewModel.doneCommand.executionSignals flatten] subscribeNext:^(NSArray *selectedContacts) {
        @strongify(self);
        [self insertContacts:selectedContacts];
        [controller.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    return controller;
}

- (DBAttachmentPickerController *)attachmentPicker {
    DBAttachmentPickerController *attachmentPicker = [DBAttachmentPickerController attachmentPickerControllerFinishPickingBlock:^(NSArray<DBAttachment *> *attachmentArray) {
        self.selectedAvatar = attachmentArray[0];
    } cancelBlock:nil];
    
    attachmentPicker.mediaType = DBAttachmentMediaTypeImage;
    return attachmentPicker;
}

#pragma mark - Helpers
- (MVChatSettingsCellType)cellTypeForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return MVChatSettingsCellTypeAvatarTitle;
        } else {
            return MVChatSettingsCellTypeAvatar;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            return MVChatSettingsCellTypeNewContact;
        } else {
            return MVChatSettingsCellTypeContact;
        }
    } else if (indexPath.section == 2) {
        return MVChatSettingsCellTypeMediaFiles;
    } else {
        return MVChatSettingsCellTypeDeleteChat;
    }
}

- (NSString *)cellIdForCellType:(MVChatSettingsCellType)type {
    switch (type) {
        case MVChatSettingsCellTypeAvatarTitle:
            return AvatarTitleCellId;
            break;
            
        case MVChatSettingsCellTypeAvatar:
            return AvatarCellId;
            break;
            
        case MVChatSettingsCellTypeNewContact:
            return NewContactCellId;
            break;
            
        case MVChatSettingsCellTypeContact:
            return ContactCellId;
            break;
            
        case MVChatSettingsCellTypeMediaFiles:
            return MediaFilesCellId;
            break;
            
        case MVChatSettingsCellTypeDeleteChat:
            return DeleteChatCellId;
            break;
    }
}

- (MVContactsListCellViewModel *)viewModelForContact:(MVContactModel *)contact {
    MVContactsListCellViewModel *model = [MVContactsListCellViewModel new];
    model.contact = contact;
    model.name = contact.name;
    model.lastSeenTime = [NSString lastSeenTimeStringForDate:contact.lastSeenDate];
    [[MVFileManager sharedInstance] loadThumbnailAvatarForContact:contact maxWidth:50 completion:^(UIImage *image) {
        model.avatar = image;
    }];
    [[[MVFileManager sharedInstance].avatarUpdateSignal filter:^BOOL(MVAvatarUpdate *update) {
        return (update.type == MVAvatarUpdateTypeContact && [update.id isEqualToString:contact.id]);
    }] subscribeNext:^(MVAvatarUpdate *update) {
        model.avatar = update.avatar;
    }];
    
    [[[MVContactManager sharedInstance].lastSeenTimeSignal filter:^BOOL(RACTuple *tuple) {
        return [contact.id isEqualToString:tuple.first];
    }] subscribeNext:^(RACTuple *tuple) {
        model.lastSeenTime = [NSString lastSeenTimeStringForDate:tuple.second];
    }];
    
    return model;
}
@end
