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

@interface MVChatViewModel() <MVMessagesUpdatesListener>
@property (assign, nonatomic) BOOL processingMessages;
@property (assign, nonatomic) BOOL initialLoadComplete;
@property (assign, nonatomic) BOOL hasUnreadMessages;
@property (assign, nonatomic) NSInteger loadedPageIndex;
@property (strong, nonatomic) RACSubject *updateSubject;
@property (strong, nonatomic) MVChatModel *chat;
@end

@implementation MVChatViewModel
#pragma mark - Initialization
- (instancetype)initWithChat:(MVChatModel *)chat {
    if (self = [super init]) {
        _loadedPageIndex = -1;
        _sliderOffset = 0;
        _chat = chat;
        _messages = [NSMutableArray new];
        _updateSubject = [RACSubject subject];
        [self setupAll];
        [self tryToLoadNextPage];
    }
    
    return self;
}

- (void)setupAll {
    MVChatManager.sharedInstance.messagesListener = self;
    self.title = self.chat.title;
    self.chatId = self.chat.id;
    self.chatParticipants = self.chat.participants;
    self.updateSignal = self.updateSubject;
    
    [[MVFileManager sharedInstance] loadThumbnailAvatarForChat:self.chat maxWidth:50 completion:^(UIImage *image) {
        self.avatar = image;
    }];
    
    @weakify(self);
    RAC(self, avatar) =
    [[[[MVFileManager sharedInstance] avatarUpdateSignal]
        filter:^BOOL(MVAvatarUpdate *update) {
            @strongify(self);
            if (self.chat.isPeerToPeer) {
                return [update.id isEqualToString:self.chat.getPeer.id];
            } else {
                return [update.id isEqualToString:self.chat.id];
            }
        }]
        map:^id (MVAvatarUpdate *update) {
            return update.avatar;
        }];
    
    
    RACSignal *messageTextValid = [RACObserve(self, messageText) map:^id _Nullable(NSString *text) {
        return @([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0);
    }];
    
    self.sendCommand = [[RACCommand alloc] initWithEnabled:messageTextValid signalBlock:^RACSignal *(id input) {
        @strongify(self);
        return [self sendCommandSignal];
    }];
    
    NSString *chatId = [self.chat.id copy];
    [self.rac_willDeallocSignal subscribeCompleted:^{
        [[MVChatManager sharedInstance] markChatAsRead:chatId];
    }];
}


#pragma mark - Handle messages
- (void)tryToLoadNextPage {
    if (self.processingMessages) {
        return;
    }
    
    NSInteger numberOfPages = [[MVChatManager sharedInstance] numberOfPagesInChatWithId:self.chatId];
    BOOL shouldLoad = (numberOfPages > self.loadedPageIndex + 1) || (numberOfPages == 0 && !self.initialLoadComplete);
    
    if (shouldLoad) {
        self.processingMessages = YES;
        [[MVChatManager sharedInstance] messagesPage:++self.loadedPageIndex forChatWithId:self.chatId withCallback:^(NSArray<MVMessageModel *> *messages) {
            [self handleNewMessagesPage:messages];
            self.processingMessages = NO;
            self.initialLoadComplete = YES;
        }];
    }
}

- (void)handleNewMessagesPage:(NSArray <MVMessageModel *> *)models {
    NSMutableArray <MVMessageCellModel *> *messages = [self.messages mutableCopy];
    
    MVMessageModel *lastLoadedMessage = [messages optionalObjectAtIndex:1].message;
    MVMessageModel *beforeLastLoadedMessage = [messages optionalObjectAtIndex:2].message;
    RACTuple *firstTuple = RACTuplePack(beforeLastLoadedMessage, lastLoadedMessage);
    
    
    //Here we iterate models array using 4-spaced RACTuple (previousModel, currentModel, nextModel, index) where index corresponds to currentModel index in the array
    RACSignal *modelsSignal =
    [[[models.rac_sequence
       scanWithStart:firstTuple reduceWithIndex:^id (RACTuple *running, MVMessageModel *next, NSUInteger index) {
           if (index == 0) {
               return RACTuplePack(running.first, running.second, next, @(index));
           } else {
               return RACTuplePack(running.second, running.third, next, @(index));
           }
           
       }]
      map:^id (RACTuple *tuple) {
          return RACTuplePack(messages, tuple.first, tuple.second, tuple.third, tuple.fourth);
      }]
     signalWithScheduler:[RACScheduler mainThreadScheduler]];
    
    
    @weakify(self);
    void (^processMessage)(MVMessageModel *, MVMessageModel *,  MVMessageModel *, NSMutableArray <MVMessageCellModel *> *) = ^void (MVMessageModel *previous, MVMessageModel *current, MVMessageModel *next, NSMutableArray <MVMessageCellModel *> *rows) {
        @strongify(self);
        NSString *sectionKey = [self headerTitleFromMessage:current processingPage:YES];
        MVMessageCellModel *viewModel = [self viewModelForMessage:current previousMessage:previous nextMessage:next];
        [rows insertObject:viewModel atIndex:0];
        
        if (!previous || ![[self headerTitleFromMessage:previous processingPage:YES] isEqualToString:sectionKey]) {
            [rows insertObject:[self viewModelForSection:sectionKey] atIndex:0];
            if ([sectionKey isEqualToString:@"New Messages"]) {
                self.hasUnreadMessages = YES;
            }
        }
    };
    
    
    [modelsSignal subscribeNext:^(RACTuple *tuple) {
        RACTupleUnpack(NSMutableArray <MVMessageCellModel *> *rows, MVMessageModel *nextModel, MVMessageModel *currentModel, MVMessageModel *previousModel, NSNumber *idx) = tuple;
        if (idx.integerValue == 0 && currentModel) {
            [rows removeObjectAtIndex:0];
            [rows removeObjectAtIndex:0];
        }
        
        if (currentModel) {
            processMessage(previousModel, currentModel, nextModel, rows);
        }
        
        if (idx.integerValue == models.count - 1) {
            processMessage(nil, previousModel, currentModel, rows);
        }
        
    } completed:^{
        @strongify(self);
        self.messages = [messages mutableCopy];
        MVMessagesListUpdate *update = [[MVMessagesListUpdate alloc] initWithType:MVMessagesListUpdateTypeReloadAll indexPath:nil];
        [self.updateSubject sendNext:update];
    }];
}

- (void)updateMessage:(MVMessageModel *)message {
    //Not used yet
}

- (void)insertNewMessage:(MVMessageModel *)message {
    self.processingMessages = YES;
    [self handleNewMessage:message];
    self.processingMessages = NO;
}

- (void)handleNewMessage:(MVMessageModel *)message {
    NSMutableArray <MVMessageCellModel *> *rows = [self.messages mutableCopy];
    
    MVMessageModel *optionalPreviousMessage = rows.optionalLastObject.message;
    MVMessageModel *previousMessage;
    NSString *header = self.hasUnreadMessages? @"New Messages" : [self headerTitleFromMessage:message processingPage:NO];
    MVMessageCellModel *headerModel;
    if (!self.hasUnreadMessages && ![header isEqualToString:[self headerTitleFromMessage:optionalPreviousMessage processingPage:NO]]) {
        headerModel = [self viewModelForSection:header];
        [rows addObject:headerModel];
    } else if ([self messageModel:message hasEqualDirectionAndTypeWith:optionalPreviousMessage]){
        previousMessage = optionalPreviousMessage;
    }
    
    if (previousMessage) {
        MVMessageModel *beforeLastMessage = [rows optionalObjectAtIndex:rows.count - 2].message;
        MVMessageCellModel *updatedModel = [self viewModelForMessage:previousMessage previousMessage:beforeLastMessage nextMessage:message];
        [rows replaceObjectAtIndex:rows.count - 1 withObject:updatedModel];
    }
    
    MVMessageCellModel *viewModel = [self viewModelForMessage:message previousMessage:previousMessage nextMessage:nil];
    [rows addObject:viewModel];
    
    self.messages = [rows mutableCopy];
    
    NSIndexPath *insertPath = [NSIndexPath indexPathForRow:rows.count - 1 inSection:0];
    MVMessagesListUpdate *insert = [[MVMessagesListUpdate alloc] initWithType:MVMessagesListUpdateTypeInsertRow indexPath:insertPath];
    
    if (previousMessage) insert.shouldReloadPrevious = YES;
    
    if (headerModel) insert.shouldInsertHeader = YES;
    
    [self.updateSubject sendNext:insert];
}

#pragma mark - Message helpers
- (MVMessageCellModel *)viewModelForMessage:(MVMessageModel *)message previousMessage:(MVMessageModel *)previousMessage nextMessage:(MVMessageModel *)nextMessage {
    MVMessageCellModel *viewModel = [MVMessageCellModel new];
    switch (message.type) {
        case MVMessageTypeText:
            viewModel.type = MVMessageCellModelTypeTextMessage;
            viewModel.tailType = [self messageCellTailTypeForModel:message previousModel:previousMessage nextModel:nextMessage];
            
            break;
        case MVMessageTypeMedia:
            viewModel.type = MVMessageCellModelTypeMediaMessage;
            viewModel.tailType = [self messageCellTailTypeForModel:message previousModel:previousMessage nextModel:nextMessage];
            break;
        case MVMessageTypeSystem:
            viewModel.type = MVMessageCellModelTypeSystemMessage;
            break;
    }
    viewModel.message = message;
    viewModel.text = message.text;
    switch (message.direction) {
        case MessageDirectionIncoming:
            viewModel.direction = MVMessageCellModelDirectionIncoming;
            break;
        case MessageDirectionOutgoing:
            viewModel.direction = MVMessageCellModelDirectionOutgoing;
            break;
    }
    
    viewModel.sendDateString = [NSString messageTimeFromDate:message.sendDate];
    
    if (message.direction == MessageDirectionIncoming) {
        [[MVFileManager sharedInstance] loadThumbnailAvatarForContact:message.contact maxWidth:50 completion:^(UIImage *image) {
            viewModel.avatar = image;
        }];
        
        [[[MVFileManager sharedInstance].avatarUpdateSignal filter:^BOOL(MVAvatarUpdate *update) {
            return (update.type == MVAvatarUpdateTypeContact && [update.id isEqualToString:message.contact.id]);
        }] subscribeNext:^(MVAvatarUpdate *update) {
            viewModel.avatar = update.avatar;
        }];
    }
    
    if (message.type == MVMessageTypeMedia) {
        //TODO: Improve
        //TODO: calculate width?
        //CGFloat maxContentWidth = [MVMessageCellModel maxContentWidthWithDirection:messageModel.direction] - MVMediaContentHorizontalOffset * 2 - MVBubbleTailSize;
        
        [[MVFileManager sharedInstance] loadThumbnailAttachmentForMessage:message maxWidth:200 completion:^(UIImage *image) {
            viewModel.mediaImage = image;
        }];
    }
    
    [viewModel calculateHeight];
    
    
    return viewModel;
}

- (MVMessageCellModel *)viewModelForSection:(NSString *)section {
    MVMessageCellModel *viewModel = [MVMessageCellModel new];
    viewModel.text = section;
    viewModel.type = MVMessageCellModelTypeHeader;
    [viewModel calculateHeight];
    
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
- (NSString *)headerTitleFromMessage:(MVMessageModel *)message processingPage:(BOOL)processingPage {
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        dateFormatter.doesRelativeDateFormatting = YES;
    }
    
    if (processingPage && !message.read) {
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
    [[MVFileManager sharedInstance] loadAttachmentForMessage:model.message completion:^(DBAttachment *attachment) {
        MVImageViewerViewModel *viewModel = [[MVImageViewerViewModel alloc] initWithSourceImageView:imageView
                                                                                         attachment:attachment
                                                                                           andIndex:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            MVChatSharedMediaPageController *imageController = [MVChatSharedMediaPageController loadFromStoryboardWithViewModels:@[viewModel] andStartIndex:0];
            completion(imageController);
        });
    }];
}

- (DBAttachmentPickerController *)attachmentPicker {
    DBAttachmentPickerController *attachmentPicker = [DBAttachmentPickerController attachmentPickerControllerFinishPickingBlock:^(NSArray<DBAttachment *> *attachmentArray) {
        for (DBAttachment *attachment in attachmentArray) {
            [[MVChatManager sharedInstance] sendMediaMessageWithAttachment:attachment toChatWithId:self.chatId];
        }
        
    } cancelBlock:nil];
    
    attachmentPicker.mediaType = DBAttachmentMediaTypeImage;
    attachmentPicker.allowsMultipleSelection = YES;
    return attachmentPicker;
}
@end
