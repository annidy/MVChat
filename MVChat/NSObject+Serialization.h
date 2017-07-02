//
//  NSObject+Serialization.h
//  MVChat
//
//  Created by Mark Vasiv on 01/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Serialization)
- (NSDictionary *)serialize;
- (instancetype)fillWithData:(NSDictionary *)data;
@end
