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

@interface MVContactsListController () <UITableViewDelegate, UITableViewDataSource, MVContactsUpdatesListener>
@property (strong, nonatomic) IBOutlet UITableView *contactsList;
@property (strong, nonatomic) NSArray <NSString *> *sections;
@property (strong, nonatomic) NSDictionary <NSString *, NSArray *> *contacts;
@end

@implementation MVContactsListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.contactsList setDelegate:self];
    [self.contactsList setDataSource:self];
    [self.contactsList setTableFooterView:[UIView new]];
    
    [self mapWithSections:[[MVContactManager sharedInstance] getAllContacts]];
    [MVContactManager sharedInstance].updatesListener = self;
}

- (void)handleContactsUpdate {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self mapWithSections:[[MVContactManager sharedInstance] getAllContacts]];
        [self.contactsList reloadData];
    });
}

#pragma mark - Data Handling
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.sections;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.contactsList deselectRowAtIndexPath:indexPath animated:YES];
    
    MVContactModel *contact = self.contacts[self.sections[indexPath.section]][indexPath.row];
    [[MVChatManager sharedInstance] chatWithContact:contact andCompeltion:^(MVChatModel *chat) {
       dispatch_async(dispatch_get_main_queue(), ^{
           [self showChatViewWithChat:chat];
       });
    }];
}

- (void)showChatViewWithChat:(MVChatModel *)chat {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MVChatViewController *chatVC = [sb instantiateViewControllerWithIdentifier:@"ChatViewController"];
    chatVC.chat = chat;
    [self.navigationController pushViewController:chatVC animated:YES];
}




@end
