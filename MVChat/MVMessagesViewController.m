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

@interface MVMessagesViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *messagesTableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messagesTrailingConstraint;

@property (strong, nonatomic) NSArray <MVMessageModel *> *messages;
@end

@implementation MVMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.messagesTableView registerClass:[MVMessageCell class] forCellReuseIdentifier:@"MessageCellIncoming"];
    [self.messagesTableView registerClass:[MVMessageCell class] forCellReuseIdentifier:@"MessageCellOutgoing"];
    self.messagesTableView.tableFooterView = [UIView new];
    self.messagesTableView.delegate = self;
    self.messagesTableView.dataSource = self;
    
    self.messages = [MVChatManager messages];
    self.messagesTableView.estimatedRowHeight = 30;
    
    UIPanGestureRecognizer *rec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGest:)];
    [self.view addGestureRecognizer:rec];
    rec.delegate = self;
    
}

- (void)panGest:(UIPanGestureRecognizer *)panRecognizer {
    
    NSArray<id <MVSlidingCell>> *visibleCells = self.messagesTableView.visibleCells;
    
    if (!visibleCells.count) {
        return;
    }
    
    BOOL willSlide = YES;
    
    if (panRecognizer.state == UIGestureRecognizerStateBegan) {
        willSlide = YES;
    } else if (panRecognizer.state == UIGestureRecognizerStateEnded || panRecognizer.state == UIGestureRecognizerStateFailed || panRecognizer.state == UIGestureRecognizerStateCancelled) {
        willSlide = NO;
    }
    
    for (MVMessageCell *cell in visibleCells) {
        if (willSlide) {
            [cell prepareToSlide];
        } else {
            [cell finishSliding];
        }
    }
    
    if (panRecognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat constant = 0;
        for (MVMessageCell *cell in visibleCells) {
            [cell setSlidingConstraint:constant];
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
        }];
        
        return;
    }
    
    CGFloat oldConstant = [visibleCells[0] slidingConstraint];
    CGFloat trans = [panRecognizer translationInView:self.view].x;
    CGFloat velocityX = [panRecognizer velocityInView:self.view].x;
    
    CGFloat constant = trans;
    if (constant > 0) {
        constant = 0;
    }
    if (constant < -40) {
        constant = -40;
    }
    
    if (oldConstant != constant) {
        CGFloat path = ABS(oldConstant - constant);
        NSTimeInterval duration = path / velocityX;
        for (MVMessageCell *cell in visibleCells) {
            [cell setSlidingConstraint:constant];
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
    NSString *cellId = @"MessageCell";
    if (self.messages[indexPath.row].direction == MessageDirectionOutgoing) {
        cellId = [cellId stringByAppendingString:@"Outgoing"];
    } else {
        cellId = [cellId stringByAppendingString:@"Incoming"];
        
    }
    
    MVMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.label.text = self.messages[indexPath.row].text;
    
    return cell;
}

@end
