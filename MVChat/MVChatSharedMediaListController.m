//
//  MVChatAttachmentsViewController.m
//  MVChat
//
//  Created by Mark Vasiv on 28/08/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "MVChatSharedMediaListController.h"
#import "MVChatSharedMediaListCell.h"
#import "MVFileManager.h"
#import <DBAttachment.h>
#import "MVImageViewerController.h"
#import "MVChatSharedMediaPageController.h"
#import "MVImageViewerViewModel.h"

static NSString *cellId = @"MVChatSharedMediaListCell";
static CGFloat numberOfItemsPerRow = 6;
static CGFloat spacing = 5;

@interface MVChatSharedMediaListController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSString *chatId;
@property (strong, nonatomic) NSArray <DBAttachment *> *attachments;
@property (strong, nonatomic) NSMutableArray <MVImageViewerViewModel *> *viewModels;
@property (strong, nonatomic) UICollectionViewCell *selectedCell;
@end

@implementation MVChatSharedMediaListController
+ (instancetype)loadFromStoryboardWithChatId:(NSString *)chatId {
    MVChatSharedMediaListController *instance = [super loadFromStoryboard];
    instance.chatId = chatId;
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.attachments = [[MVFileManager sharedInstance] attachmentsForChatWithId:self.chatId];
    self.viewModels = [NSMutableArray new];
    NSUInteger index = 0;
    for (DBAttachment *attachment in self.attachments) {
        [self.viewModels addObject:[[MVImageViewerViewModel alloc] initWithSourceImageView:nil attachment:attachment andIndex:index]];
        index ++;
    }
}

#pragma mark - Collection View
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.attachments.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MVChatSharedMediaListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    self.viewModels[indexPath.row].sourceImageView = cell.imageView;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    MVChatSharedMediaListCell *mediaCell = (MVChatSharedMediaListCell *)cell;
    DBAttachment *attachment = [self.attachments objectAtIndex:indexPath.row];
    [attachment thumbnailImageWithMaxWidth:50 completion:^(UIImage *resultImage) {
        mediaCell.imageView.image = resultImage;
    }];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MVChatSharedMediaPageController *pageController = [MVChatSharedMediaPageController loadFromStoryboardWithViewModels:[self.viewModels copy] andStartIndex:indexPath.row];
    [self presentViewController:pageController animated:YES completion:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat sideLength = collectionView.frame.size.width / numberOfItemsPerRow - spacing;
    return CGSizeMake(sideLength, sideLength);
}
@end
