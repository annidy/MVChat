//
//  MVMessageCell.h
//  MVChat
//
//  Created by Mark Vasiv on 22/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MVMessageCellModel;

@protocol MVMessageCell
- (void)fillWithModel:(MVMessageCellModel *)model;
- (UITapGestureRecognizer *)tapRecognizer;
- (MVMessageCellModel *)model;
@end
