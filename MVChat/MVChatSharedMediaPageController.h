//
//  MVlAttachmentsPageViewController.h
//  MVChat
//
//  Created by Mark Vasiv on 30/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVViewController.h"
@class MVImageViewerViewModel;

@interface MVChatSharedMediaPageController : MVViewController
+ (instancetype)loadFromStoryboardWithViewModels:(NSArray <MVImageViewerViewModel *> *)viewModels andStartIndex:(NSUInteger)index;
@end
