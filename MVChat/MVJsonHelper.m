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


+ (BOOL)writeData:(NSData *)data toFileWithName:(NSString *)name extenssion:(NSString *)extenssion {
    NSString *path = [self pathToFile:name extenssion:extenssion];
    [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    NSError *error;
    return [data writeToFile:path options:NSDataWritingAtomic error:&error];
}

+ (NSData *)dataFromFileWithName:(NSString *)name extenssion:(NSString *)extenssion {
    NSString *path = [self pathToFile:name extenssion:extenssion];
    return [[NSFileManager defaultManager] contentsAtPath:path];
}

+ (NSURL *)urlToFileWithName:(NSString *)filename extenssion:(NSString *)extenssion {
    //return [NSURL URLWithString:[self pathToFile:filename extenssion:extenssion]];
    return [NSURL fileURLWithPath:[self pathToFile:filename extenssion:extenssion]];
}
@end
