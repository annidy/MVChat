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

@interface MVContactsListController () <UITableViewDelegate, UITableViewDataSource, MVContactsUpdatesListener, MVSearchProviderDelegate, UISearchResultsUpdating>
@property (strong, nonatomic) IBOutlet UITableView *contactsList;
@property (strong, nonatomic) NSArray <NSString *> *sections;
@property (strong, nonatomic) NSDictionary <NSString *, NSArray *> *contacts;
@property (weak, nonatomic) MVContactsListSearchViewController *searchResultsController;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSMutableArray *selectedContacts;
@property (strong, nonatomic) UIBarButtonItem *doneButtonItem;
@property (strong, nonatomic) NSArray *excludingContacts;
@end

@implementation MVContactsListController
#pragma mark - Initialization
+ (instancetype)loadFromStoryboardWithMode:(MVContactsListControllerMode)mode andDoneAction:(void (^)(NSArray <MVContactModel *> *))doneAction {
    return [self loadFromStoryboardWithMode:mode andDoneAction:doneAction excludingContacts:nil];
}

+ (instancetype)loadFromStoryboardWithMode:(MVContactsListControllerMode)mode andDoneAction:(void (^)(NSArray <MVContactModel *> *))doneAction excludingContacts:(NSArray <MVContactModel *> *)excludingContacts {
    MVContactsListController *instance = [super loadFromStoryboard];
    instance.mode = mode;
    instance.doneAction = doneAction;
    instance.excludingContacts = excludingContacts;
    return instance;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _mode = MVContactsListControllerModeDefault;
        _selectedContacts = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark - View lifecycle
- (void)viewWillAppear:(BOOL)animated {
    if (self.mode == MVContactsListControllerModeSelectable) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    } else {
        [self.navigationController.navigationController setNavigationBarHidden:YES animated:YES];
    }
    
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationBar];
    self.contactsList.tableFooterView = [UIView new];
    self.contactsList.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    [self.contactsList registerClass:[MVTableViewHeader class] forHeaderFooterViewReuseIdentifier:@"MVTableViewHeader"];
    
    if (self.mode == MVContactsListControllerModeDefault) {
        [self setupSearchController];
    } else if (self.mode == MVContactsListControllerModeSelectable){
        self.contactsList.allowsMultipleSelection = YES;
    }
    
    [MVContactManager sharedInstance].updatesListener = self;
    [self mapWithSections:[[MVContactManager sharedInstance] getAllContacts]];
}

- (void)setupSearchController {
    self.searchResultsController = [MVContactsListSearchViewController loadFromStoryboardWithDelegate:self];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsController];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.contactsList.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
}

- (void)setupNavigationBar {
    if (self.mode == MVContactsListControllerModeDefault) {
        self.navigationItem.title = @"Contacts";
    } else if (self.mode == MVContactsListControllerModeSelectable) {
        self.doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(nextButtonAction)];
        self.navigationItem.rightBarButtonItem = self.doneButtonItem;
        self.doneButtonItem.enabled = NO;
        self.navigationItem.title = @"New chat";
    }
}

#pragma mark - Data Handling
- (void)handleContactsUpdate {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self mapWithSections:[[MVContactManager sharedInstance] getAllContacts]];
        [self.contactsList reloadData];
    });
}

- (void)mapWithSections:(NSArray *)contacts {
    NSMutableArray *sections = [NSMutableArray new];
    NSMutableDictionary *mappedContacts = [NSMutableDictionary new];
    for (MVContactModel *contact in contacts) {
        if ([self shouldExcludeContact:contact]) {
            continue;
        }
        NSString *sectionKey = [[contact.name substringToIndex:1] uppercaseString];
        if (!mappedContacts[sectionKey]) {
            [sections addObject:sectionKey];
            mappedContacts[sectionKey] = [NSMutableArray new];
        }
        [mappedContacts[sectionKey] addObject:contact];
    }
    
    self.sections = sections;
    self.contacts = mappedContacts;
}

- (BOOL)shouldExcludeContact:(MVContactModel *)contact {
    if (!self.excludingContacts) {
        return NO;
    }
    
    for (MVContactModel *excludingContact in self.excludingContacts) {
        if ([contact.id isEqualToString:excludingContact.id]) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contacts[self.sections[section]].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MVContactsListCell *cell = [self.contactsList dequeueReusableCellWithIdentifier:@"ContactsListCell"];
    MVContactModel *contact = self.contacts[self.sections[indexPath.section]][indexPath.row];
    [cell fillWithContact:contact];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MVTableViewHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"MVTableViewHeader"];
    header.titleLabel.text = self.sections[section];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MVContactModel *contact = self.contacts[self.sections[indexPath.section]][indexPath.row];
    
    if (self.mode == MVContactsListControllerModeDefault) {
        [self.contactsList deselectRowAtIndexPath:indexPath animated:YES];
        [self showChatViewWithContact:contact];
    } else {
        if (![self.selectedContacts containsObject:contact]) {
            [self.selectedContacts addObject:contact];
            self.doneButtonItem.enabled = YES;
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.contactsList deselectRowAtIndexPath:indexPath animated:YES];
    
    MVContactModel *contact = self.contacts[self.sections[indexPath.section]][indexPath.row];
    if ([self.selectedContacts containsObject:contact]) {
        [self.selectedContacts removeObject:contact];
    }
    
    if (!self.selectedContacts.count) {
        self.doneButtonItem.enabled = NO;
    }
}
#pragma mark - Search bar
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSArray *contacts = [self filterContactsWithString:searchController.searchBar.text];
    self.searchResultsController.filteredContacts = contacts;
}

- (NSArray *)filterContactsWithString:(NSString *)string {
    if (!string.length) {
        return [NSArray new];
    } else {
        return [[[MVContactManager sharedInstance] getAllContacts] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(MVContactModel *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [[evaluatedObject.name uppercaseString] containsString:[string uppercaseString]];
        }]];
    }
}

- (void)didSelectCellWithModel:(id)model {
    MVContactModel *contact = (MVContactModel *)model;
    [self showChatViewWithContact:contact];
}

#pragma mark - Button press
- (void)nextButtonAction {
    self.doneAction([self.selectedContacts copy]);
}

#pragma mark - Helpers
- (void)showChatViewWithContact:(MVContactModel *)contact {
    [[MVChatManager sharedInstance] chatWithContact:contact andCompeltion:^(MVChatModel *chat) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showChatViewWithChat:chat];
        });
    }];
}

- (void)showChatViewWithChat:(MVChatModel *)chat {
    MVChatViewController *chatVC = [MVChatViewController loadFromStoryboardWithChat:chat];
    [self.navigationController.navigationController pushViewController:chatVC animated:YES];
}
@end
