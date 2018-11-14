//
//  QHVCEditCropRectView.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/3/21.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QHVCEditCropRectView;
@protocol QHVCEditCropRectViewDelegate <NSObject>
@optional
- (void)cropRectViewDidBeginEditing:(QHVCEditCropRectView *)cropRectView;
- (void)cropRectViewEditingChanged:(QHVCEditCropRectView *)cropRectView;
- (void)cropRectViewDidEndEditing:(QHVCEditCropRectView *)cropRectView;

@end

@interface QHVCEditCropRectView : UIView

@property (nonatomic, weak) id<QHVCEditCropRectViewDelegate> delegate;
@property (nonatomic, assign) BOOL showGridMajor;
@property (nonatomic, assign) BOOL showGridMinor;

@end
