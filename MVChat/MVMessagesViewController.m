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
#import "MVMessageHeader.h"
#import "MVContactManager.h"

@interface MVMessagesViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *messagesTableView;
@property (strong, nonatomic) NSArray <MVMessageModel *> *messageModels;

@property (strong, nonatomic) NSMutableArray <NSString *> *sections;
@property (strong, nonatomic) NSMutableDictionary <NSString *, NSMutableArray <MVMessageModel *>*> *messages;
@property (assign, nonatomic) CGFloat sliderOffset;
@end

@implementation MVMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sliderOffset = 0;
    [self.messagesTableView registerClass:[MVMessageCell class] forCellReuseIdentifier:@"MessageCellIncoming"];
    [self.messagesTableView registerClass:[MVMessageCell class] forCellReuseIdentifier:@"MessageCellOutgoing"];
    [self.messagesTableView registerClass:[MVMessageCell class] forCellReuseIdentifier:@"MessageCellIncomingLast"];
    [self.messagesTableView registerClass:[MVMessageCell class] forCellReuseIdentifier:@"MessageCellOutgoingLast"];
    [self.messagesTableView registerClass:[MVMessageCell class] forCellReuseIdentifier:@"MessageCellOutgoingTailess"];
    [self.messagesTableView registerClass:[MVMessageCell class] forCellReuseIdentifier:@"MessageCellIncomingTailess"];
    [self.messagesTableView registerClass:[MVMessageCell class] forCellReuseIdentifier:@"MessageCellOutgoingTailessFirst"];
    [self.messagesTableView registerClass:[MVMessageCell class] forCellReuseIdentifier:@"MessageCellIncomingTailessFirst"];
    [self.messagesTableView registerClass:[MVMessageHeader class] forHeaderFooterViewReuseIdentifier:@"MessageHeader"];
    self.messagesTableView.tableFooterView = [UIView new];
    self.messagesTableView.delegate = self;
    self.messagesTableView.dataSource = self;
    
    self.messageModels = [[MVChatManager sharedInstance] messagesForChatWithId:self.chatId];
    self.messagesTableView.estimatedRowHeight = 30;
    self.messagesTableView.contentInset = UIEdgeInsetsMake(-44, 0, 0, 0);
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:panRecognizer];
    panRecognizer.delegate = self;
    
    [self mapWithSections];
    [MVContactManager startSendingAvatarUpdates];
}

- (void)mapWithSections {
    self.sections = [NSMutableArray new];
    self.messages = [NSMutableDictionary new];
    
    for (MVMessageModel *model in self.messageModels) {
        NSString *key = [self headerTitleFromDate:model.sendDate];
        NSMutableArray *rows = self.messages[key];
        if (!rows) {
            rows = [NSMutableArray new];
            [self.sections addObject:key];
        }
        [rows addObject:model];
        [self.messages setObject:rows forKey:key];
    }
}

#pragma mark - Table view
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages[self.sections[section]].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"MessageCell";
    NSString *section = self.sections[indexPath.section];
    MVMessageModel *model = self.messages[section][indexPath.row];
    
    if (model.direction == MessageDirectionOutgoing) {
        cellId = [cellId stringByAppendingString:@"Outgoing"];
    } else {
        cellId = [cellId stringByAppendingString:@"Incoming"];
    }
    
    if (![self messageHasTailAtIndexPath:indexPath]) {
        cellId = [cellId stringByAppendingString:@"Tailess"];
        if ([self messageIsFirstInTailessGroup:indexPath]) {
            cellId = [cellId stringByAppendingString:@"First"];
        }
    } else {
        if ([self messageIsLastInTailessGroup:indexPath]) {
            cellId = [cellId stringByAppendingString:@"Last"];
        }
    }

    MVMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.messageLabel.text = model.text;
    cell.timeLabel.text = [self timeFromDate:model.sendDate];
    
    __weak MVMessageCell *weakCell = cell;
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ContactAvatarUpdate" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
//        NSString *id = note.userInfo[@"Id"];
        NSString *avatarName = note.userInfo[@"Avatar"];
        weakCell.avatarImage.image = [UIImage imageNamed:avatarName];
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell <MVSlidingCell> *slidingCell = (UITableViewCell <MVSlidingCell> *)cell;
    CGFloat oldSlidingConstraint = slidingCell.slidingConstraint;
    
    if (oldSlidingConstraint != self.sliderOffset) {
        [slidingCell setSlidingConstraint:self.sliderOffset];
    }
    
    [slidingCell.contentView layoutIfNeeded];
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = self.sections[section];
    MVMessageHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"MessageHeader"];
    header.titleLabel.text = sectionTitle;
    
    return header;
}

#pragma mark - Gesture recognizers
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self.view];
    if (ABS(translation.y) > 1) {
        return NO;
    } else {
        return YES;
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panRecognizer {
    NSArray<id <MVSlidingCell>> *visibleCells = self.messagesTableView.visibleCells;
    
    if (!visibleCells.count) {
        return;
    }
    
    if (panRecognizer.state == UIGestureRecognizerStateEnded || panRecognizer.state == UIGestureRecognizerStateFailed || panRecognizer.state == UIGestureRecognizerStateCancelled) {
        CGFloat constant = 0;
        for (MVMessageCell *cell in visibleCells) {
            [cell setSlidingConstraint:constant];
        }
        
        self.sliderOffset = constant;
        
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
        }];
        
        return;
    }
    
    CGFloat oldConstant = [visibleCells[0] slidingConstraint];
    CGFloat constant = [panRecognizer translationInView:self.view].x;
    CGFloat velocityX = [panRecognizer velocityInView:self.view].x;
    
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
        
        self.sliderOffset = constant;
        
        [UIView animateWithDuration:duration animations:^{
            [self.messagesTableView layoutIfNeeded];
        }];
    }
}

#pragma mark - Helpers
- (NSString *)timeFromDate:(NSDate *)date {
    NSDateFormatter *timeFormatter = [NSDateFormatter new];
    timeFormatter.dateFormat = @"HH:mm";
    
    return [timeFormatter stringFromDate:date];
}

- (NSString *)headerTitleFromDate:(NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.timeStyle = NSDateFormatterNoStyle;
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.doesRelativeDateFormatting = YES;
    
    return [formatter stringFromDate:date];
}

- (BOOL) messageHasTailAtIndexPath:(NSIndexPath *)indexPath {
    NSString *section = self.sections[indexPath.section];
    NSArray *messages = self.messages[section];
    BOOL hasTail = YES;
    if (messages.count > indexPath.row + 1) {
        MVMessageModel *model = messages[indexPath.row];
        MVMessageModel *nextModel = messages[indexPath.row + 1];
        NSTimeInterval interval = [nextModel.sendDate timeIntervalSinceDate:model.sendDate];
        if (model.direction == nextModel.direction && interval < 60) {
            hasTail = NO;
        }
    }
    return hasTail;
}

- (MessageDirection) messageDirectionAtIndexPath:(NSIndexPath *)indexPath {
    NSString *section = self.sections[indexPath.section];
    MVMessageModel *message = self.messages[section][indexPath.row];
    
    return message.direction;
}

- (BOOL) messageIsFirstInTailessGroup:(NSIndexPath *)indexPath {
    BOOL first = NO;
    BOOL hasTail = [self messageHasTailAtIndexPath:indexPath];
    if (!hasTail) {
        if (indexPath.row - 1 >=                    0) {
            NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
            BOOL sameDirection = [self messageDirectionAtIndexPath:indexPath] == [self messageDirectionAtIndexPath:previousIndexPath];
            BOOL previousHasTail = [self messageHasTailAtIndexPath:previousIndexPath];
            if (previousHasTail && sameDirection) {
                first = YES;
            }
        } else {
            first = YES;
        }
    }
    
    return first;
}

- (BOOL) messageIsLastInTailessGroup:(NSIndexPath *)indexPath {
    BOOL last = NO;
    BOOL hasTail = [self messageHasTailAtIndexPath:indexPath];
    if (hasTail) {
        if (indexPath.row - 1 >= 0) {
            NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
            BOOL sameDirection = [self messageDirectionAtIndexPath:indexPath] == [self messageDirectionAtIndexPath:previousIndexPath];
            BOOL previousHasTail = [self messageHasTailAtIndexPath:previousIndexPath];
            if (!previousHasTail && sameDirection) {
                last = YES;
            }
        }
    }
    return last;
}
@end
