//
//  MVlAttachmentsPageViewController.m
//  MVChat
//
//  Created by Mark Vasiv on 30/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVChatSharedMediaPageController.h"
#import "MVImageViewerController.h"
#import "MVImageViewerViewModel.h"
#import "MVImageViewerTransitioningHandler.h"
#import "MVImageViewerDismissalInteractor.h"

@interface MVChatSharedMediaPageController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) NSArray <MVImageViewerViewModel *> *viewModels;
@property (assign, nonatomic) NSUInteger startIndex;
@property (weak, nonatomic) MVImageViewerController *currentController;
@property (strong, nonatomic) MVImageViewerTransitioningHandler *transitionHandler;
@property (strong, nonatomic) UIPageViewController *pageController;
@end

@implementation MVChatSharedMediaPageController
#pragma mark - Initialization
+ (instancetype)loadFromStoryboardWithViewModels:(NSArray *)viewModels andStartIndex:(NSUInteger)index {
    MVChatSharedMediaPageController *instance = [super loadFromStoryboard];
    instance.modalPresentationStyle = UIModalPresentationOverFullScreen;
    instance.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    instance.modalPresentationCapturesStatusBarAppearance = YES;
    
    instance.viewModels = viewModels;
    instance.startIndex = index;
    
    return instance;
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self setupPageController];
    [self setupInitialController];
    [self setupTransitions];
    [self setupGestureRecognizers];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Setup
- (void)setupPageController {
    UIPageViewController *pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    pageController.view.frame = self.view.bounds;
    [self addChildViewController:pageController];
    [self.view addSubview:pageController.view];
    [pageController didMoveToParentViewController:self];
    
    pageController.dataSource = self;
    pageController.delegate = self;
    self.pageController = pageController;
}

- (void)setupInitialController {
    MVImageViewerController *initialController = [self controllerAtIndex:self.startIndex];
    [self.pageController setViewControllers:@[initialController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.currentController = initialController;
}

- (void)setupGestureRecognizers {
    UIPanGestureRecognizer *panGestureRecognizer = [UIPanGestureRecognizer new];
    [panGestureRecognizer addTarget:self action:@selector(imageViewPanned:)];
    panGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:panGestureRecognizer];
}

- (void)setupTransitions {
    if (!self.currentController.viewModel.sourceImageView) {
        return;
    }
    
    self.transitionHandler = [[MVImageViewerTransitioningHandler alloc] initFromImageView:self.currentController.viewModel.sourceImageView toImageView:self.currentController.imageView];
    self.transitioningDelegate = self.transitionHandler;
}

#pragma mark - Page View Controller
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    MVImageViewerController *imageController = (MVImageViewerController *)viewController;
    return [self controllerAtIndex:imageController.viewModel.index - 1];
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    MVImageViewerController *imageController = (MVImageViewerController *)viewController;
    return [self controllerAtIndex:imageController.viewModel.index + 1];
}

- (MVImageViewerController *)controllerAtIndex:(NSInteger)index {
    if (self.viewModels.count > index && index >= 0) {
        MVImageViewerViewModel *viewModel = self.viewModels[index];
        return [MVImageViewerController loadFromStoryboardWithViewModel:viewModel];
    }
    
    return nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        self.currentController.viewModel.sourceImageView.hidden = NO;
        self.currentController = (MVImageViewerController *)pageViewController.viewControllers[0];
        self.currentController.viewModel.sourceImageView.hidden = YES;
        [self setupTransitions];
    }
}

#pragma mark - Gesture Recognizers
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)recognizer {
    BOOL imageScaled = self.currentController.scrollView.zoomScale == self.currentController.scrollView.minimumZoomScale;
    CGPoint translation = [recognizer translationInView:self.view];
    
    if (imageScaled && (ABS(translation.y) * 0.5 > ABS(translation.x))) {
        return YES;
    } else {
        return NO;
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)imageViewPanned:(UIPanGestureRecognizer *)recognizer {
    if (!self.transitionHandler) {
        return;
    }
    
    CGPoint translation = [recognizer translationInView:self.view];
    CGFloat dragPercentage = ABS(translation.y) / self.view.bounds.size.height;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.transitionHandler.dismissInteractively = YES;
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case UIGestureRecognizerStateChanged:
            [self.transitionHandler.dismissalInteractor updatePercentage:dragPercentage];
            [self.transitionHandler.dismissalInteractor updateTransform:CGAffineTransformMakeTranslation(translation.x, translation.y)];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
                self.transitionHandler.dismissInteractively = NO;
                if (dragPercentage > 0.25 ) {
                    [self.transitionHandler.dismissalInteractor finish];
                } else {
                    [self.transitionHandler.dismissalInteractor cancel];
                }
            break;
        default:
            break;
    }
}
@end
