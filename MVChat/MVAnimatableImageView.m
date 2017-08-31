//
//  MVAnimatableImageView.m
//  MVChat
//
//  Created by Mark Vasiv on 30/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVAnimatableImageView.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

@interface MVAnimatableImageView ()
@property (strong, nonatomic) UIImageView *imageView;
@end

@implementation MVAnimatableImageView
- (instancetype)init {
    if (self = [super initWithFrame:CGRectZero]) {
        self.imageView = [UIImageView new];
        self.imageView.contentMode = UIViewContentModeScaleToFill;
        self.clipsToBounds = YES;
        [self addSubview:self.imageView];
    }
    
    return self;
}

- (void)setContentMode:(UIViewContentMode)contentMode {
    [super setContentMode:contentMode];
    [self update];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self update];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    self.imageView.image = image;
    [self update];
}

- (void)update {
    UIImage *image = [self.image copy];
    if (!image) {
        return;
    }
    
    switch (self.contentMode) {
        case UIViewContentModeScaleToFill:
            self.imageView.bounds = [MVImageViewUtilities rectForSize:self.bounds.size];
            self.imageView.center = [MVImageViewUtilities centerForSize:self.bounds.size];
            break;
        case UIViewContentModeScaleAspectFit:
            self.imageView.bounds = [MVImageViewUtilities aspectFitRectForSize:image.size insideRect:self.bounds];
            self.imageView.center = [MVImageViewUtilities centerForSize:self.bounds.size];
            break;
        case UIViewContentModeScaleAspectFill:
            self.imageView.bounds = [MVImageViewUtilities aspectFillRectForSize:image.size insideRect:self.bounds];
            self.imageView.center = [MVImageViewUtilities centerForSize:self.bounds.size];
            break;
        case UIViewContentModeRedraw:
            self.imageView.bounds = [MVImageViewUtilities aspectFillRectForSize:image.size insideRect:self.bounds];
            self.imageView.center = [MVImageViewUtilities centerForSize:self.bounds.size];
            break;
        case UIViewContentModeCenter:
            self.imageView.bounds = [MVImageViewUtilities rectForSize:image.size];
            self.imageView.center = [MVImageViewUtilities centerForSize:self.bounds.size];
            break;
        case UIViewContentModeTop:
            self.imageView.bounds = [MVImageViewUtilities rectForSize:image.size];
            self.imageView.center = [MVImageViewUtilities centerTopForSize:self.image.size insideSize:self.bounds.size];
            break;
        case UIViewContentModeBottom:
            self.imageView.bounds = [MVImageViewUtilities rectForSize:image.size];
            self.imageView.center = [MVImageViewUtilities centerBottomForSize:self.image.size insideSize:self.bounds.size];
            break;
        case UIViewContentModeLeft:
            self.imageView.bounds = [MVImageViewUtilities rectForSize:image.size];
            self.imageView.center = [MVImageViewUtilities centerLeftForSize:self.image.size insideSize:self.bounds.size];
            break;
        case UIViewContentModeRight:
            self.imageView.bounds = [MVImageViewUtilities rectForSize:image.size];
            self.imageView.center = [MVImageViewUtilities centerRightForSize:self.image.size insideSize:self.bounds.size];
            break;
        case UIViewContentModeTopLeft:
            self.imageView.bounds = [MVImageViewUtilities rectForSize:image.size];
            self.imageView.center = [MVImageViewUtilities topLeftForSize:self.image.size insideSize:self.bounds.size];
            break;
        case UIViewContentModeTopRight:
            self.imageView.bounds = [MVImageViewUtilities rectForSize:self.image.size];
            self.imageView.center = [MVImageViewUtilities topRightForSize:self.image.size insideSize:self.bounds.size];
            break;
        case UIViewContentModeBottomLeft:
            self.imageView.bounds = [MVImageViewUtilities rectForSize:self.image.size];
            self.imageView.center = [MVImageViewUtilities bottomLeftForSize:self.image.size insideSize:self.bounds.size];
            break;
        case UIViewContentModeBottomRight:
            self.imageView.bounds = [MVImageViewUtilities rectForSize:self.image.size];
            self.imageView.center = [MVImageViewUtilities bottomRightForSize:self.image.size insideSize:self.bounds.size];
            break;
    }
}

@end

@implementation MVImageViewUtilities

+ (CGRect)rectForSize:(CGSize)size {
    return CGRectMake(0, 0, size.width, size.height);
}

+ (CGRect)aspectFitRectForSize:(CGSize)size insideRect:(CGRect)insideRect {
    return AVMakeRectWithAspectRatioInsideRect(size, insideRect);
}

+ (CGRect)aspectFillRectForSize:(CGSize)size insideRect:(CGRect)insideRect {
    CGFloat imageRatio = size.width / size.height;
    CGFloat insideRectRatio = insideRect.size.width / insideRect.size.height;
    if (imageRatio > insideRectRatio) {
        return CGRectMake(0, 0, floor(insideRect.size.height * imageRatio), insideRect.size.height);
    } else {
        return CGRectMake(0, 0, insideRect.size.width, floor(insideRect.size.width / imageRatio));
    }
}

+ (CGPoint)centerForSize:(CGSize)size {
    return CGPointMake(size.width / 2, size.height / 2);
}

+ (CGPoint)centerTopForSize:(CGSize)size insideSize:(CGSize)insideSize{
    return CGPointMake(insideSize.width / 2, size.height / 2);
}

+ (CGPoint)centerBottomForSize:(CGSize)size insideSize:(CGSize)insideSize{
    return CGPointMake(insideSize.width / 2, insideSize.height - size.height / 2);
}

+ (CGPoint)centerLeftForSize:(CGSize)size insideSize:(CGSize)insideSize{
    return CGPointMake(size.width / 2, insideSize.height / 2);
}

+ (CGPoint)centerRightForSize:(CGSize)size insideSize:(CGSize)insideSize{
    return CGPointMake(insideSize.width - size.width / 2, insideSize.height / 2);
}

+ (CGPoint)topLeftForSize:(CGSize)size insideSize:(CGSize)insideSize {
    return CGPointMake(size.width / 2, size.height / 2);
}

+ (CGPoint)topRightForSize:(CGSize)size insideSize:(CGSize)insideSize {
    return CGPointMake(insideSize.width - size.width / 2, size.height / 2);
}

+ (CGPoint)bottomLeftForSize:(CGSize)size insideSize:(CGSize)insideSize {
    return CGPointMake(size.width / 2, insideSize.height - size.height / 2);
}

+ (CGPoint)bottomRightForSize:(CGSize)size insideSize:(CGSize)insideSize {
    return CGPointMake(insideSize.width - size.width / 2, insideSize.height - size.height / 2);
}

@end
