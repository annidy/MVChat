//
//  UIViewController+ForceTouch.m
//  MVChat
//
//  Created by Mark Vasiv on 23/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVViewController.h"
#import <objc/runtime.h>
#import <AudioToolbox/AudioToolbox.h>

@interface MVForceTouchListener : NSObject <MVForceTouchRecogniserDelegate>
@property (strong, nonatomic) NSString *context;
@property (weak, nonatomic) UIViewController <MVForceTouchControllerProtocol> *forceViewController;
@property (weak, nonatomic) id<MVForceTouchPresentaionDelegate> delegate;
@property (assign, nonatomic) BOOL menuControllerShown;
@property (assign, nonatomic) BOOL menuControllerFinalized;
@property (strong, nonatomic) MVForceTouchGestureRecogniser *gestureRecogniser;
@property (weak, nonatomic) UIViewController *sender;
@property (weak, nonatomic) UIView *sourceView;

@end

@implementation MVForceTouchListener
- (instancetype)initWithContext:(NSString *)context presentationDelegate:(id <MVForceTouchPresentaionDelegate>)delegate senderController:(UIViewController *)sender andSourceView:(UIView *)sourceView {
    if (self = [super init]) {
        _menuControllerShown = NO;
        _menuControllerFinalized = NO;
        _context = context;
        _delegate = delegate;
        _sender = sender;
        _sourceView = sourceView;
        _gestureRecogniser = [MVForceTouchGestureRecogniser recogniserWithDelegate:self andSourceView:sourceView];;
    }
    return self;
}

- (void)forceTouchRecognized:(MVForceTouchGestureRecogniser *)recognizer {
    if (self.menuControllerShown) {
        [self.forceViewController finilizeAppearance];
        self.menuControllerFinalized = YES;
        AudioServicesPlaySystemSound(1520);
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self forceTouchRecognized:recognizer];
        });
        
    }
}

- (void)forceTouchRecognizer:(MVForceTouchGestureRecogniser *)recognizer didStartWithForce:(CGFloat)force maxForce:(CGFloat)maxForce {
    if (self.menuControllerShown) {
        return;
    }
    
    self.forceViewController = [self.delegate forceTouchViewControllerForContext:self.context];
    self.forceViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    
    [self.sender presentViewController:self.forceViewController animated:NO completion:^{
        self.menuControllerShown = YES;
    }];
}

- (void)forceTouchRecognizer:(MVForceTouchGestureRecogniser *)recognizer didMoveWithForce:(CGFloat)force maxForce:(CGFloat)maxForce {
    if (self.menuControllerShown) {
        [self.forceViewController setAppearancePercent:force/maxForce];
    }
}

- (void)forceTouchRecognizer:(MVForceTouchGestureRecogniser *)recognizer didEndWithForce:(CGFloat)force maxForce:(CGFloat)maxForce {
    if (!self.menuControllerFinalized) {
        if (self.menuControllerShown) {
            [self.forceViewController cancel];
            [self.sender dismissViewControllerAnimated:NO completion:nil];
        }
    }
    self.menuControllerShown = NO;
    self.menuControllerFinalized = NO;
}

- (void)stopListenting {
    [self.sourceView removeGestureRecognizer:self.gestureRecogniser];
}
@end

@interface MVViewController ()
@property (strong, nonatomic) NSMutableArray *forceTouchListeners;
@property (strong, nonatomic) NSString *registrationContext;
@end

@implementation MVViewController : UIViewController
+ (instancetype)loadFromStoryboard {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.definesPresentationContext = YES;
        _forceTouchListeners = [NSMutableArray new];
        _registrationContext = @"0";
    }
    
    return self;
}

- (NSString *)registerForceTouchControllerWithDelegate:(id)delegate andSourceView:(UIView *)sourceView {
    self.registrationContext = [self incrementContext:self.registrationContext];
    MVForceTouchListener *forceTouchListener = [[MVForceTouchListener alloc] initWithContext:self.registrationContext presentationDelegate:delegate senderController:self andSourceView:sourceView];
    [self.forceTouchListeners addObject:forceTouchListener];
    
    return self.registrationContext;
}

- (void)unregisterForceTouchControllerWithContext:(NSString *)context {
    [self stopListeningAndRemoveForceTouchListenerWithContext:context];
}

#pragma mark - Helpers
- (NSString *)incrementContext:(NSString *)context {
    return [NSString stringWithFormat:@"%ld", [context integerValue] + 1];
}

- (void)stopListeningAndRemoveForceTouchListenerWithContext:(NSString *)context {
    NSMutableArray *objects = [self.forceTouchListeners mutableCopy];
    for (MVForceTouchListener *object in objects) {
        if ([object.context isEqualToString:context]) {
            [object stopListenting];
            [self.forceTouchListeners removeObject:object];
        }
    }
}
@end
