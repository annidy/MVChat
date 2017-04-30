//
//  MVMessagesViewController.m
//  MVChat
//
//  Created by Mark Vasiv on 01/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVMessagesViewController.h"
#import "MVMessageModel.h"
#import "MVChatManager.h"
#import "MVMessageCell.h"

@interface MVMessagesViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *messagesTableView;

@property (strong, nonatomic) NSArray <MVMessageModel *> *messages;
@end

@implementation MVMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.messagesTableView.tableFooterView = [UIView new];
    self.messagesTableView.delegate = self;
    self.messagesTableView.dataSource = self;
    
    self.messages = [MVChatManager messages];
    self.messagesTableView.estimatedRowHeight = 30;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 50;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MVMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
    if (!cell) {
        cell = [MVMessageCell new];
        [cell build];
    }
    
    cell.label.text = self.messages[indexPath.row].text;
    
    return cell;
}

@end
