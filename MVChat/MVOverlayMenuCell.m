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
    
    self.button.layer.masksToBounds = NO;
    self.button.layer.cornerRadius = 16;
    self.button.layer.shadowColor = [UIColor darkTextColor].CGColor;
    self.button.layer.shadowOffset = CGSizeMake(1, 1);
    self.button.layer.shadowOpacity = 0.2f;
    self.button.layer.shadowRadius = 0.8f;
    self.rightButtonConstraint.constant = - [UIScreen mainScreen].bounds.size.width - 1;
}

- (IBAction)buttonTapped:(id)sender {
    [self.parentTableView.delegate tableView:self.parentTableView didSelectRowAtIndexPath:self.indexPath];
}

- (void)setButtonText:(NSString *)text {
    [self.button setTitle:text forState:UIControlStateNormal];
}

@end
