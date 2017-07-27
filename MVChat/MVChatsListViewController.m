//
//  MVChatsListViewController.m
//  MVChat
//
//  Created by Mark Vasiv on 12/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVChatsListViewController.h"
#import "MVChatManager.h"
#import "MVChatModel.h"
#import "MVRandomGenerator.h"
#import "MVChatViewController.h"
#import "MVMessageModel.h"
#import "MVChatsListCell.h"
#import "MVChatsListSearchTableViewController.h"

@interface MVChatsListViewController () <UITableViewDelegate, UITableViewDataSource, ChatsUpdatesListener, UISearchResultsUpdating>
@property (strong, nonatomic) IBOutlet UITableView *chatsList;
@property (strong, nonatomic) NSArray <MVChatModel *> *chats;
@property (strong, nonatomic) MVChatsListSearchTableViewController *searchResultsController;
@property (strong, nonatomic) UISearchController *searchController;
@end

@implementation MVChatsListViewController
#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MVChatManager sharedInstance].chatsListener = self;
    self.chats = [[MVChatManager sharedInstance] chatsList];
    
    self.chatsList.tableFooterView = [UIView new];
    self.chatsList.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    
    self.searchResultsController = [MVChatsListSearchTableViewController loadFromStoryboard];
    self.searchResultsController.tableView.delegate = self;
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsController];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.chatsList.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    
    self.chatsList.delegate = self;
    self.chatsList.dataSource = self;
}

#pragma mark - Data handling
-(void)handleChatsUpdate {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.chats = [[MVChatManager sharedInstance] chatsList];
        [self.chatsList reloadData];
    });
}

#pragma mark - Table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chats.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MVChatsListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatsListCell"];
    MVChatModel *chat = self.chats[indexPath.row];
    [cell fillWithChat:chat];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MVChatModel *selectedChat = (tableView == self.chatsList)? self.chats[indexPath.row] : self.searchResultsController.filteredChats[indexPath.row];
    [self showChatViewWithChat:selectedChat];
}

#pragma mark - Helpers
- (void)showChatViewWithChat:(MVChatModel *)chat {
    MVChatViewController *chatVC = [MVChatViewController loadFromStoryboardWithChat:chat];
    [self.navigationController.navigationController pushViewController:chatVC animated:YES];
}

#pragma mark - Search filter
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSArray *chats = [self filterChatsWithString:searchController.searchBar.text];
    self.searchResultsController.filteredChats = chats;
}

- (NSArray *)filterChatsWithString:(NSString *)string {
    if (!string.length) {
        return [NSArray new];
    } else {
        return [self.chats filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(MVChatModel *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [[evaluatedObject.title uppercaseString] containsString:[string uppercaseString]];
        }]];
    }
}

@end
