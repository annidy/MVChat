//
//  MVChatManager.h
//  MVChat
//
//  Created by Mark Vasiv on 01/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MVMessageModel;

@interface MVChatManager : NSObject

+ (NSArray <MVMessageModel *> *)messages;

@end
