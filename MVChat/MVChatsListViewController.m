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
#import "MVOverlayMenuController.h"
#import "MVUpdatesProvider.h"
#import <ReactiveObjC.h>
#import "MVContactsListViewModel.h"
#import "MVChatsListViewModel.h"
#import "MVChatsListCellViewModel.h"
#import "MVChatSettingsViewModel.h"
#import "MVChatViewModel.h"

@interface MVChatsListViewController () <UITableViewDelegate, UITableViewDataSource, MVForceTouchPresentaionDelegate, UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *chatsList;
@property (strong, nonatomic) IBOutlet UIButton *createChatButton;
@property (strong, nonatomic) MVChatsListSearchViewController *searchResultsController;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) MVChatsListViewModel *viewModel;
@end

@implementation MVChatsListViewController
#pragma mark - Initialisation 
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _viewModel = [MVChatsListViewModel new];
    }
    
    return self;
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.chatsList.tableFooterView = [UIView new];
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    }
    
    [self setupSearchController];
    [self registerForceTouchControllerWithDelegate:self andSourceView:self.createChatButton];
    [self bindAll];
    [self.chatsList reloadData];
}

- (void)bindAll {
    @weakify(self);
    [[[RACObserve(self.viewModel, listUpdates) skip:1] deliverOnMainThread]
        subscribeNext:^(NSArray *updates) {
            @strongify(self);
            for (MVChatsListUpdate *update in updates) {
                switch (update.updateType) {
                    case MVChatsListUpdateTypeReloadAll:
                        [self.chatsList reloadData];
                        break;
                        
                    case MVChatsListUpdateTypeInsert:
                        [self.chatsList insertRowsAtIndexPaths:@[update.insertIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
                        break;
                        
                    case MVChatsListUpdateTypeDelete:
                        [self.chatsList deleteRowsAtIndexPaths:@[update.removeIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                        break;

                    case MVChatsListUpdateTypeMove:
                        [self.chatsList moveRowAtIndexPath:update.startIndexPath toIndexPath:update.endIndexPath];
                        break;
                        
                    case MVChatsListUpdateTypeReload:
                        [UIView setAnimationsEnabled:NO];
                        [self.chatsList reloadRowsAtIndexPaths:@[update.reloadIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                        [UIView setAnimationsEnabled:YES];
                        break;
                        
                    default:
                        break;
                }
            }
        }];
    
    [[self.createChatButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl *x) {
        @strongify(self);
        [self createNewChat];
    }];
}

- (void)setupSearchController {
    self.searchResultsController = [MVChatsListSearchViewController loadFromStoryboardWithViewModel:self.viewModel rootViewController:self];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsController];
    self.searchController.searchResultsUpdater = self.viewModel;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchController.hidesNavigationBarDuringPresentation = YES;
    if (@available(iOS 11.0, *)) {
        self.navigationItem.searchController = self.searchController;
    } else {
        self.chatsList.tableHeaderView = self.searchController.searchBar;
    }
    
    self.definesPresentationContext = YES;
}

#pragma mark - Table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.chats.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MVChatsListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatsListCell"];
    MVChatsListCellViewModel *model = self.viewModel.chats[indexPath.row];
    [cell fillWithModel:model];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray <MVChatsListCellViewModel *> *chats = (tableView == self.chatsList)? self.viewModel.chats : self.viewModel.filteredChats.count? self.viewModel.filteredChats : @[self.viewModel.recentSearchChat];
    MVChatsListCellViewModel *model = chats[indexPath.row];
    [self showChatViewWithChat:model.chat];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView != self.chatsList) {
        self.viewModel.recentSearchChat = model;
    }
}

#pragma mark - Search controller collection view
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MVChatsListCellViewModel *model = self.viewModel.popularChats[indexPath.row];
    [self showChatViewWithChat:model.chat];
    self.viewModel.recentSearchChat = model;
}

#pragma mark - Create chat
- (void)createNewChat {
    MVContactsListViewModel *contactsListModel = [[MVContactsListViewModel alloc] initWithMode:MVContactsListModeSelectable];
    MVContactsListController *contactsList = [MVContactsListController loadFromStoryboardWithViewModel:contactsListModel];
    
    @weakify(self);
    [[contactsListModel.doneCommand.executionSignals flatten] subscribeNext:^(NSArray *selectedContacts) {
        @strongify(self);
        MVChatSettingsViewModel *settingsModel = [[MVChatSettingsViewModel alloc] initWithContacts:selectedContacts];
        MVChatSettingsViewController *settings = [MVChatSettingsViewController loadFromStoryboardWithViewModel:settingsModel];
        [self.navigationController pushViewController:settings animated:YES];
    }];
    
    [self.navigationController pushViewController:contactsList animated:YES];
}

#pragma mark - MVForceTouchPresentaionDelegate
- (UIViewController<MVForceTouchControllerProtocol> *)forceTouchViewControllerForContext:(NSString *)context {
    MVOverlayMenuController *menu = [MVOverlayMenuController loadFromStoryboard];
    NSMutableArray *menuElements = [NSMutableArray new];
    [menuElements addObject:[MVOverlayMenuElement elementWithTitle:@"Create chat" action:^{
        [self createNewChat:nil];
    }]];
    [menuElements addObject:[MVOverlayMenuElement elementWithTitle:@"Update avatars" action:^{
        [[MVUpdatesProvider sharedInstance] performAvatarsUpdate];
    }]];
    [menuElements addObject:[MVOverlayMenuElement elementWithTitle:@"Update last seen time" action:^{
        [[MVUpdatesProvider sharedInstance] performLastSeenUpdate];
    }]];
    [menuElements addObject:[MVOverlayMenuElement elementWithTitle:@"Generate new messages" action:^{
        [[MVUpdatesProvider sharedInstance] generateNewMessages];
    }]];
    [menuElements addObject:[MVOverlayMenuElement elementWithTitle:@"Generate new chats" action:^{
        [[MVUpdatesProvider sharedInstance] generateNewChats];
    }]];
    menu.menuElements = [menuElements copy];
    
    return menu;
}

#pragma mark - Helpers
- (void)showChatViewWithChat:(MVChatModel *)chat {
    MVChatViewModel *viewModel = [[MVChatViewModel alloc] initWithChat:[chat copy]];
    MVChatViewController *chatVC = [MVChatViewController loadFromStoryboardWithViewModel:viewModel];
    [self.navigationController pushViewController:chatVC animated:YES];
}
@end
