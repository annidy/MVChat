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
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messagesTrailingConstraint;

@property (strong, nonatomic) NSArray <MVMessageModel *> *messages;
@end

@implementation MVMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.messagesTableView registerClass:[MVMessageCell class] forCellReuseIdentifier:@"MessageCell"];
    self.messagesTableView.tableFooterView = [UIView new];
    self.messagesTableView.delegate = self;
    self.messagesTableView.dataSource = self;
    
    self.messages = [MVChatManager messages];
    self.messagesTableView.estimatedRowHeight = 30;
    
    UIPanGestureRecognizer *rec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGest:)];
    [self.view addGestureRecognizer:rec];
    
}

- (void)panGest:(UIPanGestureRecognizer *)panRecognizer {
    
    NSArray<MVMessageCell *> *visibleCells = self.messagesTableView.visibleCells;
    
    if (!visibleCells.count) {
        return;
    }
    
    BOOL leftActive = NO;
    
    if (panRecognizer.state == UIGestureRecognizerStateBegan) {
        leftActive = NO;
    } else if (panRecognizer.state == UIGestureRecognizerStateEnded) {
        leftActive = YES;
    }
    
    for (MVMessageCell *cell in visibleCells) {
        cell.leftConstraint.active = leftActive;
    }
    
    if (panRecognizer.state == UIGestureRecognizerStateEnded) {
        
        CGFloat constant = -25;
        for (MVMessageCell *cell in visibleCells) {
            cell.rightConstraint.constant = constant;
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
        }];
        
        return;
    }
    
    
    
    CGFloat oldConstant = visibleCells[0].rightConstraint.constant;
    
    
    CGFloat trans = [panRecognizer translationInView:self.view].x;
    CGFloat velocityX = [panRecognizer velocityInView:self.view].x;
    
    CGFloat constant = trans - 25;
    if (constant > -25) {
        constant = -25;
    }
    if (constant < -80) {
        constant = -80;
    }
    
    if (oldConstant != constant) {
        CGFloat path = ABS(oldConstant - constant);
        NSTimeInterval duration = path / velocityX;
        for (MVMessageCell *cell in visibleCells) {
            cell.rightConstraint.constant = constant;
        }
        
        [UIView animateWithDuration:duration animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MVMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
    cell.label.text = self.messages[indexPath.row].text;
    
    return cell;
}

@end
