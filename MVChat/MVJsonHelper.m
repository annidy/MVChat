//
//  MVJsonHelper.m
//  MVChat
//
//  Created by Mark Vasiv on 29/06/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVJsonHelper.h"
#import "MVContactModel.h"
#import "MVChatModel.h"
#import "NSObject+Serialization.h"

@implementation MVJsonHelper
+ (NSString *)documentsPath {
    return [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path];
}

+ (NSString *)pathToFile:(NSString *)name extenssion:(NSString *)extenssion {
    return [[[[self documentsPath] stringByAppendingPathComponent:name] stringByAppendingString:@"."]stringByAppendingString:extenssion];
}

+ (NSArray *)loadJsonFromFileWithName:(NSString *)name {
    NSString *path = [self pathToFile:name extenssion:@"json"];
    NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:path];
    
    NSArray *arr = nil;
    if (fileData && fileData.length) {
        NSError *error;
        arr = [NSJSONSerialization JSONObjectWithData:fileData options:NSJSONReadingMutableLeaves error:&error];
        if (error) {
            NSLog(@"error serializing JSON");
        }
    }
    
    return arr;
}

+ (NSArray *)parseEnitiesWithClass:(Class)class fromJson:(NSArray *)jsonArray {
    if (!jsonArray) return nil;
    
    NSMutableArray *enities = [NSMutableArray new];
    for (NSDictionary *jsonEntity in jsonArray) {
        [enities addObject:[[class new] fillWithData:jsonEntity]];
    }
    
    return [enities copy];
}

+ (NSData *)parseArrayToJson:(NSArray *)array {
    NSError *error;
    NSMutableArray *dictArray = [NSMutableArray new];
    for (id obj in array) {
        [dictArray addObject:[obj serialize]];
    }
    
    return [NSJSONSerialization dataWithJSONObject:dictArray options:NSJSONWritingPrettyPrinted error:&error];
}

+ (BOOL)writeData:(NSData *)data toFileWithName:(NSString *)name extenssion:(NSString *)extenssion {
    NSString *path = [self pathToFile:name extenssion:extenssion];
    NSError *error;
    
    return [data writeToFile:path options:NSDataWritingAtomic error:&error];
}

+ (NSData *)dataFromFileWithName:(NSString *)name extenssion:(NSString *)extenssion {
    NSString *path = [self pathToFile:name extenssion:extenssion];
    return [[NSFileManager defaultManager] contentsAtPath:path];
}
@end
