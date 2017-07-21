//
//  MVFooterViewController.m
//  MVChat
//
//  Created by Mark Vasiv on 01/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVFooterViewController.h"
#import "MVChatManager.h"

@interface MVFooterViewController () <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *messageTextField;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@end

@implementation MVFooterViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.sendButton.enabled = NO;
}

- (IBAction)messageTextFieldChanged:(id)sender {
    self.sendButton.enabled = [self.messageTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0;
}
- (IBAction)sendButtonPress:(id)sender {
    self.sendButton.enabled = NO;
    [[MVChatManager sharedInstance] sendTextMessage:self.messageTextField.text toChatWithId:self.chatId];
    self.messageTextField.text = @"";
}

@end
