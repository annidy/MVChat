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
#import "MVTextMessageCell.h"
#import "MVMessageHeader.h"
#import "MVContactManager.h"
#import "MVDataAggregator.h"
#import "MVSystemMessageCell.h"

@interface MVMessagesViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, MessagesUpdatesListener>
@property (strong, nonatomic) IBOutlet UITableView *messagesTableView;
@property (strong, nonatomic) NSArray <MVMessageModel *> *messageModels;

@property (strong, nonatomic) NSMutableArray <NSString *> *sections;
@property (strong, nonatomic) NSMutableDictionary <NSString *, NSMutableArray <MVMessageModel *>*> *messages;
@property (assign, nonatomic) CGFloat sliderOffset;
@property (assign, nonatomic) BOOL autoscrollEnabled;
@property (strong, nonatomic) UILabel *referenceLabel;
@property (assign, nonatomic) NSUInteger loadedPageIndex;
@property (assign, nonatomic) BOOL loadingNewPage;
@property (assign, nonatomic) BOOL initialLoadComplete;
@property (strong, nonatomic) NSCache *cellHeightCache;
@property (assign, nonatomic) BOOL keyboardShown;
@end

@implementation MVMessagesViewController

#pragma mark - Lifecycle
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _messageModels = [NSArray new];
        _sections = [NSMutableArray new];
        _messages = [NSMutableDictionary new];
        _cellHeightCache = [NSCache new];
        _sliderOffset = 0;
        _autoscrollEnabled = YES;
        _loadedPageIndex = -1;
    }
    
    return self;
}

- (void)dealloc {
    [self.messagesTableView removeObserver:self forKeyPath:@"contentSize"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.messagesTableView registerClass:[MVMessageHeader class] forCellReuseIdentifier:@"MVMessageHeader"];
    [self.messagesTableView registerClass:[MVSystemMessageCell class] forCellReuseIdentifier:@"MVMessageCellSystem"];
    [self.messagesTableView registerClass:[MVTextMessageCell class] forCellReuseIdentifier:@"MVMessageCellIncomingTailTypeDefault"];
    [self.messagesTableView registerClass:[MVTextMessageCell class] forCellReuseIdentifier:@"MVMessageCellIncomingTailTypeTailess"];
    [self.messagesTableView registerClass:[MVTextMessageCell class] forCellReuseIdentifier:@"MVMessageCellIncomingTailTypeLastTailess"];
    [self.messagesTableView registerClass:[MVTextMessageCell class] forCellReuseIdentifier:@"MVMessageCellIncomingTailTypeFirstTailess"];
    [self.messagesTableView registerClass:[MVTextMessageCell class] forCellReuseIdentifier:@"MVMessageCellOutgoingTailTypeDefault"];
    [self.messagesTableView registerClass:[MVTextMessageCell class] forCellReuseIdentifier:@"MVMessageCellOutgoingTailTypeTailess"];
    [self.messagesTableView registerClass:[MVTextMessageCell class] forCellReuseIdentifier:@"MVMessageCellOutgoingTailTypeLastTailess"];
    [self.messagesTableView registerClass:[MVTextMessageCell class] forCellReuseIdentifier:@"MVMessageCellOutgoingTailTypeFirstTailess"];
    self.messagesTableView.tableFooterView = [UIView new];
    self.messagesTableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    
    [self.messagesTableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];

    [MVChatManager sharedInstance].messagesListener = self;
    [[MVChatManager sharedInstance] loadMessagesForChatWithId:self.chatId withCallback:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self tryToLoadNextPage];
            self.initialLoadComplete = YES;
        });
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messagesTapped)];
    [self.messagesTableView addGestureRecognizer:tapGesture];
}

- (void)messagesTapped {
    [self.view.superview.superview endEditing:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    if (!self.keyboardShown) {
        [self adjustContentOffsetDuringKeyboardAppear:YES withNotification:notification];
        self.keyboardShown = YES;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (self.keyboardShown) {
        [self adjustContentOffsetDuringKeyboardAppear:NO withNotification:notification];
        self.keyboardShown = NO;
    }
}

- (void)adjustContentOffsetDuringKeyboardAppear:(BOOL)appear withNotification:(NSNotification *)notification {
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    CGRect keyboardEndFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = CGRectGetHeight(keyboardEndFrame);
    
    CGPoint offset = self.messagesTableView.contentOffset;
    if (appear) {
        offset.y += keyboardHeight;
    } else {
        offset.y -= keyboardHeight;
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        self.messagesTableView.contentOffset = offset;
    } completion:nil];
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
    
    if (inset != tableViewInsets.top) {
        tableViewInsets.top = inset;
        self.messagesTableView.contentInset = tableViewInsets;
    }
    
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
    
    if (offset.y != self.messagesTableView.contentOffset.y) {
        self.messagesTableView.contentOffset = offset;
    }
}

#pragma mark - Data handling
- (void)handleNewMessages:(NSArray <MVMessageUpdateModel *> *)models {
    NSMutableArray *sections = [self.sections mutableCopy];
    NSMutableDictionary *messages = [self.messages mutableCopy];
    
    for (MVMessageUpdateModel *messageUpdate in models) {
        NSString *key = [self headerTitleFromDate:messageUpdate.message.sendDate];
        NSMutableArray *rows = messages[key];
        
        if (!rows) {
            rows = [NSMutableArray new];
            if (messageUpdate.position == MessageUpdatePositionStart) {
                [sections insertObject:key atIndex:0];
            } else {
                [sections addObject:key];
            }
        }
        
        if (messageUpdate.position == MessageUpdatePositionStart) {
            [rows insertObject:messageUpdate.message atIndex:0];
        } else {
            [rows addObject:messageUpdate.message];
        }
        
        [messages setObject:rows forKey:key];
    }
    
    self.messages = [messages mutableCopy];
    self.sections = [sections mutableCopy];
    [self.messagesTableView reloadData];
}

- (void)handleNewMessage:(MVMessageUpdateModel *)messageUpdate {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self handleNewMessages:@[messageUpdate]];
    });
    
    //Animate new message!
}

- (void)handleNewMessagesBlock:(NSArray <MVMessageModel *> *)messageModels {
    NSMutableArray *sections = [self.sections mutableCopy];
    NSMutableDictionary *messages = [self.messages mutableCopy];
    
    for (MVMessageModel *message in messageModels) {
        NSString *key = [self headerTitleFromDate:message.sendDate];
        NSMutableArray *rows = messages[key];
        if (!rows) {
            rows = [NSMutableArray new];
            [sections insertObject:key atIndex:0];
            [messages setObject:rows forKey:key];
        }
        [rows insertObject:message atIndex:0];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.sections = [sections mutableCopy];
        self.messages = [messages mutableCopy];
        [self.messagesTableView reloadData];
        @synchronized (self) {
            self.loadingNewPage = NO;
        }
    });
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
            dispatch_async(dispatch_get_main_queue(), ^{
                self.loadedPageIndex++;
                [self handleNewMessagesBlock:messages];
                @synchronized (self) {
                    self.loadingNewPage = NO;
                }
            });
        }];
    } else {
        @synchronized (self) {
            self.loadingNewPage = NO;
        }
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
    NSString *section = self.sections[indexPath.section];
    MVMessageModel *model;
    
    if (indexPath.row != 0) {
        model = self.messages[section][indexPath.row - 1];
    }
    
    NSString *cacheKey = [NSString stringWithFormat:@"%@_%@", section, model.id];
    NSNumber *cachedHeight = [self.cellHeightCache objectForKey:cacheKey];
    if (cachedHeight) {
        return [cachedHeight floatValue];
    }
    
    CGFloat height;
    if (indexPath.row == 0) {
        height = [MVMessageHeader heightWithText:section];
    } else {
        if (model.type == MVMessageTypeSystem) {
            height = [MVSystemMessageCell heightWithText:model.text];
        } else {
            MVMessageCellTailType tailType = [self messageCellTailTypeAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]];
            height = [MVTextMessageCell heightWithTailType:tailType direction:model.direction andText:model.text];
        }
    }
    
    [self.cellHeightCache setObject:@(height) forKey:cacheKey];
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = [self cellIdForIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (indexPath.row == 0) {
        id <MVMessageCellSimpleProtocol> simpleCell = (id <MVMessageCellSimpleProtocol>) cell;
        NSString *sectionTitle = self.sections[indexPath.section];
        [simpleCell fillWithText:sectionTitle];
    } else {
        NSString *section = self.sections[indexPath.section];
        MVMessageModel *model = self.messages[section][indexPath.row - 1];
        if (model.type == MVMessageTypeSystem) {
            id <MVMessageCellSimpleProtocol> simpleCell = (id <MVMessageCellSimpleProtocol>) cell;
            [simpleCell fillWithText:model.text];
        } else {
            id <MVMessageCellComplexProtocol> complexCell = (id <MVMessageCellComplexProtocol>) cell;
            [complexCell fillWithModel:model];
        }
    }
    
    return cell;
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
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self.view];
    if (ABS(translation.y) > 1) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)panRecognizer {
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
        for (MVTextMessageCell *cell in visibleCells) {
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
        for (MVTextMessageCell *cell in visibleCells) {
            [cell setSlidingConstraint:constant];
        }
        
        self.sliderOffset = constant;
        
        [UIView animateWithDuration:duration animations:^{
            [self.messagesTableView layoutIfNeeded];
        }];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.messagesTableView.contentOffset.y >= (self.messagesTableView.contentSize.height - self.messagesTableView.frame.size.height)) {
        self.autoscrollEnabled = YES;
    }
    else {
        self.autoscrollEnabled = NO;
    }
    
    if(self.initialLoadComplete && self.messagesTableView.contentOffset.y <= 200) {
        [self tryToLoadNextPage];
    }
}

#pragma mark - Helpers
static NSDateFormatter *dateFormatter;
- (NSString *)headerTitleFromDate:(NSDate *)date {
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        dateFormatter.doesRelativeDateFormatting = YES;
    }
    
    return [dateFormatter stringFromDate:date];
}

- (NSString *)cellIdForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return @"MVMessageHeader";
    }
    
    NSString *section = self.sections[indexPath.section];
    MVMessageModel *model = self.messages[section][indexPath.row - 1];
    
    if (model.type == MVMessageTypeSystem) {
        return @"MVMessageCellSystem";
    }
    
    NSMutableString *cellId = [NSMutableString stringWithString:@"MVMessageCell"];
    if (model.direction == MessageDirectionOutgoing) {
        [cellId appendString:@"Outgoing"];
    } else {
        [cellId appendString:@"Incoming"];
    }
    
    MVMessageCellTailType tailType = [self messageCellTailTypeAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]];
    switch (tailType) {
        case MVMessageCellTailTypeDefault:
            [cellId appendString:@"TailTypeDefault"];
            break;
        case MVMessageCellTailTypeTailess:
            [cellId appendString:@"TailTypeTailess"];
            break;
        case MVMessageCellTailTypeLastTailess:
            [cellId appendString:@"TailTypeLastTailess"];
            break;
        case MVMessageCellTailTypeFirstTailess:
            [cellId appendString:@"TailTypeFirstTailess"];
            break;
        default:
            break;
    }
    
    return [cellId copy];
}

- (MVMessageCellTailType)messageCellTailTypeAtIndexPath:(NSIndexPath *)indexPath {
    NSString *section = self.sections[indexPath.section];
    NSArray *messages = self.messages[section];
    
    MVMessageModel *model = messages[indexPath.row];
    MVMessageModel *nextModel;
    MVMessageModel *previousModel;
    
    MVMessageModel * (^messageModelWithSameDirectionAndType)(NSInteger) = ^MVMessageModel *(NSInteger index) {
        if (messages.count > index && index >= 0) {
            MVMessageModel *possibleModel = messages[index];
            if (possibleModel.direction == model.direction && possibleModel.type == model.type) {
                return possibleModel;
            }
        }
        return nil;
    };
    
    nextModel = messageModelWithSameDirectionAndType(indexPath.row + 1);
    previousModel = messageModelWithSameDirectionAndType(indexPath.row - 1);
    
    BOOL previousHasTail = NO;
    if (previousModel) {
        NSTimeInterval interval = [model.sendDate timeIntervalSinceDate:previousModel.sendDate];
        if (interval < 60) {
            previousHasTail = NO;
        } else {
            previousHasTail = YES;
        }
    }
    
    MVMessageCellTailType tailType = MVMessageCellTailTypeDefault;
    
    NSTimeInterval interval = 0;
    if (nextModel) {
        interval = [nextModel.sendDate timeIntervalSinceDate:model.sendDate];
    }
    
    if (!nextModel || interval > 60) {
        if (previousModel && !previousHasTail) {
            tailType = MVMessageCellTailTypeLastTailess;
        } else {
            tailType = MVMessageCellTailTypeDefault;
        }
    } else {
        if (previousModel && !previousHasTail) {
            tailType = MVMessageCellTailTypeTailess;
        } else {
            tailType = MVMessageCellTailTypeFirstTailess;
        }
    }
    
    return tailType;
}
@end
