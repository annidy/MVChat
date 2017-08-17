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
#import "MVDataAggregator.h"


@implementation NSMutableIndexSet (Increment)
- (void)increment {
    if (self.count) {
        [self addIndex:self.lastIndex + 1];
    } else {
        [self addIndex:0];
    }
}
@end

@interface MVMessagesViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, MessagesUpdatesListener>
@property (strong, nonatomic) IBOutlet UITableView *messagesTableView;
@property (strong, nonatomic) NSArray <MVMessageModel *> *messageModels;

@property (strong, nonatomic) NSMutableArray <NSString *> *sections;
@property (strong, nonatomic) NSMutableDictionary <NSString *, NSMutableArray <MVMessageModel *>*> *messages;
@property (assign, nonatomic) CGFloat sliderOffset;
@property (assign, nonatomic) BOOL autoscrollEnabled;
@property (strong, nonatomic) MVDataAggregator *messageCallbackHandler;
@property (strong, nonatomic) UILabel *referenceLabel;
@property (assign, nonatomic) NSUInteger loadedPageIndex;
@property (assign, nonatomic) BOOL loadingNewPage;
@end

@implementation MVMessagesViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MVChatManager sharedInstance].messagesListener = self;
    
    self.sliderOffset = 0;
    [self.messagesTableView registerClass:[MVMessageCell class] forCellReuseIdentifier:@"MessageCellIncoming"];
    [self.messagesTableView registerClass:[MVMessageCell class] forCellReuseIdentifier:@"MessageCellOutgoing"];
    [self.messagesTableView registerClass:[MVMessageCell class] forCellReuseIdentifier:@"MessageCellIncomingLast"];
    [self.messagesTableView registerClass:[MVMessageCell class] forCellReuseIdentifier:@"MessageCellOutgoingLast"];
    [self.messagesTableView registerClass:[MVMessageCell class] forCellReuseIdentifier:@"MessageCellOutgoingTailess"];
    [self.messagesTableView registerClass:[MVMessageCell class] forCellReuseIdentifier:@"MessageCellIncomingTailess"];
    [self.messagesTableView registerClass:[MVMessageCell class] forCellReuseIdentifier:@"MessageCellOutgoingTailessFirst"];
    [self.messagesTableView registerClass:[MVMessageCell class] forCellReuseIdentifier:@"MessageCellIncomingTailessFirst"];
    [self.messagesTableView registerClass:[MVMessageHeader class] forCellReuseIdentifier:@"MessageHeader"];
    
    self.messagesTableView.tableFooterView = [UIView new];
    self.messagesTableView.delegate = self;
    self.messagesTableView.dataSource = self;
    self.messagesTableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    
    //self.messageModels = [[MVChatManager sharedInstance] messagesForChatWithId:self.chatId];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:panRecognizer];
    panRecognizer.delegate = self;
    
    //[self mapWithSections];
    [self.messagesTableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    self.autoscrollEnabled = YES;
    
    self.messageCallbackHandler = [[MVDataAggregator alloc] initWithThrottle:0.5 allowingFirst:YES maxObjectsCount:50 andBlock:^(NSArray *models) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleNewMessages:models];
        });
    }];
    
    self.loadedPageIndex = 0;
    
    [[MVChatManager sharedInstance] messagesPage:0 forChatWithId:self.chatId withCallback:^(NSArray<MVMessageModel *> *messages) {
        NSMutableArray *updates = [NSMutableArray new];
        for (MVMessageModel *message in messages) {
            [updates addObject:[MVMessageUpdateModel updateModelWithMessage:message andPosition:MessageUpdatePositionStart]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleNewMessages:updates];
        });
    }];
}

#pragma mark - Lazy loading
- (NSArray<MVMessageModel *> *)messageModels {
    if (!_messageModels) _messageModels = [NSArray new];
    return _messageModels;
}

- (NSMutableArray<NSString *> *)sections {
    if (!_sections) _sections = [NSMutableArray new];
    return _sections;
}

- (NSMutableDictionary<NSString *,NSMutableArray<MVMessageModel *> *> *)messages {
    if (!_messages) _messages = [NSMutableDictionary new];
    return _messages;
}

-(UILabel *)referenceLabel {
    if (!_referenceLabel) {
        _referenceLabel = [UILabel new];
        _referenceLabel.numberOfLines = 0;
    }
    
    return _referenceLabel;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.messagesTableView && [keyPath isEqualToString:@"contentSize"]) {
        CGSize oldSize = [[change objectForKey:NSKeyValueChangeOldKey] CGSizeValue];
        CGSize newSize = [[change objectForKey:NSKeyValueChangeNewKey] CGSizeValue];
        
        [self updateContentOffsetForOldContent:oldSize andNewContent:newSize];
        [self updateContentInsetForNewContent:newSize];
    }
}

#pragma mark - Content inset/offset
- (void)updateContentInsetForNewContent:(CGSize)contentSize {
    if (contentSize.height == 0) {
        return;
    }
    
    UIEdgeInsets tableViewInsets = self.messagesTableView.contentInset;
    CGFloat inset = self.messagesTableView.frame.size.height - self.messagesTableView.contentSize.height;
    if (inset < 64) {
        inset = 64;
    }
    if (inset == tableViewInsets.top) {
        return;
    }
    
    tableViewInsets.top = inset;
    self.messagesTableView.contentInset = tableViewInsets;
}

- (void)updateContentOffsetForOldContent:(CGSize)oldSize andNewContent:(CGSize)newSize {
    CGPoint offset = self.messagesTableView.contentOffset;
    
    if (newSize.height == 0) {
        offset.y = 0;
    } else if (self.autoscrollEnabled) {
        offset.y = newSize.height - self.messagesTableView.frame.size.height;
    } else {
        offset.y += newSize.height - oldSize.height;
    }
    
    self.messagesTableView.contentOffset = offset;
}

#pragma mark - Data handling
- (void)handleNewMessages:(NSArray <MVMessageModel *> *)models {
    NSMutableArray *sections = [self.sections mutableCopy];
    NSMutableDictionary *messages = [self.messages mutableCopy];
    
    NSMutableIndexSet *startIndexSet = [NSMutableIndexSet new];
    NSMutableIndexSet *endIndexSet = [NSMutableIndexSet new];
    NSMutableIndexSet *reloadIndexSet = [NSMutableIndexSet new];
    
    for (MVMessageUpdateModel *messageUpdate in models) {
        NSString *key = [self headerTitleFromDate:messageUpdate.message.sendDate];
        NSMutableArray *rows = messages[key];
        
        if (!rows) {
            rows = [NSMutableArray new];
            if (messageUpdate.position == MessageUpdatePositionStart) {
                [startIndexSet increment];
                [sections insertObject:key atIndex:0];
            } else {
                if (endIndexSet.count) {
                    [endIndexSet increment];
                } else {
                    [endIndexSet addIndex:sections.count];
                }
                
                [sections addObject:key];
            }
        } else {
            if (self.messages[key]) {
                if (messageUpdate.position == MessageUpdatePositionStart) {
                    [reloadIndexSet addIndex:0];
                } else {
                    [reloadIndexSet addIndex:self.messages.count - 1];
                }
            }
        }
        
        if (messageUpdate.position == MessageUpdatePositionStart) {
            [rows insertObject:messageUpdate.message atIndex:0];
        } else {
            [rows addObject:messageUpdate.message];
        }
        
        [messages setObject:rows forKey:key];
    }
    
    [startIndexSet addIndexes:endIndexSet];
    
    self.messages = [messages mutableCopy];
    self.sections = [sections mutableCopy];
    
    [UIView performWithoutAnimation:^{
        [self.messagesTableView beginUpdates];
        if (startIndexSet.count) {
            [self.messagesTableView insertSections:startIndexSet withRowAnimation:UITableViewRowAnimationNone];
        }
        if (reloadIndexSet.count) {
            [self.messagesTableView deleteSections:reloadIndexSet withRowAnimation:UITableViewRowAnimationNone];
            [self.messagesTableView insertSections:reloadIndexSet withRowAnimation:UITableViewRowAnimationNone];
            //[self.messagesTableView reloadSections:reloadIndexSet withRowAnimation:UITableViewRowAnimationNone];
        }
        [self.messagesTableView endUpdates];
    }];
}

- (void)handleNewMessage:(MVMessageUpdateModel *)messageUpdate {
    [self.messageCallbackHandler call:messageUpdate];
}

- (void)addToSections:(MVMessageModel *)model {
    NSString *key = [self headerTitleFromDate:model.sendDate];
    NSMutableArray *rows = self.messages[key];
    if (!rows) {
        rows = [NSMutableArray new];
        [self.sections addObject:key];
    }
    [rows addObject:model];
    [self.messages setObject:rows forKey:key];
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
    return self.messages[self.sections[section]].count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 26;
    }
    
    NSIndexPath *indexPathTwo = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
    indexPath = indexPathTwo;
    
    NSString *section = self.sections[indexPath.section];
    MVMessageModel *model = self.messages[section][indexPath.row];
    
    MessageDirection direction = model.direction;
    BOOL hasTail = [self messageHasTailAtIndexPath:indexPath];
    BOOL firstInTailessSection = [self messageIsFirstInTailessGroup:indexPath];
    BOOL lastInTailessSection = [self messageIsLastInTailessGroup:indexPath];
    
    CGFloat height = 0;
    
    if (!hasTail && !firstInTailessSection) {
        height += 1;
    } else if (hasTail && lastInTailessSection) {
        height += 1;
    } else {
        height += verticalMargin;
    }
    
    if (!hasTail) {
        height += 1;
    } else {
        height += verticalMargin;
    }
    
    height += 2 * verticalMargin;
    
    CGFloat tailOffset = bubbleTailMargin;
    if (!hasTail) {
        tailOffset -= tailWidth;
    }
    
    CGFloat multipler;
    if (direction == MessageDirectionOutgoing) {
        multipler = 0.8;
    } else {
        multipler = 0.7;
    }
    
    CGFloat maxLabelWidth = UIScreen.mainScreen.bounds.size.width * multipler - bubbleTailessMargin - tailOffset;
    
    [self.referenceLabel setText:model.text];
    height += [self.referenceLabel sizeThatFits:CGSizeMake(maxLabelWidth, CGFLOAT_MAX)].height;
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = [self cellIdForIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        NSString *sectionTitle = self.sections[indexPath.section];
        MVMessageHeader *header = [tableView dequeueReusableCellWithIdentifier:cellId];
        header.titleLabel.text = sectionTitle;
        return header;
    }
    
    NSIndexPath *indexPathTwo = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
    indexPath = indexPathTwo;
    
    NSString *section = self.sections[indexPath.section];
    MVMessageModel *model = self.messages[section][indexPath.row];

    MVMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.messageLabel.text = model.text;
    cell.timeLabel.text = [self timeFromDate:model.sendDate];
    
    cell.avatarImage.image = nil;
    [[MVContactManager sharedInstance] loadAvatarThumbnailForContact:model.contact completion:^(UIImage *image) {
        cell.avatarImage.image = image;
    }];
    
    __weak MVMessageCell *weakCell = cell;
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ContactAvatarUpdate" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSString *avatarName = note.userInfo[@"Avatar"];
        weakCell.avatarImage.image = [UIImage imageNamed:avatarName];
    }];
    
    return cell;
}

- (NSString *)cellIdForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return @"MessageHeader";
    }
    
    NSIndexPath *indexPathTwo = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
    indexPath = indexPathTwo;
    
    NSString *section = self.sections[indexPath.section];
    MVMessageModel *model = self.messages[section][indexPath.row];
    
    NSMutableString *cellId = [NSMutableString stringWithString:@"MessageCell"];
    if (model.direction == MessageDirectionOutgoing) {
        [cellId appendString:@"Outgoing"];
    } else {
        [cellId appendString:@"Incoming"];
    }
    if (![self messageHasTailAtIndexPath:indexPath]) {
        [cellId appendString:@"Tailess"];
        if ([self messageIsFirstInTailessGroup:indexPath]) {
            [cellId appendString:@"First"];
        }
    } else {
        if ([self messageIsLastInTailessGroup:indexPath]) {
            [cellId appendString:@"Last"];
        }
    }

    return [cellId copy];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (![cell conformsToProtocol:NSProtocolFromString(@"MVSlidingCell")]) {
        return;
    }
    
    UITableViewCell <MVSlidingCell> *slidingCell = (UITableViewCell <MVSlidingCell> *)cell;
    CGFloat oldSlidingConstraint = slidingCell.slidingConstraint;
    
    if (oldSlidingConstraint != self.sliderOffset) {
        [slidingCell setSlidingConstraint:self.sliderOffset];
    }
    
    [slidingCell.contentView layoutIfNeeded];
    
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
    
    NSMutableArray<id <MVSlidingCell>> *visibleCells = [NSMutableArray new];
    
    for (UITableViewCell *cell in self.messagesTableView.visibleCells) {
        if ([cell conformsToProtocol:NSProtocolFromString(@"MVSlidingCell")]) {
            [visibleCells addObject:(id <MVSlidingCell>)cell];
        }
    }
    
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

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.messagesTableView.contentOffset.y >= (self.messagesTableView.contentSize.height - self.messagesTableView.frame.size.height)) {
        self.autoscrollEnabled = YES;
    }
    else {
        self.autoscrollEnabled = NO;
    }
    
    if(self.messagesTableView.contentOffset.y <= 200) {
        [self tryToLoadNextPage];
    }
}

- (void)tryToLoadNextPage {
    @synchronized (self) {
        if (self.loadingNewPage) {
            return;
        }
        
        self.loadingNewPage = YES;
    }
    
    if ([[MVChatManager sharedInstance] numberOfPagesInChatWithId:self.chatId] > self.loadedPageIndex + 1) {
        [[MVChatManager sharedInstance] messagesPage:self.loadedPageIndex + 1 forChatWithId:self.chatId withCallback:^(NSArray<MVMessageModel *> *messages) {
            NSMutableArray *updates = [NSMutableArray new];
            
            for (MVMessageModel *message in messages) {
                [updates addObject:[MVMessageUpdateModel updateModelWithMessage:message andPosition:MessageUpdatePositionStart]];
            }
            
            self.loadedPageIndex++;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleNewMessages:updates];
                
                @synchronized (self) {
                    self.loadingNewPage = NO;
                }
            });
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
