//
//  MVFooterViewController.m
//  MVChat
//
//  Created by Mark Vasiv on 01/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVFooterViewController.h"
#import "MVChatManager.h"
#import <DBAttachmentPickerController.h>
#import <DBAttachment.h>

@interface MVFooterViewController () <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *messageTextField;
@property (strong, nonatomic) IBOutlet UIView *messageTextFieldMask;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UIButton *attatchButton;
@end

@implementation MVFooterViewController
#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.sendButton.enabled = NO;
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    self.messageTextFieldMask.layer.cornerRadius = 15;
    self.messageTextFieldMask.layer.borderWidth = 1;
    self.messageTextFieldMask.layer.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1].CGColor;
    self.messageTextFieldMask.layer.masksToBounds = YES;
}

#pragma mark - IBActions
- (IBAction)messageTextFieldChanged:(id)sender {
    self.sendButton.enabled = [self.messageTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0;
}

- (IBAction)sendButtonPress:(id)sender {
    self.sendButton.enabled = NO;
    [[MVChatManager sharedInstance] sendTextMessage:self.messageTextField.text toChatWithId:self.chatId];
    self.messageTextField.text = @"";
}

- (IBAction)attatchButtonTap:(id)sender {
    DBAttachmentPickerController *attachmentPicker = [DBAttachmentPickerController attachmentPickerControllerFinishPickingBlock:^(NSArray<DBAttachment *> *attachmentArray) {
        [[MVChatManager sharedInstance] sendMediaMessageWithAttachment:attachmentArray[0] toChatWithId:self.chatId];
    } cancelBlock:nil];
    
    attachmentPicker.mediaType = DBAttachmentMediaTypeImage;
    [attachmentPicker presentOnViewController:self];
}
@end
