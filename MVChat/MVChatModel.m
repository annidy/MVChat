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
@end
