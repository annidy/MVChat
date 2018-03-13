//
//  MVChatsListViewModel.h
//  MVChat
//
//  Created by Mark Vasiv on 11/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RACSignal;
@class MVChatsListCellViewModel;

typedef enum : NSUInteger {
    MVChatsListUpdateTypeReloadAll,
    MVChatsListUpdateTypeReload,
    MVChatsListUpdateTypeInsert,
    MVChatsListUpdateTypeDelete,
    MVChatsListUpdateTypeMove
} MVChatsListUpdateType;

@interface MVChatsListUpdate : NSObject
@property (assign, nonatomic) MVChatsListUpdateType updateType;
@property (strong, nonatomic) NSIndexPath *startIndexPath;
@property (strong, nonatomic) NSIndexPath *endIndexPath;
@property (strong, nonatomic) NSIndexPath *insertIndexPath;
@property (strong, nonatomic) NSIndexPath *removeIndexPath;
@property (strong, nonatomic) NSIndexPath *reloadIndexPath;
@end

@interface MVChatsListViewModel : NSObject <UISearchResultsUpdating>
@property (strong, nonatomic, readonly) NSArray <MVChatsListUpdate *> *listUpdates;
@property (assign, nonatomic, readonly) BOOL shouldShowPopularData;
@property (strong, nonatomic) MVChatsListCellViewModel *recentSearchChat;
@property (strong, nonatomic, readonly) NSArray <MVChatsListCellViewModel *> *chats;
@property (strong, nonatomic, readonly) NSArray <MVChatsListCellViewModel *> *filteredChats;
@property (strong, nonatomic, readonly) NSArray <MVChatsListCellViewModel *> *popularChats;
@end
