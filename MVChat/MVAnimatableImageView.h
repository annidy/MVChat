//
//  MVAnimatableImageView.h
//  MVChat
//
//  Created by Mark Vasiv on 30/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MVAnimatableImageView : UIView
@property (strong, nonatomic) UIImage *image;
@property (assign, nonatomic) CGFloat cornerRadius;
@end

@interface MVImageViewUtilities : NSObject
+ (CGRect)rectForSize:(CGSize)size;
+ (CGRect)aspectFitRectForSize:(CGSize)size insideRect:(CGRect)insideRect;
+ (CGRect)aspectFillRectForSize:(CGSize)size insideRect:(CGRect)insideRect;
+ (CGPoint)centerForSize:(CGSize)size;
+ (CGPoint)centerTopForSize:(CGSize)size insideSize:(CGSize)insideSize;
+ (CGPoint)centerBottomForSize:(CGSize)size insideSize:(CGSize)insideSize;
+ (CGPoint)centerLeftForSize:(CGSize)size insideSize:(CGSize)insideSize;
+ (CGPoint)centerRightForSize:(CGSize)size insideSize:(CGSize)insideSize;
+ (CGPoint)topLeftForSize:(CGSize)size insideSize:(CGSize)insideSize;
+ (CGPoint)topRightForSize:(CGSize)size insideSize:(CGSize)insideSize;
+ (CGPoint)bottomLeftForSize:(CGSize)size insideSize:(CGSize)insideSize;
+ (CGPoint)bottomRightForSize:(CGSize)size insideSize:(CGSize)insideSize;
@end
