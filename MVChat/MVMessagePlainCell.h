//
//  MVMessagePlainCell.h
//  MVChat
//
//  Created by Mark Vasiv on 06/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MVMessagePlainCell : UITableViewCell
@property (strong, nonatomic) UIView *container;
+ (CGFloat)heightWithText:(NSString *)text;
- (void)fillWithText:(NSString *)text;
@end
