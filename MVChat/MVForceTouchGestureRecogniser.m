//
//  MVForceTouchGestureRecogniser.m
//  MVChat
//
//  Created by Mark Vasiv on 23/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVForceTouchGestureRecogniser.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "NSInvocation+Protocols.h"


static CGFloat const kForceTouchBaseDefaultPressureThreshold = 0.5f;
static CGFloat const kForceTouchDefaultTriggerPressureThreshold = 3.0f;
static NSTimeInterval const kLongTapDefaultThresholdInterval = 0.3f;
static NSTimeInterval const kLongTapDefaultFinalInterval = 0.8f;

@interface MVForceTouchGestureRecogniser()
@property(nonatomic, assign) BOOL forceTouchFired;
@property(nonatomic, assign) BOOL forceTouchInitialTouchDetect;
@property (strong, nonatomic) NSTimer *initialTimer;
@property (strong, nonatomic) NSTimer *finalTimer;
@property (assign, nonatomic) BOOL forceTouchAvailable;
@end

@implementation MVForceTouchGestureRecogniser
+ (instancetype)recogniserWithDelegate:(id <MVForceTouchRecogniserDelegate>)delegate andSourceView:(UIView *)sourceView {
    MVForceTouchGestureRecogniser *recogniser = [MVForceTouchGestureRecogniser new];
    recogniser.forceTouchDelegate = delegate;
    [sourceView addGestureRecognizer:recogniser];
    recogniser.forceTouchAvailable = [[sourceView traitCollection] forceTouchCapability] == UIForceTouchCapabilityAvailable;
    
    return recogniser;
}

- (void)reset {
    [super reset];
    
    self.forceTouchFired = NO;
    self.forceTouchInitialTouchDetect = NO;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    if (self.forceTouchAvailable) {
        UITouch *aTouch = touches.anyObject;
        if(aTouch.force > kForceTouchBaseDefaultPressureThreshold) {
            self.state = UIGestureRecognizerStatePossible;
            [self forceTouchStartedWithTouch:aTouch];
        }
    } else {
        self.initialTimer = [NSTimer scheduledTimerWithTimeInterval:kLongTapDefaultThresholdInterval repeats:NO block:^(NSTimer *timer) {
            self.state = UIGestureRecognizerStatePossible;
            [self forceTouchStartedWithTouch:nil];
        }];
        self.finalTimer = [NSTimer scheduledTimerWithTimeInterval:kLongTapDefaultFinalInterval repeats:NO block:^(NSTimer *timer) {
            [self forceTouchFired:nil];
        }];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    if (self.forceTouchAvailable) {
        UITouch *aTouch = touches.anyObject;
        if(self.forceTouchInitialTouchDetect) {
            [self forceTouchUpdatedWithTouch:aTouch];
        } else if(aTouch.force > kForceTouchBaseDefaultPressureThreshold) {
            [self forceTouchStartedWithTouch:aTouch];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    if(self.forceTouchInitialTouchDetect) {
        self.state = UIGestureRecognizerStateEnded;
        if (self.forceTouchAvailable) {
            UITouch *aTouch = touches.anyObject;
            [self tryToCallDelegateSelector:@selector(forceTouchRecognizer:didEndWithForce:maxForce:) withForce:aTouch.force andMaxForce:aTouch.maximumPossibleForce];
        } else {
            [self tryToCallDelegateSelector:@selector(forceTouchRecognizer:didEndWithForce:maxForce:) withForce:0 andMaxForce:0];
        }
        
    } else {
        self.state = UIGestureRecognizerStateCancelled;
    }
    
    [self.initialTimer invalidate];
    [self.finalTimer invalidate];
    self.forceTouchInitialTouchDetect = NO;
    self.forceTouchFired = NO;
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if(self.forceTouchInitialTouchDetect) {
        self.state = UIGestureRecognizerStateEnded;
        if (self.forceTouchAvailable) {
            UITouch *aTouch = touches.anyObject;
            [self tryToCallDelegateSelector:@selector(forceTouchRecognizer:didEndWithForce:maxForce:) withForce:aTouch.force andMaxForce:aTouch.maximumPossibleForce];
        } else {
            [self tryToCallDelegateSelector:@selector(forceTouchRecognizer:didEndWithForce:maxForce:) withForce:0 andMaxForce:0];
        }
        
    } else {
        self.state = UIGestureRecognizerStateCancelled;
    }
    
    [self.initialTimer invalidate];
    [self.finalTimer invalidate];
    self.forceTouchInitialTouchDetect = NO;
    self.forceTouchFired = NO;
}

- (void)forceTouchStartedWithTouch:(UITouch *) touch {
    self.forceTouchInitialTouchDetect = YES;
    [self tryToCallDelegateSelector:@selector(forceTouchRecognizer:didStartWithForce:maxForce:) withForce:touch.force andMaxForce:touch.maximumPossibleForce];
}


- (void)forceTouchUpdatedWithTouch:(UITouch *) touch {
    if(!self.forceTouchFired && touch.force >= kForceTouchDefaultTriggerPressureThreshold) {
        [self forceTouchFired:self];
    }
    
    [self tryToCallDelegateSelector:@selector(forceTouchRecognizer:didMoveWithForce:maxForce:) withForce:touch.force andMaxForce:touch.maximumPossibleForce];
    
}

- (void)forceTouchFired:(id)sender {
    self.forceTouchFired = YES;
    
    if(self.forceTouchDelegate) {
        [self.forceTouchDelegate forceTouchRecognized:self];
    }
}

- (void)tryToCallDelegateSelector:(SEL)selector withForce:(CGFloat)force andMaxForce:(CGFloat)maxForce {
    if (!self.forceTouchDelegate || ![self.forceTouchDelegate respondsToSelector:selector]) {
        return;
    }
    
    NSInvocation *invocation = [NSInvocation invocationWithProtocol:@protocol(MVForceTouchRecogniserDelegate) selector:selector target:self.forceTouchDelegate];
    [invocation setArgument:(void *)&self atIndex:2];
    
    NSInteger numberOfArguments = [NSStringFromSelector(selector) componentsSeparatedByString:@":"].count - 1;
    
    if (numberOfArguments > 1) {
        [invocation setArgument:&force atIndex:3];
    }
    
    if (numberOfArguments > 2) {
        [invocation setArgument:&maxForce atIndex:4];
    }
    
    [invocation invoke];
}
@end
