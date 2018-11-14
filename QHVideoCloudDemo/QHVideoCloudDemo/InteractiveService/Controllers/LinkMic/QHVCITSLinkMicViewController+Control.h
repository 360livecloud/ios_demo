//
//  QHVCITSLinkMicViewController+Control.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/3/22.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QHVCITSLinkMicViewController.h"

typedef NS_ENUM(NSInteger, QHVCITSActionType)
{
    QHVCITSActionTypeSpeaker = 0,//扬声器、听筒切换 默认扬声器
    QHVCITSActionTypeMic = 1,//麦克风是否禁用  默认否
    QHVCITSActionTypeCameraSwitch = 2,//前后置摄像头切换 默认前置
    QHVCITSActionTypeCamera = 3,//相机是否禁用 默认否
//    QHVCITSActionTypeBeauty,//美颜
//    QHVCITSActionTypeFilter,//滤镜
//    QHVCITSActionTypeFaceu,//萌颜
    QHVCITSActionTypeFullScreen,//全屏
};

typedef NS_ENUM(NSInteger, QHVCITSFilterLevel)
{
    QHVCITSFilterLevelAny = 1,//均出现
    QHVCITSFilterLevelTwo = 2,//
    QHVCITSFilterLevelThree = 3,//
};

@interface QHVCITSLinkMicViewController(Control)

- (void)initActionCollectionView;
- (void)updateControlView:(QHVCITSTalkType)talkType;

@end
