//
//  MVMessageCell.h
//  MVChat
//
//  Created by Mark Vasiv on 01/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVSlidingCell.h"
#import "MVMessageCellProtocol.h"

@interface MVTextMessageCell : UITableViewCell <MVSlidingCell, MVMessageCellComplexProtocol>
@end
