//
//  MVBarButtonMenuController.m
//  MVChat
//
//  Created by Mark Vasiv on 23/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVOverlayMenuController.h"
#import "MVOverlayMenuCell.h"
#import <INTUAnimationEngine.h>

static NSString *textCellId = @"MVBarButtonMenuTextCell";

@implementation MVOverlayMenuElement
+ (instancetype)elementWithTitle:(NSString *)title action:(void (^)())action {
    MVOverlayMenuElement *element = [MVOverlayMenuElement new];
    element.title = title;
    element.action = action;
    return element;
}
@end

@interface MVOverlayMenuController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UIVisualEffectView *blurView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *cancelButtonTop;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *cancelButtonRight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *cancelButtonHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *cancelButtonWidth;
@property (strong, nonatomic) IBOutlet UITableView *menuTableView;
@property (strong, nonatomic) UIViewPropertyAnimator *blurAnimator;
@property (assign, nonatomic) BOOL finalized;
@property (assign, nonatomic) BOOL allowCancel;
@property (strong, nonatomic) NSMutableArray <NSNumber *> *showAnimationIds;
@property (assign, nonatomic) CGFloat menuElementRight;
@end

@implementation MVOverlayMenuController
#pragma mark - Initiaization
+ (instancetype)loadFromStoryboard {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:@"MVOverlayMenuController"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _showAnimationIds = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.blurView.effect = nil;
    self.blurAnimator = [[UIViewPropertyAnimator alloc] initWithDuration:0.6 curve:UIViewAnimationCurveLinear animations:^{
        self.blurView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent];
    }];
    
    self.menuTableView.tableFooterView = [UIView new];
    self.menuTableView.allowsSelection = NO;
    self.menuElementRight = 45;
    
    self.cancelButton.layer.masksToBounds = NO;
    self.cancelButton.layer.shadowColor = [UIColor darkTextColor].CGColor;
    self.cancelButton.layer.shadowOffset = CGSizeMake(1, 1);
    self.cancelButton.layer.shadowOpacity = 0.2f;
    self.cancelButton.layer.shadowRadius = 0.8f;
}

#pragma mark - MVForceTouchControllerProtocol
- (void)setAppearancePercent:(CGFloat)percent {
    if (!self.finalized) {
        self.blurAnimator.fractionComplete = percent;
    }
}

- (void)finilizeAppearance {
    self.finalized = YES;
    [self.blurAnimator startAnimation];
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.4 animations:^{
        self.cancelButton.alpha = 1;
        self.titleLabel.alpha = 1;
        [self.cancelButtonRight setActive:NO];
        [self.cancelButtonTop setActive:NO];
        self.cancelButtonWidth.constant = 50;
        self.cancelButtonHeight.constant = 50;
        [self.view layoutIfNeeded];
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showCells:self.menuTableView.visibleCells withStartCompletion:^{
            self.allowCancel = YES;
        }];
    });
}

#pragma mark - Cells animation
- (void)showCells:(NSArray *)cells withStartCompletion:(void (^)())completion {
    CGFloat startValue = - [UIScreen mainScreen].bounds.size.width - 1;
    CGFloat endValue = self.menuElementRight;
    CGFloat path = ABS(startValue - endValue);
    
    CGFloat duration = 0.7;
    INTUEasingFunction function = INTUEaseOutElastic;
    
    double delayInSeconds = 0.0;
    for (MVOverlayMenuCell *cell in cells) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            INTUAnimationID animationId = [INTUAnimationEngine animateWithDuration:duration delay:0 easing:function animations:^(CGFloat progress) {
                cell.rightButtonConstraint.constant = startValue + path * progress;
                [cell layoutIfNeeded];
            } completion:nil];
            [self.showAnimationIds addObject:@(animationId)];
            if (cells.lastObject == cell && completion) {
                completion();
            }
        });
        delayInSeconds += 0.1;
    }
}

- (void)dismissCells:(NSArray *)cells withCompletion:(void (^)())completion {
    CGFloat startValue = self.menuElementRight;
    CGFloat endValue = [UIScreen mainScreen].bounds.size.width + 1;
    CGFloat path = ABS(startValue - endValue);
    
    CGFloat duration = 0.2;
    INTUEasingFunction function = INTUEaseInBack;
    
    NSInteger index = 0;
    double delayInSeconds = 0.0;
    for (MVOverlayMenuCell *cell in cells) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.showAnimationIds.count > index) {
                [INTUAnimationEngine cancelAnimationWithID:[self.showAnimationIds.reverseObjectEnumerator.allObjects[index] integerValue]];
            }
            [INTUAnimationEngine animateWithDuration:duration delay:0 easing:function animations:^(CGFloat progress) {
                cell.rightButtonConstraint.constant = startValue + path * progress;
                [cell layoutIfNeeded];
            } completion:^(BOOL finished) {
                if (cells.lastObject == cell && completion) {
                    completion();
                }
            }];
        });
        delayInSeconds += 0.05;
        index++;
    }
}

#pragma mark - Table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuElements.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MVOverlayMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:textCellId];
    [cell setButtonText:self.menuElements[indexPath.row].title];
    cell.parentTableView = self.menuTableView;
    cell.indexPath = indexPath;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.allowCancel) {
        return;
    }
    
    [self dismissWithCompletion:^{
        self.menuElements[indexPath.row].action();
    }];
}

#pragma mark - Control actions
- (IBAction)cancelButtonTapped:(id)sender {
    if (self.allowCancel) {
        [self dismissWithCompletion:nil];
    }
}

#pragma mark - Helpers
- (void)dismissWithCompletion:(void (^)())completion {
    [self dismissCells:[self.menuTableView.visibleCells reverseObjectEnumerator].allObjects withCompletion:^{
        [UIView animateWithDuration:0.3 animations:^{
            self.blurView.effect = nil;
            self.cancelButton.alpha = 0;
            self.titleLabel.alpha = 0;
            [self.cancelButtonRight setActive:YES];
            [self.cancelButtonTop setActive:YES];
            self.cancelButtonWidth.constant = 40;
            self.cancelButtonHeight.constant = 40;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self dismissViewControllerAnimated:NO completion:^{
                if (completion) {
                    completion();
                }
            }];
        }];
        
    }];
}
@end
