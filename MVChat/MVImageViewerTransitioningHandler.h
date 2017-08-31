//
//  MVImageViewerTransitioningHandler.h
//  MVChat
//
//  Created by Mark Vasiv on 30/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MVImageViewerPresentationTransition;
@class MVImageViewerDismissalTransition;
@class MVImageViewerDismissalInteractor;

@interface MVImageViewerTransitioningHandler : NSObject <UIViewControllerTransitioningDelegate>
@property (assign, nonatomic) BOOL dismissInteractively;
@property (strong, nonatomic) MVImageViewerPresentationTransition *presentationTransition;
@property (strong, nonatomic) MVImageViewerDismissalTransition *dismissalTransition;
@property (strong, nonatomic) MVImageViewerDismissalInteractor *dismissalInteractor;
- (instancetype)initFromImageView:(UIImageView *)from toImageView:(UIImageView *)to;
@end
