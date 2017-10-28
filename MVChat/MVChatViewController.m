//
//  MVChatViewController.m
//  MVChat
//
//  Created by Mark Vasiv on 30/04/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVChatViewController.h"
#import "MVChatModel.h"
#import "MVChatManager.h"
#import "MVChatSettingsViewController.h"
#import "MVDatabaseManager.h"
#import "MVFileManager.h"
#import "MVContactProfileViewController.h"
#import "MVContactModel.h"
#import "MVContactManager.h"
#import "MVOverlayMenuController.h"
#import <DBAttachment.h>
#import "MVUpdatesProvider.h"
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

@interface MVChatViewController () <MVForceTouchPresentaionDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, MVMessagesUpdatesListener, MVMessageCellDelegate, MVChatsUpdatesListener>
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UITableView *messagesTableView;
@property (strong, nonatomic) IBOutlet UITextField *messageTextField;
@property (strong, nonatomic) IBOutlet UIView *messageTextFieldMask;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UIButton *attatchButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *footerBottom;
@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *chatTitleLabel;

@property (assign, nonatomic) CGFloat sliderOffset;
@property (assign, nonatomic) BOOL autoscrollEnabled;
@property (assign, nonatomic) BOOL keyboardShown;
@property (assign, nonatomic) NSInteger loadedPageIndex;
@property (assign, nonatomic) BOOL processingMessages;
@property (assign, nonatomic) BOOL initialLoadComplete;
@property (assign, nonatomic) BOOL processingNewPage;
@property (assign, nonatomic) BOOL hasUnreadMessages;

@property (strong, nonatomic) NSCache *cellHeightCache;
@property (strong, nonatomic) NSMutableArray <NSString *> *sections;
@property (strong, nonatomic) NSMutableDictionary <NSString *, NSMutableArray <MVMessageModel *>*> *messages;
@end

@implementation MVChatViewController
#pragma mark - Initialization
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

+ (instancetype)loadFromStoryboardWithChat:(MVChatModel *)chat {
    MVChatViewController *instance = [super loadFromStoryboard];
    instance.chat = chat;
    instance.hidesBottomBarWhenPushed = YES;
    
    return instance;
}


#pragma mark - Lifecycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.messagesTableView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
    [self setupTableView];
    [self setupFooter];
    [self registerCells];
    [self registerForNotifications];
    
    [MVChatManager sharedInstance].messagesListener = self;
    [[MVChatManager sharedInstance] addChatListener:self];
    [self tryToLoadNextPage];
}

- (void)setupNavigationBar {
    self.chatTitleLabel.text = self.chat.title;
    self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 34, 34)];
    self.avatarImageView.layer.cornerRadius = 17;
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.borderWidth = 0.3f;
    self.avatarImageView.layer.borderColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.4].CGColor;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.avatarImageView];
    [[self.avatarImageView.widthAnchor constraintEqualToConstant:34] setActive:YES];
    [[self.avatarImageView.heightAnchor constraintEqualToConstant:34] setActive:YES];
    
    [[MVFileManager sharedInstance] loadThumbnailAvatarForChat:self.chat maxWidth:50 completion:^(UIImage *image) {
        self.avatarImageView.image = image;
    }];
    
    __weak typeof(self) weakSelf = self;
    if (self.chat.isPeerToPeer) {
        [[NSNotificationCenter defaultCenter] addObserverForName:@"ContactAvatarUpdate" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            NSString *contactId = note.userInfo[@"Id"];
            UIImage *image = note.userInfo[@"Image"];
            if (weakSelf.chat.isPeerToPeer && [weakSelf.chat.getPeer.id isEqualToString:contactId]) {
                [weakSelf.avatarImageView setImage:image];
            }
        }];
    } else {
        [[NSNotificationCenter defaultCenter] addObserverForName:@"ChatAvatarUpdate" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            NSString *chatId = note.userInfo[@"Id"];
            UIImage *image = note.userInfo[@"Image"];
            if (!weakSelf.chat.isPeerToPeer && [weakSelf.chat.id isEqualToString:chatId]) {
                [weakSelf.avatarImageView setImage:image];
            }
        }];
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chatAvatarTapped)];
    [self.avatarImageView addGestureRecognizer:tapGesture];
    [self registerForceTouchControllerWithDelegate:self andSourceView:self.avatarImageView];
}

- (void)setupTableView {
    self.messagesTableView.tableFooterView = [UIView new];
}

- (void)setupFooter {
    self.sendButton.enabled = NO;
    self.messageTextFieldMask.layer.cornerRadius = 15;
    self.messageTextFieldMask.layer.borderWidth = 1;
    self.messageTextFieldMask.layer.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1].CGColor;
    self.messageTextFieldMask.layer.masksToBounds = YES;
    self.footerView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
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

- (void)registerForNotifications {
    [self.messagesTableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Data handling
- (void)updateChat:(MVChatModel *)chat withSorting:(BOOL)sorting newIndex:(NSUInteger)newIndex {
    if ([chat.id isEqualToString:self.chat.id]) {
        self.chat = chat;
        self.chatTitleLabel.text = chat.title;
    }
}

- (NSString *)chatId {
    return self.chat.id;
}

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
    
    if ([sections containsObject:@"New Messages"]) {
        self.hasUnreadMessages = YES;
    }
    
    self.messages = [messages mutableCopy];
    self.sections = [sections mutableCopy];
    self.autoscrollEnabled = (self.messagesTableView.contentOffset.y >= (self.messagesTableView.contentSize.height - self.messagesTableView.frame.size.height - 50));
    self.processingNewPage = YES;
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
    
    self.autoscrollEnabled = (self.messagesTableView.contentOffset.y >= (self.messagesTableView.contentSize.height - self.messagesTableView.frame.size.height - 50));
    self.processingNewPage = NO;
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
    BOOL shouldLoad = (!self.initialLoadComplete || numberOfPages > self.loadedPageIndex + 1);
    
    if (shouldLoad) {
        self.processingMessages = YES;
        [[MVChatManager sharedInstance] messagesPage:++self.loadedPageIndex forChatWithId:self.chatId withCallback:^(NSArray<MVMessageModel *> *messages) {
            [self handleNewMessagesPage:messages];
            self.initialLoadComplete = YES;
            self.processingMessages = NO;
        }];
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.messagesTableView && [keyPath isEqualToString:@"contentSize"]) {
        CGSize oldSize = [[change objectForKey:NSKeyValueChangeOldKey] CGSizeValue];
        CGSize newSize = [[change objectForKey:NSKeyValueChangeNewKey] CGSizeValue];
        
        if (CGSizeEqualToSize(oldSize, newSize)) {
            return;
        }
        
        [UIView animateWithDuration:(!self.processingNewPage && self.autoscrollEnabled)? 0.2 : 0 animations:^{
            [self updateContentOffsetForOldContent:oldSize
                                     andNewContent:newSize
                                 processingNewPage:self.processingNewPage
                                 autoScrollEnabled:self.autoscrollEnabled];
            
            [self updateContentInsetForNewContent:newSize frame:self.messagesTableView.frame.size.height];
        }];
    }
}

#pragma mark - Keyboard
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
    self.footerBottom.constant = appear? keyboardHeight : 0;
    CGFloat frameHeight = self.messagesTableView.frame.size.height;
    frameHeight += appear? -keyboardHeight : keyboardHeight;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        [self updateContentInsetForNewContent:self.messagesTableView.contentSize frame:frameHeight];
        self.messagesTableView.contentOffset = offset;
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark - Content inset/offset
- (void)updateContentInsetForNewContent:(CGSize)contentSize frame:(CGFloat)frameHeight {
    if (contentSize.height == 0) {
        return;
    }
    
    UIEdgeInsets tableViewInsets = self.messagesTableView.contentInset;
    CGFloat inset = frameHeight - contentSize.height;
    inset -= 64;
    
    if (inset < 64) {
        inset = 64;
    }
    
    if (inset != tableViewInsets.top) {
        tableViewInsets.top = inset;
        self.messagesTableView.contentInset = tableViewInsets;
    }
}

- (void)updateContentOffsetForOldContent:(CGSize)oldSize andNewContent:(CGSize)newSize processingNewPage:(BOOL)processingNewPage autoScrollEnabled:(BOOL)autoScroll {
    CGPoint offset = self.messagesTableView.contentOffset;
    
    if (newSize.height == 0) {
        offset.y = 0;
    } else if (autoScroll) {
        offset.y = newSize.height - self.messagesTableView.frame.size.height;
    } else if (processingNewPage) {
        offset.y += newSize.height - oldSize.height;
    }
    
    if (offset.y != self.messagesTableView.contentOffset.y) {
        self.messagesTableView.contentOffset = offset;
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
    if(self.initialLoadComplete && self.messagesTableView.contentOffset.y <= 50) {
        [self tryToLoadNextPage];
    }
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

- (UIViewController<MVForceTouchControllerProtocol> *)forceTouchViewControllerForContext:(NSString *)context {
    MVOverlayMenuController *menu = [MVOverlayMenuController loadFromStoryboard];
    NSMutableArray *items = [NSMutableArray new];
    [items addObject:[MVOverlayMenuElement elementWithTitle:@"Open profile" action:^{
        [self chatAvatarTapped];
    }]];
    
    NSString *chatId = [self.chat.id copy];
    NSArray *contacts = [self.chat.participants copy];
    [items addObject:[MVOverlayMenuElement elementWithTitle:@"Generate message" action:^{
        [[MVUpdatesProvider sharedInstance] generateMessageForChatWithId:chatId];
    }]];
    [items addObject:[MVOverlayMenuElement elementWithTitle:@"Update avatars" action:^{
        [[MVUpdatesProvider sharedInstance] performAvatarsUpdateForContacts:contacts];
    }]];
    
    menu.menuElements = items;
    
    return menu;
}

- (void)showChatSettings {
    MVChatSettingsViewController *settings = [MVChatSettingsViewController loadFromStoryboardWithChat:self.chat andDoneAction:^(NSArray<MVContactModel *> *contacts, NSString *title, DBAttachment *attachment) {
        self.chat.title = title;
        self.chat.participants = [contacts arrayByAddingObject:[MVContactManager myContact]];
        [[MVChatManager sharedInstance] updateChat:self.chat];
        if (attachment) {
            [[MVFileManager sharedInstance] saveChatAvatar:self.chat attachment:attachment];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [self.navigationController pushViewController:settings animated:YES];
}

- (void)showContactProfile {
    MVContactProfileViewController *contactProfile = [MVContactProfileViewController loadFromStoryboardWithContact:self.chat.getPeer];
    [self.navigationController pushViewController:contactProfile animated:YES];
}

#pragma mark - Actions
- (void)chatAvatarTapped {
    if (self.chat.isPeerToPeer) {
        [self showContactProfile];
    } else {
        [self showChatSettings];
    }
}

- (IBAction)tableViewTapped:(id)sender {
    [self.view.superview.superview endEditing:YES];
}

- (void)cellTapped:(UITableViewCell *)cell {
    [self.view.superview.superview endEditing:YES];
    
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

- (IBAction)messageTextFieldChanged:(id)sender {
    self.sendButton.enabled = [self.messageTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0;
}

- (IBAction)sendButtonTapped:(id)sender {
    self.sendButton.enabled = NO;
    [[MVChatManager sharedInstance] sendTextMessage:self.messageTextField.text toChatWithId:self.chatId];
    self.messageTextField.text = @"";
}

- (IBAction)attatchButtonTapped:(id)sender {
    DBAttachmentPickerController *attachmentPicker = [DBAttachmentPickerController attachmentPickerControllerFinishPickingBlock:^(NSArray<DBAttachment *> *attachmentArray) {
        [[MVChatManager sharedInstance] sendMediaMessageWithAttachment:attachmentArray[0] toChatWithId:self.chatId];
    } cancelBlock:nil];
    
    attachmentPicker.mediaType = DBAttachmentMediaTypeImage;
    [attachmentPicker presentOnViewController:self];
}

@end
