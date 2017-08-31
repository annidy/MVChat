//
//  MVChatViewController.h
//  MVChat
//
//  Created by Mark Vasiv on 30/04/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVViewController.h"
@class MVChatModel;

@interface MVChatViewController : MVViewController
@property (strong, nonatomic) MVChatModel *chat;
+ (instancetype)loadFromStoryboardWithChat:(MVChatModel *)chat;
@end
