//
//  NSBundle+DBLibrary.m
//  DBAttachmentPickerControllerExample
//
//  Created by Denis Bogatyrev on 06.08.16.
//
//  The MIT License (MIT)
//  Copyright (c) 2016 Denis Bogatyrev.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import "NSBundle+DBLibrary.h"
#import "DBAttachmentPickerController.h"

@implementation NSBundle (DBLibrary)

NSString * const kLocalizedStringNotFound = @"kLocalizedStringNotFound";

+ (instancetype)dbAttachmentPickerBundle {
    return [NSBundle bundleForClass:[DBAttachmentPickerController class]];
}

+ (instancetype)dbAttachmentPickerResourceBundle {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"DBAttachmentPickerController" ofType:@"bundle"];
    if (bundlePath) {
        bundle = [NSBundle bundleWithPath:bundlePath];
    }
    return bundle;
}

+ (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName backupBundle:(NSBundle *)bundle {
    // First try main bundle
    NSString * string = [[NSBundle mainBundle] localizedStringForKey:key value:kLocalizedStringNotFound table:tableName];
    
    // Then try the backup bundle
    if ([string isEqualToString:kLocalizedStringNotFound]) {
        string = [bundle localizedStringForKey:key value:kLocalizedStringNotFound table:tableName];
    }
    
    // Still not found?
    if ([string isEqualToString:kLocalizedStringNotFound]) {
        NSLog(@"No localized string for '%@' in '%@'", key, tableName);
        string = value.length > 0 ? value : key;
    }
    
    return string;
}

@end
