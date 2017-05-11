//
//  MVMessageCell.h
//  MVChat
//
//  Created by Mark Vasiv on 01/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVSlidingCell.h"

@interface MVMessageCell : UITableViewCell <MVSlidingCell>
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIImageView *avatarImage;
@end
