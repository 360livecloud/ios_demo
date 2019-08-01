//
//  QHVCRecordDelegate.h
//  QHVCRecordKit
//
//  Created by deng on 2018/10/18.
//  Copyright © 2018年 qihoo.QHVC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QHVCRecordSegmentInfo;
@class QHVCRecordFileInfo;

NS_ASSUME_NONNULL_BEGIN

@protocol QHVCRecordDelegate <NSObject>

@optional
#pragma mark 摄像头／麦克风采集数据的回调
/**
 *  @abstract 采集摄像头的原始视频数据
 */
- (void)didCaptureVideoBuffer:(CMSampleBufferRef)buffer;

/**
 *  @abstract 采集麦克风的原始音频数据
 */
- (void)didCaptureAudioBuffer:(CMSampleBufferRef)buffer;

/**
 *  @abstract 视频帧处理后数据（加入特效.etc）
 */
- (void)didProcessVideoBuffer:(CVPixelBufferRef)pixelBuffer withPresentationTime:(CMTime)presentationTime;

/**
 *  @abstract 音视频编码后的数据
 */
- (void)didEncodeVideoData:(NSData *)data;
- (void)didEncodeAudioData:(NSData *)data;

- (void)didCaptureStopRunningWithError:(NSError *)error;

#pragma mark 分段录制相关回调
/**
 *  @abstract 开始录制一段视频
 */
- (void)didStartRecordingSegment:(int)segmentId;

/**
 *  @abstract 正在录制的过程中。在完成该段视频录制前会一直回调，可用来更新视频段时长
 */
- (void)didRecordingSegment:(int)segmentId
               fileDuration:(CGFloat)fileDuration;

/**
 *  @abstract 完成一段视频的录制
 */
- (void)didFinishRecordingSegment:(int)segmentId
                     fileDuration:(CGFloat)fileDuration
                            error:(nullable NSError *)error;

#pragma mark 合成相关回调
- (void)didJoinSegmentsProgress:(float)progress;

/**
 *  @abstract 合成结束回调
 *  @param status 合成状态 1=end、2=cancel、-100=error
 *  @param segmentsInfo 录制的片段信息
 *  @param fileInfo 合成后的文件信息
 */
- (void)didJoinSegmentsFinish:(int)status
                 segmentsInfo:(NSArray<QHVCRecordSegmentInfo *> *)segmentsInfo
                     fileInfo:(QHVCRecordFileInfo *)fileInfo
                        error:(nullable NSError *)error;

#pragma mark 拍照片相关

- (void)didFinishProcessingPhoto:(NSData *)photoData error:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
