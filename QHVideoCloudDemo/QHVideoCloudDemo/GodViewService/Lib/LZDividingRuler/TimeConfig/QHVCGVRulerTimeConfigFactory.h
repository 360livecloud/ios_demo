//
//  QHVCGVRulerTimeConfigFactory.h
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/10/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QHVCGVRulerTimeConfig.h"

NS_ASSUME_NONNULL_BEGIN

/// 标尺支持五类精度，这五类精度也是卡尺缩放的五个阶段要经历的
typedef NS_ENUM(NSInteger, QHVCGVRulerTimeConfigType) {
    QHVCGVRulerTimeConfigMinute,        // 刻度尺上每1分钟显示的配置
    QHVCGVRulerTimeConfigFiveMinute,    // 刻度尺上每5分钟显示的配置
    QHVCGVRulerTimeConfigTenMinute,     // 刻度尺上每10分钟显示的配置
    QHVCGVRulerTimeConfigHour,          // 刻度尺上每1小时显示的配置
    QHVCGVRulerTimeConfigTwoHour,       // 刻度尺上每2小时显示的配置
    QHVCGVRulerTimeConfigFourHour       // 刻度尺上每4小时显示的配置
};

@interface QHVCGVRulerTimeConfigFactory : NSObject

+ (QHVCGVRulerTimeConfig *)configWithType:(QHVCGVRulerTimeConfigType)type;

/**
 * 根据精度比例获取config
 * @param percent : 0 ~ 100 :
        0 <= percent < 17  : QHVCGVRulerTimeConfigFourHour 类型
        17 <= percent < 34 : QHVCGVRulerTimeConfigTwoHour 类型
        34 <= percent < 51 : QHVCGVRulerTimeConfigHour 类型
        51 <= percent < 68 : QHVCGVRulerTimeConfigTenMinute 类型
        68 <= percent < 85 : QHVCGVRulerTimeConfigFiveMinute 类型
        85 <= percent <= 100 : QHVCGVRulerTimeConfigMinute 类型
 * @return QHVCGVRulerTimeConfig
 */
+ (QHVCGVRulerTimeConfig *)configWithPrecisionPercent:(CGFloat)percent;

@end

NS_ASSUME_NONNULL_END
