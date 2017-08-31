//
//  MVImageViewerDismissalInteractor.h
//  MVChat
//
//  Created by Mark Vasiv on 30/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MVImageViewerDismissalTransition;
@interface MVImageViewerDismissalInteractor : NSObject <UIViewControllerInteractiveTransitioning>
- (instancetype)initWithTransition:(MVImageViewerDismissalTransition *)transition;
- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext;
- (void)updateTransform:(CGAffineTransform)transform;
- (void)updatePercentage:(CGFloat)percentage;
- (void)cancel;
- (void)finish;
@end
