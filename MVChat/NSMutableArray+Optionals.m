//
//  NSMutableArray+Optionals.m
//  MVChat
//
//  Created by Mark Vasiv on 15/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "NSMutableArray+Optionals.h"

@implementation NSMutableArray (Optionals)
- (id)optionalObjectAtIndex:(NSUInteger)index {
    if (self.count > index) {
        return [self objectAtIndex:index];
    }
    return nil;
}

- (id)optionalLastObject {
    if (self.count) {
        return self.lastObject;
    }
    return nil;
}
@end
