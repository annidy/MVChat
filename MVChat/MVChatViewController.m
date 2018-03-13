//
//  MVMessagesViewController.m
//  MVChat
//
//  Created by Mark Vasiv on 01/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVChatViewController.h"
#import "MVChatViewModel.h"
#import "MVMessageTextCell.h"
#import "MVMessageMediaCell.h"
#import "MVMessagePlainCell.h"
#import "MVOverlayMenuController.h"
#import "MVUpdatesProvider.h"
#import <ReactiveObjC.h>
#import "DBAttachmentPickerController.h"
#import "MVMessagesListUpdate.h"

@interface MVChatViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, MVForceTouchPresentaionDelegate>
@property (strong, nonatomic) MVChatViewModel *viewModel;
@property (strong, nonatomic) IBOutlet UITableView *messagesTableView;
@property (strong, nonatomic) IBOutlet UIButton *avatarButton;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *inputPanelBottom;
@property (strong, nonatomic) IBOutlet UITextField *messageTextField;
@property (strong, nonatomic) IBOutlet UIView *messageTextFieldMask;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UIButton *attatchButton;

@end

@implementation MVChatViewController
#pragma mark - Lifecycle
+ (instancetype)loadFromStoryboardWithViewModel:(MVChatViewModel *)viewModel {
    MVChatViewController *instance = [super loadFromStoryboard];
    instance.viewModel = viewModel;
    
    return instance;
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationBar];
    [self setupFooter];
    [self setupTableView];
    [self bindAll];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (@available(iOS 11.0, *)) {
        self.messagesTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

#pragma mark - Setup views
- (void)setupNavigationBar {
    self.navigationItem.title = self.viewModel.title;
    self.avatarButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.avatarButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    self.avatarButton.layer.cornerRadius = 15;
    self.avatarButton.layer.masksToBounds = YES;
    self.avatarButton.layer.borderWidth = 0.3f;
    self.avatarButton.layer.borderColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.4].CGColor;
    [self registerForceTouchControllerWithDelegate:self andSourceView:self.avatarButton];
    self.avatarButton.translatesAutoresizingMaskIntoConstraints = NO;
    [[self.avatarButton.widthAnchor constraintEqualToConstant:30] setActive:YES];
    [[self.avatarButton.heightAnchor constraintEqualToConstant:30] setActive:YES];
    if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
}

- (void)setupTableView {
    [self.messagesTableView setTableFooterView:[UIView new]];
    [self.messagesTableView registerClass:[MVMessagePlainCell class] forCellReuseIdentifier:@"MVMessagePlainCell"];
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

- (void)setupFooter {
    self.sendButton.enabled = NO;
    self.footerView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    self.messageTextFieldMask.layer.cornerRadius = 15;
    self.messageTextFieldMask.layer.borderWidth = 1;
    self.messageTextFieldMask.layer.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1].CGColor;
    self.messageTextFieldMask.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *tapRecognizer = [UITapGestureRecognizer new];
    [self.messageTextFieldMask addGestureRecognizer:tapRecognizer];
    [self.messageTextFieldMask setUserInteractionEnabled:YES];
    @weakify(self);
    [tapRecognizer.rac_gestureSignal subscribeNext:^(UIGestureRecognizer *x) {
        @strongify(self);
        [self.messageTextField becomeFirstResponder];
    }];
}

#pragma mark - Bind
- (void)bindAll {
    RAC(self.navigationItem, title) = RACObserve(self.viewModel, title);
    RAC(self.viewModel, messageText) = [self.messageTextField rac_textSignal];
  
    @weakify(self);
    [RACObserve(self.viewModel, messageText) subscribeNext:^(NSString *text) {
        @strongify(self);
        self.messageTextField.text = text;
    }];
    
    [RACObserve(self.viewModel, avatar) subscribeNext:^(UIImage *image) {
        @strongify(self);
        [self.avatarButton setImage:image forState:UIControlStateNormal];
    }];
    
self.sendButton.rac_command = self.viewModel.sendCommand;
[[[self.attatchButton rac_signalForControlEvents:UIControlEventTouchUpInside]
    map:^id (UIControl *value) {
        @strongify(self);
        return self.viewModel.attachmentPicker;
    }]
    subscribeNext:^(DBAttachmentPickerController *controller) {
        @strongify(self);
        [controller presentOnViewController:self];
    }];

[[[self.avatarButton rac_signalForControlEvents:UIControlEventTouchUpInside]
    map:^id (UIControl *value) {
        @strongify(self);
        return [self.viewModel relevantSettingsController];
    }]
    subscribeNext:^(UIViewController *viewController) {
        @strongify(self);
        [self.navigationController pushViewController:viewController animated:YES];
    }];

    __block BOOL processingNewPage = NO;
    __block BOOL autoscroll = YES;
    __block NSValue *oldSize;
    __block BOOL keyboardShown = NO;
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIDeviceOrientationDidChangeNotification object:nil] delay:0.3] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self);
        processingNewPage = YES;
        [self.viewModel recalculateHeights];
        [self.messagesTableView reloadData];
    }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil]
        filter:^BOOL(NSNotification *value) {
            return !keyboardShown;
        }]
        subscribeNext:^(NSNotification *x) {
            @strongify(self);
            keyboardShown = YES;
            autoscroll = NO;
            [self adjustContentOffsetDuringKeyboardAppear:YES withNotification:x];
        }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil]
        filter:^BOOL(NSNotification *value) {
            return keyboardShown;
        }]
        subscribeNext:^(NSNotification *x) {
            @strongify(self);
            keyboardShown = NO;
            autoscroll = NO;
            [self adjustContentOffsetDuringKeyboardAppear:NO withNotification:x];
        }];
    
    [[[RACObserve(self.messagesTableView, contentSize)
        distinctUntilChanged] take:2]
        subscribeNext:^(NSValue *newSize) {
            @strongify(self);
            [UIView animateWithDuration:(!processingNewPage && autoscroll)? 0.2 : 0 animations:^{
                [self updateContentOffsetForOldContent:oldSize.CGSizeValue
                                         andNewContent:newSize.CGSizeValue
                                     processingNewPage:processingNewPage
                                     autoScrollEnabled:autoscroll];
                
                [self updateContentInsetForNewContent:newSize.CGSizeValue frame:self.messagesTableView.frame.size.height];
            }];
        
            oldSize = newSize;
        }];
    
    [[[[RACObserve(self.messagesTableView, contentSize) distinctUntilChanged] skip:1] throttle:0.2]
        subscribeNext:^(NSValue *newSize) {
            @strongify(self);
            
            [UIView animateWithDuration:(!processingNewPage && autoscroll)? 0.2 : 0 animations:^{
                [self updateContentOffsetForOldContent:oldSize.CGSizeValue
                                         andNewContent:newSize.CGSizeValue
                                     processingNewPage:processingNewPage
                                     autoScrollEnabled:autoscroll];
            
                [self updateContentInsetForNewContent:newSize.CGSizeValue frame:self.messagesTableView.frame.size.height];
            }];
            
            oldSize = newSize;
        }];
    
    [self.viewModel.updateSignal subscribeNext:^(MVMessagesListUpdate *update) {
        @strongify(self);
        processingNewPage = (update.type == MVMessagesListUpdateTypeReloadAll);
        autoscroll = (self.messagesTableView.contentOffset.y >= (self.messagesTableView.contentSize.height - self.messagesTableView.frame.size.height - 50)) || !self.viewModel.rows.count;
        
        self.viewModel.rows = update.rows;
        if (update.type == MVMessagesListUpdateTypeReloadAll) {
            [self.messagesTableView reloadData];
        } else if (update.type == MVMessagesListUpdateTypeInsertRow) {
            NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:update.indexPath.row-1 inSection:0];
            NSArray *insertIndexPaths = @[update.indexPath];
            if (update.shouldInsertHeader) insertIndexPaths = @[update.indexPath, previousIndexPath];
            [self.messagesTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationNone];
            if (update.shouldReloadPrevious) {
                [self.messagesTableView reloadRowsAtIndexPaths:@[previousIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        } else if (update.type == MVMessagesListUpdateTypeReloadRow) {
            [self.messagesTableView reloadRowsAtIndexPaths:@[update.indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
             
    }];
}

#pragma mark - Table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.rows.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.viewModel.rows[indexPath.row].height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MVMessageCellModel *model = self.viewModel.rows[indexPath.row];
    UITableViewCell <MVMessageCell> *cell = [tableView dequeueReusableCellWithIdentifier:model.cellId];
    
    [cell fillWithModel:model];
    
    @weakify(self);
    [[[[cell.tapRecognizer.rac_gestureSignal
        map:^id (UIGestureRecognizer *value) {
            return cell.model;
        }]
        doNext:^(id  _Nullable x) {
            @strongify(self);
            [self.messageTextField resignFirstResponder];
        }]
        filter:^BOOL(MVMessageCellModel *model) {
            return model.type == MVMessageCellModelTypeMediaMessage;
        }]
        subscribeNext:^(MVMessageCellModel *model) {
            @strongify(self);
            MVMessageMediaCell *mediaCell = (MVMessageMediaCell *)cell;
            [self showImageViewerForMessage:model fromImageView:mediaCell.mediaImageView];
        }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![cell conformsToProtocol:NSProtocolFromString(@"MVSlidingCell")]) {
        return;
    }
    
    UITableViewCell <MVSlidingCell> *slidingCell = (UITableViewCell <MVSlidingCell> *)cell;
    CGFloat oldSlidingConstraint = slidingCell.slidingConstraint;
    
    if (oldSlidingConstraint != self.viewModel.sliderOffset) {
        [slidingCell setSlidingConstraint:self.viewModel.sliderOffset];
        [slidingCell.contentView layoutIfNeeded];
    }
}

#pragma mark - Scroll View
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.messagesTableView.contentOffset.y <= 50) {
        [self.viewModel tryToLoadNextPage];
    }
}

#pragma mark - Content inset/offset
- (void)updateContentInsetForNewContent:(CGSize)contentSize frame:(CGFloat)frameHeight {
    if (contentSize.height == 0) {
        return;
    }
    
    UIEdgeInsets tableViewInsets = self.messagesTableView.contentInset;
    CGFloat inset = frameHeight - contentSize.height;
    
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

#pragma mark - Keyboard
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
    self.inputPanelBottom.constant = appear? keyboardHeight : 0;
    CGFloat frameHeight = self.messagesTableView.frame.size.height;
    frameHeight += appear? -keyboardHeight : keyboardHeight;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        [self updateContentInsetForNewContent:self.messagesTableView.contentSize frame:frameHeight];
        self.messagesTableView.contentOffset = offset;
        [self.view layoutIfNeeded];
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
    CGFloat constant = 0;
    NSTimeInterval animationDuration = 0.2;

    if (panRecognizer.state != UIGestureRecognizerStateEnded &&
        panRecognizer.state != UIGestureRecognizerStateFailed &&
        panRecognizer.state != UIGestureRecognizerStateCancelled &&
        panRecognizer.state != UIGestureRecognizerStateRecognized) {
        
        constant = [panRecognizer translationInView:self.view].x;
        if (constant > 0) constant = 0;
        if (constant < -40) constant = -40;

        CGFloat velocityX = [panRecognizer velocityInView:self.view].x;
        CGFloat oldConstant = self.viewModel.sliderOffset;
        CGFloat path = ABS(oldConstant - constant);
        animationDuration = path / velocityX;
    }
    
    @weakify(self);
    [[[[self.messagesTableView.visibleCells.rac_sequence
        filter:^BOOL(UITableViewCell *cell) {
            return [cell conformsToProtocol:NSProtocolFromString(@"MVSlidingCell")];
        }]
        filter:^BOOL(UITableViewCell <MVSlidingCell>*cell) {
            return (cell.slidingConstraint != constant);
        }]
        signalWithScheduler:[RACScheduler mainThreadScheduler]]
        subscribeNext:^(UITableViewCell <MVSlidingCell>*cell) {
            [cell setSlidingConstraint:constant];
        } completed:^{
            @strongify(self);
            self.viewModel.sliderOffset = constant;
            [UIView animateWithDuration:animationDuration animations:^{
                [self.messagesTableView layoutIfNeeded];
            }];
        }];
}

- (IBAction)tableViewTapped:(id)sender {
    [self.messageTextField resignFirstResponder];
}

#pragma mark - Force touch
- (UIViewController<MVForceTouchControllerProtocol> *)forceTouchViewControllerForContext:(NSString *)context {
    MVOverlayMenuController *menu = [MVOverlayMenuController loadFromStoryboard];
    NSMutableArray *items = [NSMutableArray new];
    [items addObject:[MVOverlayMenuElement elementWithTitle:@"Open settings" action:^{
        [self.navigationController pushViewController:[self.viewModel relevantSettingsController] animated:YES];
    }]];
    
    NSString *chatId = [self.viewModel.chatId copy];
    NSArray *contacts = [self.viewModel.chatParticipants copy];
    [items addObject:[MVOverlayMenuElement elementWithTitle:@"Generate message" action:^{
        [[MVUpdatesProvider sharedInstance] generateMessageForChatWithId:chatId];
    }]];
    [items addObject:[MVOverlayMenuElement elementWithTitle:@"Update avatars" action:^{
        [[MVUpdatesProvider sharedInstance] performAvatarsUpdateForContacts:contacts];
    }]];
    
    menu.menuElements = items;
    
    return menu;
}

#pragma mark - Image viewer
- (void)showImageViewerForMessage:(MVMessageCellModel *)model fromImageView:(UIImageView *)imageView {
    [self.viewModel imageViewerForMessage:model fromImageView:imageView completion:^(UIViewController *imageViewer) {
        [self presentViewController:imageViewer animated:YES completion:nil];
    }];
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
