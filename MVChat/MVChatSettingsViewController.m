//
//  MVChatSettingsViewController.m
//  MVChat
//
//  Created by Mark Vasiv on 12/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVChatSettingsViewController.h"
#import "MVContactModel.h"
#import "MVContactManager.h"

@interface MVChatSettingsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSMutableArray <MVContactModel *> *contacts;
@property (weak, nonatomic) UITextField *titleTextField;
@property (strong, nonatomic) NSString *chatTitle;
@property (nonatomic, copy) void (^doneAction)(NSArray <MVContactModel *> *, NSString *);
@end

static NSString *AvatarTitleCellId = @"MVChatSettingsAvatarTitleCell";
static NSString *AvatarCellId = @"MVChatSettingsAvatarCell";
static NSString *ContactCellId = @"MVChatSettingsContactCell";

@implementation MVChatSettingsViewController
#pragma mark - Initialization
+ (instancetype)loadFromStoryboard {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:@"MVChatSettingsViewController"];
}

+ (instancetype)loadFromStoryboardWithContacts:(NSArray <MVContactModel *> *)contacts andDoneAction:(void (^)(NSArray <MVContactModel *> *, NSString *))doneAction {
    MVChatSettingsViewController *instance = [self loadFromStoryboard];
    instance.contacts = [contacts mutableCopy];
    instance.doneAction = doneAction;
    
    return instance;
}
- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addObserver:self forKeyPath:@"titleTextField" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    
    //test
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Create" style:UIBarButtonItemStylePlain target:self action:@selector(createNewChat)];
    self.navigationItem.rightBarButtonItem = item;
    
}

- (void)createNewChat {
    self.doneAction(self.contacts, self.chatTitle);
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"titleTextField"];
    [self.titleTextField removeTarget:self action:@selector(titleTextDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self && [keyPath isEqualToString:@"titleTextField"]) {
        UITextField *oldTextField = change[NSKeyValueChangeOldKey];
        UITextField *newTextField = change[NSKeyValueChangeNewKey];
        
        if (oldTextField && ![oldTextField isEqual:[NSNull null]]) {
            [oldTextField removeTarget:self action:@selector(titleTextDidChange:) forControlEvents:UIControlEventEditingChanged];
        }
        
        [newTextField addTarget:self action:@selector(titleTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
}

- (void)titleTextDidChange:(UITextField *)textField {
    self.chatTitle = textField.text;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else {
        return self.contacts.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 100;
        }
    }
    
    return 44;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGFLOAT_MIN;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AvatarTitleCellId];
            UIImageView *avatarImageView = [cell viewWithTag:1];
            avatarImageView.backgroundColor = [UIColor lightGrayColor];
            avatarImageView.layer.masksToBounds = YES;
            avatarImageView.layer.cornerRadius = 30;
            UITextField *textField = [cell viewWithTag:2];
            textField.text = self.chatTitle;
            self.titleTextField = textField;
            return cell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AvatarCellId];
            return cell;
        }
    }
    
    MVContactModel *contact = self.contacts[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactCellId];
    UIImageView *contactAvatarImageView = [cell viewWithTag:1];
    UILabel *contactNameLabel = [cell viewWithTag:2];
    
    contactNameLabel.text = contact.name;
    contactAvatarImageView.image = [MVContactManager avatarForContact:contact];
    
    contactAvatarImageView.layer.masksToBounds = YES;
    contactAvatarImageView.layer.cornerRadius = 10;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
