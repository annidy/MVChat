//
//  DBThumbnailPhotoCell.m
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

#import "DBThumbnailPhotoCell.h"
#import "UIImage+DBAssetIcons.h"
#import "NSBundle+DBLibrary.h"

static const CGFloat kDefaultSelectorImageViewOffset = 4.f;

@interface DBThumbnailPhotoCell ()

@property (weak, nonatomic) IBOutlet UIImageView *selectorImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectorImageViewRightConstraint;

@end

@implementation DBThumbnailPhotoCell

#pragma mark - Class methods

+ (instancetype)thumbnailImageCell {
    DBThumbnailPhotoCell *view = [[[NSBundle dbAttachmentPickerBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] firstObject];
    return view;
}

#pragma mark - Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectorImageView.image = [UIImage imageOfSelectorOffIcon];
    self.selectorImageView.highlightedImage = [UIImage imageOfSelectorOnIconWithTintColor:self.tintColor];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.selectorOffset = 0.f;
}

#pragma mark - Accessors

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    [self.selectorImageView setTintColor:tintColor];
}

- (void)setSelectorOffset:(CGFloat)selectorOffset {
    _selectorOffset = selectorOffset;
    
    const CGFloat maxOfsset = CGRectGetWidth(self.bounds) - kDefaultSelectorImageViewOffset - CGRectGetWidth(self.selectorImageView.frame);
    self.selectorImageViewRightConstraint.constant = MIN(maxOfsset, kDefaultSelectorImageViewOffset + selectorOffset);
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self updateSelectorIndicatorStateIfNedded];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self updateSelectorIndicatorStateIfNedded];
}

- (void)setNeedsDisplayEmptySelectedIndicator:(BOOL)needsDisplayEmptySelectedIndicator {
    if (_needsDisplayEmptySelectedIndicator != needsDisplayEmptySelectedIndicator) {
        _needsDisplayEmptySelectedIndicator = needsDisplayEmptySelectedIndicator;
        [self updateSelectorIndicatorStateIfNedded];
    }
}

#pragma mark Helpers

- (void)updateSelectorIndicatorStateIfNedded {
    self.selectorImageView.highlighted = (self.selected || self.highlighted);
    self.selectorImageView.hidden = ( !self.selected && !self.needsDisplayEmptySelectedIndicator);
}

@end
