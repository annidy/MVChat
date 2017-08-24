//
//  MVBarButtonMenuCell.h
//  MVChat
//
//  Created by Mark Vasiv on 23/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MVOverlayMenuCell : UITableViewCell
@property (weak, nonatomic) UITableView *parentTableView;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *rightButtonConstraint;
- (void)setButtonText:(NSString *)text;
@end
