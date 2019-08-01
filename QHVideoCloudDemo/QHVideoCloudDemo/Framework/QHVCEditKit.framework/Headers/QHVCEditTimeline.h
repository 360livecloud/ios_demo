//
//  QHVCEditTimeline.h
//  QHVCEditKit
//
//  Created by liyue-g on 2018/4/20.
//  Copyright © 2018年 liyue-g. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "QHVCEditDefinitions.h"

@class QHVCEditTrack;
@class QHVCEditEffect;

@interface QHVCEditTimeline : QHVCEditObject


#pragma mark - 基础方法

/**
 初始化，创建时间线
 
 @return 实例对象
 */
- (instancetype)initTimeline;


/**
 释放时间线

 @return 返回值
 */
- (QHVCEditError)free;


/**
 获取timelineId

 @return timelineId
 */
- (NSInteger)timelineId;


/**
 时间线时长（单位：毫秒）
 时间线时长计算方式：以时间线内所有轨道结束时间点最大值为结束时间点
 
 @return 时间线时长
 */
- (NSInteger)duration;


/**
 添加自定义数据

 @param userData 自定义数据
 @return 返回值
 */
- (QHVCEditError)setUserData:(void *)userData;


/**
 获取自定义数据

 @return 自定义数据
 */
- (void *)userData;


#pragma mark - 输出设置

/**
 设置输出分辨率（必填项）

 @param width 输出宽度
 @param height 输出高度
 @return 返回值
 */
- (QHVCEditError)setOutputWidth:(NSInteger)width height:(NSInteger)height;


/**
 获取输出分辨率

 @return 输出分辨率
 */
- (CGSize)outputSize;


/**
 设置输出画布背景色，默认填充黑色

 @param bgColor 背景颜色,16进制ARGB
 @return 返回值
 */
- (QHVCEditError)setOutputBgColor:(NSString *)bgColor;


/**
 获取输出画布背景色，默认填充黑色

 @return 输出画布背景色
 */
- (NSString *)outputBgColor;

/**
 设置输出帧率，默认30fps
 实时预览和合成都会按照输出帧率渲染
 
 @param fps 视频帧率
 @return 返回值
 */
- (QHVCEditError)setOutputFps:(NSInteger)fps;


/**
 输出帧率

 @return 视频帧率
 */
- (NSInteger)outputFps;


/**
 设置输出码率

 @param bitrate 输出码率
 @return 返回值
 */
- (QHVCEditError)setVideoOutputBitrate:(NSInteger)bitrate;


/**
 输出码率
 
 @return 返回值
 */
- (NSInteger)videoOutputBitrate;


/**
 设置整体渲染倍速，影响所有素材、特效渲染速度
 默认原速1.0，大于1.0为快速播放，0~1.0为慢速播放

 @param speed 倍速（倍速>0）
 @return 返回值
 */
- (QHVCEditError)setSpeed:(CGFloat)speed;


/**
 整体渲染倍速

 @return 倍速
 */
- (CGFloat)speed;


/**
 设置整体播放音量，影响所有素材、特效音量
 默认原素材音量100，0~100为减小音量，100~200为放大音量

 @param volume 音量值（0~200）
 @return 返回值
 */
- (QHVCEditError)setVolume:(NSInteger)volume;


/**
 整体音量

 @return 音量
 */
- (NSInteger)volume;


/**
 设置合成输出文件路径
 默认为 cache/com.qihoo.videocloud/QHVCEdit/output.mp4

 @param filePath 合成输出文件路径
 @return 返回值
 */
- (QHVCEditError)setOutputPath:(NSString *)filePath;


/**
 合成输出文件路径

 @return 返回值
 */
- (NSString *)outputPath;


#pragma mark - 轨道相关


/**
 添加轨道

 @param track 轨道对象
 @return 返回值
 */
- (QHVCEditError)appendTrack:(QHVCEditTrack *)track;


/**
 删除轨道

 @param trackId 轨道Id
 @return 返回值
 */
- (QHVCEditError)deleteTrackById:(NSInteger)trackId;


/**
 通过轨道Id获取轨道

 @param trackId 轨道Id
 @return 轨道
 */
- (QHVCEditTrack *)getTrackById:(NSInteger)trackId;


/**
 获取时间线上所有轨道

 @return 轨道数组
 */
- (NSArray<QHVCEditTrack *>*)getTracks;


#pragma mark - 时间线特效


/**
 添加时间线特效

 @param effect 特效
 @return 返回值
 */
- (QHVCEditError)addEffect:(QHVCEditEffect *)effect;


/**
 删除时间线特效

 @param effectId 特效Id
 @return 返回值
 */
- (QHVCEditError)deleteEffectById:(NSInteger)effectId;


/**
 更新特效参数

 @param effect 特效
 @return 返回值
 */
- (QHVCEditError)updateEffect:(QHVCEditEffect *)effect;


/**
 获取特效

 @param effectId 特效Id
 @return 特效
 */
- (QHVCEditEffect *)getEffectById:(NSInteger)effectId;


/**
 获取时间线上添加的所有特效

 @return 特效数组
 */
- (NSArray<QHVCEditEffect *>*)getEffects;

@end
