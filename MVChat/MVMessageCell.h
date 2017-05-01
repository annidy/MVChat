//
//  MVMessageCell.h
//  MVChat
//
//  Created by Mark Vasiv on 01/05/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MVMessageCell : UITableViewCell
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) NSLayoutConstraint *rightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *leftConstraint;
@end
