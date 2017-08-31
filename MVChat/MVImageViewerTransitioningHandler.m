//
//  MVImageViewerTransitioningHandler.m
//  MVChat
//
//  Created by Mark Vasiv on 30/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVImageViewerTransitioningHandler.h"
#import "MVImageViewerPresentationTransition.h"
#import "MVImageViewerDismissalTransition.h"
#import "MVImageViewerDismissalInteractor.h"

@interface MVImageViewerTransitioningHandler()

@end

@implementation MVImageViewerTransitioningHandler
- (instancetype)initFromImageView:(UIImageView *)from toImageView:(UIImageView *)to {
    if (self = [super init]) {
        _presentationTransition = [[MVImageViewerPresentationTransition alloc] initFromImageView:from];
        _dismissalTransition = [[MVImageViewerDismissalTransition alloc] initWithFromImageView:to toImageView:from];
        _dismissalInteractor = [[MVImageViewerDismissalInteractor alloc] initWithTransition:_dismissalTransition];
    }
    
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self.presentationTransition;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self.dismissalTransition;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    return self.dismissInteractively ? self.dismissalInteractor : nil;
}


@end
