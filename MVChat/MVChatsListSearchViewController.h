//
//  MVChatsListSearchTableViewController.h
//  MVChat
//
//  Created by Mark Vasiv on 27/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVSearchProviderDelegate.h"
#import "MVViewController.h"
@class MVChatModel;
@class MVChatsListViewModel;

@interface MVChatsListSearchViewController : MVViewController
+ (instancetype)loadFromStoryboardWithViewModel:(MVChatsListViewModel *)viewModel rootViewController:(UIViewController <UITableViewDelegate, UICollectionViewDelegate> *)root;
@end
