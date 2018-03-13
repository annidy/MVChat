//
//  MVContactsListCellViewModel.h
//  MVChat
//
//  Created by Mark Vasiv on 08/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MVContactModel;
@class UIImage;

@interface MVContactsListCellViewModel : NSObject
@property (strong, nonatomic) MVContactModel *contact;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *lastSeenTime;
@property (strong, nonatomic) UIImage *avatar;
@end
