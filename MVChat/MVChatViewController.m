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
#import <DBAttachment.h>
#import "MVUpdatesProvider.h"

@interface MVChatViewController () <MVForceTouchPresentaionDelegate>
@property (weak, nonatomic) MVMessagesViewController *MessagesController;
@property (weak, nonatomic) MVFooterViewController *FooterController;
@property (strong, nonatomic) UILabel *navigationItemTitleLabel;
@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *inputPanelBottom;
@end

@implementation MVChatViewController
#pragma mark - Initialization
+ (instancetype)loadFromStoryboardWithChat:(MVChatModel *)chat {
    MVChatViewController *instance = [super loadFromStoryboard];
    instance.chat = chat;
    
    return instance;
}

#pragma mark - Lifecycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    [self adjustInputPanelPositionDuringKeyabordAppear:YES withNotification:notification];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self adjustInputPanelPositionDuringKeyabordAppear:NO withNotification:notification];
}

- (void)adjustInputPanelPositionDuringKeyabordAppear:(BOOL)appear withNotification:(NSNotification *)notification {
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGRect keyboardFrameEnd = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = CGRectGetHeight(keyboardFrameEnd);
    
    self.inputPanelBottom.constant = appear? keyboardHeight : 0;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
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
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.borderWidth = 0.3f;
    imageView.layer.borderColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.4].CGColor;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    self.navigationItem.rightBarButtonItem = item;
    self.avatarImageView = imageView;
    
    [[imageView.widthAnchor constraintEqualToConstant:34] setActive:YES];
    [[imageView.heightAnchor constraintEqualToConstant:34] setActive:YES];
    
    [[MVFileManager sharedInstance] loadThumbnailAvatarForChat:self.chat maxWidth:50 completion:^(UIImage *image) {
        self.avatarImageView.image = image;
    }];
    
    __weak typeof(self) weakSelf = self;
    if (self.chat.isPeerToPeer) {
        [[NSNotificationCenter defaultCenter] addObserverForName:@"ContactAvatarUpdate" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            NSString *contactId = note.userInfo[@"Id"];
            UIImage *image = note.userInfo[@"Image"];
            if (weakSelf.chat.isPeerToPeer && [weakSelf.chat.getPeer.id isEqualToString:contactId]) {
                [weakSelf.avatarImageView setImage:image];
            }
        }];
    } else {
        [[NSNotificationCenter defaultCenter] addObserverForName:@"ChatAvatarUpdate" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            NSString *chatId = note.userInfo[@"Id"];
            UIImage *image = note.userInfo[@"Image"];
            if (!weakSelf.chat.isPeerToPeer && [weakSelf.chat.id isEqualToString:chatId]) {
                [weakSelf.avatarImageView setImage:image];
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
    
    NSString *chatId = [self.chat.id copy];
    NSArray *contacts = [self.chat.participants copy];
    [items addObject:[MVOverlayMenuElement elementWithTitle:@"Generate message" action:^{
        [[MVUpdatesProvider sharedInstance] generateMessageForChatWithId:chatId];
    }]];
    [items addObject:[MVOverlayMenuElement elementWithTitle:@"Update avatars" action:^{
        [[MVUpdatesProvider sharedInstance] performAvatarsUpdateForContacts:contacts];
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
        self.chat.participants = [contacts arrayByAddingObject:MVContactManager.myContact];
        self.chat.title = title;
        [[MVChatManager sharedInstance] updateChat:self.chat];
        self.navigationItemTitleLabel.text = title;
        [self.navigationController popViewControllerAnimated:YES];
        if (attachment) {
            [[MVFileManager sharedInstance] saveChatAvatar:self.chat attachment:attachment];
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
