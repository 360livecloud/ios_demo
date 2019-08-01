//
//  QHVCRecordTypeDefine.h
//  QHVideoCloudToolSetDebug
//
//  Created by deng on 2018/10/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QHVCRecordVideoOrientation)
{
    QHVCRecordVideoOrientationPortrait = 1,           //垂直方向
    QHVCRecordVideoOrientationPortraitUpsideDown,
    QHVCRecordVideoOrientationLandscapeRight,     //水平方向，屏幕相对home键在右
    QHVCRecordVideoOrientationLandscapeLeft,      //水平方向，屏幕相对home键在左
};

typedef NS_ENUM(NSUInteger, QHVCRecordRenderMode)
{
    QHVCRecordRenderModeAspectFill,               //等比填充画布，可能会裁剪
    QHVCRecordRenderModeAspectFit,                //等比填充画布，可能会有黑边,
    QHVCRecordRenderModeScaleToFill,              //完全铺满画布，可能会变形
};

typedef NS_ENUM(NSUInteger, QHVCRecordVideoCodecFormat)
{
    QHVCRecordAudioCodecH264 = 0,
    QHVCRecordAudioCodecH265 = 1,
};

/**
 * 音频编码格式
 */
typedef NS_ENUM(NSUInteger, QHVCRecordAudioCodecFormat)
{
    QHVCRecordAudioCodecAAC = 0,
};

/**
 * 音频采样率
 */
typedef NS_ENUM(NSUInteger, QHVCRecordAudioSampleRate)
{
    QHVCRecordAudioSampleRate22050HZ = 22050,
    QHVCRecordAudioSampleRate44100HZ = 44100,
    QHVCRecordAudioSampleRate48000HZ = 48000,
};

typedef NS_ENUM(NSInteger, QHVCRecordError) {
    QHVCRecordOK = 0,//操作成功
    QHVCRecordErrorFalse = -1,//失败
    QHVCRecordErrorInvalidParam = -2,//参数初始化错误或者无效参数
};

typedef NS_ENUM(NSInteger, QHVCRecordSpeedMode) {
    QHVCRecordSpeedModeSetrate = 1,//变速&变调
    QHVCRecordSpeedModeTempo = 2,//变速&不变调
};

typedef NS_ENUM(NSInteger, QHVCRecordLogLevel) {
    QHVCRecordLogLevelTrace = 0,
    QHVCRecordLogLevelDebug = 1,
    QHVCRecordLogLevelInfo  = 2,
    QHVCRecordLogLevelWarn  = 3,
    QHVCRecordLogLevelError = 4,
    QHVCRecordLogLevelAlarm = 5,
    QHVCRecordLogLevelFatal = 6,
};
NS_ASSUME_NONNULL_END
