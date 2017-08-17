//
//  MVContactProfileViewController.h
//  MVChat
//
//  Created by Mark Vasiv on 17/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MVContactModel;

@interface MVContactProfileViewController : UIViewController
+ (instancetype)loadFromStoryboard;
+ (instancetype)loadFromStoryboardWithContact:(MVContactModel *)contact;
@end
