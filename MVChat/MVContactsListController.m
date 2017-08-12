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
@end

@implementation MVContactsListController
#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.contactsList setDelegate:self];
    [self.contactsList setDataSource:self];
    [self.contactsList setTableFooterView:[UIView new]];
    self.contactsList.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    [self.contactsList registerClass:[MVTableViewHeader class] forHeaderFooterViewReuseIdentifier:@"MVTableViewHeader"];
    
    self.searchResultsController = [MVContactsListSearchViewController loadFromStoryboardWithDelegate:self];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsController];
    self.searchController.searchResultsUpdater = self;
    //self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.contactsList.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;

    
    [self mapWithSections:[[MVContactManager sharedInstance] getAllContacts]];
    [MVContactManager sharedInstance].updatesListener = self;
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
    [self.contactsList deselectRowAtIndexPath:indexPath animated:YES];
    
    MVContactModel *contact = self.contacts[self.sections[indexPath.section]][indexPath.row];
    [self showChatViewWithContact:contact];
}

#pragma mark - Search bar
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSArray *contacts = [self filterContactsWithString:searchController.searchBar.text];
    self.searchResultsController.filteredContacts = contacts;
    
//    if (searchController.isActive) {
//        self.searchController.searchResultsController.view.hidden = NO;
//    }
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
