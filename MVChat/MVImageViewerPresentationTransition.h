//
//  MVImageViewerPresentationTransition.h
//  MVChat
//
//  Created by Mark Vasiv on 30/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MVImageViewerPresentationTransition : NSObject <UIViewControllerAnimatedTransitioning>
- (instancetype)initFromImageView:(UIImageView *)fromImage;
@end
