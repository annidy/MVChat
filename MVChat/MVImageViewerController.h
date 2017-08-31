//
//  MVImageViewerController.h
//  MVChat
//
//  Created by Mark Vasiv on 29/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVViewController.h"
@class MVImageViewerViewModel;

@interface MVImageViewerController : MVViewController
+ (instancetype)loadFromStoryboardWithViewModel:(MVImageViewerViewModel *)viewModel;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) MVImageViewerViewModel *viewModel;
@end
