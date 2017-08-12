//
//  MVChatSettingsViewController.h
//  MVChat
//
//  Created by Mark Vasiv on 12/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MVChatModel;
@class MVContactModel;

@interface MVChatSettingsViewController : UIViewController
@property (strong, nonatomic) MVChatModel *chat;
+ (instancetype)loadFromStoryboard;
+ (instancetype)loadFromStoryboardWithContacts:(NSArray <MVContactModel *> *)contacts andDoneAction:(void (^)(NSArray <MVContactModel *> *, NSString *))doneAction;
@end
