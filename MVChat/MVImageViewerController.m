//
//  MVImageViewerController.m
//  MVChat
//
//  Created by Mark Vasiv on 29/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVImageViewerController.h"
#import <DBAttachment.h>
#import "MVAnimatableImageView.h"
#import "MVImageViewerViewModel.h"

@interface MVImageViewerController () <UIScrollViewDelegate>
@end

@implementation MVImageViewerController
#pragma mark - Initialization
+ (instancetype)loadFromStoryboardWithViewModel:(MVImageViewerViewModel *)viewModel {
    MVImageViewerController *instance = [super loadFromStoryboard];
    instance.viewModel = viewModel;
    return instance;
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.viewModel.sourceImageView.image) {
        self.imageView.image = self.viewModel.sourceImageView.image;
    } else {
        [self.viewModel.attachment loadThumbnailImageWithTargetSize:CGSizeMake(100, 100) completion:^(UIImage *resultImage) {
            self.imageView.image = resultImage;
        }];
    }
    
    [self setupScrollView];
    [self setupGestureRecognizers];
    [self loadOriginalImage];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Setup
- (void)setupScrollView {
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.alwaysBounceHorizontal = NO;
}

- (void)setupGestureRecognizers {
    UITapGestureRecognizer *tapGestureRecognizer = [UITapGestureRecognizer new];
    tapGestureRecognizer.numberOfTapsRequired = 2;
    [tapGestureRecognizer addTarget:self action:@selector(imageViewDoubleTapped)];
    [self.imageView addGestureRecognizer:tapGestureRecognizer];
}

- (void)loadOriginalImage {
    [self.viewModel.attachment originalImageWithCompletion:^(UIImage *resultImage) {
        self.imageView.image = resultImage;
    }];
}

#pragma mark - Scroll View
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (!self.imageView.image) {
        return;
    }
    
    if (scrollView.zoomScale == scrollView.minimumZoomScale) {
        self.scrollView.alwaysBounceVertical = NO;
        self.scrollView.alwaysBounceHorizontal = NO;
    } else {
        self.scrollView.alwaysBounceVertical = YES;
        self.scrollView.alwaysBounceHorizontal = YES;
    }
    
    CGRect imageViewSize = [MVImageViewUtilities aspectFitRectForSize:self.imageView.image.size insideRect:self.imageView.frame];
    CGFloat verticalInsets = -(scrollView.contentSize.height - MAX(imageViewSize.size.height, scrollView.bounds.size.height)) / 2;
    CGFloat horizontalInsets = -(scrollView.contentSize.width - MAX(imageViewSize.size.width, scrollView.bounds.size.width)) / 2;
    scrollView.contentInset = UIEdgeInsetsMake(verticalInsets, horizontalInsets, verticalInsets, horizontalInsets);
}

#pragma mark - Gesture recognizers
- (void)imageViewDoubleTapped {
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    } else {
        [self.scrollView setZoomScale:self.scrollView.maximumZoomScale animated:YES];
    }
}
    
@end
