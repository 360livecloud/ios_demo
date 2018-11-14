//
//  QHVCEditCropRectControl.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/3/21.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QHVCEditCropRectControl;
@protocol QHVCEditCropRectControlDelegate <NSObject>

- (void)cropRectConrolViewDidBegin:(QHVCEditCropRectControl *)cropRectConrolView;
- (void)cropRectConrolViewValueChanged:(QHVCEditCropRectControl *)cropRectConrolView;
- (void)cropRectConrolViewDidEnd:(QHVCEditCropRectControl *)cropRectConrolView;

@end

@interface QHVCEditCropRectControl : UIView

@property (nonatomic, weak) id<QHVCEditCropRectControlDelegate> delegate;
@property (nonatomic, readonly, assign) CGPoint translation;

@end
