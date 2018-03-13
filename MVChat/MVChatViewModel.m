//
//  MVChatViewModel.m
//  MVChat
//
//  Created by Mark Vasiv on 13/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVChatViewModel.h"
#import "MVChatModel.h"
#import <ReactiveObjC.h>
#import "MVMessageCellModel.h"
#import "MVChatManager.h"
#import "MVMessageModel.h"
#import "NSString+Helpers.h"
#import "MVFileManager.h"
#import "MVChatSettingsViewController.h"
#import "MVChatSettingsViewModel.h"
#import "MVContactProfileViewModel.h"
#import "MVContactProfileViewController.h"
#import "MVImageViewerViewModel.h"
#import "MVChatSharedMediaPageController.h"
#import "DBAttachmentPickerController.h"
#import "NSMutableArray+Optionals.h"
#import "MVMessagesListUpdate.h"
#import <DBAttachment.h>

@interface MVChatViewModel()
@property (strong, nonatomic) NSMutableArray <MVMessageCellModel *> *messages;
@property (assign, nonatomic) BOOL processingMessages;
@property (assign, nonatomic) BOOL initialLoadComplete;
@property (assign, nonatomic) NSInteger loadedPageIndex;
@property (assign, nonatomic) NSInteger numberOfProcessedMessages;
@property (strong, nonatomic) RACReplaySubject *updateSubject;
@property (strong, nonatomic) MVChatModel *chat;
@property (strong, nonatomic) RACScheduler *scheduler;
@property (strong, nonatomic) dispatch_queue_t queue;
@property (nonatomic, copy) BOOL (^insertMessage)(MVMessageModel *, MVMessageModel *,  MVMessageModel *, NSMutableArray <MVMessageCellModel *> *, BOOL);
@end

@implementation MVChatViewModel
#pragma mark - Initialization
- (instancetype)initWithChat:(MVChatModel *)chat {
    if (self = [super init]) {
        _loadedPageIndex = -1;
        _sliderOffset = 0;
        _chat = chat;
        _messages = [NSMutableArray new];
        _updateSubject = [RACReplaySubject replaySubjectWithCapacity:1];
        _scheduler = [MVChatManager sharedInstance].viewModelScheduler;
        _queue = [MVChatManager sharedInstance].viewModelQueue;
        _chatId = chat.id;
        _updateSignal = [_updateSubject deliverOnMainThread];
        
        @weakify(self);
        self.insertMessage = ^BOOL (MVMessageModel *previous, MVMessageModel *current, MVMessageModel *next, NSMutableArray <MVMessageCellModel *> *rows, BOOL reverse) {
            @strongify(self);
            if (previous && !previous.read && !reverse) {
                current.read = NO;
            }
            
            NSString *sectionKey = [self headerTitleFromMessage:current];
            NSString *previousSectionKey = [self headerTitleFromMessage:previous];
            MVMessageCellModel *viewModel = [self viewModelForMessage:current previousMessage:previous nextMessage:next];
            MVMessageCellModel *headerViewModel = [self viewModelForSection:sectionKey];
            BOOL shouldInsertHeader = ![previousSectionKey isEqualToString:sectionKey];
            
            NSInteger insertIndex = reverse? 0 : rows.count;
            
            [rows insertObject:viewModel atIndex:insertIndex];
            if (shouldInsertHeader) {
                [rows insertObject:headerViewModel atIndex:insertIndex];
            }
            
            return shouldInsertHeader;
        };
        
        [self setupAll];
        [self tryToLoadNextPage];
    }
    
    return self;
}

- (void)setupAll {
    self.title = self.chat.title;
    self.chatParticipants = self.chat.participants;
    [[MVFileManager sharedInstance] loadThumbnailAvatarForChat:self.chat maxWidth:50 completion:^(UIImage *image) {
        self.avatar = image;
    }];
    
    @weakify(self);
    RAC(self, avatar) = [[[[MVFileManager sharedInstance] avatarUpdateSignal] filter:^BOOL(MVAvatarUpdate *update) {
        @strongify(self);
        if (self.chat.isPeerToPeer) {
            return [update.id isEqualToString:self.chat.getPeer.id];
        } else {
            return [update.id isEqualToString:self.chat.id];
        }
    }] map:^id (MVAvatarUpdate *update) {
        return update.avatar;
    }];
    
    RACSignal *messageTextValid = [RACObserve(self, messageText) map:^id (NSString *text) {
        return @([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0);
    }];
    
    self.sendCommand = [[RACCommand alloc] initWithEnabled:messageTextValid signalBlock:^RACSignal *(id input) {
        @strongify(self);
        return [self sendCommandSignal];
    }];
    
    [[MVChatManager sharedInstance].messageUpdateSignal subscribeNext:^(MVMessageModel *message) {
        @strongify(self);
        [self insertNewMessage:message];
    }];
    
    [[MVChatManager sharedInstance].messageReloadSignal subscribeNext:^(MVMessageModel *message) {
        @strongify(self);
        [self updateMessage:message];
    }];
    
    NSString *chatId = [self.chat.id copy];
    [[[MVChatManager sharedInstance].chatUpdateSignal filter:^BOOL(MVChatUpdate *chatUpdate) {
        return chatUpdate.updateType == ChatUpdateTypeModify && [chatUpdate.chat.id isEqualToString:chatId];
    }] subscribeNext:^(MVChatUpdate *chatUpdate) {
        @strongify(self);
        self.chat = chatUpdate.chat;
        self.title = chatUpdate.chat.title;
        self.chatParticipants = chatUpdate.chat.participants;
    }];
    
    [self.rac_willDeallocSignal subscribeCompleted:^{
        [[MVChatManager sharedInstance] markChatAsRead:chatId];
    }];
}

#pragma mark - Handle messages
- (void)tryToLoadNextPage {
    if (self.processingMessages) {
        return;
    }
    self.processingMessages = YES;
    
    BOOL shouldLoad = (!self.initialLoadComplete || ([[MVChatManager sharedInstance] numberOfPagesInChatWithId:self.chatId]) > self.loadedPageIndex + 1);
    
    if (!shouldLoad) {
        self.processingMessages = NO;
        return;
    }
    
    @weakify(self);
    [[[[[MVChatManager sharedInstance] messagesPage:++self.loadedPageIndex forChatWithId:self.chatId] map:^id (NSArray<MVMessageModel *> *models) {
        @strongify(self);
        NSMutableArray <MVMessageCellModel *> *messages = self.messages;
        MVMessageModel *lastLoadedMessage = [messages optionalObjectAtIndex:1].message;
        MVMessageModel *beforeLastLoadedMessage = [messages optionalObjectAtIndex:2].message;
        RACTuple *firstTuple = RACTuplePack(beforeLastLoadedMessage, lastLoadedMessage);
        return [[models.rac_sequence scanWithStart:firstTuple reduceWithIndex:^id (RACTuple *running, MVMessageModel *next, NSUInteger index) {
            if (index == 0) {
                return RACTuplePack(running.first, running.second, next, @(index));
            } else {
                return RACTuplePack(running.second, running.third, next, @(index));
            }
            
        }] map:^id (RACTuple *tuple) {
            return RACTuplePack(messages, tuple.first, tuple.second, tuple.third, tuple.fourth, @(models.count));
        }];
    }] flattenMap:^__kindof RACSignal *(RACSequence *sequence) {
        @strongify(self);
        return [sequence signalWithScheduler:self.scheduler];
    }] subscribeNext:^(RACTuple *tuple) {
        RACTupleUnpack(NSMutableArray <MVMessageCellModel *> *rows, MVMessageModel *nextModel, MVMessageModel *currentModel, MVMessageModel *previousModel, NSNumber *idx, NSNumber *count) = tuple;
        @strongify(self);
        if (idx.integerValue == 0 && currentModel) {
            [rows removeObjectAtIndex:0];
            [rows removeObjectAtIndex:0];
        }
        if (currentModel) {
            self.insertMessage(previousModel, currentModel, nextModel, rows, YES);
        }
        if (idx.integerValue == count.integerValue - 1) {
            self.insertMessage(nil, previousModel, currentModel, rows, YES);
        }
    } completed:^{
        @strongify(self);
        self.processingMessages = NO;
        self.initialLoadComplete = YES;
        self.numberOfProcessedMessages += self.messages.count;
        MVMessagesListUpdate *update = [[MVMessagesListUpdate alloc] initWithType:MVMessagesListUpdateTypeReloadAll indexPath:nil rows:[self.messages copy]];
        [self.updateSubject sendNext:update];
    }];
}

- (void)insertNewMessage:(MVMessageModel *)message {
    self.processingMessages = YES;
    [self handleNewMessage:message];
    self.numberOfProcessedMessages++;
    if (self.numberOfProcessedMessages % MVMessagesPageSize == 0) {
        self.loadedPageIndex++;
    }
    self.processingMessages = NO;
}

- (void)handleNewMessage:(MVMessageModel *)message {
    NSMutableArray <MVMessageCellModel *> *rows = self.messages;
    MVMessageCellModel *previousModel = rows.optionalLastObject;
    
    BOOL reloadPrevious = NO;
    if (previousModel.message && [self messageModel:previousModel.message hasEqualDirectionAndTypeWith:message]) {
        MVMessageModel *beforeLastMessage = [rows optionalObjectAtIndex:rows.count - 2].message;
        MVMessageCellModel *updatedModel = [self viewModelForMessage:previousModel.message previousMessage:beforeLastMessage nextMessage:message];
        if (updatedModel.tailType != previousModel.tailType) {
            [rows replaceObjectAtIndex:rows.count - 1 withObject:updatedModel];
            reloadPrevious = YES;
        }
    }
    
    BOOL insertHeader = self.insertMessage(previousModel.message, message, nil, rows, NO);
    
    NSIndexPath *insertPath = [NSIndexPath indexPathForRow:rows.count - 1 inSection:0];
    MVMessagesListUpdate *insert = [[MVMessagesListUpdate alloc] initWithType:MVMessagesListUpdateTypeInsertRow indexPath:insertPath rows:[rows copy]];
    insert.shouldReloadPrevious = reloadPrevious;
    insert.shouldInsertHeader = insertHeader;

    [self.updateSubject sendNext:insert];
}

- (void)updateMessage:(MVMessageModel *)message {
    if (message.type != MVMessageTypeMedia) {
        return;
    }
    
    NSInteger index = 0;
    BOOL found = NO;
    for (MVMessageCellModel *cellModel in self.rows) {
        if ([cellModel.message.id isEqualToString:message.id]) {
            cellModel.message = message;
            //[cellModel calculateSize];
            found = YES;
        } else {
            index ++;
        }
    }
    
    if (found) {
        NSIndexPath *updatePath = [NSIndexPath indexPathForRow:index inSection:0];
        MVMessagesListUpdate *update = [[MVMessagesListUpdate alloc] initWithType:MVMessagesListUpdateTypeReloadRow indexPath:updatePath rows:[self.messages copy]];
        [self.updateSubject sendNext:update];
    }
}

#pragma mark - Message helpers
- (MVMessageCellModelType)modelTypeForMessageType:(MVMessageType)type {
    switch (type) {
        case MVMessageTypeText:
            return MVMessageCellModelTypeTextMessage;
            break;
        case MVMessageTypeMedia:
            return MVMessageCellModelTypeMediaMessage;
            break;
        case MVMessageTypeSystem:
            return MVMessageCellModelTypeSystemMessage;
            break;
    }
}

- (MVMessageCellModelDirection)modeldirectionForMessageDirection:(MessageDirection)direction {
    switch (direction) {
        case MessageDirectionIncoming:
            return MVMessageCellModelDirectionIncoming;
            break;
        case MessageDirectionOutgoing:
            return MVMessageCellModelDirectionOutgoing;
            break;
    }
}

- (MVMessageCellModel *)viewModelForMessage:(MVMessageModel *)message previousMessage:(MVMessageModel *)previousMessage nextMessage:(MVMessageModel *)nextMessage {
    MVMessageCellModel *viewModel = [MVMessageCellModel new];
    viewModel.type = [self modelTypeForMessageType:message.type];
    if (message.type != MVMessageTypeSystem) {
        viewModel.tailType = [self messageCellTailTypeForModel:message previousModel:previousMessage nextModel:nextMessage];
    }
    viewModel.message = message;
    viewModel.text = message.text;
    [viewModel calculateSize];
    if (message.type == MVMessageTypeMedia) {
        [message.attachment thumbnailImageWithMaxWidth:viewModel.width completion:^(UIImage *resultImage) {
            viewModel.mediaImage = resultImage;
        }];
    }
    viewModel.direction = [self modeldirectionForMessageDirection:message.direction];
    viewModel.sendDateString = [NSString messageTimeFromDate:message.sendDate];
    
    
    if (message.direction == MessageDirectionIncoming) {
        [[MVFileManager sharedInstance] loadThumbnailAvatarForContact:message.contact maxWidth:50 completion:^(UIImage *image) {
            viewModel.avatar = image;
        }];
        
        RAC(viewModel, avatar) =
        [[[[MVFileManager sharedInstance].avatarUpdateSignal filter:^BOOL(MVAvatarUpdate *update) {
            return (update.type == MVAvatarUpdateTypeContact
                    && [update.id isEqualToString:message.contact.id]);
        }] map:^id(MVAvatarUpdate *update) {
            return update.avatar;
        }] takeUntil:viewModel.rac_willDeallocSignal];
    }
    
    return viewModel;
}

- (MVMessageCellModel *)viewModelForSection:(NSString *)section {
    MVMessageCellModel *viewModel = [MVMessageCellModel new];
    viewModel.text = section;
    viewModel.type = MVMessageCellModelTypeHeader;
    [viewModel calculateSize];
    
    return viewModel;
}

- (MVMessageCellTailType)messageCellTailTypeForModel:(MVMessageModel *)model previousModel:(MVMessageModel *)possiblePreviousModel nextModel:(MVMessageModel *)possibleNextModel {
    MVMessageModel *previousModel;
    MVMessageModel *nextModel;
    
    if ([self messageModel:possiblePreviousModel hasEqualDirectionAndTypeWith:model]) {
        previousModel = possiblePreviousModel;
    }
    
    if ([self messageModel:possibleNextModel hasEqualDirectionAndTypeWith:model]) {
        nextModel = possibleNextModel;
    }
    
    BOOL previousHasTail = NO;
    if (previousModel) {
        NSTimeInterval interval = [model.sendDate timeIntervalSinceDate:previousModel.sendDate];
        if (interval < 60) {
            previousHasTail = NO;
        } else {
            previousHasTail = YES;
        }
    }
    
    MVMessageCellTailType tailType = MVMessageCellTailTypeDefault;
    
    NSTimeInterval interval = 0;
    if (nextModel) {
        interval = [nextModel.sendDate timeIntervalSinceDate:model.sendDate];
    }
    
    if (!nextModel || interval > 60) {
        if (previousModel && !previousHasTail) {
            tailType = MVMessageCellTailTypeLastTailess;
        } else {
            tailType = MVMessageCellTailTypeDefault;
        }
    } else {
        if (previousModel && !previousHasTail) {
            tailType = MVMessageCellTailTypeTailess;
        } else {
            tailType = MVMessageCellTailTypeFirstTailess;
        }
    }
    
    return tailType;
}

static NSDateFormatter *dateFormatter;
- (NSString *)headerTitleFromMessage:(MVMessageModel *)message {
    if (!message) {
        return nil;
    }
    
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        dateFormatter.doesRelativeDateFormatting = YES;
    }
    
    if (!message.read) {
        return @"New Messages";
    } else {
        return [dateFormatter stringFromDate:message.sendDate];
    }
}

- (BOOL)messageModel:(MVMessageModel *)first hasEqualDirectionAndTypeWith:(MVMessageModel *)second {
    if (first.direction == second.direction && first.type == second.type) {
        return YES;
    }
    return NO;
}

- (void)recalculateHeights {
    for (MVMessageCellModel *model in self.messages) {
        [model calculateSize];
    }
    
    for (MVMessageCellModel *model in self.rows) {
        [model calculateSize];
    }
}
#pragma mark - Send command
- (RACSignal *)sendCommandSignal {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        [[MVChatManager sharedInstance] sendTextMessage:self.messageText toChatWithId:self.chatId];
        [subscriber sendCompleted];
        self.messageText = @"";
        return nil;
    }];
}

#pragma mark - View controller helpers
- (MVChatSettingsViewController *)settingsController {
    MVChatSettingsViewModel *viewModel = [[MVChatSettingsViewModel alloc] initWithChat:self.chat];
    return [MVChatSettingsViewController loadFromStoryboardWithViewModel:viewModel];
}

- (MVContactProfileViewController *)profileController {
    MVContactProfileViewModel *viewModel = [[MVContactProfileViewModel alloc] initWithContact:self.chat.getPeer];
    return [MVContactProfileViewController loadFromStoryboardWithViewModel:viewModel];
}

- (UIViewController *)relevantSettingsController {
    if (self.chat.isPeerToPeer) {
        return [self profileController];
    } else {
        return [self settingsController];
    }
}

- (void)imageViewerForMessage:(MVMessageCellModel *)model fromImageView:(UIImageView *)imageView completion:(void (^)(UIViewController *))completion {
    MVImageViewerViewModel *viewModel = [[MVImageViewerViewModel alloc] initWithSourceImageView:imageView
                                                                                     attachment:model.message.attachment
                                                                                       andIndex:0];
    dispatch_async(dispatch_get_main_queue(), ^{
        MVChatSharedMediaPageController *imageController = [MVChatSharedMediaPageController loadFromStoryboardWithViewModels:@[viewModel] andStartIndex:0];
        completion(imageController);
    });
}

- (DBAttachmentPickerController *)attachmentPicker {
    DBAttachmentPickerController *attachmentPicker = [DBAttachmentPickerController attachmentPickerControllerFinishPickingBlock:^(NSArray<DBAttachment *> *attachmentArray) {
        dispatch_async(self.queue, ^{        
            for (DBAttachment *attachment in attachmentArray) {
                [[MVChatManager sharedInstance] sendMediaMessageWithAttachment:attachment toChatWithId:self.chatId];
            }
        });
        
    } cancelBlock:nil];
    
    attachmentPicker.mediaType = DBAttachmentMediaTypeImage;
    attachmentPicker.allowsMultipleSelection = YES;
    return attachmentPicker;
}
@end
