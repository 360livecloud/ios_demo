//
//  QHVCEditStickerIconView.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QHVCEditStickerIconView;

typedef void(^DeleteAction)(QHVCEditStickerIconView *sticker);
typedef void(^RotateAction)(BOOL isEnd, QHVCEditStickerIconView *sticker);
typedef void(^MoveAction)(BOOL isEnd, QHVCEditStickerIconView *sticker);
typedef void(^PinchAction)(BOOL isEnd, QHVCEditStickerIconView *sticker);
typedef void(^FadeInOutAction)(QHVCEditStickerIconView *sticker);
typedef void(^MoveInOutAction)(QHVCEditStickerIconView *sticker);
typedef void(^JumpInOutAction)(QHVCEditStickerIconView *sticker);
typedef void(^RotateInOutAction)(QHVCEditStickerIconView *sticker);

@interface QHVCEditStickerIconView : UIView

@property (nonatomic,   copy) DeleteAction deleteCompletion;
@property (nonatomic,   copy) RotateAction rotateAction;
@property (nonatomic,   copy) MoveAction moveAction;
@property (nonatomic,   copy) PinchAction pinchAction;
@property (nonatomic,   copy) FadeInOutAction fadeInOutAction;
@property (nonatomic,   copy) MoveInOutAction moveInOutAction;
@property (nonatomic,   copy) JumpInOutAction jumpInOutAction;
@property (nonatomic,   copy) RotateInOutAction rotateInOutAction;
@property (nonatomic, strong) UIImageView *sticker;
@property (nonatomic, strong) UILabel *subtitle;
@property (nonatomic, assign) CGFloat rotateAngle;

- (void)setStickerImageUrl:(NSString *)imageUrl;
- (void)setUserData:(void *)userData;
- (void *)userData;

@end
