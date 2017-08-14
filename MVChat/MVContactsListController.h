//
//  MVContactsListController.h
//  MVChat
//
//  Created by Mark Vasiv on 25/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MVContactModel;

typedef enum : NSUInteger {
    MVContactsListControllerModeDefault,
    MVContactsListControllerModeSelectable
} MVContactsListControllerMode;

@interface MVContactsListController : UIViewController
@property (assign, nonatomic) MVContactsListControllerMode mode;
@property (nonatomic, copy) void (^doneAction)(NSArray <MVContactModel *> *);
+ (instancetype)loadFromStoryboard;
+ (instancetype)loadFromStoryboardWithMode:(MVContactsListControllerMode)mode andDoneAction:(void (^)(NSArray <MVContactModel *> *))doneAction;
+ (instancetype)loadFromStoryboardWithMode:(MVContactsListControllerMode)mode andDoneAction:(void (^)(NSArray <MVContactModel *> *))doneAction excludingContacts:(NSArray <MVContactModel *> *)excludingContacts;
@end
