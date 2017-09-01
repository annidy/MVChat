//
//  MVContactsListener.h
//  MVChat
//
//  Created by Mark Vasiv on 01/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MVContactsUpdatesListener <NSObject>
- (void)updateContacts;
@end
