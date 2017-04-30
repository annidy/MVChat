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
        
        if ([self randomBool]) {
            message.direction = MessageDirectionIncoming;
        } else {
            message.direction = MessageDirectionOutgoing;
        }
        
        [messages addObject:message];
    }
    
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

@end
