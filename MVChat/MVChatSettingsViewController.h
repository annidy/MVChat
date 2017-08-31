//
//  MVChatSettingsViewController.h
//  MVChat
//
//  Created by Mark Vasiv on 12/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVViewController.h"
@class MVChatModel;
@class MVContactModel;
@class DBAttachment;

@interface MVChatSettingsViewController : MVViewController
+ (instancetype)loadFromStoryboardWithContacts:(NSArray <MVContactModel *> *)contacts andDoneAction:(void (^)(NSArray <MVContactModel *> *, NSString *, DBAttachment *))doneAction;
+ (instancetype)loadFromStoryboardWithChat:(MVChatModel *)chat andDoneAction:(void (^)(NSArray <MVContactModel *> *, NSString *, DBAttachment *))doneAction;
@end
