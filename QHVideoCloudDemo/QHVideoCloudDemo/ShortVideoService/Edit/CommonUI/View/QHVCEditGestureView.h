//
//  QHVCEditGestureView.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/8/7.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QHVCEditGestureView : UIView

- (void)prepareSubviews;
- (void)tapGestureAction;
- (void)rotateGestureAction:(BOOL)isEnd;
- (void)moveGestureAction:(BOOL)isEnd;
- (void)pinchGestureAction:(BOOL)isEnd;
- (void)hideBorder:(BOOL)hidden;
- (CGRect)rectToOutputRect:(CGSize)outputSize;

@property (nonatomic, assign) CGFloat radian;
@property (nonatomic, assign) BOOL tapEnable;
@property (nonatomic, assign) BOOL rotateEnable;
@property (nonatomic, assign) BOOL moveEnable;
@property (nonatomic, assign) BOOL pinchEnable;

@property (nonatomic, assign) CGFloat moveExtentX; //允许水平方向移动超出父窗口位移
@property (nonatomic, assign) CGFloat moveExtentY; //允许垂直方向移动超出父窗口位移

@end
