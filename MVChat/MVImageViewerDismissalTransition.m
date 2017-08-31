//
//  MVImageViewerDismissalTransition.m
//  MVChat
//
//  Created by Mark Vasiv on 30/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVImageViewerDismissalTransition.h"
#import "MVAnimatableImageView.h"

typedef enum : NSUInteger {
    TransitionStateStart,
    TransitionStateEnd
} TransitionState;

@interface MVImageViewerDismissalTransition ()
@property (strong, nonatomic) id <UIViewControllerContextTransitioning> transitionContext;
@property (strong, nonatomic) UIImageView *fromImageView;
@property (strong, nonatomic) UIImageView *toImageView;
@property (strong, nonatomic) MVAnimatableImageView *animatableImageview;
@property (strong, nonatomic) UIView *fromView;
@property (strong, nonatomic) UIView *fadeView;

@property (assign, nonatomic) CGAffineTransform translationTransform;
@property (assign, nonatomic) CGAffineTransform scaleTransform;
@property (assign, nonatomic) CGFloat cornerRadius;

@end

@implementation MVImageViewerDismissalTransition
- (instancetype)initWithFromImageView:(UIImageView *)fromImageView toImageView:(UIImageView *)toImageView {
    if (self = [self init]) {
        _fromImageView = fromImageView;
        _toImageView = toImageView;
        _animatableImageview = [MVAnimatableImageView new];
        _fadeView = [UIView new];
        _translationTransform = CGAffineTransformIdentity;
        _scaleTransform = CGAffineTransformIdentity;
    }
    
    return self;
}

- (void)setTranslationTransform:(CGAffineTransform)translationTransform {
    _translationTransform = translationTransform;
    [self updateTransform];
}

- (void)setScaleTransform:(CGAffineTransform)scaleTransform {
    _scaleTransform = scaleTransform;
    [self updateTransform];
}

- (void)updateTransform:(CGAffineTransform)transform {
    self.translationTransform = transform;
}

- (void)updatePercentage:(CGFloat)percentage {
    CGFloat invertedPercentage = 1.0 - percentage;
    self.fadeView.alpha = invertedPercentage;
    self.cornerRadius = self.toImageView.layer.cornerRadius * percentage;
    self.scaleTransform = CGAffineTransformScale(CGAffineTransformIdentity, invertedPercentage, invertedPercentage);
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    [self start:transitionContext];
    [self finish];
}

- (void)start:(id <UIViewControllerContextTransitioning>)transitionContext {
    self.transitionContext = transitionContext;
    self.fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *containerView = transitionContext.containerView;
    UIView *fromSuperView = self.fromImageView.superview;
    UIImage *image = self.fromImageView.image != nil ? self.fromImageView.image : self.toImageView.image;
    
    self.animatableImageview.image = image;
    self.animatableImageview.frame = [fromSuperView convertRect:self.fromImageView.frame toView:nil];
    self.animatableImageview.contentMode = UIViewContentModeScaleAspectFit;
    
    self.fromView.hidden = YES;
    
    self.fadeView.frame = containerView.bounds;
    self.fadeView.backgroundColor = [UIColor blackColor];
    
    [containerView addSubview:self.fadeView];
    [containerView addSubview:self.animatableImageview];
}

- (void)cancel {
    [self.transitionContext cancelInteractiveTransition];
    [UIView animateWithDuration:[self transitionDuration:self.transitionContext]
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self applyState:TransitionStateStart];
                     }
                     completion:^(BOOL finished) {
                         self.fromView.hidden = NO;
                         [self.animatableImageview removeFromSuperview];
                         [self.fadeView removeFromSuperview];
                         [self.transitionContext completeTransition:NO];
                     }];
}

- (void)finish {
    [UIView animateWithDuration:[self transitionDuration:self.transitionContext]
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self applyState:TransitionStateEnd];
                     }
                     completion:^(BOOL finished) {
                         self.toImageView.hidden = NO;
                         [self.fadeView removeFromSuperview];
                         [self.animatableImageview removeFromSuperview];
                         [self.fromView removeFromSuperview];
                         [self.transitionContext completeTransition:finished];
                     }];
}

- (void)updateTransform {
    self.animatableImageview.transform = CGAffineTransformConcat(self.scaleTransform, self.translationTransform);
    self.animatableImageview.cornerRadius = self.cornerRadius;
}

- (void)applyState:(TransitionState)state {
    switch (state) {
        case TransitionStateStart:
            self.animatableImageview.contentMode = UIViewContentModeScaleAspectFit;
            self.animatableImageview.transform = CGAffineTransformIdentity;
            self.animatableImageview.frame = self.fromImageView.frame;
            self.animatableImageview.cornerRadius = 0;
            self.fadeView.alpha = 1.0;
            break;
        case TransitionStateEnd:
            self.animatableImageview.contentMode = self.toImageView.contentMode;
            self.animatableImageview.transform = CGAffineTransformIdentity;
            self.animatableImageview.frame = [self.toImageView.superview convertRect:self.toImageView.frame toView:nil];
            self.animatableImageview.cornerRadius = self.toImageView.layer.cornerRadius;
            self.fadeView.alpha = 0.0;
            break;
    }
}

@end
