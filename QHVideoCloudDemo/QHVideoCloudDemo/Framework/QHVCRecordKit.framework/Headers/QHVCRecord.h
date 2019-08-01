//
//  QHVCRecord.h
//  QHVideoCloudToolSetDebug
//
//  Created by deng on 2018/10/10.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "QHVCRecordVideoConfig.h"
#import "QHVCRecordAudioConfig.h"
#import "QHVCRecordTypeDefine.h"
#import "QHVCRecordFilter.h"
#import "QHVCRecordMusicInfo.h"
#import "QHVCRecordDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface QHVCRecord : NSObject

/**
 *  @abstract startCameraPreview 之后调用有效,单位:pixels
 */
@property (nonatomic,assign,readonly) CMVideoDimensions captureVideoDimensions;

/**
*  @abstract 视频相关配置（startCameraPreview前设置，不设置不采集相机）
*  @param videoConfig 视频相关配置
*/
- (int)setVideoConfig:(QHVCRecordVideoConfig *)videoConfig;

/**
 *  @abstract 音频相关配置（startCameraPreview前设置，不设置不采集麦克风）
 *  @param audioConfig 音频相关配置
 */
- (int)setAudioConfig:(QHVCRecordAudioConfig *)audioConfig;

- (int)setRecordDelegate:(nullable id<QHVCRecordDelegate>)delegate;
- (nullable id<QHVCRecordDelegate>)recordDelegate;

#pragma mark - 摄像头、麦克风相关逻辑

- (int)setVideoOrientation:(QHVCRecordVideoOrientation)videoOrientation;

/**
 *  @abstract 调整焦距，startCameraPreview 之后调用有效
 *  @param distance 取值范围 1~5
 */
- (int)setZoom:(CGFloat)distance;

/**
 *  @abstract 设置摄像头焦点，startCameraPreview 之后调用有效
 *  @param point 焦点
 */
- (int)setFocusPointOfInterest:(CGPoint)point;

/**
 *  @abstract 切换前后摄像头（默认前置）
 *  @param isFront  YES 切换到前置摄像头, NO 切换到后置摄像头
 */
- (int)switchCamera:(BOOL)isFront;

/**
 *  @abstract 打开闪关灯，startCameraPreview 之后调用有效
 *  @param enable YES-打开，NO-关闭.
 */
- (int)toggleTorch:(BOOL)enable;

/**
 *  @abstract 静音
 *  @param mute 是否静音
 */
- (int)setMute:(BOOL)mute;

/**
 *  @abstract 开始画面预览
 */
- (int)startCameraPreview:(UIView *)preview;

/**
 *  @abstract 结束画面预览
 */
- (int)stopCameraPreview;

#pragma mark - 录制相关逻辑

/**
 *  @abstract 设置录制速率(startRecord前设置，录制ing设置无效，支持设置范围1/2 ~ 2)
 */
- (int)setRecordSpeed:(float)recordSpeed;

- (int)setRecordSpeed:(float)recordSpeed
                 mode:(QHVCRecordSpeedMode)speedMode;

/**
 *  @abstract 设置录制路径
 *  @param videoPath 视频文件输出路径（多段视频录制，为合成后的视频输出路径）
 *  @param videoSegmentsFolder 分段视频存储目录
 */
- (int)setRecordPath:(NSString *)videoPath
 videoSegmentsFolder:(NSString *)videoSegmentsFolder;

/**
 *  @abstract 支持导入历史分段录制文件（prepareToRecord前）
 *  @param segments 分段信息
 */
- (int)setRecordSegments:(NSArray<QHVCRecordSegmentInfo *> *)segments;

/**
 *  @abstract 录制预处理
 */
- (int)prepareToRecord;

/**
 *  @abstract 开始录制视频
 */
- (int)startRecord;

/**
 *  @abstract 结束本次视频录制(调用joinAllSegments，合成多段视频，视频输出到videoPath)
 */
- (int)stopRecord;

/**
 *  @abstract 删除当前录制视频最后一片段
 */
- (int)deleteLastSegment;

/**
 *  @abstract 删除当前录制视频最后一个片段的指定时长（单位 ms）
 *  注：指定时长大于最后一段时长会跨段继续删除
 */
- (int)deleteLastSegmentByMS:(int)ms;

/**
 *  @abstract 删除当前录制视频所有片段
 */
- (int)deleteAllSegments;

/**
 *  @abstract 合成当前录制视频所有片段
 */
- (int)joinAllSegments;

/**
 *  @abstract 停止合成当前录制的视频片段
 */
- (int)cancelJoin;

#pragma mark 拍照片

- (int)takePhoto:(int)outputWidth outputHeight:(int)outputHeight;

#pragma mark 背景音乐

- (int)setBackgroundMusic:(QHVCRecordMusicInfo *)music;
- (QHVCRecordMusicInfo *)backgroundMusic;

#pragma mark - 录制效果设置相关逻辑

/**
 *  @abstract 增加特效(多次调用，按照调用顺序依次叠加)
 *  @param effect 特效（可自定义特效）
 */
- (int)appendEffect:(QHVCRecordFilter *)effect;

- (int)insertEffect:(QHVCRecordFilter *)effect atIndex:(NSUInteger)index;
/**
 *  @abstract 删除特效
 *  @param effect 特效
 */
- (int)removeEffect:(QHVCRecordFilter *)effect;

#pragma mark Common
+ (QHVCRecordFileInfo *)fetchFileInfo:(NSString *)filePath;

//统计相关，请正确设置，利于排查线上问题，在上传前设置

/**
 *  @功能 设置统计信息
 *  @参数 info
 @{@"channelId":@"",//设置第三方渠道号
 @"userId":@"",//设置第三方用户id
 };
 */
- (void)setStatisticsInfo:(NSDictionary *)info;

/**
 * 开启日志（debug阶段辅助开发调试，根据实际情况使用）
 * @参数 level 日志等级
 */
+ (void)openLogWithLevel:(QHVCRecordLogLevel)level;

/**
 * 设置日志输出callback
 * @参数 callback 回调block
 */
+ (void)setLogOutputCallBack:(void(^)(int loggerID, QHVCRecordLogLevel level, const char *data))callback;

/**
 *  @功能 获取上传sdk版本号
 *  @返回值 sdk版本号（e.g. 2.0.0.0）
 */
+ (NSString *)sdkVersion;

@end

NS_ASSUME_NONNULL_END
