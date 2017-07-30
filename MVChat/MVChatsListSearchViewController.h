//
//  MVChatsListSearchTableViewController.h
//  MVChat
//
//  Created by Mark Vasiv on 27/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVSearchProviderDelegate.h"
@class MVChatModel;

@interface MVChatsListSearchViewController : UIViewController
@property (strong, nonatomic) MVChatModel *resentSearchChat;
@property (strong, nonatomic) NSArray *popularChats;
@property (strong, nonatomic) NSArray *filteredChats;
+ (instancetype)loadFromStoryboard;
+ (instancetype)loadFromStoryboardWithDelegate:(id <MVSearchProviderDelegate>)delegate;
@end
