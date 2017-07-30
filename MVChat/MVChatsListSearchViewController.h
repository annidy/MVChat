//
//  MVChatsListSearchTableViewController.h
//  MVChat
//
//  Created by Mark Vasiv on 27/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MVChatModel;

@protocol MVSearchProviderDelegate
- (void)didSelectCellWithChat:(MVChatModel *)chat;
@end
@interface MVChatsListSearchViewController : UIViewController
@property (strong, nonatomic) MVChatModel *resentSearchChat;
@property (strong, nonatomic) NSArray *popularChats;
@property (strong, nonatomic) NSArray *filteredChats;
+ (instancetype)loadFromStoryboard;
+ (instancetype)loadFromStoryboardWithTableViewDelegate:(id <MVSearchProviderDelegate>)delegate;
@end
