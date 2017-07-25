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

@interface MVChatsListViewController () <UITableViewDelegate, UITableViewDataSource, ChatsUpdatesListener>
@property (strong, nonatomic) IBOutlet UITableView *chatsList;
@property (strong, nonatomic) NSArray <MVChatModel *> *chats;
@end

@implementation MVChatsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [MVChatManager sharedInstance].chatsListener = self;
    self.chats = [[MVChatManager sharedInstance] chatsList];
    
    
    self.chatsList.delegate = self;
    self.chatsList.dataSource = self;
    self.chatsList.tableFooterView = [UIView new];
    self.tabBarController.view.backgroundColor = [UIColor whiteColor];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chats.count;
}

-(void)handleChatsUpdate {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.chats = [[MVChatManager sharedInstance] chatsList];
        [self.chatsList reloadData];
    });
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MVChatsListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatsListCell"];
    MVChatModel *chat = self.chats[indexPath.row];
    
    [cell fillWithChat:chat];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self showChatViewWithChat:self.chats[indexPath.row]];
}

- (void)showChatViewWithChat:(MVChatModel *)chat {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    MVChatViewController *chatVC = [sb instantiateViewControllerWithIdentifier:@"ChatViewController"];
    chatVC.chat = chat;
    [self.navigationController pushViewController:chatVC animated:YES];
}

@end
