//
//  NSMutableArray+Optionals.h
//  MVChat
//
//  Created by Mark Vasiv on 15/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray<ObjectType> (Optionals)
- (ObjectType)optionalObjectAtIndex:(NSUInteger)index;
- (ObjectType)optionalLastObject;
@end
