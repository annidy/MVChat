//
//  MVDataAggregator.h
//  MVChat
//
//  Created by Mark Vasiv on 15/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MVDataAggregator : NSObject
- (instancetype)initWithThrottle:(NSTimeInterval)throttle allowingFirst:(BOOL)allowsFirst maxObjectsCount:(NSUInteger)maxCount andBlock:(void (^)(NSArray *))block;
- (void)call:(id)object;
@end
