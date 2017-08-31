//
//  MVImageViewerViewModel.h
//  MVChat
//
//  Created by Mark Vasiv on 30/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIImageView;
@class DBAttachment;

@interface MVImageViewerViewModel : NSObject
- (instancetype)initWithSourceImageView:(UIImageView *)imageView attachment:(DBAttachment *)attachment andIndex:(NSUInteger)index;
@property (weak, nonatomic) UIImageView *sourceImageView;
@property (strong, nonatomic) DBAttachment *attachment;
@property (assign, nonatomic) NSUInteger index;
@end
