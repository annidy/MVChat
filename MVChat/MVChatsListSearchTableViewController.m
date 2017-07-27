//
//  MVChatsListSearchTableViewController.m
//  MVChat
//
//  Created by Mark Vasiv on 27/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVChatsListSearchTableViewController.h"
#import "MVChatsListCell.h"
#import "MVChatViewController.h"

@interface MVChatsListSearchTableViewController ()
@end

@implementation MVChatsListSearchTableViewController
#pragma mark - Initialization
+ (instancetype)loadFromStoryboard {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:@"MVChatsListSearchTableViewController"];
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.tableFooterView = [UIView new];
    [self addObserver:self forKeyPath:@"filteredChats" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"filteredChats"]) {
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredChats.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MVChatsListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatsListCell"];
    MVChatModel *chat = self.filteredChats[indexPath.row];
    [cell fillWithChat:chat];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"CHATS";
}
@end
