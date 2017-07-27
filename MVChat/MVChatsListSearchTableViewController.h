//
//  MVChatsListSearchTableViewController.h
//  MVChat
//
//  Created by Mark Vasiv on 27/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MVChatModel;

@interface MVChatsListSearchTableViewController : UITableViewController
@property (strong, nonatomic) NSArray *filteredChats;
+ (instancetype)loadFromStoryboard;
@end
