//
//  MVChatsListSearchTableViewController.m
//  MVChat
//
//  Created by Mark Vasiv on 27/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVChatsListSearchViewController.h"
#import "MVChatsListCell.h"
#import "MVChatsListCellViewModel.h"
#import "MVChatViewController.h"
#import "MVChatsListSearchCollectionViewCell.h"
#import "MVTableViewHeader.h"
#import "MVChatsListViewModel.h"
#import <ReactiveObjC.h>
#import "MVChatModel.h"

@interface MVChatsListSearchViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *popularChatsHeaderHeight;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeight;
@property (strong, nonatomic) IBOutlet UIView *popularChatsHeader;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *popularChatsSeparatorHeight;
@property (strong, nonatomic) IBOutlet UIView *popularChatsSeparator;
@property (strong, nonatomic) IBOutlet UIView *tableHeaderHolder;
@property (weak, nonatomic) UIViewController <UITableViewDelegate, UICollectionViewDelegate> *rootViewController;
@property (strong, nonatomic) MVChatsListViewModel *viewModel;
@end

@implementation MVChatsListSearchViewController
#pragma mark - Initialization
+ (instancetype)loadFromStoryboardWithViewModel:(MVChatsListViewModel *)viewModel rootViewController:(UIViewController <UITableViewDelegate, UICollectionViewDelegate> *)root{
    MVChatsListSearchViewController *instance = [super loadFromStoryboard];
    instance.viewModel = viewModel;
    instance.rootViewController = root;
    
    return instance;
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[MVTableViewHeader class] forHeaderFooterViewReuseIdentifier:@"MVTableViewHeader"];
    [self bindViewModel];
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
}

- (void)bindViewModel {
    @weakify(self);
    [[RACObserve(self.viewModel, filteredChats) deliverOnMainThread] subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView reloadData];
        [self.collectionView reloadData];
    }];
    
    [[RACObserve(self.viewModel, recentSearchChat) deliverOnMainThread] subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView reloadData];
    }];
    
    RACSignal *showPopularSignal = [RACObserve(self.viewModel, shouldShowPopularData) deliverOnMainThread];
    RAC(self.tableView, tableHeaderView) = [showPopularSignal map:^id (NSNumber *shouldShow) {
        @strongify(self);
        return [shouldShow boolValue]? self.tableHeaderHolder : nil;
    }];
}

#pragma mark - Table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.viewModel.filteredChats.count || self.viewModel.recentSearchChat) {
        return 1;
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.viewModel.filteredChats.count) {
        return self.viewModel.filteredChats.count;
    } else if (self.viewModel.recentSearchChat) {
        return 1;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MVTableViewHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"MVTableViewHeader"];
    if (self.viewModel.filteredChats.count) {
        header.titleLabel.text = @"CHATS";
    } else {
        header.titleLabel.text = @"RECENT SEARCH";
    }
    
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MVChatsListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatsListCell"];
    [cell fillWithModel:[self modelForIndexPath:indexPath]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.rootViewController tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - Collection view
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.viewModel.shouldShowPopularData) {
        return self.viewModel.popularChats.count;
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MVChatsListSearchCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MVChatsListSearchCollectionViewCell" forIndexPath:indexPath];
    [cell fillWithModel:self.viewModel.popularChats[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.rootViewController collectionView:collectionView didSelectItemAtIndexPath:indexPath];
}

#pragma mark - Helpers
- (MVChatsListCellViewModel *)modelForIndexPath:(NSIndexPath *)indexPath {
    if (self.viewModel.filteredChats.count) {
        return self.viewModel.filteredChats[indexPath.row];
    } else {
        return self.viewModel.recentSearchChat;
    }
}
@end
