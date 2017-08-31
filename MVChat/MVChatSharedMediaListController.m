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

@interface MVChatSharedMediaListController () <UICollectionViewDataSource, UICollectionViewDelegate>
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
    DBAttachment *attachment = [self.attachments objectAtIndex:indexPath.row];
    self.viewModels[indexPath.row].sourceImageView = cell.imageView;
    [attachment thumbnailImageWithMaxWidth:100 completion:^(UIImage *resultImage) {
        cell.imageView.image = resultImage;
    }];
    
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MVChatSharedMediaPageController *pageController = [MVChatSharedMediaPageController loadFromStoryboardWithViewModels:[self.viewModels copy] andStartIndex:indexPath.row];
    [self presentViewController:pageController animated:YES completion:nil];
}

@end
