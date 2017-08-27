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
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UIButton *attatchButton;
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
- (IBAction)attatchButtonTap:(id)sender {
    DBAttachmentPickerController *attachmentPicker = [DBAttachmentPickerController attachmentPickerControllerFinishPickingBlock:^(NSArray<DBAttachment *> *attachmentArray) {
        DBAttachment *attachment = attachmentArray[0];
        //self.avatarAttachment = attachment;
//        [attachment loadThumbnailImageWithTargetSize:CGSizeMake(100, 100) completion:^(UIImage *resultImage) {
////            self.avatarImage = resultImage;
//  //          self.avatarChanged = YES;
////            self.doneButton.enabled = [self canProceed];
//        }];
        
        [[MVChatManager sharedInstance] sendMediaMessageWithAttachment:attachment toChatWithId:self.chatId];
    } cancelBlock:nil];
    
    attachmentPicker.mediaType = DBAttachmentMediaTypeImage;
    [attachmentPicker presentOnViewController:self];

}

@end
