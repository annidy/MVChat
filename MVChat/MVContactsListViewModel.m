//
//  MVContactsListViewModel.m
//  MVChat
//
//  Created by Mark Vasiv on 08/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVContactsListViewModel.h"
#import "MVContactManager.h"
#import "MVContactsListCellViewModel.h"
#import "MVContactModel.h"
#import "NSString+Helpers.h"
#import <ReactiveObjC.h>
#import "MVContactsListSearchViewController.h"
#import "MVFileManager.h"

@interface MVContactsListViewModel() <MVContactsUpdatesListener>
@property (strong, nonatomic) NSArray <MVContactModel *> *excludingContacts;
@property (strong, nonatomic, readwrite) NSArray <NSString *> *sections;
@property (strong, nonatomic, readwrite) NSDictionary <NSString *, NSArray *> *rows;
@property (strong, nonatomic, readwrite) NSArray <MVContactsListCellViewModel *> *filteredRows;
@property (strong, nonatomic) NSMutableArray <MVContactsListCellViewModel *> *selectedContacts;
@property (assign, nonatomic) BOOL canProceed;
@end

@implementation MVContactsListViewModel
#pragma mark - Initialization
- (instancetype)initWithMode:(MVContactsListMode)mode {
    return [self initWithMode:mode excludingContacts:nil];
}

- (instancetype)initWithMode:(MVContactsListMode)mode excludingContacts:(NSArray <MVContactModel *> *)excludingContacts {
    if (self = [super init]) {
        _mode = mode;
        _excludingContacts = excludingContacts;
        _selectedContacts = [NSMutableArray new];
        [self bindAll];
    }
    
    return self;
}

#pragma mark - Data handling
- (void)bindAll {
    [self mapWithSections:[[MVContactManager sharedInstance] getAllContacts]];
    [MVContactManager sharedInstance].updatesListener = self;
    
    @weakify(self);
    self.doneCommand = [[RACCommand alloc] initWithEnabled:RACObserve(self, canProceed) signalBlock:^RACSignal *(id  input) {
        @strongify(self);
        return [self doneExecutionSignal];
    }];
}

- (void)updateContacts {
    [self mapWithSections:[[MVContactManager sharedInstance] getAllContacts]];
}

- (void)mapWithSections:(NSArray <MVContactModel *> *)contacts {
    NSMutableArray *sections = [NSMutableArray new];
    NSMutableDictionary *mappedContacts = [NSMutableDictionary new];
    
    for (MVContactModel *contact in contacts) {
        if ([self shouldExcludeContact:contact]) {
            continue;
        }
        NSString *sectionKey = [[contact.name substringToIndex:1] uppercaseString];
        if (!mappedContacts[sectionKey]) {
            [sections addObject:sectionKey];
            mappedContacts[sectionKey] = [NSMutableArray new];
        }
        MVContactsListCellViewModel *viewModel = [MVContactsListCellViewModel new];
        viewModel.name = contact.name;
        viewModel.lastSeenTime = [NSString lastSeenTimeStringForDate:contact.lastSeenDate];
        viewModel.contact = contact;
        
        @weakify(viewModel);
        [[MVFileManager sharedInstance] loadThumbnailAvatarForContact:contact maxWidth:50 completion:^(UIImage *image) {
            @strongify(viewModel);
            viewModel.avatar = image;
        }];
        
        [[[MVContactManager sharedInstance].lastSeenTimeSignal filter:^BOOL(RACTuple *tuple) {
            return [tuple.first isEqualToString:contact.id];
        }] subscribeNext:^(RACTuple *tuple) {
            viewModel.lastSeenTime = [NSString lastSeenTimeStringForDate:tuple.second];
        }];
        
        [[[MVFileManager sharedInstance].avatarUpdateSignal filter:^BOOL(MVAvatarUpdate *update) {
            return (update.type == MVAvatarUpdateTypeContact && [update.id isEqualToString:contact.id]);
        }] subscribeNext:^(MVAvatarUpdate *update) {
            viewModel.avatar = update.avatar;
        }];
        
        [mappedContacts[sectionKey] addObject:viewModel];
    }
    
    self.sections = [sections copy];
    self.rows = [mappedContacts copy];
}

- (BOOL)shouldExcludeContact:(MVContactModel *)contact {
    return [self.excludingContacts containsObject:contact];
}

#pragma mark - Filter
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    self.filteredRows = [self filterContactsWithString:searchController.searchBar.text];
}

- (NSArray *)filterContactsWithString:(NSString *)string {
    if (!string.length) {
        return nil;
    }
    
    @weakify(self);
    NSArray *filteredRows = [[[self.sections.rac_sequence.signal flattenMap:^__kindof RACSignal *(NSString *section) {
        @strongify(self);
        return self.rows[section].rac_sequence.signal;
    }] filter:^BOOL(MVContactsListCellViewModel *model) {
        return [model.name.uppercaseString containsString:string.uppercaseString];
    }] toArray];
    
    return filteredRows;
}

#pragma mark - Select Contacts
- (BOOL)isModelSelected:(MVContactsListCellViewModel *)model {
    return [self.selectedContacts containsObject:model];
}

- (void)selectModel:(MVContactsListCellViewModel *)model {
    if (![self isModelSelected:model]) {
        [self.selectedContacts addObject:model];
        [self updateCanProcced];
    }
}

- (void)deselectModel:(MVContactsListCellViewModel *)model {
    if ([self isModelSelected:model]) {
        [self.selectedContacts removeObject:model];
        [self updateCanProcced];
    }
}

#pragma mark - Done Button
- (void)updateCanProcced {
    self.canProceed = self.selectedContacts.count > 0;
}

- (RACSignal *)doneExecutionSignal {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        NSArray *contacts = [[[self.selectedContacts.rac_sequence signalWithScheduler:[RACScheduler mainThreadScheduler]] map:^id (MVContactsListCellViewModel *model) {
            return model.contact;
        }] toArray];
        
        [subscriber sendNext:contacts];
        [subscriber sendCompleted];
        return nil;
    }];
}
@end
