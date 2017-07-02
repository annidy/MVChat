//
//  MVTextGenerator.h
//  MVChat
//
//  Created by Mark Vasiv on 02/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MVTextGenerator : NSObject
- (NSString *)words:(NSUInteger)count;
- (NSString *)sentences:(NSUInteger)count;
@end
