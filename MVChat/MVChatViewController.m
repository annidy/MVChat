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
#import "MVContactManager.h"
#import "MVOverlayMenuController.h"

@interface MVChatViewController () <MVForceTouchPresentaionDelegate>
@property (weak, nonatomic) MVMessagesViewController *MessagesController;
@property (weak, nonatomic) MVFooterViewController *FooterController;
@property (strong, nonatomic) UILabel *navigationItemTitleLabel;
@property (strong, nonatomic) UIImageView *avatarImageView;
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
    
    //buttons
    UIImageView *imageView = [UIImageView new];
    imageView.frame = CGRectMake(0, 0, 34, 34);
    imageView.layer.cornerRadius = 17;
    imageView.layer.masksToBounds = YES;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    self.navigationItem.rightBarButtonItem = item;
    self.avatarImageView = imageView;
    if (self.chat.isPeerToPeer) {
        [[MVContactManager sharedInstance] loadAvatarThumbnailForContact:self.chat.getPeer completion:^(UIImage *image) {
            [self.avatarImageView setImage:image];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:@"ContactAvatarUpdate" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            NSString *contactId = note.userInfo[@"Id"];
            UIImage *image = note.userInfo[@"Image"];
            if (self.chat.isPeerToPeer && [self.chat.getPeer.id isEqualToString:contactId]) {
                [self.avatarImageView setImage:image];
            }
        }];
    } else {
        [[MVChatManager sharedInstance] loadAvatarThumbnailForChat:self.chat completion:^(UIImage *image) {
            [self.avatarImageView setImage:image];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:@"ChatAvatarUpdate" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            NSString *chatId = note.userInfo[@"Id"];
            UIImage *image = note.userInfo[@"Image"];
            if (!self.chat.isPeerToPeer && [self.chat.id isEqualToString:chatId]) {
                [self.avatarImageView setImage:image];
            }
        }];
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigationItemTitleTappedAction)];
    [self.avatarImageView addGestureRecognizer:tapGesture];
    
    [self registerForceTouchControllerWithDelegate:self andSourceView:self.avatarImageView];
    
}

- (UIViewController<MVForceTouchControllerProtocol> *)forceTouchViewControllerForContext:(NSString *)context {
    MVOverlayMenuController *menu = [MVOverlayMenuController loadFromStoryboard];
    NSMutableArray *items = [NSMutableArray new];
    [items addObject:[MVOverlayMenuElement elementWithTitle:@"Open profile" action:^{
        [self navigationItemTitleTappedAction];
    }]];
    [items addObject:[MVOverlayMenuElement elementWithTitle:@"Spawn message" action:^{
        [self spawnNewMessage];
    }]];
    [items addObject:[MVOverlayMenuElement elementWithTitle:@"Generate avatars" action:^{
        
    }]];
    
    menu.menuElements = items;
    
    return menu;
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
        if (attachment) {
            [[MVFileManager sharedInstance] saveAttachment:attachment asChatAvatar:self.chat];
        }
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
