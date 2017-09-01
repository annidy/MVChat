//
//  MVChatSettingsViewController.m
//  MVChat
//
//  Created by Mark Vasiv on 12/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVChatSettingsViewController.h"
#import "MVContactModel.h"
#import "MVContactManager.h"
#import "MVChatModel.h"
#import "MVContactsListController.h"
#import "MVChatManager.h"
#import <DBAttachmentPickerController.h>
#import <DBAttachment.h>
#import "MVFileManager.h"
#import "MVContactProfileViewController.h"
#import "NSString+Helpers.h"

typedef enum : NSUInteger {
    MVChatSettingsModeNew,
    MVChatSettingsModeSettings
} MVChatSettingsMode;

@interface MVChatSettingsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) MVChatSettingsMode mode;
@property (strong, nonatomic) MVChatModel *chat;
@property (strong, nonatomic) NSMutableArray <MVContactModel *> *contacts;
@property (weak, nonatomic) UITextField *titleTextField;
@property (strong, nonatomic) NSString *chatTitle;
@property (nonatomic, copy) void (^doneAction)(NSArray <MVContactModel *> *, NSString *, DBAttachment *);
@property (strong, nonatomic) UIBarButtonItem *doneButton;
@property (weak, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UIImage *avatarImage;
@property (strong, nonatomic) DBAttachment *avatarAttachment;
@property (assign, nonatomic) BOOL avatarChanged;
@end

static NSString *AvatarTitleCellId = @"MVChatSettingsAvatarTitleCell";
static NSString *AvatarCellId = @"MVChatSettingsAvatarCell";
static NSString *ContactCellId = @"MVChatSettingsContactCell";
static NSString *NewContactCellId = @"MVChatSettingsNewContactCell";
static NSString *DeleteContactCellId = @"MVChatSettingsDeleteCell";

@implementation MVChatSettingsViewController
#pragma mark - Initialization
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _contacts = [NSMutableArray new];
    }
    
    return self;
}

+ (instancetype)loadFromStoryboardWithContacts:(NSArray <MVContactModel *> *)contacts andDoneAction:(void (^)(NSArray <MVContactModel *> *, NSString *, DBAttachment *))doneAction {
    MVChatSettingsViewController *instance = [super loadFromStoryboard];
    instance.contacts = [contacts mutableCopy];
    instance.doneAction = doneAction;
    instance.mode = MVChatSettingsModeNew;
    
    return instance;
}

+ (instancetype)loadFromStoryboardWithChat:(MVChatModel *)chat andDoneAction:(void (^)(NSArray <MVContactModel *> *, NSString *, DBAttachment *))doneAction {
    MVChatSettingsViewController *instance = [super loadFromStoryboard];
    instance.chat = chat;
    instance.doneAction = doneAction;
    instance.mode = MVChatSettingsModeSettings;
    
    for (MVContactModel *contact in chat.participants) {
        if (!contact.iam) {
            [instance.contacts addObject:contact];
        }
    }
    
    return instance;
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addObserver:self forKeyPath:@"titleTextField" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"avatarImage" options:NSKeyValueObservingOptionNew context:nil];
    [self setupNavigationBar];
    
    if (self.mode == MVChatSettingsModeSettings) {
        self.chatTitle = self.chat.title;
        [[MVChatManager sharedInstance] loadAvatarThumbnailForChat:self.chat completion:^(UIImage *image) {
            self.avatarImage = image;
            self.avatarImageView.image = image;
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:@"ChatAvatarUpdate" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            NSString *chatId = note.userInfo[@"Id"];
            UIImage *image = note.userInfo[@"Image"];
            if ([self.chat.id isEqualToString:chatId]) {
                self.avatarImageView.image = image;
                self.avatarImage = image;
            }
        }];
    }
}

- (void)setupNavigationBar {
    NSString *doneButtonTitle;
    NSString *navigationBarTitle;
    if (self.mode == MVChatSettingsModeNew) {
        doneButtonTitle = @"Create";
        navigationBarTitle = @"New chat";
    } else if (self.mode == MVChatSettingsModeSettings) {
        doneButtonTitle = @"Done";
        navigationBarTitle = @"Settings";
    }
    self.doneButton = [[UIBarButtonItem alloc] initWithTitle:doneButtonTitle style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonAction)];
    self.navigationItem.rightBarButtonItem = self.doneButton;
    self.navigationItem.title = navigationBarTitle;
    self.doneButton.enabled = NO;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"titleTextField"];
    [self.titleTextField removeTarget:self action:@selector(titleTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self removeObserver:self forKeyPath:@"avatarImage"];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self && [keyPath isEqualToString:@"titleTextField"]) {
        UITextField *oldTextField = change[NSKeyValueChangeOldKey];
        UITextField *newTextField = change[NSKeyValueChangeNewKey];
        
        if (oldTextField && ![oldTextField isEqual:[NSNull null]]) {
            [oldTextField removeTarget:self action:@selector(titleTextDidChange:) forControlEvents:UIControlEventEditingChanged];
        }
        
        [newTextField addTarget:self action:@selector(titleTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    } else if (object == self && [keyPath isEqualToString:@"avatarImage"]) {
        UIImage *newImage = change[NSKeyValueChangeNewKey];
        self.avatarImageView.image = newImage;
    }
}

#pragma mark - Button and control actions
- (void)titleTextDidChange:(UITextField *)textField {
    self.chatTitle = textField.text;
    self.doneButton.enabled = [self canProceed];
}

- (void)doneButtonAction {
    self.doneAction(self.contacts, self.chatTitle, self.avatarAttachment);
}

#pragma mark - Table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.mode == MVChatSettingsModeNew) {
        return 2;
    } else {
        return 3;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return self.contacts.count + 1;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 100;
        }
    }
    
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGFLOAT_MIN;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AvatarTitleCellId];
            UIImageView *avatarImageView = [cell viewWithTag:1];
            avatarImageView.backgroundColor = [UIColor lightGrayColor];
            avatarImageView.layer.masksToBounds = YES;
            avatarImageView.layer.cornerRadius = 30;
            
            UITapGestureRecognizer *tapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showChatPhotoSelectController)];
            avatarImageView.userInteractionEnabled = YES;
            [avatarImageView addGestureRecognizer:tapGestureRecogniser];
            
            if (self.avatarImage) {
                avatarImageView.image = self.avatarImage;
            } else {
                //set placeholder
            }
            
            self.avatarImageView = avatarImageView;
            
            UITextField *textField = [cell viewWithTag:2];
            textField.text = self.chatTitle;
            self.titleTextField = textField;
            return cell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AvatarCellId];
            return cell;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            return [tableView dequeueReusableCellWithIdentifier:NewContactCellId];
        }
        
        MVContactModel *contact = self.contacts[indexPath.row - 1];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactCellId];
        UIImageView *contactAvatarImageView = [cell viewWithTag:1];
        UILabel *contactNameLabel = [cell viewWithTag:2];
        UILabel *lastSeenLabel = [cell viewWithTag:3];
        
        contactNameLabel.text = contact.name;
        
        [[MVFileManager sharedInstance] loadAvatarAttachmentForContact:contact completion:^(DBAttachment *attachment) {
            [attachment thumbnailImageWithMaxWidth:50 completion:^(UIImage *image) {
                contactAvatarImageView.image = image;
            }];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:@"ContactAvatarUpdate" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            NSString *contactId = note.userInfo[@"Id"];
            UIImage *image = note.userInfo[@"Image"];
            if ([contact.id isEqualToString:contactId]) {
                contactAvatarImageView.image = image;
            }
        }];
        
        contactAvatarImageView.layer.masksToBounds = YES;
        contactAvatarImageView.layer.cornerRadius = 15;
        
        lastSeenLabel.text = [NSString lastSeenTimeStringForDate:contact.lastSeenDate];
        [[NSNotificationCenter defaultCenter] addObserverForName:@"ContactLastSeenTimeUpdate" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            NSString *contactId = note.userInfo[@"Id"];
            if ([contactId isEqualToString:contact.id]) {
                NSDate *lastSeenDate = note.userInfo[@"LastSeenTime"];
                lastSeenLabel.text = [NSString lastSeenTimeStringForDate:lastSeenDate];
                contact.lastSeenDate = lastSeenDate;
            }
        }];
        
        return cell;
    } else {
        return [tableView dequeueReusableCellWithIdentifier:DeleteContactCellId];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            [self showChatPhotoSelectController];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self showContactsSelectController];
        } else {
            [self showContactProfileForContact:self.contacts[indexPath.row - 1]];
        }
        
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        [self showDeleteAlert];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row > 0) {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.contacts removeObjectAtIndex:indexPath.row - 1];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    self.doneButton.enabled = [self canProceed];
}

- (void)showContactsSelectController {
    MVContactsListController *contactsListController = [MVContactsListController loadFromStoryboardWithMode:MVContactsListControllerModeSelectable andDoneAction:^(NSArray<MVContactModel *> *selectedContacts) {
        [self.contacts addObjectsFromArray:selectedContacts];
        [self.tableView reloadData];
        [self dismissViewControllerAnimated:YES completion:nil];
        self.doneButton.enabled = [self canProceed];
    } excludingContacts:[self.contacts copy]];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:contactsListController];
    contactsListController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(dismissContactsSelectController)];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)dismissContactsSelectController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showDeleteAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delete and Exit" message:@"Are you sure you want to delete and exit this chat?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[MVChatManager sharedInstance] exitAndDeleteChat:self.chat];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:yesAction];
    [alertController addAction:noAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showChatPhotoSelectController {
    DBAttachmentPickerController *attachmentPicker = [DBAttachmentPickerController attachmentPickerControllerFinishPickingBlock:^(NSArray<DBAttachment *> *attachmentArray) {
        DBAttachment *attachment = attachmentArray[0];
        self.avatarAttachment = attachment;
        [attachment loadThumbnailImageWithTargetSize:CGSizeMake(100, 100) completion:^(UIImage *resultImage) {
            self.avatarImage = resultImage;
            self.avatarChanged = YES;
            self.doneButton.enabled = [self canProceed];
        }];
    } cancelBlock:nil];
    
    attachmentPicker.mediaType = DBAttachmentMediaTypeImage;
    [attachmentPicker presentOnViewController:self];
}

- (void)showContactProfileForContact:(MVContactModel *)contact {
    MVContactProfileViewController *contactProfile = [MVContactProfileViewController loadFromStoryboardWithContact:contact];
    [self.navigationController pushViewController:contactProfile animated:YES];
}

#pragma mark - Helpers
- (BOOL)canProceed {
    if (self.mode == MVChatSettingsModeSettings) {
        return [self dataChanged];
    } else {
        return (self.contacts.count > 0 && self.chatTitle.length > 0);
    }
}

- (BOOL)dataChanged {
    NSMutableSet *chatParticipants = [NSMutableSet new];
    NSMutableSet *selectedContacts = [NSMutableSet new];
    for (MVContactModel *contact in self.chat.participants) {
        if (!contact.iam) {
            [chatParticipants addObject:contact.id];
        }
    }
    for (MVContactModel *contact in self.contacts) {
        [selectedContacts addObject:contact.id];
    }
    
    if ([chatParticipants isEqualToSet:selectedContacts] && [self.chat.title isEqualToString:self.chatTitle] && !self.avatarChanged) {
        return NO;
    } else {
        return YES;
    }
}

@end
