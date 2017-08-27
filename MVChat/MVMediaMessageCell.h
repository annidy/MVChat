//
//  MVMediaMessageCell.h
//  MVChat
//
//  Created by Mark Vasiv on 27/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVSlidingCell.h"
#import "MVMessageCellProtocol.h"

@interface MVMediaMessageCell : UITableViewCell <MVSlidingCell, MVMessageCellComplexProtocol>

@end
