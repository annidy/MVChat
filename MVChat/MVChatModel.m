//
//  MVChatModel.m
//  MVChat
//
//  Created by Mark Vasiv on 11/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVChatModel.h"
#import "MVContactModel.h"
#import "MVMessageModel.h"

@implementation MVChatModel
- (instancetype)initWithId:(NSString *)id andTitle:(NSString *)title {
    if (self = [super init]) {
        _id = id;
        _title = title;
    }
    
    return self;
}

- (BOOL)isPeerToPeer {
    if (self.participants.count == 2) {
        return YES;
    } else {
        return NO;
    }
}

- (MVContactModel *)getPeer {
    for (MVContactModel *contact in self.participants) {
        if (!contact.iam) {
            return contact;
        }
    }
    
    return nil;
}
- (id)copyWithZone:(NSZone *)zone {
    MVChatModel *copy = [[MVChatModel allocWithZone:zone] init];
    copy.id = [self.id copy];
    copy.title = [self.title copy];
    copy.participants = [self.participants copy];
    copy.lastUpdateDate = [self.lastUpdateDate copy];
    copy.lastMessage = [self.lastMessage copy];
    
    return copy;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        _id = [decoder decodeObjectForKey:@"id"];
        _title = [decoder decodeObjectForKey:@"title"];
        _participants = [decoder decodeObjectForKey:@"participants"];
        _lastUpdateDate = [decoder decodeObjectForKey:@"lastUpdateDate"];
        _lastMessage = [decoder decodeObjectForKey:@"lastMessage"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_id forKey:@"id"];
    [encoder encodeObject:_title forKey:@"title"];
    [encoder encodeObject:_participants forKey:@"participants"];
    [encoder encodeObject:_lastUpdateDate forKey:@"lastUpdateDate"];
    [encoder encodeObject:_lastMessage forKey:@"lastMessage"];
}

- (NSComparisonResult)compareChatByLastUpdateDate:(MVChatModel *)chat {
    NSTimeInterval first = self.lastUpdateDate.timeIntervalSinceReferenceDate;
    NSTimeInterval second = chat.lastUpdateDate.timeIntervalSinceReferenceDate;
    
    if (first == second) {
        return NSOrderedSame;
    } else if (first > second) {
        return NSOrderedAscending;
    } else {
        return NSOrderedDescending;
    }
}

+ (NSComparator)comparatorByLastUpdateDate {
    return ^NSComparisonResult(MVChatModel *object1, MVChatModel *object2){
        return [object1 compareChatByLastUpdateDate:object2];
    };
}
@end
