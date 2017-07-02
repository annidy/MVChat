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

@implementation MVContactManager
+ (NSArray *)getContacts {
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:3];
    
    MVContactModel *contact1 = [[MVContactModel alloc] initWithId:@"0" name:@"Seth Davids" iam:NO status:ContactStatusOffline andAvatarName:@"avatar01"];
    MVContactModel *contact2 = [[MVContactModel alloc] initWithId:@"1" name:@"Andrew Stock" iam:NO status:ContactStatusDoNotDisturb andAvatarName:@"avatar02"];
    MVContactModel *contact3 = [[MVContactModel alloc] initWithId:@"2" name:@"Matt Daniels" iam:YES status:ContactStatusOnline andAvatarName:@"avatar03"];
    
    [arr addObject:contact1];
    [arr addObject:contact2];
    [arr addObject:contact3];

    
    
    return [arr copy];
}

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

+ (NSString *)getRandomAvatarName {
    int value = arc4random_uniform(5);
    return [NSString stringWithFormat:@"avatar0%d", value+1];
}

- (void) readJson {
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:@""];
    NSArray *contacts = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
}
@end
