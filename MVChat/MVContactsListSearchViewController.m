//
//  MVContactsListSearchViewController.m
//  MVChat
//
//  Created by Mark Vasiv on 30/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVContactsListSearchViewController.h"
#import "MVTableViewHeader.h"
#import "MVContactsListCell.h"
#import <ReactiveObjC.h>
#import "MVContactsListViewModel.h"
#import "MVChatManager.h"
#import "MVChatViewController.h"

@interface MVContactsListSearchViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MVContactsListViewModel *viewModel;
@end

@implementation MVContactsListSearchViewController
+ (instancetype)loadFromStoryboardWithViewModel:(MVContactsListViewModel *)viewModel {
    MVContactsListSearchViewController *instance = [super loadFromStoryboard];
    instance.viewModel = viewModel;
    
    return instance;
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[MVTableViewHeader class] forHeaderFooterViewReuseIdentifier:@"MVTableViewHeader"];
    
    @weakify(self);
    [RACObserve(self.viewModel, filteredRows) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.filteredRows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MVContactsListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactsListCell"];
    [cell fillWithModel:self.viewModel.filteredRows[indexPath.row]];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MVTableViewHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"MVTableViewHeader"];
    header.titleLabel.text = @"CONTACTS";
    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MVContactsListCellViewModel *model = self.viewModel.filteredRows[indexPath.row];
    [self showChatViewWithContact:model.contact];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark - Helpers
- (void)showChatViewWithContact:(MVContactModel *)contact {
    [[MVChatManager sharedInstance] chatWithContact:contact andCompeltion:^(MVChatModel *chat) {
        [self showChatViewWithChat:chat];
    }];
}

- (void)showChatViewWithChat:(MVChatModel *)chat {
    MVChatViewController *chatVC = [MVChatViewController loadFromStoryboardWithChat:chat];
    [self.presentingViewController.navigationController pushViewController:chatVC animated:YES];
}
@end
