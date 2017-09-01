//
//  MVMessageModel.m
//  MVChat
//
//  Created by Mark Vasiv on 01/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVMessageModel.h"

@implementation MVMessageModel
- (id)copyWithZone:(NSZone *)zone {
    MVMessageModel *copy = [[MVMessageModel allocWithZone:zone] init];
    copy.id = [self.id copy];
    copy.chatId = [self.chatId copy];
    copy.text = [self.text copy];
    copy.direction = self.direction;
    copy.type = self.type;
    copy.sendDate = [self.sendDate copy];
    copy.contact = [self.contact copy];
    
    return copy;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        _id = [decoder decodeObjectForKey:@"id"];
        _chatId = [decoder decodeObjectForKey:@"chatId"];
        _text = [decoder decodeObjectForKey:@"text"];
        _direction = [decoder decodeIntegerForKey:@"direction"];
        _type = [decoder decodeIntegerForKey:@"type"];
        _sendDate = [decoder decodeObjectForKey:@"sendDate"];
        _contact = [decoder decodeObjectForKey:@"contact"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_id forKey:@"id"];
    [encoder encodeObject:_chatId forKey:@"chatId"];
    [encoder encodeObject:_text forKey:@"text"];
    [encoder encodeInteger:_direction forKey:@"direction"];
    [encoder encodeInteger:_type forKey:@"type"];
    [encoder encodeObject:_sendDate forKey:@"sendDate"];
    [encoder encodeObject:_contact forKey:@"contact"];
}

- (NSComparisonResult)compareMessageBySendDate:(MVMessageModel *)message {
    NSTimeInterval first = self.sendDate.timeIntervalSinceReferenceDate;
    NSTimeInterval second = message.sendDate.timeIntervalSinceReferenceDate;
    
    if (first == second) {
        return NSOrderedSame;
    } else if (first > second) {
        return NSOrderedAscending;
    } else {
        return NSOrderedDescending;
    }
}
@end
