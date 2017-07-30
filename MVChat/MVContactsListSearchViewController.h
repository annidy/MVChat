//
//  MVContactsListSearchViewController.h
//  MVChat
//
//  Created by Mark Vasiv on 30/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVSearchProviderDelegate.h"

@interface MVContactsListSearchViewController : UIViewController
@property (strong, nonatomic) NSArray *filteredContacts;
+ (instancetype)loadFromStoryboard;
+ (instancetype)loadFromStoryboardWithDelegate:(id <MVSearchProviderDelegate>)delegate;
@end
