//
//  NSString+Helpers.m
//  MVChat
//
//  Created by Mark Vasiv on 01/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "NSString+Helpers.h"
#import "MVContactModel.h"

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

+ (NSString *)titleChangeStringForContactName:(NSString *)name andTitle:(NSString *)title {
    return [NSString stringWithFormat:@"%@ changed title to %@", name, title];
}

+ (NSString *)addContactsStringForName:(NSString *)name oldContacts:(NSArray *)oldContacts newContacts:(NSArray *)newContacts {
    NSMutableSet *addContactsSet = [NSMutableSet setWithArray:newContacts];
    [addContactsSet minusSet:[NSSet setWithArray:oldContacts]];
    
    if (addContactsSet.count) {
        NSString *namesString = [NSString new];
        NSUInteger realCount = 0;
        for (MVContactModel *addContact in [addContactsSet allObjects]) {
            if (addContact.iam) {
                continue;
            }
            namesString = [namesString stringByAppendingString:addContact.name];
            namesString = [namesString stringByAppendingString:@", "];
            realCount ++;
        }
        
        if (realCount) {
            namesString = [namesString substringToIndex:namesString.length - 2];
            NSString *startString = [name copy];
            if (realCount == 1) {
                startString = [startString stringByAppendingString:@" add contact: "];
            } else {
                startString = [startString stringByAppendingString:@" add contacts: "];
            }
            
            return [startString stringByAppendingString:namesString];
        }
    }
    
    return nil;
}

+ (NSString *)removeContactsStringForName:(NSString *)name oldContacts:(NSArray *)oldContacts newContacts:(NSArray *)newContacts {
    NSMutableSet *removeContactsSet = [NSMutableSet setWithArray:oldContacts];
    [removeContactsSet minusSet:[NSSet setWithArray:newContacts]];
    
    if (removeContactsSet.count) {
        NSString *namesString = [NSString new];
        NSUInteger realCount = 0;
        for (MVContactModel *addContact in [removeContactsSet allObjects]) {
            if (addContact.iam) {
                continue;
            }
            namesString = [namesString stringByAppendingString:addContact.name];
            namesString = [namesString stringByAppendingString:@", "];
            realCount ++;
        }
        
        if (realCount) {
            namesString = [namesString substringToIndex:namesString.length - 2];
            NSString *startString = [name copy];
            if (realCount == 1) {
                startString = [startString stringByAppendingString:@" removed contact: "];
            } else {
                startString = [startString stringByAppendingString:@" removed contacts: "];
            }
            
            return [startString stringByAppendingString:namesString];
        }
    }
    
    return nil;
}
static NSDateFormatter *messageTimeFormatter;
+ (NSString *)messageTimeFromDate:(NSDate *)date {
    if (!messageTimeFormatter) {
        messageTimeFormatter = [NSDateFormatter new];
        messageTimeFormatter.dateFormat = @"HH:mm";
    }

    return [messageTimeFormatter stringFromDate:date];
}
@end
