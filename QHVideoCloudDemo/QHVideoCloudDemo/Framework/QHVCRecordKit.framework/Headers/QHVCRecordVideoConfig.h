//
//  QHVCRecordConfig.h
//  QHVideoCloudToolSetDebug
//
//  Created by deng on 2018/10/10.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QHVCRecordTypeDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface QHVCRecordVideoConfig : NSObject

/**
 *  @abstract 设置视频编码码率 kbps(默认 1024)
*/
@property (nonatomic, assign) int videoBitrate;

/**
 *  @abstract 设置视频编码器每秒编码帧数 默认25帧
 */
@property (nonatomic, assign) int fps;

/**
 *  @abstract 设置视频编码器关键帧间隔(单位：秒 默认2s)
 */
@property (nonatomic, assign) int videoMaxKeyframeInterval;

/**
 *  @abstract 设置视频编码器输出宽高（默认480*640）
 */
@property (nonatomic, assign) int videoWidth;
@property (nonatomic, assign) int videoHeight;

/**
 *  @abstract 视频编码格式
 */
@property (nonatomic, assign) QHVCRecordVideoCodecFormat videoCodecFormat;

@property (nonatomic, strong) NSDictionary *optionalVideoConfig;

/**
 *  @abstract 创建一个默认配置的 QHVCRecordVideoConfig 实例.
 *  @return 创建的默认 QHVCRecordVideoConfig 对象
 */
+ (instancetype)defaultVideoConfig;

@end

NS_ASSUME_NONNULL_END
