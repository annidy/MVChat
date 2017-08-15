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
#import "MVChatsListSearchViewController.h"
#import "MVContactsListController.h"
#import "MVChatSettingsViewController.h"
#import "MVFileManager.h"

@interface MVChatsListViewController () <UITableViewDelegate, UITableViewDataSource, ChatsUpdatesListener, UISearchResultsUpdating, MVSearchProviderDelegate>
@property (strong, nonatomic) IBOutlet UITableView *chatsList;
@property (strong, nonatomic) NSArray <MVChatModel *> *chats;
@property (strong, nonatomic) MVChatsListSearchViewController *searchResultsController;
@property (strong, nonatomic) UISearchController *searchController;
@end

@implementation MVChatsListViewController
#pragma mark - View lifecycle
- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationController setNavigationBarHidden:YES animated:YES];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MVChatManager sharedInstance].chatsListener = self;
    self.chats = [[MVChatManager sharedInstance] chatsList];
    
    self.chatsList.tableFooterView = [UIView new];
    self.chatsList.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    
    self.searchResultsController = [MVChatsListSearchViewController loadFromStoryboardWithDelegate:self];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsController];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.chatsList.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    
    self.chatsList.delegate = self;
    self.chatsList.dataSource = self;
    
    [self setupNavigationBar];
}

- (void)setupNavigationBar {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(createNewChat)];
    self.navigationItem.rightBarButtonItem = item;
    self.navigationItem.title = @"Chats";
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

#pragma mark - Search filter
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSArray *chats = [self filterChatsWithString:searchController.searchBar.text];
    self.searchResultsController.filteredChats = chats;
    self.searchResultsController.popularChats = [self.chats subarrayWithRange:NSMakeRange(0, self.chats.count>5? 5:self.chats.count)];
    if (searchController.isActive) {
        self.searchController.searchResultsController.view.hidden = NO;
    }
}

- (void)didSelectCellWithModel:(id)model {
    MVChatModel *chat = (MVChatModel *)model;
    [self showChatViewWithChat:chat];
    self.searchResultsController.resentSearchChat = chat;
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

#pragma mark - Create chat
- (void)createNewChat {
    UINavigationController *rootNavigationController = self.navigationController.navigationController;
    MVContactsListController *contactsList = [MVContactsListController loadFromStoryboardWithMode:MVContactsListControllerModeSelectable andDoneAction:^(NSArray<MVContactModel *> *selectedContacts) {
        MVChatSettingsViewController *settings = [MVChatSettingsViewController loadFromStoryboardWithContacts:selectedContacts andDoneAction:^(NSArray<MVContactModel *> *chatContacts, NSString *chatTitle, DBAttachment *avatarImage) {
            
            [[MVChatManager sharedInstance] createChatWithContacts:chatContacts title:chatTitle andCompeltion:^(MVChatModel *chat) {
                [[MVFileManager sharedInstance] saveAttachment:avatarImage asChatAvatar:chat];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [rootNavigationController popToRootViewControllerAnimated:YES];
                    [self showChatViewWithChat:chat];
                });
            }];
        }];
        [rootNavigationController pushViewController:settings animated:YES];
    }];
    [rootNavigationController pushViewController:contactsList animated:YES];
}

#pragma mark - Helpers
- (void)showChatViewWithChat:(MVChatModel *)chat {
    MVChatViewController *chatVC = [MVChatViewController loadFromStoryboardWithChat:chat];
    [self.navigationController.navigationController pushViewController:chatVC animated:YES];
}

@end
