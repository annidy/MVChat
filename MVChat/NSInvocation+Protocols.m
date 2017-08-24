//
//  NSInvocation+Protocols.m
//  MVChat
//
//  Created by Mark Vasiv on 23/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "NSInvocation+Protocols.h"
#import <objc/runtime.h>

@implementation NSInvocation (Protocols)
+ (id)invocationWithProtocol:(Protocol*)targetProtocol selector:(SEL)selector target:(id)target {
    struct objc_method_description desc;
    BOOL required = YES;
    desc = protocol_getMethodDescription(targetProtocol, selector, required, YES);
    
    if (desc.name == NULL) {
        required = NO;
        desc = protocol_getMethodDescription(targetProtocol, selector, required, YES);
    }
    
    if (desc.name == NULL) {
        return nil;
    }

    NSMethodSignature *sig = [NSMethodSignature signatureWithObjCTypes:desc.types];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    [inv setSelector:selector];
    [inv setTarget:target];
    
    return inv;
}
@end
