//
//  MVContactModel.m
//  MVChat
//
//  Created by Mark Vasiv on 01/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVContactModel.h"

@implementation MVContactModel
- (instancetype) initWithId:(NSString *)id name:(NSString *)name iam:(BOOL)iam status:(ContactStatus)status andAvatarName:(NSString *)avatarName {
    if (self = [super init]) {
        _id = id;
        _name = name;
        _iam = iam;
        _status = status;
        _avatarName = avatarName;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        return NO;
    }
    
    return [self isEqualToContact:object];
}

- (BOOL)isEqualToContact:(MVContactModel *)contact {
    return  (self.id == contact.id || [self.id isEqualToString:contact.id]) &&
            (self.name == contact.name || [self.name isEqualToString:contact.name]) &&
            (self.avatarName == contact.avatarName || [self.avatarName isEqualToString:contact.avatarName]) &&
            self.status == contact.status &&
            self.iam == contact.iam &&
            (self.phoneNumbers == contact.phoneNumbers || [self.phoneNumbers isEqualToArray:contact.phoneNumbers]) &&
            (self.lastSeenDate == contact.lastSeenDate || [self.lastSeenDate isEqualToDate:contact.lastSeenDate]);
}

-(NSUInteger)hash {
    return self.id.hash;
}

-(id)copyWithZone:(NSZone *)zone {
    MVContactModel *copy = [[MVContactModel allocWithZone:zone] init];
    copy.id = [self.id copy];
    copy.name = [self.name copy];
    copy.iam = self.iam;
    copy.status = self.status;
    copy.avatarName = [self.avatarName copy];
    copy.phoneNumbers = [self.phoneNumbers copy];
    copy.lastSeenDate = [self.lastSeenDate copy];
    
    return copy;
}

@end
