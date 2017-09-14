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
}

#pragma mark - Setup views
- (void)setupNavigationBar {
    self.navigationItem.title = self.viewModel.title;
    self.avatarButton.layer.cornerRadius = 15;
    self.avatarButton.layer.masksToBounds = YES;
    self.avatarButton.layer.borderWidth = 0.3f;
    self.avatarButton.layer.borderColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.4].CGColor;
    [self registerForceTouchControllerWithDelegate:self andSourceView:self.avatarButton];
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
}

#pragma mark - Bind
- (void)bindAll {
    RAC(self.navigationItem, title) = RACObserve(self.viewModel, title);
    RAC(self.viewModel, messageText) = [self.messageTextField rac_textSignal];
    
    self.sendButton.rac_command = self.viewModel.sendCommand;
    
    @weakify(self);
    [[[self.attatchButton rac_signalForControlEvents:UIControlEventTouchUpInside] 
        map:^id (UIControl *value) {
            @strongify(self);
            return self.viewModel.attachmentPicker;
        }] 
        subscribeNext:^(DBAttachmentPickerController *controller) {
            @strongify(self);
            [controller presentOnViewController:self];
        }];
    
    [RACObserve(self.viewModel, messageText) subscribeNext:^(NSString *text) {
        @strongify(self);
        self.messageTextField.text = text;
    }];
    
    [RACObserve(self.viewModel, avatar) subscribeNext:^(UIImage *image) {
        @strongify(self);
        [self.avatarButton setImage:image forState:UIControlStateNormal];
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

    __block BOOL processingNewPage;
    __block BOOL autoscroll = YES;
    __block NSValue *oldSize;
    __block BOOL keyboardShown = NO;
    
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
    
    

    [RACObserve(self.messagesTableView, contentSize)
        subscribeNext:^(NSValue *newSize) {
            @strongify(self);
            
            [UIView animateWithDuration:(!processingNewPage && autoscroll)? 0.2 : 0 animations:^{
                [self updateContentOffsetForOldContent:oldSize.CGSizeValue
                                         andNewContent:newSize.CGSizeValue
                                     processingNewPage:processingNewPage
                                     autoScrollEnabled:autoscroll];
            
                [self updateContentInsetForNewContent:newSize.CGSizeValue];
            }];
            
            oldSize = newSize;
        }];
    
    [self.viewModel.updateSignal subscribeNext:^(MVMessagesListUpdate *update) {
        @strongify(self);
        processingNewPage = (update.type == MVMessagesListUpdateTypeReloadAll);
        autoscroll = (self.messagesTableView.contentOffset.y >= (self.messagesTableView.contentSize.height - self.messagesTableView.frame.size.height - 50));
        
        if (update.type == MVMessagesListUpdateTypeReloadAll) {
            [self.messagesTableView reloadData];
        } else if (update.type == MVMessagesListUpdateTypeInsertRow) {
            [UIView performWithoutAnimation:^{
                NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:update.indexPath.row-1 inSection:0];
                NSArray *insertIndexPaths = @[update.indexPath];
                if (update.shouldInsertHeader) insertIndexPaths = @[update.indexPath, previousIndexPath];
                
                [self.messagesTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
                if (update.shouldReloadPrevious) {
                    [self.messagesTableView reloadRowsAtIndexPaths:@[previousIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
            }];
        }
    }];
    
    
}

#pragma mark - Table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.messages.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.viewModel.messages[indexPath.row].height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MVMessageCellModel *model = self.viewModel.messages[indexPath.row];
    UITableViewCell <MVMessageCell> *cell = [tableView dequeueReusableCellWithIdentifier:model.cellId];
    
    [cell fillWithModel:model];
    
    @weakify(self);
    [[[[cell.tapRecognizer.rac_gestureSignal
        map:^id (UIGestureRecognizer *value) {
            return cell.model;
        }]
        doNext:^(id  _Nullable x) {
            @strongify(self);
            [self.view.superview.superview endEditing:YES];
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
- (void)updateContentInsetForNewContent:(CGSize)contentSize {
    if (contentSize.height == 0) {
        return;
    }
    
    UIEdgeInsets tableViewInsets = self.messagesTableView.contentInset;
    CGFloat inset = self.messagesTableView.frame.size.height - contentSize.height;
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
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
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
    [self.view.superview.superview endEditing:YES];
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
@end
