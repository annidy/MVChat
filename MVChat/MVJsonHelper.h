//
//  MVJsonHelper.h
//  MVChat
//
//  Created by Mark Vasiv on 29/06/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MVContactModel;

@interface MVJsonHelper : NSObject
+ (NSArray *)loadJsonFromFileWithName:(NSString *)name;
+ (NSArray *)parseEnitiesWithClass:(Class)class fromJson:(NSArray *)jsonArray;
+ (NSData *)parseArrayToJson:(NSArray *)array;
+ (BOOL)writeData:(NSData *)data toFileWithName:(NSString *)name;
@end
