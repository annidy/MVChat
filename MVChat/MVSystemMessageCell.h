//
//  MVSystemMessageCell.h
//  MVChat
//
//  Created by Mark Vasiv on 21/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVMessageCellProtocol.h"

@interface MVSystemMessageCell : UITableViewCell <MVMessageCellProtocol>
@property (strong, nonatomic) UILabel *titleLabel;
@end
