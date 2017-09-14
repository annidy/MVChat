//
//  MVChatViewModel.h
//  MVChat
//
//  Created by Mark Vasiv on 13/09/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MVMessageCellModel;
@class RACSignal;
@class RACCommand;
@class MVChatModel;

@interface MVChatViewModel : NSObject
- (instancetype)initWithChat:(MVChatModel *)chat;

@property (strong, nonatomic) NSMutableArray <MVMessageCellModel *> *messages;
@property (strong, nonatomic) UIImage *avatar;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *messageText;
@property (strong, nonatomic) RACSignal *updateSignal;
@property (strong, nonatomic) RACCommand *sendCommand;
@property (assign, nonatomic) CGFloat sliderOffset;
@property (strong, nonatomic) NSString *chatId;
@property (strong, nonatomic) NSArray *chatParticipants;

- (void)tryToLoadNextPage;
- (UIViewController *)relevantSettingsController;
- (UIViewController *)attachmentPicker;
- (void)imageViewerForMessage:(MVMessageCellModel *)model fromImageView:(UIImageView *)imageView completion:(void (^)(UIViewController *))completion;
@end
