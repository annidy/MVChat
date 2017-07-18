//
//  MVDataAggregator.m
//  MVChat
//
//  Created by Mark Vasiv on 15/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVDataAggregator.h"

enum {
    kWorkTodo = 1,
    kNoWorkTodo = 0
};

@interface MVDataAggregator()
@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) NSConditionLock *lock;
@property (strong, nonatomic) NSDate *lastCallTime;
@property (strong, nonatomic) NSDate *lastForwardTime;
@property (assign, nonatomic) NSTimeInterval throttle;
@property (assign, nonatomic) NSUInteger maxCount;
@property (assign, nonatomic) BOOL allowFirst;
@property (nonatomic, copy) void (^callBack)(NSArray *);
@end

@implementation MVDataAggregator

- (instancetype)initWithThrottle:(NSTimeInterval)throttle allowingFirst:(BOOL)allowsFirst maxObjectsCount:(NSUInteger)maxCount andBlock:(void (^)(NSArray *))block {
    if (self = [super init]) {
        _throttle = throttle;
        _callBack = block;
        _allowFirst = allowsFirst;
        _data = [NSMutableArray new];
        _lock = [[NSConditionLock alloc] initWithCondition: kNoWorkTodo];
        _maxCount = maxCount;
        
        [NSThread detachNewThreadSelector:@selector(startWorking) toTarget:self withObject:nil];
    }
    
    return self;
}

- (void)startWorking {
    while (YES) {
        [self.lock lockWhenCondition:kWorkTodo];
        NSArray *dataToHandle;
        if (self.data.count) {
            NSDate *delayedTime = [NSDate new];
            NSTimeInterval forwardDelay = delayedTime.timeIntervalSinceReferenceDate - self.lastForwardTime.timeIntervalSinceReferenceDate;
            if (forwardDelay > self.throttle || self.allowFirst) {
                self.lastForwardTime = delayedTime;
                self.allowFirst = NO;
                if (self.maxCount && self.data.count > self.maxCount) {
                    dataToHandle = [self.data subarrayWithRange:NSMakeRange(0, self.maxCount)];
                    [self.data removeObjectsInRange:NSMakeRange(0, self.maxCount)];
                } else {
                    dataToHandle = [self.data copy];
                    [self.data removeAllObjects];
                }
            }
        }
        
        [self.lock unlockWithCondition:self.data.count? kWorkTodo : kNoWorkTodo];
        if (dataToHandle) {
            self.callBack(dataToHandle);
        }
    }
}

- (void)call:(id)object {
    [self.lock lock];
    self.lastCallTime = [NSDate new];
    [self.data addObject:object];
    [self.lock unlockWithCondition:kWorkTodo];
}

@end
