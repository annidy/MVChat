//
//  MVSlidingCell.h
//  MVChat
//
//  Created by Mark Vasiv on 01/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MVSlidingCell <NSObject>
- (CGFloat)slidingConstraint;
- (void)setSlidingConstraint:(CGFloat)constant;
@end
