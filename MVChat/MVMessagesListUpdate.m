//
//  MVMessagesListUpdate.m
//  MVChat
//
//  Created by Mark Vasiv on 15/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVMessagesListUpdate.h"

@implementation MVMessagesListUpdate
- (instancetype)initWithType:(MVMessagesListUpdateType)type indexPath:(NSIndexPath *)indexPath {
    if (self = [super init]) {
        _type = type;
        _indexPath = indexPath;
    }
    
    return self;
}
@end
