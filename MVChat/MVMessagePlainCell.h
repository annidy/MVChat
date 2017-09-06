//
//  MVMessagePlainCell.h
//  MVChat
//
//  Created by Mark Vasiv on 06/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVMessageCellProtocol.h"

@interface MVMessagePlainCell : UITableViewCell <MVMessageCellSimpleProtocol>
@property (strong, nonatomic) UIView *container;
@end
