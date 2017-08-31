//
//  MVChatAttachmentsViewController.h
//  MVChat
//
//  Created by Mark Vasiv on 28/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVViewController.h"

@interface MVChatSharedMediaListController : MVViewController
+ (instancetype)loadFromStoryboardWithChatId:(NSString *)chatId;
@end
