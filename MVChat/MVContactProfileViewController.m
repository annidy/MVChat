//
//  MVContactProfileViewController.m
//  MVChat
//
//  Created by Mark Vasiv on 17/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVContactProfileViewController.h"
#import "MVChatModel.h"
#import "MVContactModel.h"
#import "MVContactManager.h"
#import "MVChatViewController.h"
#import "MVChatManager.h"
#import "MVChatSharedMediaListController.h"
#import "MVFileManager.h"
#import <DBAttachment.h>
#import "NSString+Helpers.h"

@interface MVContactProfileViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MVContactModel *contact;
@property (weak, nonatomic) UILabel *statusLabel;
@property (weak, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UIImage *avatarImage;
@end

static NSString *AvatarTitleCellId = @"MVContactProfileAvatarTitleCell";
static NSString *PhoneCellId = @"MVContactProfilePhoneCell";
static NSString *MediaCellId = @"MVContactProfileMediaCell";
static NSString *ChatCellId = @"MVContactProfileChatCell";

@implementation MVContactProfileViewController
#pragma mark - Initialization
+ (instancetype)loadFromStoryboardWithContact:(MVContactModel *)contact {
    MVContactProfileViewController *instance = [super loadFromStoryboard];
    instance.contact = contact;
    
    return instance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ContactLastSeenTimeUpdate" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSString *contactId = note.userInfo[@"Id"];
        if ([contactId isEqualToString:self.contact.id]) {
            NSDate *lastSeenDate = note.userInfo[@"LastSeenTime"];
            self.contact.lastSeenDate = lastSeenDate;
            self.statusLabel.text = [NSString lastSeenTimeStringForDate:lastSeenDate];
        }
    }];
    
    [[MVFileManager sharedInstance] loadThumbnailAvatarForContact:self.contact maxWidth:50 completion:^(UIImage *image) {
        self.avatarImage = image;
        self.avatarImageView.image = image;
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ContactAvatarUpdate" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSString *contactId = note.userInfo[@"Id"];
        UIImage *image = note.userInfo[@"Image"];
        if ([self.contact.id isEqualToString:contactId]) {
            self.avatarImageView.image = image;
        }
    }];
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return self.contact.phoneNumbers.count;
    } else {
        return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 100;
    } else if (indexPath.section == 1) {
        return 60;
    } else {
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGFLOAT_MIN;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:AvatarTitleCellId];
        [self fillAvatarCell:cell];
    } else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:PhoneCellId];
        [self fillPhoneCell:cell withIndex:indexPath.row];
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:MediaCellId];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:ChatCellId];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        [self showFullAvatar];
    } else if (indexPath.section == 1) {
        [self showCallMenu];
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [self showAllSharedMedia];
        } else {
            [self showChat];
        }
    }
}

- (void)fillAvatarCell:(UITableViewCell *)cell {
    UIImageView *avatarImageView = [cell viewWithTag:1];
    UILabel *nameLabel = [cell viewWithTag:2];
    UILabel *statusLabel = [cell viewWithTag:3];
    
    nameLabel.text = self.contact.name;
    statusLabel.text = [NSString lastSeenTimeStringForDate:self.contact.lastSeenDate];
    self.statusLabel = statusLabel;
    avatarImageView.layer.cornerRadius = 30;
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.image = self.avatarImage;
    self.avatarImageView = avatarImageView;
}

- (void)fillPhoneCell:(UITableViewCell *)cell withIndex:(NSUInteger)index {
    UILabel *phoneLabel = [cell viewWithTag:2];
    phoneLabel.text = self.contact.phoneNumbers[index];
}

- (void)showFullAvatar {
    
}

- (void)showCallMenu {
    
}

- (void)showAllSharedMedia {
    [[MVChatManager sharedInstance] chatWithContact:self.contact andCompeltion:^(MVChatModel *chat) {
        dispatch_async(dispatch_get_main_queue(), ^{
            MVChatSharedMediaListController *vc = [MVChatSharedMediaListController loadFromStoryboardWithChatId:chat.id];
            [self.navigationController pushViewController:vc animated:YES];
        });
    }];
    
}

- (void)showChat {
    if ([self canPopToShowChat]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [[MVChatManager sharedInstance] chatWithContact:self.contact andCompeltion:^(MVChatModel *chat) {
            dispatch_async(dispatch_get_main_queue(), ^{
                MVChatViewController *chatViewController = [MVChatViewController loadFromStoryboardWithChat:chat];
                [self.navigationController pushViewController:chatViewController animated:YES];
            });
        }];
    }
}

- (BOOL)canPopToShowChat {
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1) {
        UIViewController *previousViewController = viewControllers[viewControllers.count-2];
        if ([previousViewController isKindOfClass:[MVChatViewController class]]) {
            MVChatViewController *previousChatView = (MVChatViewController *)previousViewController;
            NSArray *previousChatContacts = previousChatView.chat.participants;
            if (previousChatContacts.count == 2) {
                BOOL validChat = YES;
                for (MVContactModel *contact in previousChatContacts) {
                    if (!contact.iam && ![contact.id isEqualToString:self.contact.id]) {
                        validChat = NO;
                    }
                }
                
                return validChat;
            }
        }
    }
    
    return NO;
}

@end
