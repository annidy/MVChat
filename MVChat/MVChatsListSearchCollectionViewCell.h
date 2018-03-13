//
//  MVChatsListStackViewItem.h
//  MVChat
//
//  Created by Mark Vasiv on 28/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MVChatsListCellViewModel;

@interface MVChatsListSearchCollectionViewCell : UICollectionViewCell
- (void)fillWithModel:(MVChatsListCellViewModel *)model;
@end
