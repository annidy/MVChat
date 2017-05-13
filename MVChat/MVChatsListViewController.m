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
    self.chats = [[MVChatManager sharedInstance] chatsList];
    [self.chatsList reloadData];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatsListCell"];
    
    UILabel *titleLabel = [cell viewWithTag:101];
    titleLabel.text = self.chats[indexPath.row].title;
    
    UILabel *messageLabel = [cell viewWithTag:102];
    messageLabel.text = @"sample message";
    
    UIImageView *avatarImageView = [cell viewWithTag:100];
    NSString *avatarName = [NSString stringWithFormat:@"avatar0%ld",(long)[[MVRandomGenerator sharedInstance] getRandomIndexWithMax:5]];
    avatarImageView.image = [UIImage imageNamed:avatarName];
    
    avatarImageView.layer.cornerRadius = 20;
    avatarImageView.layer.masksToBounds = YES;
    
    return cell;
}

@end
