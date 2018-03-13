//
//  MVContactsListSearchViewController.h
//  MVChat
//
//  Created by Mark Vasiv on 30/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVViewController.h"
@class MVContactsListViewModel;

@interface MVContactsListSearchViewController : MVViewController
+ (instancetype)loadFromStoryboardWithViewModel:(MVContactsListViewModel *)viewModel;
@end
