//
//  MVChatSettingsViewController.m
//  MVChat
//
//  Created by Mark Vasiv on 12/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVChatSettingsViewController.h"
#import "MVChatModel.h"
#import <DBAttachmentPickerController.h>
#import "MVContactProfileViewController.h"
#import "MVChatSharedMediaListController.h"
#import <ReactiveObjC.h>
#import "MVChatSettingsViewModel.h"
#import "MVContactsListCellViewModel.h"
#import "MVChatViewController.h"
#import "MVContactProfileViewModel.h"
#import "MVContactsListController.h"
#import "MVChatViewModel.h"

@interface MVChatSettingsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) MVChatSettingsViewModel *viewModel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@end

@implementation MVChatSettingsViewController
#pragma mark - Initialization
+ (instancetype)loadFromStoryboardWithViewModel:(MVChatSettingsViewModel *)viewModel {
    MVChatSettingsViewController *instance = [super loadFromStoryboard];
    instance.viewModel = viewModel;
    
    return instance;
}

#pragma mark - View lifecycle and setup
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationBar];
    [self bindAll];
}

- (void)setupNavigationBar {
    if (self.viewModel.mode == MVChatSettingsModeNew) {
        [self.doneButton setTitle:@"Create" forState:UIControlStateNormal];
        [self.navigationItem setTitle:@"New Chat"];
    } else {
        [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [self.navigationItem setTitle:@"Settings"];
    }
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
}

- (void)bindAll {
    self.doneButton.rac_command = self.viewModel.doneCommand;
    
    @weakify(self);
    [RACObserve(self.viewModel, contactModels) subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView reloadData];
    }];
    
    [[self.viewModel.doneCommand.executionSignals flatten] subscribeNext:^(MVChatModel *chat) {
        @strongify(self);
        if (self.viewModel.mode == MVChatSettingsModeNew) {
            MVChatViewModel *viewModel = [[MVChatViewModel alloc] initWithChat:chat];
            NSArray *viewControllers = @[self.navigationController.viewControllers[0], [MVChatViewController loadFromStoryboardWithViewModel:viewModel]];
            [self.navigationController setViewControllers:viewControllers animated:YES];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}
#pragma mark - Table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.viewModel.mode == MVChatSettingsModeNew) {
        return 2;
    } else {
        return 4;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return self.viewModel.contactModels.count + 1;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 100;
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
    MVChatSettingsCellType cellType = [self.viewModel cellTypeForIndexPath:indexPath];
    NSString *cellId = [self.viewModel cellIdForCellType:cellType];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    switch (cellType) {
        case MVChatSettingsCellTypeAvatarTitle:
            [self setupAvatarTitleCell:cell];
            break;
        case MVChatSettingsCellTypeContact:
            [self setupContactCell:cell withModel:self.viewModel.contactModels[indexPath.row - 1]];
        default:
            break;
    }
    
    return cell;
}

- (void)setupAvatarTitleCell:(UITableViewCell *)cell {
    UIImageView *avatarImageView = [cell viewWithTag:1];
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.cornerRadius = 30;
    avatarImageView.layer.borderWidth = 0.3f;
    avatarImageView.layer.borderColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.4].CGColor;
    avatarImageView.userInteractionEnabled = YES;
    
    UITextField *titleTextField = [cell viewWithTag:2];
    
    @weakify(self);
    
    RAC(titleTextField, text) = [RACObserve(self.viewModel, chatTitle) takeUntil:cell.rac_prepareForReuseSignal];
    [[titleTextField rac_signalForControlEvents:UIControlEventEditingChanged] subscribeNext:^(UITextField *field) {
        @strongify(self);
        self.viewModel.chatTitle = field.text;
    }];
    
    if (!self.viewModel.avatarImage) {
        avatarImageView.image = [UIImage imageNamed:@"avatarPlaceholder"];
    }
    
    RAC(avatarImageView, image) = [[RACObserve(self.viewModel, avatarImage) ignore:nil] takeUntil:cell.rac_prepareForReuseSignal];
    
    UITapGestureRecognizer *tapRecognizer = [UITapGestureRecognizer new];
    [avatarImageView addGestureRecognizer:tapRecognizer];
    [[tapRecognizer.rac_gestureSignal takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(UIGestureRecognizer *x) {
        @strongify(self);
        [self showChatPhotoSelectController];
    }];
    
    //TODO: Need to remove recognizer?
}

- (void)setupContactCell:(UITableViewCell *)cell withModel:(MVContactsListCellViewModel *)model {
    UIImageView *contactAvatarImageView = [cell viewWithTag:1];
    contactAvatarImageView.layer.masksToBounds = YES;
    contactAvatarImageView.layer.cornerRadius = 15;
    contactAvatarImageView.layer.borderWidth = 0.3f;
    contactAvatarImageView.layer.borderColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.4].CGColor;
    
    RAC(contactAvatarImageView, image) = [RACObserve(model, avatar) takeUntil:cell.rac_prepareForReuseSignal];
    UILabel *contactNameLabel = [cell viewWithTag:2];
    RAC (contactNameLabel, text) = [RACObserve(model, name) takeUntil:cell.rac_prepareForReuseSignal];
    
    UILabel *lastSeenLabel = [cell viewWithTag:3];
    RAC(lastSeenLabel, text) = [RACObserve(model, lastSeenTime) takeUntil:cell.rac_prepareForReuseSignal];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MVChatSettingsCellType cellType = [self.viewModel cellTypeForIndexPath:indexPath];
    
    switch (cellType) {
        case MVChatSettingsCellTypeAvatar:
            [self showChatPhotoSelectController];
            break;
        case MVChatSettingsCellTypeNewContact:
            [self showContactsSelectController];
            break;
        case MVChatSettingsCellTypeContact:
            [self showContactProfileForContact:self.viewModel.contactModels[indexPath.row - 1].contact];
            break;
        case MVChatSettingsCellTypeMediaFiles:
            [self showAllSharedMedia];
            break;
        case MVChatSettingsCellTypeDeleteChat:
            [self showDeleteAlert];
            break;
        default:
            break;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    MVChatSettingsCellType cellType = [self.viewModel cellTypeForIndexPath:indexPath];
    if (cellType == MVChatSettingsCellTypeContact) {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel removeContactAtIndex:indexPath.row - 1];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Helpers
- (void)showAllSharedMedia {
    MVChatSharedMediaListController *vc = [MVChatSharedMediaListController loadFromStoryboardWithChatId:self.viewModel.chat.id];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showContactsSelectController {
    MVContactsListController *controller = [self.viewModel contactsSelectController];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)showDeleteAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delete and Exit" message:@"Are you sure you want to delete and exit this chat?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self.viewModel deleteChat];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:yesAction];
    [alertController addAction:noAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showChatPhotoSelectController {
    DBAttachmentPickerController *attachmentPicker = [self.viewModel attachmentPicker];
    [attachmentPicker presentOnViewController:self];
}

- (void)showContactProfileForContact:(MVContactModel *)contact {
    MVContactProfileViewModel *viewModel = [[MVContactProfileViewModel alloc] initWithContact:contact];
    MVContactProfileViewController *contactProfile = [MVContactProfileViewController loadFromStoryboardWithViewModel:viewModel];
    [self.navigationController pushViewController:contactProfile animated:YES];
}
@end
