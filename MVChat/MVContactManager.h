//
//  MVContactManager.h
//  MVChat
//
//  Created by Mark Vasiv on 05/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MVContactManager : NSObject
+ (void)startSendingStatusUpdates;
+ (void)startSendingAvatarUpdates;
+ (NSArray *)getContacts;
@end
