//
//  MVMessagesViewController.h
//  MVChat
//
//  Created by Mark Vasiv on 01/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVViewController.h"
@class MVChatViewModel;

@interface MVChatViewController : MVViewController
+ (instancetype)loadFromStoryboardWithViewModel:(MVChatViewModel *)viewModel;
@end
