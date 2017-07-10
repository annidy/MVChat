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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatsListCell"];
    
    UILabel *titleLabel = [cell viewWithTag:101];
    titleLabel.text = self.chats[indexPath.row].title;
    
    UILabel *messageLabel = [cell viewWithTag:102];
    messageLabel.text = self.chats[indexPath.row].lastMessage.text;
    
    UILabel *dateLabel = [cell viewWithTag:103];
    dateLabel.text = @"12.03.2015";
    
    UIImageView *avatarImageView = [cell viewWithTag:100];
    //NSString *avatarName = [NSString stringWithFormat:@"avatar0%ld",(long)[[MVRandomGenerator sharedInstance] randomIndexWithMax:4] + 1];
    //avatarImageView.image = [UIImage imageNamed:avatarName];
    
    avatarImageView.layer.cornerRadius = 24;
    avatarImageView.layer.masksToBounds = YES;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[MVChatManager sharedInstance] loadMessagesForChatWithId:self.chats[indexPath.row].id];
    [self showChatViewWithChat:self.chats[indexPath.row]];
}

- (void)showChatViewWithChat:(MVChatModel *)chat {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    MVChatViewController *chatVC = [sb instantiateViewControllerWithIdentifier:@"ChatViewController"];
    chatVC.chat = chat;
    [self.navigationController pushViewController:chatVC animated:YES];
}

@end
