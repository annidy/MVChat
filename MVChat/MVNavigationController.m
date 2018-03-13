//
//  MVNavigationController.m
//  MVChat
//
//  Created by Mark Vasiv on 27/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVNavigationController.h"

@interface MVNavigationController ()

@end

@implementation MVNavigationController
#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationBar.translucent = YES;
    if (@available(iOS 11.0, *)) {
        self.navigationBar.prefersLargeTitles = YES;
    }
}
@end
