//
//  QHVCGVRulerTimeConfig.h
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/10/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHVCGVRulerTimeConfig : NSObject

/// 时间精度，每个刻度代表时间，单位秒
@property (nonatomic, assign) CGFloat timePrecision;
/// 起始刻度
@property (nonatomic, assign) NSUInteger minValue;
/// 总刻度数
@property (nonatomic, assign) NSUInteger maxValue;
/// 刻度线间距
@property (nonatomic, assign) CGFloat lineSpace;
/// 刻度线宽度
@property (nonatomic, assign) CGFloat lineWidth;
/// 相隔多少刻度显示一下刻度值
@property (nonatomic, assign) NSUInteger scalesCountBetweenScaleText;
/// 相隔多少刻度线显示长刻度线
@property (nonatomic, assign) NSUInteger scalesCountBetweenLargeLine;

@end

NS_ASSUME_NONNULL_END
