//
//  MVContactsListCell.h
//  MVChat
//
//  Created by Mark Vasiv on 25/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MVContactModel;
@class MVContactsListCellViewModel;

@interface MVContactsListCell : UITableViewCell
- (void)fillWithModel:(MVContactsListCellViewModel *)model;
@end
