//
//  MVImageViewerPresentationTransition.m
//  MVChat
//
//  Created by Mark Vasiv on 30/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVImageViewerPresentationTransition.h"
#import "MVAnimatableImageView.h"

@interface MVImageViewerPresentationTransition()
@property (strong, nonatomic) UIImageView *fromImageView;
@end

@implementation MVImageViewerPresentationTransition
- (instancetype)initFromImageView:(UIImageView *)fromImage {
    if (self = [super init]) {
        _fromImageView =  fromImage;
    }
    
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = transitionContext.containerView;
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromParentView = self.fromImageView.superview;
    
    MVAnimatableImageView *img = [MVAnimatableImageView new];
    img.image = self.fromImageView.image;
    img.frame =  [fromParentView convertRect:self.fromImageView.frame toView:nil];
    img.contentMode = self.fromImageView.contentMode;
    
    UIView *fadeView = [[UIView alloc] initWithFrame:containerView.bounds];
    fadeView.backgroundColor = [UIColor blackColor];
    fadeView.alpha = 0.0;
    
    toView.frame = containerView.bounds;
    toView.hidden = YES;
    self.fromImageView.hidden = YES;
    
    [containerView addSubview:toView];
    [containerView addSubview:fadeView];
    [containerView addSubview:img];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         img.contentMode = UIViewContentModeScaleAspectFit;
                         img.frame = containerView.bounds;
                         fadeView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         toView.hidden = NO;
                         [fadeView removeFromSuperview];
                         [img removeFromSuperview];
                         [transitionContext completeTransition:YES];
                     }];
    
}
@end
