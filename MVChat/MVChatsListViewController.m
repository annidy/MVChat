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
    
    UILabel *title = [cell viewWithTag:100];
    title.text = self.chats[indexPath.row].title;
    
    return cell;
}

@end
