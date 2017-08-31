//
//  MVImageViewerDismissalInteractor.m
//  MVChat
//
//  Created by Mark Vasiv on 30/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVImageViewerDismissalInteractor.h"
#import "MVImageViewerDismissalTransition.h"

@interface MVImageViewerDismissalInteractor ()
@property (strong, nonatomic) MVImageViewerDismissalTransition *transition;
@end

@implementation MVImageViewerDismissalInteractor
- (instancetype)initWithTransition:(MVImageViewerDismissalTransition *)transition {
    if (self = [super init]) {
        _transition = transition;
    }
    
    return self;
}
    
- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    [self.transition start:transitionContext];
}

- (void)updateTransform:(CGAffineTransform)transform {
    [self.transition updateTransform:transform];
}

- (void)updatePercentage:(CGFloat)percentage {
    [self.transition updatePercentage:percentage];
}

- (void)cancel {
    [self.transition cancel];
}

- (void)finish {
    [self.transition finish];
}
@end
