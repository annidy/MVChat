//
//  MVChatModel.m
//  MVChat
//
//  Created by Mark Vasiv on 11/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVChatModel.h"

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
@end
