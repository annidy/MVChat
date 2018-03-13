//
//  MVContactsListViewModel.h
//  MVChat
//
//  Created by Mark Vasiv on 08/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVContactsListCellViewModel.h"
@class RACSignal;
@class RACCommand;
@class MVContactsListSearchViewController;


typedef enum : NSUInteger {
    MVContactsListModeDefault,
    MVContactsListModeSelectable
} MVContactsListMode;

@interface MVContactsListViewModel : NSObject <UISearchResultsUpdating>
- (instancetype)initWithMode:(MVContactsListMode)mode;
- (instancetype)initWithMode:(MVContactsListMode)mode excludingContacts:(NSArray <MVContactModel *> *)excludingContacts;

- (void)selectModel:(MVContactsListCellViewModel *)model;
- (void)deselectModel:(MVContactsListCellViewModel *)model;
- (BOOL)isModelSelected:(MVContactsListCellViewModel *)model;

@property (assign, nonatomic) MVContactsListMode mode;
@property (strong, nonatomic) RACCommand *doneCommand;
@property (strong, nonatomic, readonly) NSArray <NSString *> *sections;
@property (strong, nonatomic, readonly) NSDictionary <NSString *, NSArray *> *rows;
@property (strong, nonatomic, readonly) NSArray <MVContactsListCellViewModel *> *filteredRows;
@property (weak, nonatomic) MVContactsListSearchViewController *searchResultsController;
@end
