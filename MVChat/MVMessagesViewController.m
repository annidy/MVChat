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
#import "MVMessageTextCell.h"
#import "MVMessageHeaderCell.h"
#import "MVContactManager.h"
#import "MVMessageSystemCell.h"
#import "MVMessageMediaCell.h"
#import "MVMessageCellDelegate.h"
#import "MVChatSharedMediaPageController.h"
#import "MVImageViewerViewModel.h"
#import "MVFileManager.h"

@interface MVMessagesViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, MVMessagesUpdatesListener, MVMessageCellDelegate>
@property (strong, nonatomic) IBOutlet UITableView *messagesTableView;

@property (strong, nonatomic) NSMutableArray <NSString *> *sections;
@property (strong, nonatomic) NSMutableDictionary <NSString *, NSMutableArray <MVMessageModel *>*> *messages;
@property (assign, nonatomic) CGFloat sliderOffset;
@property (assign, nonatomic) BOOL autoscrollEnabled;
@property (assign, nonatomic) NSInteger loadedPageIndex;
@property (assign, nonatomic) BOOL processingMessages;
@property (assign, nonatomic) BOOL initialLoadComplete;
@property (strong, nonatomic) NSCache *cellHeightCache;
@property (assign, nonatomic) BOOL keyboardShown;
@property (assign, nonatomic) BOOL hasUnreadMessages;
@property (assign, nonatomic) BOOL shouldAnimateContentOffset;
@end

@implementation MVMessagesViewController

#pragma mark - Lifecycle
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
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
    
    [self registerCells];
    
    self.messagesTableView.tableFooterView = [UIView new];
    self.messagesTableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    
    [MVChatManager sharedInstance].messagesListener = self;
    [self tryToLoadNextPage];
    
    [self.messagesTableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)registerCells {
    [self.messagesTableView registerClass:[MVMessageHeaderCell class] forCellReuseIdentifier:@"MVMessageHeaderCell"];
    [self.messagesTableView registerClass:[MVMessageSystemCell class] forCellReuseIdentifier:@"MVMessageSystemCell"];
    [self.messagesTableView registerClass:[MVMessageTextCell class] forCellReuseIdentifier:@"MVMessageTextTailTypeDefaultIncomingCell"];
    [self.messagesTableView registerClass:[MVMessageTextCell class] forCellReuseIdentifier:@"MVMessageTextTailTypeTailessIncomingCell"];
    [self.messagesTableView registerClass:[MVMessageTextCell class] forCellReuseIdentifier:@"MVMessageTextTailTypeLastTailessIncomingCell"];
    [self.messagesTableView registerClass:[MVMessageTextCell class] forCellReuseIdentifier:@"MVMessageTextTailTypeFirstTailessIncomingCell"];
    [self.messagesTableView registerClass:[MVMessageTextCell class] forCellReuseIdentifier:@"MVMessageTextTailTypeDefaultOutgoingCell"];
    [self.messagesTableView registerClass:[MVMessageTextCell class] forCellReuseIdentifier:@"MVMessageTextTailTypeTailessOutgoingCell"];
    [self.messagesTableView registerClass:[MVMessageTextCell class] forCellReuseIdentifier:@"MVMessageTextTailTypeLastTailessOutgoingCell"];
    [self.messagesTableView registerClass:[MVMessageTextCell class] forCellReuseIdentifier:@"MVMessageTextTailTypeFirstTailessOutgoingCell"];
    [self.messagesTableView registerClass:[MVMessageMediaCell class] forCellReuseIdentifier:@"MVMessageMediaTailTypeDefaultIncomingCell"];
    [self.messagesTableView registerClass:[MVMessageMediaCell class] forCellReuseIdentifier:@"MVMessageMediaTailTypeTailessIncomingCell"];
    [self.messagesTableView registerClass:[MVMessageMediaCell class] forCellReuseIdentifier:@"MVMessageMediaTailTypeLastTailessIncomingCell"];
    [self.messagesTableView registerClass:[MVMessageMediaCell class] forCellReuseIdentifier:@"MVMessageMediaTailTypeFirstTailessIncomingCell"];
    [self.messagesTableView registerClass:[MVMessageMediaCell class] forCellReuseIdentifier:@"MVMessageMediaTailTypeDefaultOutgoingCell"];
    [self.messagesTableView registerClass:[MVMessageMediaCell class] forCellReuseIdentifier:@"MVMessageMediaTailTypeTailessOutgoingCell"];
    [self.messagesTableView registerClass:[MVMessageMediaCell class] forCellReuseIdentifier:@"MVMessageMediaTailTypeLastTailessOutgoingCell"];
    [self.messagesTableView registerClass:[MVMessageMediaCell class] forCellReuseIdentifier:@"MVMessageMediaTailTypeFirstTailessOutgoingCell"];
}

#pragma mark - Data handling
- (void)handleNewMessagesPage:(NSArray <MVMessageModel *> *)models {
    NSMutableArray *sections = [self.sections mutableCopy];
    NSMutableDictionary *messages = [self.messages mutableCopy];
    
    for (MVMessageModel *message in models) {
        NSString *sectionKey = [self headerTitleFromMessage:message];
        NSMutableArray *rows = messages[sectionKey];
        
        if (!rows) {
            rows = [NSMutableArray new];
            [messages setObject:rows forKey:sectionKey];
            [sections insertObject:sectionKey atIndex:0];
            
        }
        
        [rows insertObject:message atIndex:0];
    }
    
    self.messages = [messages mutableCopy];
    self.sections = [sections mutableCopy];
    [self.messagesTableView reloadData];
    [[MVChatManager sharedInstance] markChatAsRead:self.chatId];
}

- (void)handleNewMessage:(MVMessageModel *)message {
    NSMutableArray *sections = [self.sections mutableCopy];
    NSMutableDictionary *messages = [self.messages mutableCopy];
    
    NSString *sectionKey = [self headerTitleFromMessage:message];
    NSMutableArray *rows = messages[sectionKey];
    
    BOOL insertedSection = NO;
    if (!rows) {
        insertedSection = YES;
        rows = [NSMutableArray new];
        [messages setObject:rows forKey:sectionKey];
        [sections addObject:sectionKey];
    }
    
    [rows addObject:message];
    
    self.messages = [messages mutableCopy];
    self.sections = [sections mutableCopy];
    self.shouldAnimateContentOffset = YES;
    if (insertedSection) {
        [self.messagesTableView insertSections:[NSIndexSet indexSetWithIndex:self.sections.count - 1] withRowAnimation:UITableViewRowAnimationBottom];
    } else {
        NSIndexPath *indexPathToInsert = [NSIndexPath indexPathForRow:rows.count inSection:sections.count - 1];
        NSIndexPath *indexPathToReload = [NSIndexPath indexPathForRow:rows.count - 1 inSection:sections.count - 1];
        [self.messagesTableView insertRowsAtIndexPaths:@[indexPathToInsert] withRowAnimation:UITableViewRowAnimationBottom];
        [self.messagesTableView reloadRowsAtIndexPaths:@[indexPathToReload] withRowAnimation:UITableViewRowAnimationNone];
    }
    [[MVChatManager sharedInstance] markChatAsRead:self.chatId];
}

- (void)insertNewMessage:(MVMessageModel *)message {
    self.processingMessages = YES;
    [self handleNewMessage:message];
    self.processingMessages = NO;
    
}

- (void)updateMessage:(MVMessageModel *)message {
    //TODO: support delivery status
}

- (void)tryToLoadNextPage {
    if (self.processingMessages) {
        return;
    }
    
    NSInteger numberOfPages = [[MVChatManager sharedInstance] numberOfPagesInChatWithId:self.chatId];
    BOOL shouldLoad = (numberOfPages > self.loadedPageIndex + 1) || (numberOfPages == 0 && !self.initialLoadComplete);
    
    if (shouldLoad) {
        self.processingMessages = YES;
        [[MVChatManager sharedInstance] messagesPage:++self.loadedPageIndex forChatWithId:self.chatId withCallback:^(NSArray<MVMessageModel *> *messages) {
            [self handleNewMessagesPage:messages];
            self.processingMessages = NO;
            self.initialLoadComplete = YES;
        }];
    }
}

#pragma mark - Table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages[self.sections[section]].count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *section = self.sections[indexPath.section];
    MVMessageModel *model;
    MVMessageCellTailType tailType = 0;
    
    if (indexPath.row != 0) {
        model = self.messages[section][indexPath.row - 1];
        if (model.type != MVMessageTypeSystem) {
            tailType = [self messageCellTailTypeAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]];
        }
    }
    
    NSString *cacheKey = [NSString stringWithFormat:@"%@_%@_%lu", section, model.id, (unsigned long)tailType];
    NSNumber *cachedHeight = [self.cellHeightCache objectForKey:cacheKey];
    if (cachedHeight) {
        return [cachedHeight floatValue];
    }
    
    CGFloat height;
    if (indexPath.row == 0) {
        height = [MVMessageHeaderCell heightWithText:section];
    } else if (model.type == MVMessageTypeSystem) {
        height = [MVMessageSystemCell heightWithText:model.text];
    } else if (model.type == MVMessageTypeText){
        height = [MVMessageTextCell heightWithTailType:tailType direction:model.direction andModel:model];
    } else {
        height = [MVMessageMediaCell heightWithTailType:tailType direction:model.direction andModel:model];
    }
    
    [self.cellHeightCache setObject:@(height) forKey:cacheKey];
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = [self cellIdForIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (indexPath.row == 0) {
        MVMessagePlainCell *headerCell = (MVMessagePlainCell *)cell;
        NSString *sectionTitle = self.sections[indexPath.section];
        [headerCell fillWithText:sectionTitle];
    } else {
        NSString *section = self.sections[indexPath.section];
        MVMessageModel *model = self.messages[section][indexPath.row - 1];
        if (model.type == MVMessageTypeSystem) {
            MVMessagePlainCell *systemCell = (MVMessagePlainCell *)cell;
            [systemCell fillWithText:model.text];
        } else {
            MVMessageBubbleCell *bubbleCell = (MVMessageBubbleCell *)cell;
            [bubbleCell fillWithModel:model];
            bubbleCell.indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
            bubbleCell.delegate = self;
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
        [slidingCell.contentView layoutIfNeeded];
    }
}

#pragma mark - Scroll View
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.autoscrollEnabled = (self.messagesTableView.contentOffset.y >= (self.messagesTableView.contentSize.height - self.messagesTableView.frame.size.height));
    
    if(self.initialLoadComplete && self.messagesTableView.contentOffset.y <= 200) {
        [self tryToLoadNextPage];
    }
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
        [self.messagesTableView setContentOffset:offset animated:self.shouldAnimateContentOffset];
        self.shouldAnimateContentOffset = NO;
    }
}

#pragma mark - Handle Keyboard
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

#pragma mark - Gesture recognizers
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self.view];
    return ABS(translation.y) < 1;
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
        for (MVMessageTextCell *cell in visibleCells) {
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
    
    if (constant > 0) constant = 0;
    
    if (constant < -40) constant = -40;
    
    if (oldConstant != constant) {
        CGFloat path = ABS(oldConstant - constant);
        NSTimeInterval duration = path / velocityX;
        for (MVMessageTextCell *cell in visibleCells) {
            [cell setSlidingConstraint:constant];
        }
        
        self.sliderOffset = constant;
        
        [UIView animateWithDuration:duration animations:^{
            [self.messagesTableView layoutIfNeeded];
        }];
    }
}

- (IBAction)tableViewTapped:(id)sender {
    [self.view.superview.superview endEditing:YES];
}

- (void)cellTapped:(UITableViewCell *)cell {
    if (![cell isKindOfClass:[MVMessageMediaCell class]]) {
        return;
    }
    
    MVMessageMediaCell *mediaCell = (MVMessageMediaCell *)cell;
    NSIndexPath *indexPath = mediaCell.indexPath;
    NSString *section = self.sections[indexPath.section];
    MVMessageModel *message = self.messages[section][indexPath.row];
    
    [[MVFileManager sharedInstance] loadAttachmentForMessage:message completion:^(DBAttachment *attachment) {
        MVImageViewerViewModel *viewModel = [[MVImageViewerViewModel alloc] initWithSourceImageView:mediaCell.mediaImageView attachment:attachment andIndex:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            MVChatSharedMediaPageController *imageController = [MVChatSharedMediaPageController loadFromStoryboardWithViewModels:@[viewModel] andStartIndex:0];
            [self presentViewController:imageController animated:YES completion:nil];
        });
    }];
}

#pragma mark - Helpers
static NSDateFormatter *dateFormatter;
- (NSString *)headerTitleFromMessage:(MVMessageModel *)message {
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        dateFormatter.doesRelativeDateFormatting = YES;
    }
    
    if ((!self.initialLoadComplete && message.read) || (self.initialLoadComplete && !self.hasUnreadMessages)) {
        return [dateFormatter stringFromDate:message.sendDate];
    } else {
        return @"New Messages";
    }
}

- (NSString *)cellIdForIndexPath:(NSIndexPath *)indexPath {
    NSMutableString *cellId = [NSMutableString stringWithString:@"MVMessage"];
    
    if (indexPath.row == 0) {
        [cellId appendString:@"Header"];
    } else {
        NSString *section = self.sections[indexPath.section];
        MVMessageModel *model = self.messages[section][indexPath.row - 1];
        
        if (model.type == MVMessageTypeSystem) {
            [cellId appendString:@"System"];
        } else {
            if(model.type == MVMessageTypeMedia) {
                [cellId appendString:@"Media"];
            } else {
                [cellId appendString:@"Text"];
            }
            
            [cellId appendString:@"TailType"];
            MVMessageCellTailType tailType = [self messageCellTailTypeAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]];
            switch (tailType) {
                case MVMessageCellTailTypeDefault:
                    [cellId appendString:@"Default"];
                    break;
                case MVMessageCellTailTypeTailess:
                    [cellId appendString:@"Tailess"];
                    break;
                case MVMessageCellTailTypeLastTailess:
                    [cellId appendString:@"LastTailess"];
                    break;
                case MVMessageCellTailTypeFirstTailess:
                    [cellId appendString:@"FirstTailess"];
                    break;
                default:
                    break;
            }
            
            if (model.direction == MessageDirectionOutgoing) {
                [cellId appendString:@"Outgoing"];
            } else {
                [cellId appendString:@"Incoming"];
            }
        }
    }
    
    [cellId appendString:@"Cell"];
    
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
