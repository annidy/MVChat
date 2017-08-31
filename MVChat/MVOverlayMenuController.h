//
//  MVBarButtonMenuController.h
//  MVChat
//
//  Created by Mark Vasiv on 23/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVViewController.h"

@interface MVOverlayMenuElement : NSObject
@property (strong, nonatomic) NSString *title;
@property (nonatomic, copy) void (^action)();
+ (instancetype)elementWithTitle:(NSString *)title action:(void (^)())action;
@end

@interface MVOverlayMenuController : MVViewController <MVForceTouchControllerProtocol>
@property (strong, nonatomic) NSArray <MVOverlayMenuElement *> *menuElements;
@end
