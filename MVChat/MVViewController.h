//
//  UIViewController+ForceTouch.h
//  MVChat
//
//  Created by Mark Vasiv on 23/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVForceTouchGestureRecogniser.h"

@protocol MVForceTouchControllerProtocol <NSObject>
- (void)setAppearancePercent:(CGFloat)percent;
- (void)finilizeAppearance;
@end

@protocol MVForceTouchPresentaionDelegate <NSObject>
- (UIViewController <MVForceTouchControllerProtocol> *)forceTouchViewControllerForContext:(NSString *)context;
@end

@interface MVViewController : UIViewController
+ (instancetype)loadFromStoryboard;
- (NSString *)registerForceTouchControllerWithDelegate:(id <MVForceTouchPresentaionDelegate>)delegate andSourceView:(UIView *)sourceView;
- (void)unregisterForceTouchControllerWithContext:(NSString *)context;
@end
