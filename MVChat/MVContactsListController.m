//
//  MVContactsListController.m
//  MVChat
//
//  Created by Mark Vasiv on 25/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVContactsListController.h"
#import "MVContactsListCell.h"
#import "MVContactManager.h"
#import "MVContactModel.h"
#import "MVChatManager.h"
#import "MVChatViewController.h"
#import "MVContactsListSearchViewController.h"
#import "MVTableViewHeader.h"
#import "MVContactsListViewModel.h"
#import <ReactiveObjC.h>
#import "MVChatViewModel.h"

@interface MVContactsListController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *contactsList;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) MVContactsListViewModel *viewModel;
@end

@implementation MVContactsListController
#pragma mark - Initialization
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _viewModel = [[MVContactsListViewModel alloc] initWithMode:MVContactsListModeDefault];
    }
    
    return self;
}

+ (instancetype)loadFromStoryboardWithViewModel:(MVContactsListViewModel *)viewModel {
    MVContactsListController *instance = [MVContactsListController loadFromStoryboard];
    instance.viewModel = viewModel;
    return instance;
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationBar];
    [self bindViewModel];
    
    if (self.viewModel.mode == MVContactsListModeSelectable) {
        self.contactsList.allowsMultipleSelection = YES;
    } else {
        [self setupSearchController];
    }
    
    self.contactsList.tableFooterView = [UIView new];
    [self.contactsList registerClass:[MVTableViewHeader class] forHeaderFooterViewReuseIdentifier:@"MVTableViewHeader"];
}

- (void)setupSearchController {
    self.viewModel.searchResultsController = [MVContactsListSearchViewController loadFromStoryboardWithViewModel:self.viewModel];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.viewModel.searchResultsController];
    self.searchController.searchResultsUpdater = self.viewModel;
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.contactsList.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
}

- (void)setupNavigationBar {
    if (self.viewModel.mode == MVContactsListModeDefault) {
        self.navigationItem.title = @"Contacts";
    } else {
        self.navigationItem.title = @"New chat";
        UIBarButtonItem *doneButton = [UIBarButtonItem new];
        doneButton.style = UIBarButtonItemStylePlain;
        doneButton.title = @"Next";
        doneButton.rac_command = self.viewModel.doneCommand;
        self.navigationItem.rightBarButtonItem = doneButton;
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
}

- (void)dismiss:(id)sender {
    if (self.presentingViewController) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)bindViewModel {
    @weakify(self);
    [[RACObserve(self.viewModel, rows) deliverOnMainThread] subscribeNext:^(id x) {
        @strongify(self);
        [self.contactsList reloadData];
    }];
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = self.viewModel.sections[section];
    return self.viewModel.rows[key].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MVContactsListCell *cell = [self.contactsList dequeueReusableCellWithIdentifier:@"ContactsListCell"];
    MVContactsListCellViewModel *model = self.viewModel.rows[self.viewModel.sections[indexPath.section]][indexPath.row];
    [cell fillWithModel:model];
    if ([self.viewModel isModelSelected:model]) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MVTableViewHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"MVTableViewHeader"];
    header.titleLabel.text = self.viewModel.sections[section];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MVContactsListCellViewModel *model = self.viewModel.rows[self.viewModel.sections[indexPath.section]][indexPath.row];
    
    if (self.viewModel.mode == MVContactsListModeDefault) {
        [self.contactsList deselectRowAtIndexPath:indexPath animated:YES];
        [self showChatViewWithContact:model.contact];
    } else {
        [self.viewModel selectModel:model];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.contactsList deselectRowAtIndexPath:indexPath animated:YES];
    
    MVContactsListCellViewModel *model = self.viewModel.rows[self.viewModel.sections[indexPath.section]][indexPath.row];
    [self.viewModel deselectModel:model];
}

#pragma mark - Helpers
- (void)showChatViewWithContact:(MVContactModel *)contact {
    [[MVChatManager sharedInstance] chatWithContact:contact andCompeltion:^(MVChatModel *chat) {
        [self showChatViewWithChat:chat];
    }];
}

- (void)showChatViewWithChat:(MVChatModel *)chat {
    MVChatViewModel *viewModel = [[MVChatViewModel alloc] initWithChat:chat];
    MVChatViewController *chatVC = [MVChatViewController loadFromStoryboardWithViewModel:viewModel];
    [self.navigationController pushViewController:chatVC animated:YES];
}
@end
