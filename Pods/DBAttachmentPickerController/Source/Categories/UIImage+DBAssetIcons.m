//
//  UIImage+DBAssetIcons.m
//  DBAttachmentPickerController
//
//  Created by Denis Bogatyrev on 14.03.16.
//
//  The MIT License (MIT)
//  Copyright (c) 2016 Denis Bogatyrev.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import "UIImage+DBAssetIcons.h"

@implementation UIImage (DBAssetIcons)

#pragma mark Cache

static UIImage* _imageOfSmartAlbumBurstsIcon = nil;
static UIImage* _imageOfSmartAlbumSlomoVideosIcon = nil;
static UIImage* _imageOfSmartAlbumTimelapsesIcon = nil;
static UIImage* _imageOfSmartAlbumVideosIcon = nil;
static UIImage* _imageOfSmartAlbumPanoramasIcon = nil;
static UIImage* _imageOfSmartAlbumSelfPortraitsIcon = nil;
static UIImage* _imageOfSmartAlbumFavoritesIcon = nil;
static UIImage* _imageOfSmartAlbumScreenshotsIcon = nil;
static UIImage* _imageOfVideoTimelapseIcon = nil;
static UIImage* _imageOfVideoHighFrameRateIcon = nil;
static UIImage* _imageOfVideoIcon = nil;
static UIImage* _imageOfSelectorOffIcon = nil;

#pragma mark Drawing Methods

+ (void)drawSmartAlbumBurstsIcon
{
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Group
    {
        //// Rectangle Drawing
        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 11, 48, 35) cornerRadius: 1];
        [color setFill];
        [rectanglePath fill];
        
        
        //// Rectangle 2 Drawing
        UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(4, 7, 41, 3) byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: CGSizeMake(1, 1)];
        [rectangle2Path closePath];
        [color setFill];
        [rectangle2Path fill];
        
        
        //// Rectangle 3 Drawing
        UIBezierPath* rectangle3Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(7, 4, 35, 2) byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: CGSizeMake(1, 1)];
        [rectangle3Path closePath];
        [color setFill];
        [rectangle3Path fill];
    }
}

+ (void)drawSmartAlbumSlomoVideosIcon
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// short15 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, 15 * M_PI / 180);
    
    UIBezierPath* short15Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -22, 2, 2) cornerRadius: 1];
    [color setFill];
    [short15Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// short45 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, 45 * M_PI / 180);
    
    UIBezierPath* short45Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -22, 2, 2) cornerRadius: 1];
    [color setFill];
    [short45Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// short75 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, 75 * M_PI / 180);
    
    UIBezierPath* short75Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -22, 2, 2) cornerRadius: 1];
    [color setFill];
    [short75Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// short105 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, 105 * M_PI / 180);
    
    UIBezierPath* short105Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -22, 2, 2) cornerRadius: 1];
    [color setFill];
    [short105Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// short135 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, 135 * M_PI / 180);
    
    UIBezierPath* short135Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -22, 2, 2) cornerRadius: 1];
    [color setFill];
    [short135Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// short165 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, 165 * M_PI / 180);
    
    UIBezierPath* short165Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -22, 2, 2) cornerRadius: 1];
    [color setFill];
    [short165Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// short195 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -165 * M_PI / 180);
    
    UIBezierPath* short195Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -22, 2, 2) cornerRadius: 1];
    [color setFill];
    [short195Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// short225 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -135 * M_PI / 180);
    
    UIBezierPath* short225Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -22, 2, 2) cornerRadius: 1];
    [color setFill];
    [short225Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// short255 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -105 * M_PI / 180);
    
    UIBezierPath* short255Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -22, 2, 2) cornerRadius: 1];
    [color setFill];
    [short255Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// short285 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -75 * M_PI / 180);
    
    UIBezierPath* short285Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -22, 2, 2) cornerRadius: 1];
    [color setFill];
    [short285Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// short315 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -45 * M_PI / 180);
    
    UIBezierPath* short315Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -22, 2, 2) cornerRadius: 1];
    [color setFill];
    [short315Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// short345 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -15 * M_PI / 180);
    
    UIBezierPath* short345Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -22, 2, 2) cornerRadius: 1];
    [color setFill];
    [short345Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// long0 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    
    UIBezierPath* long0Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -22, 3, 8) cornerRadius: 1];
    [color setFill];
    [long0Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// long30 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, 30 * M_PI / 180);
    
    UIBezierPath* long30Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -22, 3, 8) cornerRadius: 1];
    [color setFill];
    [long30Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// long60 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, 60 * M_PI / 180);
    
    UIBezierPath* long60Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -22, 3, 8) cornerRadius: 1];
    [color setFill];
    [long60Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// long90 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, 90 * M_PI / 180);
    
    UIBezierPath* long90Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -22, 3, 8) cornerRadius: 1];
    [color setFill];
    [long90Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// long120 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, 120 * M_PI / 180);
    
    UIBezierPath* long120Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -22, 3, 8) cornerRadius: 1];
    [color setFill];
    [long120Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// long150 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, 150 * M_PI / 180);
    
    UIBezierPath* long150Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -22, 3, 8) cornerRadius: 1];
    [color setFill];
    [long150Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// long180 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -180 * M_PI / 180);
    
    UIBezierPath* long180Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -22, 3, 8) cornerRadius: 1];
    [color setFill];
    [long180Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// long210 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -150 * M_PI / 180);
    
    UIBezierPath* long210Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -22, 3, 8) cornerRadius: 1];
    [color setFill];
    [long210Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// long240 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -120 * M_PI / 180);
    
    UIBezierPath* long240Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -22, 3, 8) cornerRadius: 1];
    [color setFill];
    [long240Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// long270 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -90 * M_PI / 180);
    
    UIBezierPath* long270Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -22, 3, 8) cornerRadius: 1];
    [color setFill];
    [long270Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// long300 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -60 * M_PI / 180);
    
    UIBezierPath* long300Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -22, 3, 8) cornerRadius: 1];
    [color setFill];
    [long300Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// long330 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -30 * M_PI / 180);
    
    UIBezierPath* long330Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -22, 3, 8) cornerRadius: 1];
    [color setFill];
    [long330Path fill];
    
    CGContextRestoreGState(context);
}

+ (void)drawSmartAlbumTimelapsesIcon
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Group
    {
        //// Rectangle Drawing
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 24, 24);
        
        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -22.5, 3, 6) cornerRadius: 1];
        [color setFill];
        [rectanglePath fill];
        
        CGContextRestoreGState(context);
        
        
        //// Rectangle 2 Drawing
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 24, 24);
        CGContextRotateCTM(context, 30 * M_PI / 180);
        
        UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -22.5, 3, 6) cornerRadius: 1];
        [color setFill];
        [rectangle2Path fill];
        
        CGContextRestoreGState(context);
        
        
        //// Rectangle 3 Drawing
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 24, 24);
        CGContextRotateCTM(context, 60 * M_PI / 180);
        
        UIBezierPath* rectangle3Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -22.5, 3, 6) cornerRadius: 1];
        [color setFill];
        [rectangle3Path fill];
        
        CGContextRestoreGState(context);
        
        
        //// Rectangle 4 Drawing
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 24, 24);
        CGContextRotateCTM(context, 90 * M_PI / 180);
        
        UIBezierPath* rectangle4Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -22.5, 3, 6) cornerRadius: 1];
        [color setFill];
        [rectangle4Path fill];
        
        CGContextRestoreGState(context);
        
        
        //// Rectangle 5 Drawing
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 24, 24);
        CGContextRotateCTM(context, 120 * M_PI / 180);
        
        UIBezierPath* rectangle5Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -22.5, 3, 6) cornerRadius: 1];
        [color setFill];
        [rectangle5Path fill];
        
        CGContextRestoreGState(context);
        
        
        //// Rectangle 6 Drawing
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 24, 24);
        CGContextRotateCTM(context, 150 * M_PI / 180);
        
        UIBezierPath* rectangle6Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -22.5, 3, 6) cornerRadius: 1];
        [color setFill];
        [rectangle6Path fill];
        
        CGContextRestoreGState(context);
        
        
        //// Rectangle 7 Drawing
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 24, 24);
        CGContextRotateCTM(context, -180 * M_PI / 180);
        
        UIBezierPath* rectangle7Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -22.5, 3, 6) cornerRadius: 1];
        [color setFill];
        [rectangle7Path fill];
        
        CGContextRestoreGState(context);
        
        
        //// Rectangle 8 Drawing
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 24, 24);
        CGContextRotateCTM(context, -150 * M_PI / 180);
        
        UIBezierPath* rectangle8Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -22.5, 3, 6) cornerRadius: 1];
        [color setFill];
        [rectangle8Path fill];
        
        CGContextRestoreGState(context);
        
        
        //// Rectangle 9 Drawing
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 24, 24);
        CGContextRotateCTM(context, -120 * M_PI / 180);
        
        UIBezierPath* rectangle9Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -22.5, 3, 6) cornerRadius: 1];
        [color setFill];
        [rectangle9Path fill];
        
        CGContextRestoreGState(context);
        
        
        //// Rectangle 10 Drawing
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 24, 24);
        CGContextRotateCTM(context, -90 * M_PI / 180);
        
        UIBezierPath* rectangle10Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -22.5, 3, 6) cornerRadius: 1];
        [color setFill];
        [rectangle10Path fill];
        
        CGContextRestoreGState(context);
        
        
        //// Rectangle 11 Drawing
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 24, 24);
        CGContextRotateCTM(context, -60 * M_PI / 180);
        
        UIBezierPath* rectangle11Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -22.5, 3, 6) cornerRadius: 1];
        [color setFill];
        [rectangle11Path fill];
        
        CGContextRestoreGState(context);
        
        
        //// Rectangle 12 Drawing
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 24, 24);
        CGContextRotateCTM(context, -30 * M_PI / 180);
        
        UIBezierPath* rectangle12Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -22.5, 3, 6) cornerRadius: 1];
        [color setFill];
        [rectangle12Path fill];
        
        CGContextRestoreGState(context);
    }
}

+ (void)drawSmartAlbumVideosIcon
{
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Group
    {
        //// Rectangle Drawing
        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 11, 34, 27) cornerRadius: 5];
        [color setFill];
        [rectanglePath fill];
        
        
        //// Bezier Drawing
        UIBezierPath* bezierPath = UIBezierPath.bezierPath;
        [bezierPath moveToPoint: CGPointMake(36, 21.38)];
        [bezierPath addLineToPoint: CGPointMake(48, 11)];
        [bezierPath addLineToPoint: CGPointMake(48, 38)];
        [bezierPath addLineToPoint: CGPointMake(36, 27.62)];
        [bezierPath addLineToPoint: CGPointMake(36, 21.38)];
        [bezierPath closePath];
        [color setFill];
        [bezierPath fill];
    }
}

+ (void)drawSmartAlbumPanoramasIcon
{
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = UIBezierPath.bezierPath;
    [rectanglePath moveToPoint: CGPointMake(2, 38)];
    [rectanglePath addLineToPoint: CGPointMake(7, 35)];
    [rectanglePath addLineToPoint: CGPointMake(13, 33)];
    [rectanglePath addLineToPoint: CGPointMake(20, 32)];
    [rectanglePath addLineToPoint: CGPointMake(28, 32)];
    [rectanglePath addLineToPoint: CGPointMake(35, 33)];
    [rectanglePath addLineToPoint: CGPointMake(41, 35)];
    [rectanglePath addLineToPoint: CGPointMake(46, 38)];
    [rectanglePath addLineToPoint: CGPointMake(46, 11)];
    [rectanglePath addLineToPoint: CGPointMake(41, 14)];
    [rectanglePath addLineToPoint: CGPointMake(35, 16)];
    [rectanglePath addLineToPoint: CGPointMake(28, 17)];
    [rectanglePath addLineToPoint: CGPointMake(20, 17)];
    [rectanglePath addLineToPoint: CGPointMake(13, 16)];
    [rectanglePath addLineToPoint: CGPointMake(7, 14)];
    [rectanglePath addLineToPoint: CGPointMake(2, 11)];
    [rectanglePath addLineToPoint: CGPointMake(2, 38)];
    [rectanglePath closePath];
    [color setFill];
    [rectanglePath fill];
}

+ (void)drawSmartAlbumSelfPortraitsIcon
{
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Rectangle 2 Drawing
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(6, 12, 4, 2)];
    [color setFill];
    [rectangle2Path fill];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
    [bezier2Path moveToPoint: CGPointMake(24, 17.5)];
    [bezier2Path addCurveToPoint: CGPointMake(14.8, 22) controlPoint1: CGPointMake(20.23, 17.5) controlPoint2: CGPointMake(16.5, 18.87)];
    [bezier2Path addCurveToPoint: CGPointMake(13.5, 28) controlPoint1: CGPointMake(14.02, 23.44) controlPoint2: CGPointMake(13.5, 25.79)];
    [bezier2Path addCurveToPoint: CGPointMake(23, 37.5) controlPoint1: CGPointMake(13.5, 35) controlPoint2: CGPointMake(19, 37.5)];
    [bezier2Path addLineToPoint: CGPointMake(25.5, 37.5)];
    [bezier2Path addCurveToPoint: CGPointMake(25.5, 35.5) controlPoint1: CGPointMake(25.5, 37.43) controlPoint2: CGPointMake(25.5, 35.5)];
    [bezier2Path addLineToPoint: CGPointMake(23, 35.5)];
    [bezier2Path addCurveToPoint: CGPointMake(15.5, 28) controlPoint1: CGPointMake(17.5, 35.5) controlPoint2: CGPointMake(15.5, 31.5)];
    [bezier2Path addCurveToPoint: CGPointMake(16.38, 23.58) controlPoint1: CGPointMake(15.5, 26.39) controlPoint2: CGPointMake(15.76, 24.88)];
    [bezier2Path addCurveToPoint: CGPointMake(24, 19.5) controlPoint1: CGPointMake(17.69, 20.84) controlPoint2: CGPointMake(19.93, 19.5)];
    [bezier2Path addCurveToPoint: CGPointMake(31.5, 27) controlPoint1: CGPointMake(30, 19.5) controlPoint2: CGPointMake(31.5, 23)];
    [bezier2Path addCurveToPoint: CGPointMake(31.5, 27.5) controlPoint1: CGPointMake(31.5, 28) controlPoint2: CGPointMake(31.5, 27.5)];
    [bezier2Path addLineToPoint: CGPointMake(28, 27.5)];
    [bezier2Path addLineToPoint: CGPointMake(32.5, 35)];
    [bezier2Path addLineToPoint: CGPointMake(37, 27.5)];
    [bezier2Path addLineToPoint: CGPointMake(33.5, 27.5)];
    [bezier2Path addCurveToPoint: CGPointMake(33.5, 27) controlPoint1: CGPointMake(33.5, 27.5) controlPoint2: CGPointMake(33.5, 29)];
    [bezier2Path addCurveToPoint: CGPointMake(24, 17.5) controlPoint1: CGPointMake(33.5, 21.5) controlPoint2: CGPointMake(29.5, 17.5)];
    [bezier2Path closePath];
    [bezier2Path moveToPoint: CGPointMake(29, 10)];
    [bezier2Path addLineToPoint: CGPointMake(34, 15)];
    [bezier2Path addLineToPoint: CGPointMake(38.89, 15)];
    [bezier2Path addCurveToPoint: CGPointMake(42.32, 15.26) controlPoint1: CGPointMake(40.65, 15) controlPoint2: CGPointMake(41.53, 15)];
    [bezier2Path addLineToPoint: CGPointMake(42.47, 15.3)];
    [bezier2Path addCurveToPoint: CGPointMake(44.7, 17.53) controlPoint1: CGPointMake(43.51, 15.68) controlPoint2: CGPointMake(44.32, 16.49)];
    [bezier2Path addCurveToPoint: CGPointMake(45, 21.11) controlPoint1: CGPointMake(45, 18.47) controlPoint2: CGPointMake(45, 19.35)];
    [bezier2Path addLineToPoint: CGPointMake(45, 36.89)];
    [bezier2Path addCurveToPoint: CGPointMake(44.74, 40.32) controlPoint1: CGPointMake(45, 38.65) controlPoint2: CGPointMake(45, 39.53)];
    [bezier2Path addLineToPoint: CGPointMake(44.7, 40.47)];
    [bezier2Path addCurveToPoint: CGPointMake(42.47, 42.7) controlPoint1: CGPointMake(44.32, 41.51) controlPoint2: CGPointMake(43.51, 42.32)];
    [bezier2Path addCurveToPoint: CGPointMake(38.89, 43) controlPoint1: CGPointMake(41.53, 43) controlPoint2: CGPointMake(40.65, 43)];
    [bezier2Path addLineToPoint: CGPointMake(8.11, 43)];
    [bezier2Path addCurveToPoint: CGPointMake(4.68, 42.74) controlPoint1: CGPointMake(6.35, 43) controlPoint2: CGPointMake(5.47, 43)];
    [bezier2Path addLineToPoint: CGPointMake(4.53, 42.7)];
    [bezier2Path addCurveToPoint: CGPointMake(2.3, 40.47) controlPoint1: CGPointMake(3.49, 42.32) controlPoint2: CGPointMake(2.68, 41.51)];
    [bezier2Path addCurveToPoint: CGPointMake(2, 36.89) controlPoint1: CGPointMake(2, 39.53) controlPoint2: CGPointMake(2, 38.65)];
    [bezier2Path addLineToPoint: CGPointMake(2, 21.11)];
    [bezier2Path addCurveToPoint: CGPointMake(2.26, 17.68) controlPoint1: CGPointMake(2, 19.35) controlPoint2: CGPointMake(2, 18.47)];
    [bezier2Path addLineToPoint: CGPointMake(2.3, 17.53)];
    [bezier2Path addCurveToPoint: CGPointMake(4.53, 15.3) controlPoint1: CGPointMake(2.68, 16.49) controlPoint2: CGPointMake(3.49, 15.68)];
    [bezier2Path addCurveToPoint: CGPointMake(8.11, 15) controlPoint1: CGPointMake(5.47, 15) controlPoint2: CGPointMake(6.35, 15)];
    [bezier2Path addLineToPoint: CGPointMake(13, 15)];
    [bezier2Path addLineToPoint: CGPointMake(18, 10)];
    [bezier2Path addLineToPoint: CGPointMake(29, 10)];
    [bezier2Path closePath];
    [color setFill];
    [bezier2Path fill];
}

+ (void)drawSmartAlbumFavoritesIcon
{
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(24, 45)];
    [bezierPath addLineToPoint: CGPointMake(3.5, 24)];
    [bezierPath addCurveToPoint: CGPointMake(1.5, 16) controlPoint1: CGPointMake(2, 22) controlPoint2: CGPointMake(1.5, 21)];
    [bezierPath addCurveToPoint: CGPointMake(12.5, 5) controlPoint1: CGPointMake(1.5, 11) controlPoint2: CGPointMake(4.5, 5)];
    [bezierPath addCurveToPoint: CGPointMake(24, 12) controlPoint1: CGPointMake(20.5, 5) controlPoint2: CGPointMake(24, 12)];
    [bezierPath addCurveToPoint: CGPointMake(35.5, 5) controlPoint1: CGPointMake(24, 12) controlPoint2: CGPointMake(26.5, 5)];
    [bezierPath addCurveToPoint: CGPointMake(46.5, 16) controlPoint1: CGPointMake(44.5, 5) controlPoint2: CGPointMake(46.5, 10)];
    [bezierPath addCurveToPoint: CGPointMake(44.5, 24) controlPoint1: CGPointMake(46.5, 21.5) controlPoint2: CGPointMake(44.5, 24)];
    [bezierPath addLineToPoint: CGPointMake(24, 45)];
    [bezierPath closePath];
    [color setFill];
    [bezierPath fill];
}

+ (void)drawSmartAlbumScreenshotsIcon
{
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(25.47, 4.5)];
    [bezierPath addLineToPoint: CGPointMake(21.75, 4.5)];
    [bezierPath addCurveToPoint: CGPointMake(21.31, 4.54) controlPoint1: CGPointMake(21.5, 4.5) controlPoint2: CGPointMake(21.41, 4.51)];
    [bezierPath addCurveToPoint: CGPointMake(21, 4.97) controlPoint1: CGPointMake(21.12, 4.6) controlPoint2: CGPointMake(21, 4.78)];
    [bezierPath addCurveToPoint: CGPointMake(21.31, 5.46) controlPoint1: CGPointMake(21, 5.22) controlPoint2: CGPointMake(21.12, 5.4)];
    [bezierPath addCurveToPoint: CGPointMake(22.53, 5.5) controlPoint1: CGPointMake(21.42, 5.5) controlPoint2: CGPointMake(21.53, 5.5)];
    [bezierPath addLineToPoint: CGPointMake(26.25, 5.5)];
    [bezierPath addCurveToPoint: CGPointMake(26.69, 5.46) controlPoint1: CGPointMake(26.47, 5.5) controlPoint2: CGPointMake(26.58, 5.5)];
    [bezierPath addCurveToPoint: CGPointMake(27, 5.02) controlPoint1: CGPointMake(26.88, 5.4) controlPoint2: CGPointMake(27, 5.22)];
    [bezierPath addCurveToPoint: CGPointMake(26.69, 4.54) controlPoint1: CGPointMake(27, 4.78) controlPoint2: CGPointMake(26.88, 4.6)];
    [bezierPath addCurveToPoint: CGPointMake(25.47, 4.5) controlPoint1: CGPointMake(26.58, 4.5) controlPoint2: CGPointMake(26.47, 4.5)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(31.97, 7.5)];
    [bezierPath addLineToPoint: CGPointMake(16.03, 7.5)];
    [bezierPath addCurveToPoint: CGPointMake(15.13, 7.57) controlPoint1: CGPointMake(15.59, 7.5) controlPoint2: CGPointMake(15.37, 7.5)];
    [bezierPath addCurveToPoint: CGPointMake(14.57, 8.13) controlPoint1: CGPointMake(14.87, 7.67) controlPoint2: CGPointMake(14.67, 7.87)];
    [bezierPath addCurveToPoint: CGPointMake(14.5, 9.03) controlPoint1: CGPointMake(14.5, 8.37) controlPoint2: CGPointMake(14.5, 8.59)];
    [bezierPath addLineToPoint: CGPointMake(14.5, 36.97)];
    [bezierPath addCurveToPoint: CGPointMake(14.57, 37.87) controlPoint1: CGPointMake(14.5, 37.41) controlPoint2: CGPointMake(14.5, 37.63)];
    [bezierPath addCurveToPoint: CGPointMake(15.13, 38.43) controlPoint1: CGPointMake(14.67, 38.13) controlPoint2: CGPointMake(14.87, 38.33)];
    [bezierPath addCurveToPoint: CGPointMake(16.03, 38.5) controlPoint1: CGPointMake(15.37, 38.5) controlPoint2: CGPointMake(15.59, 38.5)];
    [bezierPath addLineToPoint: CGPointMake(31.97, 38.5)];
    [bezierPath addCurveToPoint: CGPointMake(32.87, 38.43) controlPoint1: CGPointMake(32.41, 38.5) controlPoint2: CGPointMake(32.63, 38.5)];
    [bezierPath addCurveToPoint: CGPointMake(33.43, 37.87) controlPoint1: CGPointMake(33.13, 38.33) controlPoint2: CGPointMake(33.33, 38.13)];
    [bezierPath addCurveToPoint: CGPointMake(33.5, 36.97) controlPoint1: CGPointMake(33.5, 37.63) controlPoint2: CGPointMake(33.5, 37.41)];
    [bezierPath addLineToPoint: CGPointMake(33.5, 9.03)];
    [bezierPath addCurveToPoint: CGPointMake(33.43, 8.13) controlPoint1: CGPointMake(33.5, 8.59) controlPoint2: CGPointMake(33.5, 8.37)];
    [bezierPath addCurveToPoint: CGPointMake(32.87, 7.57) controlPoint1: CGPointMake(33.33, 7.87) controlPoint2: CGPointMake(33.13, 7.67)];
    [bezierPath addCurveToPoint: CGPointMake(31.97, 7.5) controlPoint1: CGPointMake(32.63, 7.5) controlPoint2: CGPointMake(32.41, 7.5)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(24, 40.5)];
    [bezierPath addCurveToPoint: CGPointMake(22, 42.5) controlPoint1: CGPointMake(22.9, 40.5) controlPoint2: CGPointMake(22, 41.4)];
    [bezierPath addCurveToPoint: CGPointMake(24, 44.5) controlPoint1: CGPointMake(22, 43.6) controlPoint2: CGPointMake(22.9, 44.5)];
    [bezierPath addCurveToPoint: CGPointMake(26, 42.5) controlPoint1: CGPointMake(25.1, 44.5) controlPoint2: CGPointMake(26, 43.6)];
    [bezierPath addCurveToPoint: CGPointMake(24, 40.5) controlPoint1: CGPointMake(26, 41.4) controlPoint2: CGPointMake(25.1, 40.5)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(31.48, 1.89)];
    [bezierPath addLineToPoint: CGPointMake(31.71, 1.95)];
    [bezierPath addCurveToPoint: CGPointMake(35.05, 5.29) controlPoint1: CGPointMake(33.26, 2.51) controlPoint2: CGPointMake(34.49, 3.74)];
    [bezierPath addCurveToPoint: CGPointMake(35.5, 10.67) controlPoint1: CGPointMake(35.5, 6.71) controlPoint2: CGPointMake(35.5, 8.03)];
    [bezierPath addLineToPoint: CGPointMake(35.5, 37.33)];
    [bezierPath addCurveToPoint: CGPointMake(35.11, 42.48) controlPoint1: CGPointMake(35.5, 39.97) controlPoint2: CGPointMake(35.5, 41.29)];
    [bezierPath addLineToPoint: CGPointMake(35.05, 42.71)];
    [bezierPath addCurveToPoint: CGPointMake(31.71, 46.05) controlPoint1: CGPointMake(34.49, 44.26) controlPoint2: CGPointMake(33.26, 45.49)];
    [bezierPath addCurveToPoint: CGPointMake(26.33, 46.5) controlPoint1: CGPointMake(30.29, 46.5) controlPoint2: CGPointMake(28.97, 46.5)];
    [bezierPath addLineToPoint: CGPointMake(21.67, 46.5)];
    [bezierPath addCurveToPoint: CGPointMake(16.52, 46.11) controlPoint1: CGPointMake(19.03, 46.5) controlPoint2: CGPointMake(17.71, 46.5)];
    [bezierPath addLineToPoint: CGPointMake(16.29, 46.05)];
    [bezierPath addCurveToPoint: CGPointMake(12.95, 42.71) controlPoint1: CGPointMake(14.74, 45.49) controlPoint2: CGPointMake(13.51, 44.26)];
    [bezierPath addCurveToPoint: CGPointMake(12.5, 37.33) controlPoint1: CGPointMake(12.5, 41.29) controlPoint2: CGPointMake(12.5, 39.97)];
    [bezierPath addLineToPoint: CGPointMake(12.5, 10.67)];
    [bezierPath addCurveToPoint: CGPointMake(12.76, 6) controlPoint1: CGPointMake(12.5, 8.38) controlPoint2: CGPointMake(12.5, 7.08)];
    [bezierPath addCurveToPoint: CGPointMake(12.89, 5.52) controlPoint1: CGPointMake(12.8, 5.84) controlPoint2: CGPointMake(12.84, 5.68)];
    [bezierPath addLineToPoint: CGPointMake(12.95, 5.29)];
    [bezierPath addCurveToPoint: CGPointMake(14.51, 3.01) controlPoint1: CGPointMake(13.27, 4.4) controlPoint2: CGPointMake(13.81, 3.62)];
    [bezierPath addCurveToPoint: CGPointMake(16.29, 1.95) controlPoint1: CGPointMake(15.02, 2.55) controlPoint2: CGPointMake(15.63, 2.19)];
    [bezierPath addCurveToPoint: CGPointMake(21.67, 1.5) controlPoint1: CGPointMake(17.71, 1.5) controlPoint2: CGPointMake(19.03, 1.5)];
    [bezierPath addLineToPoint: CGPointMake(26.33, 1.5)];
    [bezierPath addCurveToPoint: CGPointMake(31.48, 1.89) controlPoint1: CGPointMake(28.97, 1.5) controlPoint2: CGPointMake(30.29, 1.5)];
    [bezierPath closePath];
    [color setFill];
    [bezierPath fill];
}

+ (void)drawVideoTimelapseIcon
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Rectangle Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -19, 2, 6) cornerRadius: 1];
    [color setFill];
    [rectanglePath fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 2 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -15 * M_PI / 180);
    
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -19, 2, 6) cornerRadius: 1];
    [color setFill];
    [rectangle2Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 3 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -30 * M_PI / 180);
    
    UIBezierPath* rectangle3Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -19, 2, 6) cornerRadius: 1];
    [color setFill];
    [rectangle3Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 4 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -45 * M_PI / 180);
    
    UIBezierPath* rectangle4Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -19, 2, 6) cornerRadius: 1];
    [color setFill];
    [rectangle4Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 5 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -60 * M_PI / 180);
    
    UIBezierPath* rectangle5Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -19, 2, 6) cornerRadius: 1];
    [color setFill];
    [rectangle5Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 6 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -75 * M_PI / 180);
    
    UIBezierPath* rectangle6Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -19, 2, 6) cornerRadius: 1];
    [color setFill];
    [rectangle6Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 7 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -90 * M_PI / 180);
    
    UIBezierPath* rectangle7Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -19, 2, 6) cornerRadius: 1];
    [color setFill];
    [rectangle7Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 8 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -105 * M_PI / 180);
    
    UIBezierPath* rectangle8Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -19, 2, 6) cornerRadius: 1];
    [color setFill];
    [rectangle8Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 9 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -120 * M_PI / 180);
    
    UIBezierPath* rectangle9Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -19, 2, 6) cornerRadius: 1];
    [color setFill];
    [rectangle9Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 10 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -135 * M_PI / 180);
    
    UIBezierPath* rectangle10Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -19, 2, 6) cornerRadius: 1];
    [color setFill];
    [rectangle10Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 11 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -150 * M_PI / 180);
    
    UIBezierPath* rectangle11Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -19, 2, 6) cornerRadius: 1];
    [color setFill];
    [rectangle11Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 12 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -165 * M_PI / 180);
    
    UIBezierPath* rectangle12Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -19, 2, 6) cornerRadius: 1];
    [color setFill];
    [rectangle12Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 13 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -180 * M_PI / 180);
    
    UIBezierPath* rectangle13Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -19, 2, 6) cornerRadius: 1];
    [color setFill];
    [rectangle13Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 14 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -195 * M_PI / 180);
    
    UIBezierPath* rectangle14Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -19, 2, 6) cornerRadius: 1];
    [color setFill];
    [rectangle14Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 15 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -210 * M_PI / 180);
    
    UIBezierPath* rectangle15Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -19, 2, 6) cornerRadius: 1];
    [color setFill];
    [rectangle15Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 16 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -225 * M_PI / 180);
    
    UIBezierPath* rectangle16Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -19, 2, 6) cornerRadius: 1];
    [color setFill];
    [rectangle16Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 17 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -240 * M_PI / 180);
    
    UIBezierPath* rectangle17Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -19, 2, 6) cornerRadius: 1];
    [color setFill];
    [rectangle17Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 18 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -255 * M_PI / 180);
    
    UIBezierPath* rectangle18Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -19, 2, 6) cornerRadius: 1];
    [color setFill];
    [rectangle18Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 19 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -270 * M_PI / 180);
    
    UIBezierPath* rectangle19Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -19, 2, 6) cornerRadius: 1];
    [color setFill];
    [rectangle19Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 20 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -285 * M_PI / 180);
    
    UIBezierPath* rectangle20Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -19, 2, 6) cornerRadius: 1];
    [color setFill];
    [rectangle20Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 21 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -300 * M_PI / 180);
    
    UIBezierPath* rectangle21Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -19, 2, 6) cornerRadius: 1];
    [color setFill];
    [rectangle21Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 22 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -315 * M_PI / 180);
    
    UIBezierPath* rectangle22Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -19, 2, 6) cornerRadius: 1];
    [color setFill];
    [rectangle22Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 23 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -330 * M_PI / 180);
    
    UIBezierPath* rectangle23Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -19, 2, 6) cornerRadius: 1];
    [color setFill];
    [rectangle23Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 24 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -345 * M_PI / 180);
    
    UIBezierPath* rectangle24Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1, -19, 2, 6) cornerRadius: 1];
    [color setFill];
    [rectangle24Path fill];
    
    CGContextRestoreGState(context);
}

+ (void)drawVideoHighFrameRateIcon
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Rectangle Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -19.5, 3, 8) cornerRadius: 1];
    [color setFill];
    [rectanglePath fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 2 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -90 * M_PI / 180);
    
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -19.5, 3, 8) cornerRadius: 1];
    [color setFill];
    [rectangle2Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 3 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -180 * M_PI / 180);
    
    UIBezierPath* rectangle3Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -19.5, 3, 8) cornerRadius: 1];
    [color setFill];
    [rectangle3Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 4 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -270 * M_PI / 180);
    
    UIBezierPath* rectangle4Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -19.5, 3, 8) cornerRadius: 1];
    [color setFill];
    [rectangle4Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 5 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -45 * M_PI / 180);
    
    UIBezierPath* rectangle5Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -19.5, 3, 11) cornerRadius: 1];
    [color setFill];
    [rectangle5Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 6 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -135 * M_PI / 180);
    
    UIBezierPath* rectangle6Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -19.5, 3, 11) cornerRadius: 1];
    [color setFill];
    [rectangle6Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 7 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -225 * M_PI / 180);
    
    UIBezierPath* rectangle7Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -19.5, 3, 11) cornerRadius: 1];
    [color setFill];
    [rectangle7Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 8 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, 45 * M_PI / 180);
    
    UIBezierPath* rectangle8Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -19.5, 3, 11) cornerRadius: 1];
    [color setFill];
    [rectangle8Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 9 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -22.5 * M_PI / 180);
    
    UIBezierPath* rectangle9Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -19.5, 3, 5) cornerRadius: 1];
    [color setFill];
    [rectangle9Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 10 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -112.5 * M_PI / 180);
    
    UIBezierPath* rectangle10Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -19.5, 3, 5) cornerRadius: 1];
    [color setFill];
    [rectangle10Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 11 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -202.5 * M_PI / 180);
    
    UIBezierPath* rectangle11Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -19.5, 3, 5) cornerRadius: 1];
    [color setFill];
    [rectangle11Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 12 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, 67.5 * M_PI / 180);
    
    UIBezierPath* rectangle12Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -19.5, 3, 5) cornerRadius: 1];
    [color setFill];
    [rectangle12Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 13 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -67.5 * M_PI / 180);
    
    UIBezierPath* rectangle13Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -19.5, 3, 5) cornerRadius: 1];
    [color setFill];
    [rectangle13Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 14 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, -157.5 * M_PI / 180);
    
    UIBezierPath* rectangle14Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -19.5, 3, 5) cornerRadius: 1];
    [color setFill];
    [rectangle14Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 15 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, 112.5 * M_PI / 180);
    
    UIBezierPath* rectangle15Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -19.5, 3, 5) cornerRadius: 1];
    [color setFill];
    [rectangle15Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Rectangle 16 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 24, 24);
    CGContextRotateCTM(context, 22.5 * M_PI / 180);
    
    UIBezierPath* rectangle16Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(-1.5, -19.5, 3, 5) cornerRadius: 1];
    [color setFill];
    [rectangle16Path fill];
    
    CGContextRestoreGState(context);
}

+ (void)drawVideoIcon
{
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(3, 11.5, 27, 24) cornerRadius: 5];
    [color setFill];
    [rectanglePath fill];
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(33, 22.5)];
    [bezierPath addLineToPoint: CGPointMake(45, 12)];
    [bezierPath addLineToPoint: CGPointMake(45, 35)];
    [bezierPath addLineToPoint: CGPointMake(33, 24.5)];
    [bezierPath addLineToPoint: CGPointMake(33, 22.5)];
    [bezierPath closePath];
    [color setFill];
    [bezierPath fill];
}

#pragma mark Generated Images

+ (UIImage*)imageOfSmartAlbumBurstsIcon
{
    if (_imageOfSmartAlbumBurstsIcon)
        return _imageOfSmartAlbumBurstsIcon;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(48, 48), NO, 0.0f);
    [self drawSmartAlbumBurstsIcon];
    
    _imageOfSmartAlbumBurstsIcon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfSmartAlbumBurstsIcon;
}

+ (UIImage*)imageOfSmartAlbumSlomoVideosIcon
{
    if (_imageOfSmartAlbumSlomoVideosIcon)
        return _imageOfSmartAlbumSlomoVideosIcon;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(48, 48), NO, 0.0f);
    [self drawSmartAlbumSlomoVideosIcon];
    
    _imageOfSmartAlbumSlomoVideosIcon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfSmartAlbumSlomoVideosIcon;
}

+ (UIImage*)imageOfSmartAlbumTimelapsesIcon
{
    if (_imageOfSmartAlbumTimelapsesIcon)
        return _imageOfSmartAlbumTimelapsesIcon;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(48, 48), NO, 0.0f);
    [self drawSmartAlbumTimelapsesIcon];
    
    _imageOfSmartAlbumTimelapsesIcon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfSmartAlbumTimelapsesIcon;
}

+ (UIImage*)imageOfSmartAlbumVideosIcon
{
    if (_imageOfSmartAlbumVideosIcon)
        return _imageOfSmartAlbumVideosIcon;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(48, 48), NO, 0.0f);
    [self drawSmartAlbumVideosIcon];
    
    _imageOfSmartAlbumVideosIcon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfSmartAlbumVideosIcon;
}

+ (UIImage*)imageOfSmartAlbumPanoramasIcon
{
    if (_imageOfSmartAlbumPanoramasIcon)
        return _imageOfSmartAlbumPanoramasIcon;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(48, 48), NO, 0.0f);
    [self drawSmartAlbumPanoramasIcon];
    
    _imageOfSmartAlbumPanoramasIcon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfSmartAlbumPanoramasIcon;
}

+ (UIImage*)imageOfSmartAlbumSelfPortraitsIcon
{
    if (_imageOfSmartAlbumSelfPortraitsIcon)
        return _imageOfSmartAlbumSelfPortraitsIcon;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(48, 48), NO, 0.0f);
    [self drawSmartAlbumSelfPortraitsIcon];
    
    _imageOfSmartAlbumSelfPortraitsIcon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfSmartAlbumSelfPortraitsIcon;
}

+ (UIImage*)imageOfSmartAlbumFavoritesIcon
{
    if (_imageOfSmartAlbumFavoritesIcon)
        return _imageOfSmartAlbumFavoritesIcon;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(48, 48), NO, 0.0f);
    [self drawSmartAlbumFavoritesIcon];
    
    _imageOfSmartAlbumFavoritesIcon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfSmartAlbumFavoritesIcon;
}

+ (UIImage*)imageOfSmartAlbumScreenshotsIcon
{
    if (_imageOfSmartAlbumScreenshotsIcon)
        return _imageOfSmartAlbumScreenshotsIcon;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(48, 48), NO, 0.0f);
    [self drawSmartAlbumScreenshotsIcon];
    
    _imageOfSmartAlbumScreenshotsIcon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfSmartAlbumScreenshotsIcon;
}

+ (UIImage*)imageOfVideoTimelapseIcon
{
    if (_imageOfVideoTimelapseIcon)
        return _imageOfVideoTimelapseIcon;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(48, 48), NO, 0.0f);
    [self drawVideoTimelapseIcon];
    
    _imageOfVideoTimelapseIcon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfVideoTimelapseIcon;
}

+ (UIImage*)imageOfVideoHighFrameRateIcon
{
    if (_imageOfVideoHighFrameRateIcon)
        return _imageOfVideoHighFrameRateIcon;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(48, 48), NO, 0.0f);
    [self drawVideoHighFrameRateIcon];
    
    _imageOfVideoHighFrameRateIcon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfVideoHighFrameRateIcon;
}

+ (UIImage*)imageOfVideoIcon
{
    if (_imageOfVideoIcon)
        return _imageOfVideoIcon;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(48, 48), NO, 0.0f);
    [self drawVideoIcon];
    
    _imageOfVideoIcon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfVideoIcon;
}

#pragma mark - Selector

+ (void)drawSelectorOnIconWithTintColor: (UIColor*)tintColor
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* shadowColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.498];
    
    //// Shadow Declarations
    NSShadow* shadow = [[NSShadow alloc] init];
    [shadow setShadowColor: shadowColor];
    [shadow setShadowOffset: CGSizeMake(0.1, -0.1)];
    [shadow setShadowBlurRadius: 5];
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(2.5, 2.5, 73, 73)];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, [shadow.shadowColor CGColor]);
    [color setFill];
    [ovalPath fill];
    CGContextRestoreGState(context);
    
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
    [bezier2Path moveToPoint: CGPointMake(54, 25)];
    [bezier2Path addLineToPoint: CGPointMake(31.5, 47.5)];
    [bezier2Path addLineToPoint: CGPointMake(22.5, 38.5)];
    [bezier2Path addLineToPoint: CGPointMake(19.5, 41.5)];
    [bezier2Path addLineToPoint: CGPointMake(31.5, 53.5)];
    [bezier2Path addLineToPoint: CGPointMake(57, 28)];
    [bezier2Path addLineToPoint: CGPointMake(54, 25)];
    [bezier2Path closePath];
    [bezier2Path moveToPoint: CGPointMake(72.5, 39)];
    [bezier2Path addCurveToPoint: CGPointMake(39, 72.5) controlPoint1: CGPointMake(72.5, 57.5) controlPoint2: CGPointMake(57.5, 72.5)];
    [bezier2Path addCurveToPoint: CGPointMake(5.5, 39) controlPoint1: CGPointMake(20.5, 72.5) controlPoint2: CGPointMake(5.5, 57.5)];
    [bezier2Path addCurveToPoint: CGPointMake(20.74, 10.91) controlPoint1: CGPointMake(5.5, 27.23) controlPoint2: CGPointMake(11.56, 16.89)];
    [bezier2Path addCurveToPoint: CGPointMake(39, 5.5) controlPoint1: CGPointMake(25.99, 7.49) controlPoint2: CGPointMake(32.26, 5.5)];
    [bezier2Path addCurveToPoint: CGPointMake(72.5, 39) controlPoint1: CGPointMake(57.5, 5.5) controlPoint2: CGPointMake(72.5, 20.5)];
    [bezier2Path closePath];
    [tintColor setFill];
    [bezier2Path fill];
}

+ (void)drawSelectorOffIcon
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* shadowColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.498];
    
    //// Shadow Declarations
    NSShadow* shadow = [[NSShadow alloc] init];
    [shadow setShadowColor: shadowColor];
    [shadow setShadowOffset: CGSizeMake(0.1, -0.1)];
    [shadow setShadowBlurRadius: 5];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(39, 5.5)];
    [bezierPath addCurveToPoint: CGPointMake(20.74, 10.91) controlPoint1: CGPointMake(32.26, 5.5) controlPoint2: CGPointMake(25.99, 7.49)];
    [bezierPath addCurveToPoint: CGPointMake(5.5, 39) controlPoint1: CGPointMake(11.56, 16.89) controlPoint2: CGPointMake(5.5, 27.23)];
    [bezierPath addCurveToPoint: CGPointMake(39, 72.5) controlPoint1: CGPointMake(5.5, 57.5) controlPoint2: CGPointMake(20.5, 72.5)];
    [bezierPath addCurveToPoint: CGPointMake(72.5, 39) controlPoint1: CGPointMake(57.5, 72.5) controlPoint2: CGPointMake(72.5, 57.5)];
    [bezierPath addCurveToPoint: CGPointMake(39, 5.5) controlPoint1: CGPointMake(72.5, 20.5) controlPoint2: CGPointMake(57.5, 5.5)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(75.5, 39)];
    [bezierPath addCurveToPoint: CGPointMake(39, 75.5) controlPoint1: CGPointMake(75.5, 59.16) controlPoint2: CGPointMake(59.16, 75.5)];
    [bezierPath addCurveToPoint: CGPointMake(2.5, 39) controlPoint1: CGPointMake(18.84, 75.5) controlPoint2: CGPointMake(2.5, 59.16)];
    [bezierPath addCurveToPoint: CGPointMake(18.06, 9.1) controlPoint1: CGPointMake(2.5, 26.63) controlPoint2: CGPointMake(8.65, 15.71)];
    [bezierPath addCurveToPoint: CGPointMake(39, 2.5) controlPoint1: CGPointMake(23.98, 4.94) controlPoint2: CGPointMake(31.21, 2.5)];
    [bezierPath addCurveToPoint: CGPointMake(75.5, 39) controlPoint1: CGPointMake(59.16, 2.5) controlPoint2: CGPointMake(75.5, 18.84)];
    [bezierPath closePath];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, [shadow.shadowColor CGColor]);
    [color setFill];
    [bezierPath fill];
    CGContextRestoreGState(context);
}

+ (UIImage*)imageOfSelectorOnIconWithTintColor: (UIColor*)tintColor
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(78, 78), NO, 0.0f);
    [self drawSelectorOnIconWithTintColor: tintColor];
    
    UIImage* imageOfSelectorIcon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageOfSelectorIcon;
}

+ (UIImage*)imageOfSelectorOffIcon
{
    if (_imageOfSelectorOffIcon)
        return _imageOfSelectorOffIcon;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(78, 78), NO, 0.0f);
    [self drawSelectorOffIcon];
    
    _imageOfSelectorOffIcon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfSelectorOffIcon;
}

#pragma mark -

+ (void)drawFileIconWithExtensionText: (NSString*)text
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    //// Shadow Declarations
    NSShadow* shadow = [[NSShadow alloc] init];
    [shadow setShadowColor: [UIColor.blackColor colorWithAlphaComponent: 0.5]];
    [shadow setShadowOffset: CGSizeMake(0.1, -0.1)];
    [shadow setShadowBlurRadius: 10];
    NSShadow* shadow2 = [[NSShadow alloc] init];
    [shadow2 setShadowColor: [UIColor.blackColor colorWithAlphaComponent: 0.5]];
    [shadow2 setShadowOffset: CGSizeMake(0.1, -0.1)];
    [shadow2 setShadowBlurRadius: 10];
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = UIBezierPath.bezierPath;
    [rectanglePath moveToPoint: CGPointMake(48, 219)];
    [rectanglePath addLineToPoint: CGPointMake(186, 219)];
    [rectanglePath addLineToPoint: CGPointMake(186, 60)];
    [rectanglePath addLineToPoint: CGPointMake(141, 60)];
    [rectanglePath addLineToPoint: CGPointMake(141, 15)];
    [rectanglePath addLineToPoint: CGPointMake(48, 15)];
    [rectanglePath addLineToPoint: CGPointMake(48, 219)];
    [rectanglePath closePath];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, [shadow.shadowColor CGColor]);
    [UIColor.whiteColor setFill];
    [rectanglePath fill];
    CGContextRestoreGState(context);
    
    
    
    //// Rectangle 2 Drawing
    UIBezierPath* rectangle2Path = UIBezierPath.bezierPath;
    [rectangle2Path moveToPoint: CGPointMake(141, 60)];
    [rectangle2Path addLineToPoint: CGPointMake(186, 60)];
    [rectangle2Path addLineToPoint: CGPointMake(141, 15)];
    [rectangle2Path addLineToPoint: CGPointMake(141, 36)];
    [rectangle2Path addLineToPoint: CGPointMake(141, 60)];
    [rectangle2Path closePath];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadow2.shadowOffset, shadow2.shadowBlurRadius, [shadow2.shadowColor CGColor]);
    [UIColor.whiteColor setFill];
    [rectangle2Path fill];
    CGContextRestoreGState(context);
    
    
    
    //// Text Drawing
    CGRect textRect = CGRectMake(48, 161, 138, 50);
    NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    textStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize: 38], NSForegroundColorAttributeName: UIColor.grayColor, NSParagraphStyleAttributeName: textStyle};
    
    CGFloat textTextHeight = [text boundingRectWithSize: CGSizeMake(textRect.size.width, INFINITY)  options: NSStringDrawingUsesLineFragmentOrigin attributes: textFontAttributes context: nil].size.height;
    CGContextSaveGState(context);
    CGContextClipToRect(context, textRect);
    [text drawInRect: CGRectMake(CGRectGetMinX(textRect), CGRectGetMinY(textRect) + (CGRectGetHeight(textRect) - textTextHeight) / 2, CGRectGetWidth(textRect), textTextHeight) withAttributes: textFontAttributes];
    CGContextRestoreGState(context);
}

+ (UIImage*)imageOfFileIconWithExtensionText: (NSString*)text
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(234, 234), NO, 0.0f);
    [self drawFileIconWithExtensionText:text];
    
    UIImage* imageOfSelectorIcon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageOfSelectorIcon;
}

#pragma mark -

+ (UIImage *)placeholderImageWithSize:(CGSize)size {    
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *backgroundColor = [UIColor colorWithRed:(239.0 / 255.0) green:(239.0 / 255.0) blue:(244.0 / 255.0) alpha:1.0];
    UIColor *iconColor = [UIColor colorWithRed:(179.0 / 255.0) green:(179.0 / 255.0) blue:(182.0 / 255.0) alpha:1.0];
    
    // Background
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    // Icon (back)
    CGRect backIconRect = CGRectMake(size.width * (16.0 / 68.0),
                                     size.height * (20.0 / 68.0),
                                     size.width * (32.0 / 68.0),
                                     size.height * (24.0 / 68.0));
    
    CGContextSetFillColorWithColor(context, [iconColor CGColor]);
    CGContextFillRect(context, backIconRect);
    
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, CGRectInset(backIconRect, 1.0, 1.0));
    
    // Icon (front)
    CGRect frontIconRect = CGRectMake(size.width * (20.0 / 68.0),
                                      size.height * (24.0 / 68.0),
                                      size.width * (32.0 / 68.0),
                                      size.height * (24.0 / 68.0));
    
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, CGRectInset(frontIconRect, -1.0, -1.0));
    
    CGContextSetFillColorWithColor(context, [iconColor CGColor]);
    CGContextFillRect(context, frontIconRect);
    
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, CGRectInset(frontIconRect, 1.0, 1.0));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end
