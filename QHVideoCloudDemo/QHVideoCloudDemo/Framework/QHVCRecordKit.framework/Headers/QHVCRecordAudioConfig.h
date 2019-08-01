//
//  QHVCRecordAudioConfig.h
//  QHVideoCloudToolSetDebug
//
//  Created by deng on 2018/10/11.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QHVCRecordTypeDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface QHVCRecordAudioConfig : NSObject

/**
 *  @abstract 音频输出声道数 默认为 1
 */
@property (nonatomic, assign) NSUInteger numberOfChannels;

/**
 *  @abstract 音频输出采样率 默认为 44100Hz
 */
@property (nonatomic, assign) QHVCRecordAudioSampleRate sampleRate;

/**
 *  @abstract 音频编码码率 单位kbps 默认为 64kbps
 */
@property (nonatomic, assign) NSInteger audioBitRate;

/**
 *  @abstract 音频编码格式
 */
@property (nonatomic, assign) QHVCRecordAudioCodecFormat audioCodecFormat;

/**
 *  @abstract 扩展字段配置(预留)
 */
@property (nonatomic, strong) NSDictionary *optionalAudioConfig;

/**
 *  @abstract 创建一个默认配置的 QHVCRecordAudioConfig 实例.
 *  @return 创建的默认 QHVCRecordAudioConfig 对象
 */
+ (instancetype)defaultAudioConfig;

@end

NS_ASSUME_NONNULL_END
