//
//  MVContactsListSearchViewController.m
//  MVChat
//
//  Created by Mark Vasiv on 30/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVContactsListSearchViewController.h"
#import "MVTableViewHeader.h"
#import "MVContactsListCell.h"

@interface MVContactsListSearchViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) id <MVSearchProviderDelegate> delegate;
@end

@implementation MVContactsListSearchViewController
+ (instancetype)loadFromStoryboard {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:@"MVContactsListSearchViewController"];
}

+ (instancetype)loadFromStoryboardWithDelegate:(id <MVSearchProviderDelegate>)delegate {
    MVContactsListSearchViewController *instance = [self loadFromStoryboard];
    instance.delegate = delegate;
    return instance;
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[MVTableViewHeader class] forHeaderFooterViewReuseIdentifier:@"MVTableViewHeader"];
    [self addObserver:self forKeyPath:@"filteredContacts" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"filteredContacts"]) {
        [self.tableView reloadData];
    }
}

#pragma mark - Table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredContacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MVContactsListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactsListCell"];
    [cell fillWithContact:self.filteredContacts[indexPath.row]];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MVTableViewHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"MVTableViewHeader"];
    header.titleLabel.text = @"CONTACTS";
    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.delegate didSelectCellWithModel:self.filteredContacts[indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
@end
