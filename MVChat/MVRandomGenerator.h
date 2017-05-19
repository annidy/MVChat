//
//  MVRandomGenerator.h
//  MVChat
//
//  Created by Mark Vasiv on 12/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    MVUpdateTypeChats,
    MVUpdateTypeMessages
} MVUpdateType;

@protocol AppListener
- (void)updateWithType:(MVUpdateType)type andObjects:(NSArray *)objects;
@end

@interface MVRandomGenerator : NSObject

@property (weak, nonatomic) id <AppListener> updatesListener;
+(instancetype)sharedInstance;
- (void)generateData;
- (NSInteger)randomIndexWithMax:(NSInteger)max;
@end
