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
#import "MVChatSettingsViewController.h"
#import "MVDatabaseManager.h"
#import "MVFileManager.h"
#import "MVContactProfileViewController.h"
#import "MVContactModel.h"

@interface MVChatViewController () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) MVMessagesViewController *MessagesController;
@property (weak, nonatomic) MVFooterViewController *FooterController;
@property (strong, nonatomic) UILabel *navigationItemTitleLabel;
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
    [self setupNavigationBar];
}

- (void)setupNavigationBar {
    //title label
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17];
    titleLabel.text = self.chat.title;
    CGFloat labelWidth = [titleLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].width;
    titleLabel.frame = CGRectMake(0,0, labelWidth, 500);
    titleLabel.userInteractionEnabled = YES;
    self.navigationItemTitleLabel = titleLabel;
    self.navigationItem.titleView = titleLabel;
    
    UITapGestureRecognizer *titleLabelTapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigationItemTitleTappedAction)];
    [self.navigationItem.titleView addGestureRecognizer:titleLabelTapRecogniser];
    
    //buttons
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Spawn" style:UIBarButtonItemStylePlain target:self action:@selector(spawnNewMessage)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)navigationItemTitleTappedAction {
    if (self.chat.isPeerToPeer) {
        [self showContactProfile];
    } else {
        [self showChatSettings];
    }
}

- (void)showChatSettings {
    MVChatSettingsViewController *settings = [MVChatSettingsViewController loadFromStoryboardWithChat:self.chat andDoneAction:^(NSArray<MVContactModel *> *contacts, NSString *title, DBAttachment *attachment) {
        self.chat.participants = [contacts arrayByAddingObject:[MVDatabaseManager sharedInstance].myContact];
        self.chat.title = title;
        [[MVChatManager sharedInstance] updateChat:self.chat];
        self.navigationItemTitleLabel.text = title;
        [self.navigationController popViewControllerAnimated:YES];
        [[MVFileManager sharedInstance] saveAttachment:attachment asChatAvatar:self.chat];
    }];
    
    [self.navigationController pushViewController:settings animated:YES];
}

- (void)showContactProfile {
    MVContactModel *peer;
    for (MVContactModel *contact in self.chat.participants) {
        if (!contact.iam) {
            peer = contact;
        }
    }
    MVContactProfileViewController *contactProfile = [MVContactProfileViewController loadFromStoryboardWithContact:peer];
    [self.navigationController pushViewController:contactProfile animated:YES];
}

- (void)spawnNewMessage {
    [[MVChatManager sharedInstance] generateMessageForChatWithId:self.chat.id];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:animated];
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
