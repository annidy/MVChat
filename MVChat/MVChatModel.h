//
//  MVChatModel.h
//  MVChat
//
//  Created by Mark Vasiv on 11/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MVContactModel;
@class MVMessageModel;

@interface MVChatModel : NSObject
@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *avatarName;
@property (strong, nonatomic) NSArray <MVContactModel *> *participants;
@property (strong, nonatomic) NSDate *lastUpdateDate;
@property (strong, nonatomic) MVMessageModel *lastMessage;
- (instancetype)initWithId:(NSString *)id andTitle:(NSString *)title;
@end
