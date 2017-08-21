//
//  MVMessageModel.h
//  MVChat
//
//  Created by Mark Vasiv on 01/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MVContactModel.h"

typedef enum : NSUInteger {
    MessageDirectionIncoming,
    MessageDirectionOutgoing
} MessageDirection;

typedef enum : NSUInteger {
    MVMessageTypeText,
    MVMessageTypeSystem
} MVMessageType;

@interface MVMessageModel : NSObject
@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *chatId;
@property (strong, nonatomic) NSString *text;
@property (assign, nonatomic) MessageDirection direction;
@property (assign, nonatomic) MVMessageType type;
@property (strong, nonatomic) NSDate *sendDate;
@property (strong, nonatomic) MVContactModel *contact;
@end
