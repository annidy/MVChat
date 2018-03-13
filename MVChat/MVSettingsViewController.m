//
//  MVSettingsViewController.m
//  MVChat
//
//  Created by Mark Vasiv on 07/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVSettingsViewController.h"
#import "MVUpdatesProvider.h"
#import "MVContactManager.h"

@interface MVSettingsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MVSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MVSettingsCell"];
    UILabel *label = [cell viewWithTag:1];
    if (indexPath.row == 0) {
        label.text = @"Generate data";
        label.textColor = [UIColor blackColor];
    } else {
        label.text = @"Delete data";
        label.textColor = [UIColor colorWithRed:1 green:0.2196078431 blue:0.137254902 alpha:1];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        if (self.hasData) {
            [self showAlertWithTitle:@"Generate data" action:^(UIAlertAction *action) {
                [[MVUpdatesProvider sharedInstance] generateData];
            }];
        } else {
            [[MVUpdatesProvider sharedInstance] generateData];
        }
    } else {
        if (self.hasData) {
            [self showAlertWithTitle:@"Delete data" action:^(UIAlertAction *action) {
                [[MVUpdatesProvider sharedInstance] deleteAllData];
            }];
        }
    }
}

- (BOOL)hasData {
    NSArray *contacts = [[MVContactManager sharedInstance] getAllContacts];
    return (contacts && contacts.count);
}

- (void)showAlertWithTitle:(NSString *)title action:(void(^)(UIAlertAction *action))action {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:@"All exisiting data will be deleted. Do you want to proceed?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDestructive handler:action];
    [controller addAction:cancel];
    [controller addAction:ok];
    [self presentViewController:controller animated:YES completion:nil];
}
@end
