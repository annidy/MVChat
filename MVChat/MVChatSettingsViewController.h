//
//  MVChatSettingsViewController.h
//  MVChat
//
//  Created by Mark Vasiv on 12/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVViewController.h"
@class MVChatSettingsViewModel;

@interface MVChatSettingsViewController : MVViewController
+ (instancetype)loadFromStoryboardWithViewModel:(MVChatSettingsViewModel *)viewModel;
@end
