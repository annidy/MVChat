//
//  MVChatViewController.h
//  MVChat
//
//  Created by Mark Vasiv on 30/04/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MVChatModel;

@interface MVChatViewController : UIViewController
@property (strong, nonatomic) MVChatModel *chat;
+ (instancetype)loadFromStoryboard;
+ (instancetype)loadFromStoryboardWithChat:(MVChatModel *)chat;
@end
