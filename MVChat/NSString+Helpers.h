//
//  NSString+Helpers.h
//  MVChat
//
//  Created by Mark Vasiv on 01/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Helpers)
+ (NSString *)lastSeenTimeStringForDate:(NSDate *)lastSeenDate;
@end
