//
//  MVSearchProviderDelegate.h
//  MVChat
//
//  Created by Mark Vasiv on 30/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol MVSearchProviderDelegate <NSObject>
- (void)didSelectCellWithModel:(id)model;
@end
