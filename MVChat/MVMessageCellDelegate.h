//
//  MVMessageCellDelegate.h
//  MVChat
//
//  Created by Mark Vasiv on 31/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MVMessageCellProtocol.h"

@protocol MVMessageCellDelegate <NSObject>
- (void)cellTapped:(UITableViewCell *)cell;
@end
