//
//  QHVCEditBeautifyView.h
//  QHVideoCloudToolSet
//
//  Created by yinchaoyu on 2018/6/4.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, QHVCEditBeautifyType)
{
    QHVCEditBeautifyType_Beautify,
    QHVCEditBeautifyType_White,
    QHVCEditBeautifyType_Face,
    QHVCEditBeautifyType_Eye,
};

typedef void (^ChangeComplete)(float beautyLevel, float whiteLevel, float faceLevel, float eyeLevel);

@interface QHVCEditBeautifyView : UIView

@property (nonatomic, copy) ChangeComplete onChangeComplete;

@end
