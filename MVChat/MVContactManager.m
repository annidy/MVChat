//
//  MVContactManager.m
//  MVChat
//
//  Created by Mark Vasiv on 05/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVContactManager.h"
#import "MVContactModel.h"
#import "MVJsonHelper.h"
#import "MVDatabaseManager.h"
#import "MVFileManager.h"
#import <DBAttachment.h>
#import "MVRandomGenerator.h"

@interface MVContactManager()
@property (strong, nonatomic) dispatch_queue_t managerQueue;
@property (strong, nonatomic) NSArray <MVContactModel *> *contacts;
@end

@implementation MVContactManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static MVContactManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [MVContactManager new];
    });
    
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _managerQueue = dispatch_queue_create("com.markvasiv.contactsManager", DISPATCH_QUEUE_SERIAL);
        _contacts = [NSArray new];
        dispatch_async(self.managerQueue, ^{
            [self generateUserActivity];
        });
    }
    
    return self;
}

- (void)loadContacts {
    [[MVDatabaseManager sharedInstance] allContacts:^(NSArray<MVContactModel *> *allContacts) {
        NSMutableArray *sortedContacts = [allContacts mutableCopy];
        [self sortContacts:sortedContacts];
        
        @synchronized (self.contacts) {
            self.contacts = [sortedContacts copy];
        }
        
        [self.updatesListener handleContactsUpdate];
    }];
}

- (NSArray <MVContactModel *> *)getAllContacts {
    @synchronized (self.contacts) {
        return self.contacts;
    }
}

- (void)sortContacts:(NSMutableArray *)contacts {
    [contacts sortUsingComparator:^NSComparisonResult(MVContactModel *contact1, MVContactModel *contact2) {
        NSString *first = [[contact1.name substringToIndex:1] uppercaseString];
        NSString *second = [[contact2.name substringToIndex:1] uppercaseString];
        
        return [first compare:second];
    }];
}

- (void)loadAvatarThumbnailForContact:(MVContactModel *)contact completion:(void (^)(UIImage *))callback {
    [[MVFileManager sharedInstance] loadAvatarAttachmentForContact:contact completion:^(DBAttachment *attachment) {
        [attachment loadOriginalImageWithCompletion:^(UIImage *resultImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(resultImage);
            });
        }];
    }];
}

- (NSString *)lastSeenTimeStringForDate:(NSDate *)lastSeenDate {
    NSString *durationString;
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute
                                                 fromDate:lastSeenDate
                                                   toDate:[NSDate new]
                                                  options: 0];
    NSInteger days = [components day];
    NSInteger hour = [components hour];
    NSInteger minutes = [components minute];
    
    if (days > 0) {
        if (days > 1) {
            durationString = [NSString stringWithFormat:@"%ld days", (long)days];
        }
        else {
            durationString = [NSString stringWithFormat:@"%ld day", (long)days];
        }
    } else if (hour > 0) {
        if (hour > 1) {
            durationString = [NSString stringWithFormat:@"%ld hours", (long)hour];
        }
        else {
            durationString = [NSString stringWithFormat:@"%ld hour", (long)hour];
        }
    } else if (minutes > 0) {
        if (minutes > 1) {
            durationString = [NSString stringWithFormat:@"%ld minutes", (long)minutes];
        }
    }
    
    if (durationString) {
        return [[@"last seen " stringByAppendingString:durationString] stringByAppendingString:@" ago"];
    } else {
        return @"online";
    }
    
}

//Event generators
- (void)generateUserActivity {
    NSArray *contacts;
    @synchronized (self.contacts) {
        contacts = [self.contacts copy];
    }
    
    for (MVContactModel *contact in contacts) {
        NSDate *lastSeenDate = [[MVRandomGenerator sharedInstance] randomLastSeenDate];
        NSNotification *update = [[NSNotification alloc] initWithName:@"ContactLastSeenTimeUpdate" object:nil userInfo:@{@"Id" : contact.id, @"LastSeenTime" : lastSeenDate}];
        [[NSNotificationCenter defaultCenter] postNotification:update];
        contact.lastSeenDate = lastSeenDate;
    }
    
    NSMutableArray *changedContacts = [NSMutableArray new];
    @synchronized (self.contacts) {
        for (MVContactModel *existingContact in self.contacts) {
            for (MVContactModel *updatedContact in contacts) {
                if ([existingContact.id isEqualToString:updatedContact.id]) {
                    existingContact.lastSeenDate = updatedContact.lastSeenDate;
                    [changedContacts addObject:existingContact];
                }
            }
        }
    }
    
    [[MVDatabaseManager sharedInstance] insertContacts:changedContacts withCompletion:^(BOOL success) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([self getRandomDelay] * NSEC_PER_SEC)), self.managerQueue, ^{
            [self generateUserActivity];
        });
    }];
}

//Legacy
+ (void)startSendingStatusUpdates {
    NSNotification *status = [[NSNotification alloc] initWithName:@"ContactStatusUpdate" object:nil userInfo:@{@"Id" : [self getRandomContactId], @"Status" : @([self getRandomStatus])}];
    [[NSNotificationCenter defaultCenter] postNotification:status];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([self getRandomDelay] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startSendingStatusUpdates];
    });
}

+ (void)startSendingAvatarUpdates {
    NSNotification *status = [[NSNotification alloc] initWithName:@"ContactAvatarUpdate" object:nil userInfo:@{@"Id" : [self getRandomContactId], @"Avatar" : [self getRandomAvatarName]}];
    [[NSNotificationCenter defaultCenter] postNotification:status];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([self getRandomDelay] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startSendingAvatarUpdates];
    });
}

+ (ContactStatus)getRandomStatus {
    int value = arc4random_uniform(2);
    return (ContactStatus)value;
}

+ (NSString *)getRandomContactId {
    int value = arc4random_uniform(2);
    return [NSString stringWithFormat:@"%d", value];
}

+ (int)getRandomDelay {
    return arc4random_uniform(10);
}

- (int)getRandomDelay {
    return arc4random_uniform(100);
}

+ (NSString *)getRandomAvatarName {
    int value = arc4random_uniform(5);
    return [NSString stringWithFormat:@"avatar0%d", value+1];
}

- (void) readJson {
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:@""];
    NSArray *contacts = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
}
@end
