//
//  MVForceTouchGestureRecogniser.h
//  MVChat
//
//  Created by Mark Vasiv on 23/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MVForceTouchGestureRecogniser;

@protocol MVForceTouchRecogniserDelegate <NSObject>
- (void)forceTouchRecognized:(MVForceTouchGestureRecogniser*)recognizer;
@optional
- (void)forceTouchRecognizer:(MVForceTouchGestureRecogniser *)recognizer didStartWithForce:(CGFloat)force maxForce:(CGFloat)maxForce;
- (void)forceTouchRecognizer:(MVForceTouchGestureRecogniser *)recognizer didMoveWithForce:(CGFloat)force maxForce:(CGFloat)maxForce;
- (void)forceTouchRecognizer:(MVForceTouchGestureRecogniser *)recognizer didCancelWithForce:(CGFloat)force maxForce:(CGFloat)maxForce;
- (void)forceTouchRecognizer:(MVForceTouchGestureRecogniser *)recognizer didEndWithForce:(CGFloat)force maxForce:(CGFloat)maxForce;
@end

@interface MVForceTouchGestureRecogniser : UIGestureRecognizer
@property(nonatomic, weak) id<MVForceTouchRecogniserDelegate> forceTouchDelegate;
+ (instancetype)recogniserWithDelegate:(id <MVForceTouchRecogniserDelegate>)delegate andSourceView:(UIView *)sourceView;
@end
