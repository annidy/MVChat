//
//  MVContactModel.h
//  MVChat
//
//  Created by Mark Vasiv on 01/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    ContactStatusOnline,
    ContactStatusOffline,
    ContactStatusDoNotDisturb
} ContactStatus;

@interface MVContactModel : NSObject
@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) BOOL iam;
@property (assign, nonatomic) ContactStatus status;
@property (strong, nonatomic) NSString *avatarName;
- (instancetype) initWithId:(NSString *)id name:(NSString *)name iam:(BOOL)iam status:(ContactStatus)status andAvatarName:(NSString *)avatarName;
@end
