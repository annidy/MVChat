//
//  NSInvocation+Protocols.h
//  MVChat
//
//  Created by Mark Vasiv on 23/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSInvocation (Protocols)
+ (id)invocationWithProtocol:(Protocol*)targetProtocol selector:(SEL)selector target:(id)target;
@end
