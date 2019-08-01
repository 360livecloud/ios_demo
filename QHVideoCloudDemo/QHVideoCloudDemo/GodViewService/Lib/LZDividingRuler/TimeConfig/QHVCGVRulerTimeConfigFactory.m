//
//  QHVCGVRulerTimeConfigFactory.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/10/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCGVRulerTimeConfigFactory.h"

const CGFloat kQHVCGVRulerTimeMaxLineSpace = 12.5;
const CGFloat kQHVCGVRulerTimeMinLineSpace = 6.5;





@implementation QHVCGVRulerTimeConfigFactory

+ (QHVCGVRulerTimeConfig *)configWithType:(QHVCGVRulerTimeConfigType)type {
    if (type == QHVCGVRulerTimeConfigMinute) {
        return [self minutesConfig];
    }
    else if (type == QHVCGVRulerTimeConfigFiveMinute) {
        return [self fiveMinutesConfig];
    }
    else if (type == QHVCGVRulerTimeConfigTenMinute) {
        return [self tenMinutesConfig];
    }
    else if (type == QHVCGVRulerTimeConfigHour) {
        return [self hourConfig];
    }
    else if (type == QHVCGVRulerTimeConfigTwoHour) {
        return [self twoHourConfig];
    }
    else if (type == QHVCGVRulerTimeConfigFourHour) {
        return [self fourHourConfig];
    }
    return [self tenMinutesConfig];
}

+ (QHVCGVRulerTimeConfig *)minutesConfig {
    QHVCGVRulerTimeConfig *config = [QHVCGVRulerTimeConfig new];
    config.timePrecision = 10;
    config.minValue = 0;
    config.maxValue = 1 * 24 * 60 * 6;
//    config.lineSpace = 17.5;
    config.lineSpace = 3.5;
    config.lineWidth = 0.5;
    config.scalesCountBetweenScaleText = 6;
    config.scalesCountBetweenLargeLine = 6;
    return config;
}

+ (QHVCGVRulerTimeConfig *)fiveMinutesConfig {
    QHVCGVRulerTimeConfig *config = [QHVCGVRulerTimeConfig new];
    config.timePrecision = 60;
    config.minValue = 0;
    config.maxValue = 1 * 24 * 60;
//    config.lineSpace = 15.5;
    config.lineSpace = 3.5;
    config.lineWidth = 0.5;
    config.scalesCountBetweenScaleText = 5;
    config.scalesCountBetweenLargeLine = 5;
    return config;
}

+ (QHVCGVRulerTimeConfig *)tenMinutesConfig {
    QHVCGVRulerTimeConfig *config = [QHVCGVRulerTimeConfig new];
    config.timePrecision = 60;
    config.minValue = 0;
    config.maxValue = 1 * 24 * 60 / 10 * 10;
//    config.lineSpace = 13.5;
    config.lineSpace = 3.5;
    config.lineWidth = 0.5;
    config.scalesCountBetweenScaleText = 10;
    config.scalesCountBetweenLargeLine = 10;
    return config;
}

+ (QHVCGVRulerTimeConfig *)hourConfig {
    QHVCGVRulerTimeConfig *config = [QHVCGVRulerTimeConfig new];
    config.timePrecision = 60 * 10;
    config.minValue = 0;
    config.maxValue = 1 * 24 * 6;
//    config.lineSpace = 12.5;
    config.lineSpace = 3.5;
    config.lineWidth = 0.5;
    config.scalesCountBetweenScaleText = 6;
    config.scalesCountBetweenLargeLine = 6;
    return config;
}

+ (QHVCGVRulerTimeConfig *)twoHourConfig {
    QHVCGVRulerTimeConfig *config = [QHVCGVRulerTimeConfig new];
    config.timePrecision = 60 * 10;
    config.minValue = 0;
    config.maxValue = 1 * 24 / 2 * (6 * 2);
//    config.lineSpace = 10.5;
    config.lineSpace = 3.5;
    config.lineWidth = 0.5;
    config.scalesCountBetweenScaleText = 6 * 2;
    config.scalesCountBetweenLargeLine = 6;
    return config;
}

+ (QHVCGVRulerTimeConfig *)fourHourConfig {
    QHVCGVRulerTimeConfig *config = [QHVCGVRulerTimeConfig new];
    config.timePrecision = 60 * 10;
    config.minValue = 0;
    config.maxValue = 1 * 24 / 2 * (6 * 2);
//    config.lineSpace = 9.5;
    config.lineSpace = 3.5;
    config.lineWidth = 0.5;
    config.scalesCountBetweenScaleText = 6 * 4;
    config.scalesCountBetweenLargeLine = 6;
    return config;
}

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
+ (QHVCGVRulerTimeConfig *)configWithPrecisionPercent:(CGFloat)percent {
    CGFloat fourHourMin = 2.5;
    CGFloat fourHourMax = 3.5;
    
    CGFloat twoHourMin = 2.5;
    CGFloat twoHourMax = 6.5;
    
    CGFloat hourMin    = 5.5;
    CGFloat hourMax    = 28.5;
    
    CGFloat tenMinutesMin = 2.5;
    CGFloat tenMinutesMax = 13.5;
    
    CGFloat fiveMinutesMin = 13.5;
    CGFloat fiveMinutesMax = 28.5;
    
    CGFloat minutesMin = 4.5;
    CGFloat minutesMax = 12.5;
    
    
    QHVCGVRulerTimeConfig *config;
    if (percent >= 0 && percent < 17) {
        config = [self fourHourConfig];
        config.lineSpace = fourHourMin + (NSInteger)floor(percent / 17 * (fourHourMax - fourHourMin));
    }
    else if (percent >= 17 && percent < 34) {
        config = [self twoHourConfig];
        config.lineSpace = twoHourMin + (NSInteger)((percent - 17) / 17 * (twoHourMax - twoHourMin));
    }
    else if (percent >= 34 && percent < 51) {
        config = [self hourConfig];
        config.lineSpace = hourMin + (NSInteger)((percent - 17 * 2) / 17 * (hourMax - hourMin));
    }
    else if (percent >= 51 && percent < 68) {
        config = [self tenMinutesConfig];
        config.lineSpace = tenMinutesMin + (NSInteger)((percent - 17 * 3) / 17 * (tenMinutesMax - tenMinutesMin));
    }
    else if (percent >= 68 && percent < 85) {
        config = [self fiveMinutesConfig];
        config.lineSpace = fiveMinutesMin + (NSInteger)((percent - 17 * 4) / 17 * (fiveMinutesMax - fiveMinutesMin));
    }
    else if (percent >= 85 && percent <= 100) {
        config = [self minutesConfig];
        config.lineSpace = minutesMin + (NSInteger)((percent - 17 * 5) / 17 * (minutesMax - minutesMin));
    }
    return config;
}

@end
