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
#import "MVChatModel.h"
#import "MVChatManager.h"

@interface MVChatViewController () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) MVMessagesViewController *MessagesController;
@property (weak, nonatomic) MVFooterViewController *FooterController;

@end

@implementation MVChatViewController
#pragma mark - Initialization
+ (instancetype)loadFromStoryboard {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:@"ChatViewController"];
}

+ (instancetype)loadFromStoryboardWithChat:(MVChatModel *)chat {
    MVChatViewController *instance = [self loadFromStoryboard];
    instance.chat = chat;
    
    return instance;
}

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.chat.title;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Spawn" style:UIBarButtonItemStylePlain target:self action:@selector(spawnNewMessage)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)spawnNewMessage {
    [[MVChatManager sharedInstance] generateMessageForChatWithId:self.chat.id];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [super viewWillDisappear:animated];
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EmbedMessages"]) {
        self.MessagesController = segue.destinationViewController;
        self.MessagesController.chatId = self.chat.id;
    } else if ([segue.identifier isEqualToString:@"EmbedFooter"]) {
        self.FooterController = segue.destinationViewController;
        self.FooterController.chatId = self.chat.id;
    }
}
@end
