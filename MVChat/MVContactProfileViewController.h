//
//  MVContactProfileViewController.h
//  MVChat
//
//  Created by Mark Vasiv on 17/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVViewController.h"
@class MVContactProfileViewModel;

@interface MVContactProfileViewController : MVViewController
+ (instancetype)loadFromStoryboardWithViewModel:(MVContactProfileViewModel *)viewModel;
@end
