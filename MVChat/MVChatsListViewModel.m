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
- (instancetype)initWithType:(MVChatsListUpdateType)type start:(NSIndexPath *)start end:(NSIndexPath *)end {
    if (self = [super init]) {
        _updateType = type;
        _startIndexPath = start;
        _endIndexPath = end;
    }
    
    return self;
}
@end

@interface MVChatsListViewModel () <MVChatsUpdatesListener>
@property (strong, nonatomic, readwrite) NSArray *chats;
@property (strong, nonatomic, readwrite) NSArray *filteredChats;
@property (strong, nonatomic, readwrite) NSArray *popularChats;
@property (strong, nonatomic) RACSubject *updateSubject;
@property (assign, nonatomic, readwrite) BOOL shouldShowPopularData;
@end

@implementation MVChatsListViewModel
#pragma mark - Lifecycle
- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    
    return self;
}

- (void)setup {
    self.updateSubject = [RACSubject subject];
    self.updateSignal = [self.updateSubject deliverOnMainThread];
    
    RAC(self, shouldShowPopularData) = [[RACObserve(self, filteredChats) map:^id _Nullable(NSArray *chats) {
        return @((BOOL)chats);
    }] not];
    
    [MVChatManager sharedInstance].chatsListener = self;
    [self updateChats];
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
    
    [[[MVFileManager sharedInstance].avatarUpdateSignal filter:^BOOL(MVAvatarUpdate *update) {
        if (chat.isPeerToPeer) {
            return (update.type == MVAvatarUpdateTypeContact && [update.id isEqualToString:chat.getPeer.id]);
        } else {
            return (update.type == MVAvatarUpdateTypeChat && [update.id isEqualToString:chat.id]);
        }
    }] subscribeNext:^(MVAvatarUpdate *update) {
        viewModel.avatar = update.avatar;
    }];
    
    return viewModel;
}

#pragma mark - Chats Listener
- (void)updateChats {
    @weakify(self);
    self.chats = [[[MVChatManager sharedInstance].chatsList.rac_sequence.signal map:^id (MVChatModel *chat) {
        @strongify(self);
        return [self viewModelForChat:chat];
    }] toArray];
    
    MVChatsListUpdate *update = [[MVChatsListUpdate alloc] initWithType:MVChatsListUpdateTypeReloadAll start:nil end:nil];
    [self.updateSubject sendNext:update];
}

- (void)insertNewChat:(MVChatModel *)chat {
    NSMutableArray *chats = [self.chats mutableCopy];
    [chats insertObject:[self viewModelForChat:chat] atIndex:0];
    self.chats = [chats copy];
    
    MVChatsListUpdate *update = [[MVChatsListUpdate alloc] initWithType:MVChatsListUpdateTypeInsert start:[NSIndexPath indexPathForRow:0 inSection:0] end:nil];
    [self.updateSubject sendNext:update];
}

- (void)removeChat:(MVChatModel *)chat {
    NSUInteger index = [self indexOfChat:chat];
    if (index != NSNotFound) {
        NSMutableArray *chats = [self.chats mutableCopy];
        [chats removeObjectAtIndex:index];
        self.chats = [chats copy];
        MVChatsListUpdate *update = [[MVChatsListUpdate alloc] initWithType:MVChatsListUpdateTypeDelete start:[NSIndexPath indexPathForRow:index inSection:0] end:nil];
        [self.updateSubject sendNext:update];
    }
}

- (void)updateChat:(MVChatModel *)chat withSorting:(BOOL)sorting newIndex:(NSUInteger)newIndex {
    NSUInteger index = [self indexOfChat:chat];
    NSMutableArray *chats = [self.chats mutableCopy];
    MVChatsListCellViewModel *model = [self viewModelForChat:chat];
    
    if (sorting) {
        [chats removeObjectAtIndex:index];
        [chats insertObject:model atIndex:newIndex];
    } else {
        [chats replaceObjectAtIndex:index withObject:model];
    }
    
    self.chats = [chats copy];
    
    if (sorting) {
        MVChatsListUpdate *move = [[MVChatsListUpdate alloc] initWithType:MVChatsListUpdateTypeMove start:[NSIndexPath indexPathForRow:index inSection:0] end:[NSIndexPath indexPathForRow:newIndex inSection:0]];
        [self.updateSubject sendNext:move];
    }
    
    NSInteger rowToReload = sorting? newIndex : index;
    MVChatsListUpdate *reload = [[MVChatsListUpdate alloc] initWithType:MVChatsListUpdateTypeReload start:[NSIndexPath indexPathForRow:rowToReload inSection:0] end:nil];
    [self.updateSubject sendNext:reload];
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
