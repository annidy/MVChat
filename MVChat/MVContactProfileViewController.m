//
//  MVContactProfileViewController.m
//  MVChat
//
//  Created by Mark Vasiv on 17/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVContactProfileViewController.h"
#import "MVContactProfileViewModel.h"
#import "MVChatViewController.h"
#import "MVChatSharedMediaListController.h"
#import <ReactiveObjC.h>

@interface MVContactProfileViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MVContactProfileViewModel *viewModel;
@end

@implementation MVContactProfileViewController
#pragma mark - Initialization
+ (instancetype)loadFromStoryboardWithViewModel:(MVContactProfileViewModel *)viewModel {
    MVContactProfileViewController *instance = [super loadFromStoryboard];
    instance.viewModel = viewModel;
    
    return instance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Contact";
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return self.viewModel.phoneNumbers.count;
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
    MVContactProfileCellType cellType = [self.viewModel cellTypeForIndexPath:indexPath];
    NSString *cellId = [self.viewModel cellIdForCellType:cellType];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cellType == MVContactProfileCellTypeContact) {
        [self fillAvatarCell:cell];
    } else if (cellType == MVContactProfileCellTypePhone) {
        [self fillPhoneCell:cell withIndex:indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MVContactProfileCellType cellType = [self.viewModel cellTypeForIndexPath:indexPath];
    
    switch (cellType) {
        case MVContactProfileCellTypeSharedMedia:
            [self showAllSharedMedia];
            break;
            
        case MVContactProfileCellTypeChat:
            [self showChat];
            break;
            
        default:
            break;
    }
}

- (void)fillAvatarCell:(UITableViewCell *)cell {
    UIImageView *avatarImageView = [cell viewWithTag:1];
    avatarImageView.layer.cornerRadius = 30;
    avatarImageView.layer.borderWidth = 0.3f;
    avatarImageView.layer.borderColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.4].CGColor;
    avatarImageView.layer.masksToBounds = YES;
    RAC(avatarImageView, image) = [RACObserve(self.viewModel, avatar) takeUntil:cell.rac_prepareForReuseSignal];
    
    UILabel *nameLabel = [cell viewWithTag:2];
    nameLabel.text = self.viewModel.name;
    
    UILabel *lastSeenLabel = [cell viewWithTag:3];
    RAC(lastSeenLabel, text) = [RACObserve(self.viewModel, lastSeen) takeUntil:cell.rac_prepareForReuseSignal];
}

- (void)fillPhoneCell:(UITableViewCell *)cell withIndex:(NSUInteger)index {
    UILabel *phoneLabel = [cell viewWithTag:2];
    phoneLabel.text = self.viewModel.phoneNumbers[index];
}


- (void)showAllSharedMedia {
    [self.viewModel sharedMediaController:^(MVChatSharedMediaListController *controller) {
        [self.navigationController pushViewController:controller animated:YES];
    }];
}

- (void)showChat {
    if ([self canPopToShowChat]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.viewModel chatController:^(MVChatViewController *controller) {
            [self.navigationController pushViewController:controller animated:YES];
        }];
    }
}

- (BOOL)canPopToShowChat {
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1) {
        UIViewController *previousViewController = viewControllers[viewControllers.count-2];
        if ([previousViewController isKindOfClass:[MVChatViewController class]]) {
            return YES;
        }
    }
    
    return NO;
}

@end
