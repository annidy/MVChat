//
//  MVChatManager.m
//  MVChat
//
//  Created by Mark Vasiv on 01/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVChatManager.h"
#import "MVMessageModel.h"

@implementation MVChatManager
+ (NSArray <MVMessageModel *> *)messages {
    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:50];
    for (int i = 0; i < 50; i++) {
        MVMessageModel *message = [MVMessageModel new];
        message.text = [self randomString];
        message.sendDate = [self randomDate];
        
        if ([self randomBool]) {
            message.direction = MessageDirectionIncoming;
        } else {
            message.direction = MessageDirectionOutgoing;
        }
        
        [messages addObject:message];
    }
    
    [messages sortUsingComparator:^NSComparisonResult(MVMessageModel *obj1, MVMessageModel *obj2) {
        if (obj1.sendDate.timeIntervalSinceReferenceDate > obj2.sendDate.timeIntervalSinceReferenceDate) {
            return NSOrderedDescending;
        } else if (obj1.sendDate.timeIntervalSinceReferenceDate < obj2.sendDate.timeIntervalSinceReferenceDate) {
            return NSOrderedAscending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    return [messages copy];
}

#pragma mark - Helpers
static char *letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

+ (NSString *)randomString {
    NSUInteger length = arc4random_uniform(50);
    NSMutableString *randomString = [NSMutableString stringWithCapacity: length];
    
    for (int i = 0; i < length; i++) {
        [randomString appendFormat: @"%c", letters[arc4random_uniform((int)strlen(letters))]];
    }
    
    return randomString;
}

+ (BOOL)randomBool {
    return arc4random_uniform(50) % 2;
}

+ (NSDate *)randomDate {
    NSDate *date = [NSDate new];
    double time = arc4random_uniform(5000000);
    
    return [date dateByAddingTimeInterval:-time];
}

@end
