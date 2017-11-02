//
//  MVChatsListViewModel.m
//  MVChat
//
//  Created by Mark Vasiv on 11/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVChatsListViewModel.h"
#import "MVChatManager.h"
#import "MVChatModel.h"
#import "MVChatsListCellViewModel.h"
#import "MVMessageModel.h"
#import "MVFileManager.h"
#import <ReactiveObjC.h>

@implementation MVChatsListUpdate : NSObject
+ (instancetype)insertUpdateWithIndex:(NSIndexPath *)index {
    return [[MVChatsListUpdate alloc] initWithType:MVChatsListUpdateTypeInsert startIndex:nil endIndex:nil insertIndex:index deleteIndex:nil reloadIndex:nil];
}

+ (instancetype)deleteUpdateWithIndex:(NSIndexPath *)index {
    return [[MVChatsListUpdate alloc] initWithType:MVChatsListUpdateTypeDelete startIndex:nil endIndex:nil insertIndex:nil deleteIndex:index reloadIndex:nil];
}

+ (instancetype)reloadAllUpdate {
    return [[MVChatsListUpdate alloc] initWithType:MVChatsListUpdateTypeReloadAll startIndex:nil endIndex:nil insertIndex:nil deleteIndex:nil reloadIndex:nil];
}

+ (instancetype)moveUpdateWithStartIndex:(NSIndexPath *)start endIndex:(NSIndexPath *)end {
    return [[MVChatsListUpdate alloc] initWithType:MVChatsListUpdateTypeMove startIndex:start endIndex:end insertIndex:nil deleteIndex:nil reloadIndex:nil];
}

+ (instancetype)reloadUpdateWithIndex:(NSIndexPath *)index {
    return [[MVChatsListUpdate alloc] initWithType:MVChatsListUpdateTypeMove startIndex:nil endIndex:nil insertIndex:nil deleteIndex:nil reloadIndex:index];
}

- (instancetype)initWithType:(MVChatsListUpdateType)type startIndex:(NSIndexPath *)start endIndex:(NSIndexPath *)end insertIndex:(NSIndexPath *)insert deleteIndex:(NSIndexPath *)delete reloadIndex:(NSIndexPath *)reload {
    if (self = [super init]) {
        _updateType = type;
        _startIndexPath = start;
        _endIndexPath = end;
        _insertIndexPath = insert;
        _removeIndexPath = delete;
        _reloadIndexPath = reload;
    }
    
    return self;
}
@end

@interface MVChatsListViewModel ()
@property (strong, nonatomic, readwrite) NSArray *chats;
@property (strong, nonatomic, readwrite) NSArray *filteredChats;
@property (strong, nonatomic, readwrite) NSArray *popularChats;
@property (assign, nonatomic, readwrite) BOOL shouldShowPopularData;
@property (strong, nonatomic, readwrite) NSArray *listUpdates;
@end

@implementation MVChatsListViewModel
#pragma mark - Lifecycle
- (instancetype)init {
    if (self = [super init]) {
        [self setupBindings];
    }
    
    return self;
}

- (void)setupBindings {
    MVChatManager *chatManager = [MVChatManager sharedInstance];
    RACScheduler *viewModelScheduler = chatManager.viewModelScheduler;
    RACSignal *chatUpdateSignal = [chatManager.chatUpdateSignal deliverOn:viewModelScheduler];
    
    self.chats = [self viewModelsForChats:chatManager.chatsList];
    self.listUpdates = @[[MVChatsListUpdate reloadAllUpdate]];
    
    @weakify(self);
    RACSignal *reloadSignal = [[[[chatUpdateSignal filter:^BOOL(MVChatUpdate *listUpdate) {
        return listUpdate.updateType == ChatUpdateTypeReload;
    }] map:^id(MVChatUpdate *listUpdate) {
        @strongify(self);
        return [self viewModelsForChats:chatManager.chatsList];
    }] doNext:^(NSArray *models) {
        @strongify(self);
        self.chats = models;
    }] map:^id (NSArray *models) {
        return @[[MVChatsListUpdate reloadAllUpdate]];
    }];
    
    RACSignal *insertSignal = [[[[chatUpdateSignal filter:^BOOL(MVChatUpdate *listUpdate) {
        return listUpdate.updateType == ChatUpdateTypeInsert;
    }] map:^id (MVChatUpdate *listUpdate) {
        @strongify(self);
        return [self viewModelForChat:listUpdate.chat];
    }] doNext:^(MVChatsListViewModel *model) {
        @strongify(self);
        NSMutableArray *chats = [self.chats mutableCopy];
        [chats insertObject:model atIndex:0];
        self.chats = [chats copy];
    }] map:^id (MVChatsListViewModel *model) {
        return @[[MVChatsListUpdate insertUpdateWithIndex:[NSIndexPath indexPathForRow:0 inSection:0]]];
    }];
    
    RACSignal *deleteSignal = [[[[[chatUpdateSignal filter:^BOOL(MVChatUpdate *listUpdate) {
        return listUpdate.updateType == ChatUpdateTypeDelete;
    }] map:^id(MVChatUpdate *listUpdate) {
        @strongify(self);
        return @([self indexOfChat:listUpdate.chat]);
    }] filter:^BOOL(NSNumber *index) {
        return index.integerValue != NSNotFound;
    }] doNext:^(NSNumber *index) {
        @strongify(self);
        NSMutableArray *chats = [self.chats mutableCopy];
        [chats removeObjectAtIndex:index.integerValue];
        self.chats = [chats copy];
    }] map:^id (NSNumber *index) {
        return @[[MVChatsListUpdate deleteUpdateWithIndex:[NSIndexPath indexPathForRow:index.integerValue inSection:0]]];
    }];
    
    RACSignal *modifySignal = [[[[chatUpdateSignal filter:^BOOL(MVChatUpdate *listUpdate) {
        return listUpdate.updateType == ChatUpdateTypeModify;
    }] map:^id (MVChatUpdate *listUpdate) {
        @strongify(self);
        return RACTuplePack(@(listUpdate.sorting), [self viewModelForChat:listUpdate.chat], @([self indexOfChat:listUpdate.chat]), @(listUpdate.index));
    }] doNext:^(RACTuple *tuple) {
        RACTupleUnpack(NSNumber *sorting, MVChatsListCellViewModel *model, NSNumber *oldIndex, NSNumber *newIndex) = tuple;
        @strongify(self);
        NSMutableArray *chats = [self.chats mutableCopy];
        if (sorting.boolValue) {
            [chats removeObjectAtIndex:oldIndex.integerValue];
            [chats insertObject:model atIndex:newIndex.integerValue];
        } else {
            [chats replaceObjectAtIndex:oldIndex.integerValue withObject:model];
        }
        self.chats = [chats copy];
    }] map:^id (RACTuple *tuple) {
        RACTupleUnpack(NSNumber *sorting, MVChatsListCellViewModel *model, NSNumber *oldIndex, NSNumber *newIndex) = tuple;
        NSMutableArray *updates = [NSMutableArray new];
        if (sorting.boolValue) {
            NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:oldIndex.integerValue inSection:0];
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:newIndex.integerValue inSection:0];
            MVChatsListUpdate *move = [MVChatsListUpdate moveUpdateWithStartIndex:oldIndexPath endIndex:newIndexPath];
            [updates addObject:move];
        }
        NSInteger rowToReload = sorting.boolValue? newIndex.integerValue : oldIndex.integerValue;
        MVChatsListUpdate *reload = [MVChatsListUpdate reloadUpdateWithIndex:[NSIndexPath indexPathForRow:rowToReload inSection:0]];
        [updates addObject:reload];
        return updates.copy;
    }];
    
    RAC(self, listUpdates) = [RACSignal merge:@[reloadSignal, insertSignal, deleteSignal, modifySignal]];
    
    RAC(self, shouldShowPopularData) = [[RACObserve(self, filteredChats) map:^id(NSArray *chats) {
        return @((BOOL)chats);
    }] not];
}

#pragma mark - Data handling
- (MVChatsListCellViewModel *)viewModelForChat:(MVChatModel *)chat {
    MVChatsListCellViewModel *viewModel = [MVChatsListCellViewModel new];
    viewModel.chat = chat;
    if (chat.isPeerToPeer) {
        viewModel.title = chat.getPeer.name;
    } else {
        viewModel.title = chat.title;
    }
    
    viewModel.message = [self textFromMessage:chat.lastMessage];
    
    if (chat.unreadCount != 0) {
        viewModel.unreadCount = [NSString stringWithFormat:@"%lu", (unsigned long)chat.unreadCount];
    }
    
    viewModel.updateDate = [self textFromUpdateDate:chat.lastUpdateDate];
    
    [[MVFileManager sharedInstance] loadThumbnailAvatarForChat:chat maxWidth:50 completion:^(UIImage *image) {
        viewModel.avatar = image;
    }];
    
    RAC(viewModel, avatar) =
    [[[[MVFileManager sharedInstance].avatarUpdateSignal filter:^BOOL(MVAvatarUpdate *update) {
        if (chat.isPeerToPeer) {
            return (update.type == MVAvatarUpdateTypeContact && [update.id isEqualToString:chat.getPeer.id]);
        } else {
            return (update.type == MVAvatarUpdateTypeChat && [update.id isEqualToString:chat.id]);
        }
    }] map:^id (MVAvatarUpdate *update) {
        return update.avatar;
    }] takeUntil:viewModel.rac_willDeallocSignal];
    
    return viewModel;
}

- (NSArray <MVChatsListCellViewModel *> *)viewModelsForChats:(NSArray <MVChatModel *> *)chats {
    NSMutableArray *models = [NSMutableArray new];
    for (MVChatModel *chat in chats) {
        [models addObject:[self viewModelForChat:chat]];
    }
    return [models copy];
}
#pragma mark - Search filter
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if (searchController.isActive) {
        self.filteredChats = [self filterChatsWithString:searchController.searchBar.text];
        self.popularChats = [self.chats subarrayWithRange:NSMakeRange(0, self.chats.count>5? 5:self.chats.count)];
        searchController.searchResultsController.view.hidden = NO;
    }
    
}

- (NSArray *)filterChatsWithString:(NSString *)string {
    if (!string.length) {
        return nil;
    }
    
    return [[self.chats.rac_sequence.signal filter:^BOOL(MVChatsListCellViewModel *model) {
        return [model.title.uppercaseString containsString:string.uppercaseString];
    }] toArray];
}

#pragma mark - Helpers
- (NSUInteger)indexOfChat:(MVChatModel *)chat {
    for (MVChatsListCellViewModel *model in self.chats) {
        if ([model.chat.id isEqualToString:chat.id]) {
            return [self.chats indexOfObject:model];
        }
    }
    
    return NSNotFound;
}

- (NSString *)textFromMessage:(MVMessageModel *)message {
    if (message.type == MVMessageTypeMedia) {
        return @"Media message";
    } else {
        return message.text;
    }
}

- (NSString *)textFromUpdateDate:(NSDate *)date {
    if ([[NSCalendar currentCalendar] isDateInToday:date]) {
        return [self.todayDateFormatter stringFromDate:date];
    } else {
        return [self.defaultDateFormatter stringFromDate:date];
    }
}

static NSDateFormatter *defaultDateFormatter;
- (NSDateFormatter *)defaultDateFormatter {
    if (!defaultDateFormatter) {
        defaultDateFormatter = [NSDateFormatter new];
        [defaultDateFormatter setDateStyle:NSDateFormatterShortStyle];
        [defaultDateFormatter setDoesRelativeDateFormatting:YES];
    }
    
    return defaultDateFormatter;
}

static NSDateFormatter *todayDateFormatter;
- (NSDateFormatter *)todayDateFormatter {
    if (!todayDateFormatter) {
        todayDateFormatter = [NSDateFormatter new];
        [todayDateFormatter setDateStyle:NSDateFormatterNoStyle];
        [todayDateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [todayDateFormatter setDoesRelativeDateFormatting:YES];
    }
    
    return todayDateFormatter;
}
@end
