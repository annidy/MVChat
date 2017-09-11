//
//  MVContactsListController.h
//  MVChat
//
//  Created by Mark Vasiv on 25/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVViewController.h"
@class MVContactModel;
@class MVContactsListViewModel;

@interface MVContactsListController : MVViewController
+ (instancetype)loadFromStoryboardWithViewModel:(MVContactsListViewModel *)viewModel;
@end
