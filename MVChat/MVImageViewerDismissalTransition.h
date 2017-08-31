//
//  MVImageViewerDismissalTransition.h
//  MVChat
//
//  Created by Mark Vasiv on 30/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MVImageViewerDismissalTransition : NSObject <UIViewControllerAnimatedTransitioning>
- (instancetype)initWithFromImageView:(UIImageView *)fromImageView toImageView:(UIImageView *)toImageView;
- (void)start:(id <UIViewControllerContextTransitioning>)transitionContext;
- (void)updateTransform:(CGAffineTransform)transform;
- (void)updatePercentage:(CGFloat)percentage;
- (void)cancel;
- (void)finish;
@end
