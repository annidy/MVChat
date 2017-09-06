//
//  MVMessageCell.h
//  MVChat
//
//  Created by Mark Vasiv on 22/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVMessageModel.h"

typedef enum : NSUInteger {
    MVMessageCellTailTypeDefault,
    MVMessageCellTailTypeTailess,
    MVMessageCellTailTypeFirstTailess,
    MVMessageCellTailTypeLastTailess
} MVMessageCellTailType;
