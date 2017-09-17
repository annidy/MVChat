//
//  MVMessagesListUpdate.h
//  MVChat
//
//  Created by Mark Vasiv on 15/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    MVMessagesListUpdateTypeReloadAll,
    MVMessagesListUpdateTypeInsertRow
} MVMessagesListUpdateType;

@interface MVMessagesListUpdate : NSObject
- (instancetype)initWithType:(MVMessagesListUpdateType)type indexPath:(NSIndexPath *)indexPath rows:(NSArray *)rows;
@property (assign, nonatomic) MVMessagesListUpdateType type;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (assign, nonatomic) BOOL shouldReloadPrevious;
@property (assign, nonatomic) BOOL shouldInsertHeader;
@property (strong, nonatomic) NSArray *rows;
@end
