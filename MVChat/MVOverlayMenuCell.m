//
//  MVBarButtonMenuCell.m
//  MVChat
//
//  Created by Mark Vasiv on 23/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVOverlayMenuCell.h"

@interface MVOverlayMenuCell ()
@property (strong, nonatomic) IBOutlet UIButton *button;
@end

@implementation MVOverlayMenuCell
- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    self.button.layer.masksToBounds = YES;
    self.button.layer.cornerRadius = 16;
    self.button.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    self.button.contentEdgeInsets = UIEdgeInsetsMake(7, 25, 7, 25);
    self.button.tintColor = [UIColor darkGrayColor];
    self.rightButtonConstraint.constant = - [UIScreen mainScreen].bounds.size.width - 1;
}

- (IBAction)buttonTapped:(id)sender {
    [self.parentTableView.delegate tableView:self.parentTableView didSelectRowAtIndexPath:self.indexPath];
}

- (void)setButtonText:(NSString *)text {
    [self.button setTitle:text forState:UIControlStateNormal];
}

@end
