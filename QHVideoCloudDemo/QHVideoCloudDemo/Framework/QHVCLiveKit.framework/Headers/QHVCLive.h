//
//  QHVCLive.h
//  QHVCLiveKit
//
//  Created by niezhiqiang on 2018/1/9.
//  Copyright © 2018年 qihoo360. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, QHVCLiveError)
{
    QHVCLiveError_NoError,                       //无错误
    QHVCLiveError_NotSupport,                    //不支持
    QHVCLiveError_ParamError,                    //参数错误
    QHVCLiveError_InitFailed,                    //初始化失败
};

typedef NS_ENUM(NSUInteger, QHVCLiveDetailError)
{
    QHVCLiveDetailError_NoError,                //无错误
};

typedef NS_ENUM(NSUInteger, QHVCLiveRenderMode)
{
    QHVCLiveRenderModeAspectFill,               //等比填充画布，可能会裁剪
    QHVCLiveRenderModeAspectFit,                //等比填充画布，可能会有黑边,
    QHVCLiveRenderModeScaleToFill,              //完全铺满画布，可能会变形
};

typedef NS_ENUM(NSUInteger, QHVCLiveOutputPreset)
{
    QHVCLiveOutputPreset352x288 = 0,
    QHVCLiveOutputPreset640x480,
    QHVCLiveOutputPreset1280x720,
    QHVCLiveOutputPreset1920x1080,
    QHVCLiveOutputPreset3840x2160               //4k iOS9以后生效
};

typedef NS_ENUM(NSUInteger, QHVCLiveVideoOrientation)
{
    QHVCLiveVideoOrientationPortrait,           //垂直方向
    QHVCLiveVideoOrientationLandscapeRight,     //水平方向，屏幕相对home键在右
    QHVCLiveVideoOrientationLandscapeLeft,      //水平方向，屏幕相对home键在左
};

typedef NS_ENUM(NSUInteger, QHVCLiveTorchMode)
{
    QHVCLiveTorchModeOff,                       //关闭闪光灯
    QHVCLiveTorchModeOn,                        //开启闪光灯
    QHVCLiveTorchModeAuto,                      //自动开关闪光灯
};

typedef NS_ENUM(NSUInteger, QHVCLiveCameraPosition)
{
    QHVCLiveCameraPositionFront,                //前置摄像头
    QHVCLiveCameraPositionBack,                 //后置摄像头
};

typedef NS_ENUM(NSUInteger, QHVCLiveFilterType)
{
    QHVCLiveFilterTypeNormal,                   //滤镜颜色：无（color：B7B7B7）
    QHVCLiveFilterTypeNature,                   //自然（color：FFC0A5）
    QHVCLiveFilterTypeClean,                    //清新（color：B3CBE8）
    QHVCLiveFilterTypeVivid,                    //鲜艳（color：EF4C4C）
    QHVCLiveFilterTypeFresh,                    //淡雅（color：7D93D8）
    QHVCLiveFilterTypeSweety,                   //糖果（color：FFB9D2）
    QHVCLiveFilterTypeRosy,                     //玫瑰（color：E05086）
    QHVCLiveFilterTypeLolita,                   //洛丽塔(color：E29994)
    QHVCLiveFilterTypeSunset,                   //日落（color：EF8401）
    QHVCLiveFilterTypeGrass,                    //草原（color：8BBF9F）
    QHVCLiveFilterTypeCoral,                    //珊瑚色(color：2BBACF)
    QHVCLiveFilterTypePink,                     //粉嫩（color：FFB9D2）
    QHVCLiveFilterTypeUrban,                    //都市（color：58DEE0）
    QHVCLiveFilterTypeCrisp,                    //新鲜（color：52CCBF）
    QHVCLiveFilterTypeBeach,                    //海滨（color：2A84C8）
    QHVCLiveFilterTypeVintage,                  //酒红（color：881212）
};

typedef struct
{
    int width;
    int height;
    int video_bitrate;
    int fps;
    int keyframeInterval;

    int audio_bitrate;
    int samplerate;
    int channels;
}QHVCLiveRecordConfig;

/**
 日志级别
 */
typedef NS_ENUM(NSInteger, QHVCLiveLogLevel)
{
    QHVCLiveLogLevelTrace = 0,//trace
    QHVCLiveLogLevelDebug = 1,//debug
    QHVCLiveLogLevelInfo  = 2,//info
    QHVCLiveLogLevelWarn  = 3,//warn
    QHVCLiveLogLevelError = 4,//error
    QHVCLiveLogLevelAlarm = 5,//alarm
    QHVCLiveLogLevelFatal = 6,//fatal
};

/**
 录制类型

 - QHVCLiveRecordTypeDefault: 默认录制音视频（注意录制过程中修改无效）
 */
typedef NS_ENUM(NSUInteger, QHVCLiveRecordType)
{
    QHVCLiveRecordTypeDefault,                  //音视频
    QHVCLiveRecordTypeAudio                     //单音频
};

/**
 推流类型

 - QHVCLivePushStreamTypeDefault: 默认推音视频流（注意推流过程中修改无效）
 */
typedef NS_ENUM(NSUInteger, QHVCLivePushStreamType)
{
    QHVCLivePushStreamTypeDefault,               //音视频
    QHVCLivePushStreamTypeVideo,                 //单视频
    QHVCLivePushStreamTypeAudio                  //单音频
};

NS_ASSUME_NONNULL_BEGIN

@protocol QHVCLiveKitDelegate <NSObject>

@optional

/**
 当前视频预览画面截图回调
 
 @param buffer 画面数据对象
 */
- (void)onTakeSnapshot:(CVPixelBufferRef _Nullable )buffer;

/**
 调度完成回调

 @param isSuccess 是否调度成功
 @param sn 拉流SN
 @param publishUrl 推流地址
 */
- (void)onPreparePublishWithStatus:(BOOL)isSuccess sn:(NSString * _Nullable)sn publishUrl:(NSString * _Nullable)publishUrl;

/**
 视频帧原始数据
 @param buffer 视频帧数据对象
 */
- (void)onVideoCaptureBuffer:(CMSampleBufferRef _Nullable )buffer;

/**
 音频帧原始数据
 @param buffer 音频帧数据对象
 */
- (void)onAudioCaptureBuffer:(CMSampleBufferRef _Nullable )buffer;

/**
 视频帧处理后数据
 @param buffer 视频帧数据对象
 */
- (void)onVideoProcessedBuffer:(CVPixelBufferRef _Nullable )buffer;

/**
 音频帧处理后数据
 @param buffer 音频帧数据对象
 */
//- (void)onAudioProcessedBuffer:(CMSampleBufferRef _Nullable )buffer;

/**
 分段录制回调

 @param index 索引
 @param duration 总时长MS
 */
- (void)segmentVideoIndex:(NSInteger)index duration:(long)duration;

/**
 合成状态回调接口
 
 @param status 合成状态 0 success
 @param progress 合成进度 0~1
 */
- (void)combineVideoStatus:(int)status progress:(CGFloat)progress;

@end

@interface QHVCLive : NSObject

@property (nonatomic, weak) _Null_unspecified id<QHVCLiveKitDelegate> liveDelegate;
/**
 QHVCLive初始化
 
 @return QHVCLive单例对象
 */
+ (instancetype)sharedInstance;

/**
 获取业务ID
 
 @return 业务ID
 */
- (NSString *)currentSessionId;

#pragma mark - 采集相关
/**
 设置相机预览画布
 
 @param preview 预览画布
 */
- (void)setPreviewView:(UIView *)preview;

/**
 捕获相机
 */
- (void)startCapture;

/**
 关闭相机
 */
- (void)stopCapture;

#pragma mark - 相机控制
/**
 设置相机采集方向，默认为 AVCaptureVideoOrientationPortrait
 需在startCapture前调用
 
 @param videoOrientation  相机采集方向
 */
- (void)setVideoOrientation:(QHVCLiveVideoOrientation)videoOrientation;

/**
 获取当前视频采集方向
 
 @return 视频采集方向
 */
- (QHVCLiveVideoOrientation)currentVideoOrientation;

/**
 设置闪光灯模式
 
 @param mode 闪光灯模式
 */
- (void)setTorchMode:(QHVCLiveTorchMode)mode;

/**
 获取当前相机闪光灯模式
 
 @return 闪光灯模式
 */
- (QHVCLiveTorchMode)currentCameraTorchMode;

/**
 设置摄像头位置(前置/后置), 默认启用前置摄像头
 
 @param position 摄像头位置
 */
- (void)setCameraPosition:(QHVCLiveCameraPosition)position;

/**
 获取当前相机摄像头位置（前置/后置）
 
 @return 摄像头位置
 */
- (QHVCLiveCameraPosition)currentCameraPosition;

/**
 设置摄像头焦距，默认为最小值1.0
 
 @param factor 摄像头焦距
 @return 调整后的实际焦距
 */
- (CGFloat)setVideoZoomFactor:(CGFloat)factor;

/**
 设置摄像头焦点
 
 @param point 焦点
 */
- (void)setVideoFocusPointOfInterest:(CGPoint)point;

#pragma mark - 推流相关
/**
 设置推流地址
 @param rtmpAddr 推流地址（rtmp://）
 @return 是否设置成功
 */
- (QHVCLiveError)preparePushStream:(NSString *)rtmpAddr;

/**
 @param type 推流类型
 @return 错误类型
 */
- (QHVCLiveError)setPushStreamType:(QHVCLivePushStreamType)type;

/**
 开始推流
 @return 错误类型
 */
- (QHVCLiveError)startPushStream;

/**
 关闭推流
 */
- (void)stopPushStream;

#pragma mark - 录制相关

/**
 @param type 录制类型
 @return 错误类型
 */
- (QHVCLiveError)setRecordType:(QHVCLiveRecordType)type;

/**
开始录制
@param filePath 录像存储路径（确保有读写权限）
@param config   配置
@return 错误类型
 */
- (QHVCLiveError)startRecord:(NSString *)filePath recordConfig:(QHVCLiveRecordConfig * _Nullable)config;

/**
 开始录制
 @param filePath 录像存储路径（确保有读写权限）
 @return 错误类型
 */
- (QHVCLiveError)startRecord:(NSString *)filePath;

/**
 停止录制
 */
- (void)stopRecord;

+ (void)setLogLevel:(QHVCLiveLogLevel)level;

+ (NSString *)getVersion;

@end

NS_ASSUME_NONNULL_END
