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
@end
