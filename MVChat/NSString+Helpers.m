//
//  NSString+Helpers.m
//  MVChat
//
//  Created by Mark Vasiv on 01/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "NSString+Helpers.h"

@implementation NSString (Helpers)
+ (NSString *)lastSeenTimeStringForDate:(NSDate *)lastSeenDate {
    NSString *durationString;
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute
                                                                   fromDate:lastSeenDate
                                                                     toDate:[NSDate new]
                                                                    options: 0];
    
    NSInteger days = [components day];
    NSInteger hour = [components hour];
    NSInteger minutes = [components minute];
    
    if (days > 0) {
        if (days > 1) {
            durationString = [NSString stringWithFormat:@"%ld days", (long)days];
        }
        else {
            durationString = [NSString stringWithFormat:@"%ld day", (long)days];
        }
    } else if (hour > 0) {
        if (hour > 1) {
            durationString = [NSString stringWithFormat:@"%ld hours", (long)hour];
        }
        else {
            durationString = [NSString stringWithFormat:@"%ld hour", (long)hour];
        }
    } else if (minutes > 0) {
        if (minutes > 1) {
            durationString = [NSString stringWithFormat:@"%ld minutes", (long)minutes];
        }
    }
    
    if (durationString) {
        return [[@"last seen " stringByAppendingString:durationString] stringByAppendingString:@" ago"];
    } else {
        return @"online";
    }
    
}
@end
