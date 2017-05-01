//
//  MVChatViewController.m
//  MVChat
//
//  Created by Mark Vasiv on 30/04/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVChatViewController.h"
#import "MVMessagesViewController.h"
#import "MVFooterViewController.h"

@interface MVChatViewController () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) MVMessagesViewController *MessagesController;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messagesTableTrailingConstraint;
@property (weak, nonatomic) MVFooterViewController *FooterController;
@end

@implementation MVChatViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EmbedMessages"]) {
        self.MessagesController = segue.destinationViewController;
    } else if ([segue.identifier isEqualToString:@"EmbedFooter"]) {
        self.FooterController = segue.destinationViewController;
    }
}


@end
