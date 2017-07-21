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
    
//    UILabel *titleLabel = [cell viewWithTag:101];
//    titleLabel.text = self.chats[indexPath.row].title;
//    
//    UILabel *messageLabel = [cell viewWithTag:102];
//    messageLabel.text = self.chats[indexPath.row].lastMessage.text;
//    
//    UILabel *dateLabel = [cell viewWithTag:103];
//    dateLabel.text = @"12.03.2015";
//    
//    UIImageView *avatarImageView = [cell viewWithTag:100];
//    //NSString *avatarName = [NSString stringWithFormat:@"avatar0%ld",(long)[[MVRandomGenerator sharedInstance] randomIndexWithMax:4] + 1];
//    //avatarImageView.image = [UIImage imageNamed:avatarName];
//    
//    NSString *title = self.chats[indexPath.row].title;
//    NSArray *words = [title componentsSeparatedByString:@" "];
//    NSMutableString *abv = [NSMutableString new];
//    for (NSString *sub in words) {
//        [abv appendString:[sub substringToIndex:1]];
//    }
//    CGFloat fontSize = 20;
//    
//    
//    UIView *avatarView = [cell viewWithTag:104];
//    UILabel *avatarTitle = [cell viewWithTag:105];
//    avatarView.backgroundColor = [UIColor colorWithRed:158/255.0 green:215/255.0 blue:245/255.0 alpha:1];
//    avatarTitle.text = [abv uppercaseString];
//    avatarView.layer.cornerRadius = 24;
//    avatarView.layer.masksToBounds = YES;
//    avatarImageView.alpha = 0;
    
//    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(48, 48)];
//    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull context) {
//        [[UIColor colorWithRed:158/255.0 green:215/255.0 blue:245/255.0 alpha:1] setFill];
//        [context fillRect:CGRectMake(0, 0, 200, 200)];
//        NSString *a = [[abv copy] uppercaseString];
//        NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
//        textStyle.alignment = NSTextAlignmentLeft;
//        NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 20], NSForegroundColorAttributeName: UIColor.whiteColor, NSParagraphStyleAttributeName:textStyle};
//        //[a drawInRect:CGRectMake(0, 0, 50, 50) withAttributes:textFontAttributes];
//        CGFloat width = [a sizeWithAttributes:textFontAttributes].width;
//        CGFloat height = [a sizeWithAttributes:textFontAttributes].height;
//        [a drawAtPoint:CGPointMake((48-width)/2, (48-height)/2) withAttributes:textFontAttributes];
//    }];
//    
//    avatarImageView.image = image;
    
    //avatarImageView.layer.cornerRadius = 24;
    //avatarImageView.layer.masksToBounds = YES;
    
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
