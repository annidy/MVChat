//
//  MVChatsListSearchTableViewController.m
//  MVChat
//
//  Created by Mark Vasiv on 27/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVChatsListSearchViewController.h"
#import "MVChatsListCell.h"
#import "MVChatViewController.h"
#import "MVChatsListSearchCollectionViewCell.h"
#import "MVTableViewHeader.h"

@interface MVChatsListSearchViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *popularChatsHeaderHeight;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeight;
@property (strong, nonatomic) IBOutlet UIView *popularChatsHeader;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *popularChatsSeparatorHeight;
@property (strong, nonatomic) IBOutlet UIView *popularChatsSeparator;
@property (weak, nonatomic) id <MVSearchProviderDelegate> delegate;
@end

@implementation MVChatsListSearchViewController
#pragma mark - Initialization
+ (instancetype)loadFromStoryboard {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:@"MVChatsListSearchViewController"];
}

+ (instancetype)loadFromStoryboardWithDelegate:(id <MVSearchProviderDelegate>)delegate {
    MVChatsListSearchViewController *instance = [self loadFromStoryboard];
    instance.delegate = delegate;
    return instance;
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[MVTableViewHeader class] forHeaderFooterViewReuseIdentifier:@"MVTableViewHeader"];
    [self addObserver:self forKeyPath:@"filteredChats" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"resentSearchChat" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"filteredChats"]) {
        [self.tableView reloadData];
        [self.collectionView reloadData];
        
        if (self.shouldShowPopularData) {
            self.collectionView.hidden = NO;
            self.popularChatsHeader.hidden = NO;
            self.popularChatsSeparator.hidden = NO;
            self.collectionViewHeight.constant = 80;
            self.popularChatsHeaderHeight.constant = 20;
            self.popularChatsSeparatorHeight.constant = 1;
            self.tableView.scrollEnabled = NO;
        } else {
            self.tableView.scrollEnabled = YES;
            self.collectionView.hidden = YES;
            self.popularChatsHeader.hidden = YES;
            self.popularChatsSeparator.hidden = YES;
            self.popularChatsSeparatorHeight.constant = 0;
            self.collectionViewHeight.constant = 0;
            self.popularChatsHeaderHeight.constant = 0;
        }
    } else if ([keyPath isEqualToString:@"resentSearchChat"]) {
        [self.tableView reloadData];
    }
}

#pragma mark - Table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.filteredChats.count || self.shouldShowRecentChat) {
        return 1;
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.filteredChats.count) {
        return self.filteredChats.count;
    } else if (self.shouldShowRecentChat){
        return 1;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MVChatsListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatsListCell"];
    MVChatModel *chat;
    if (self.filteredChats.count) {
        chat = self.filteredChats[indexPath.row];
    } else {
        chat = self.resentSearchChat;
    }
    [cell fillWithChat:chat];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MVTableViewHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"MVTableViewHeader"];
    
    if (self.filteredChats.count) {
        header.titleLabel.text = @"CHATS";
    } else {
        header.titleLabel.text = @"RECENT SEARCH";
    }
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.filteredChats.count) {
        [self.delegate didSelectCellWithModel:self.filteredChats[indexPath.row]];
    } else {
        [self.delegate didSelectCellWithModel:self.resentSearchChat];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark - Collection view
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.shouldShowPopularData) {
        return self.popularChats.count;
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MVChatsListSearchCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MVChatsListSearchCollectionViewCell" forIndexPath:indexPath];
    [cell fillWithChat:self.popularChats[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate didSelectCellWithModel:self.popularChats[indexPath.row]];
}

#pragma mark - Helpers
- (BOOL)shouldShowPopularData {
    if (!self.filteredChats.count) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)shouldShowRecentChat {
    if (self.resentSearchChat) {
        return YES;
    } else {
        return NO;
    }
}
@end
