//
//  MVImageViewerViewModel.m
//  MVChat
//
//  Created by Mark Vasiv on 30/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVImageViewerViewModel.h"

@implementation MVImageViewerViewModel
- (instancetype)initWithSourceImageView:(UIImageView *)imageView attachment:(DBAttachment *)attachment andIndex:(NSUInteger)index {
    if (self = [super init]) {
        _sourceImageView = imageView;
        _attachment = attachment;
        _index = index;
    }
    
    return self;
}
@end
