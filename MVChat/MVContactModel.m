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
@end
