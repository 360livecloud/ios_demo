//
//  QHVCLive+Advance.h
//  QHVCLiveKit
//
//  Created by niezhiqiang on 2018/1/9.
//  Copyright © 2018年 qihoo360. All rights reserved.
//

#import "QHVCLive.h"

@interface QHVCLive (Advance)

#pragma mark - 视频采集相关
/**
 关闭视频帧
 @param enabled 是否关闭视频帧
 */
- (void)enableVideoFrame:(BOOL)enabled;

/**
 前置摄像头开启/关闭镜像，默认开启
 
 @param isMirrored 是否开启镜像
 */
- (void)setFrontCameraMirrored:(BOOL)isMirrored;

/**
 前置摄像头是否开启镜像

 @return 是否开启
 */
- (BOOL)frontCameraMirrored;

/**
 设置预览画面渲染模式，默认 QHVCLiveRenderModeAspectFill
 
 @param renderMode 画面渲染模式
 */
- (void)setPreviewRenderMode:(QHVCLiveRenderMode)renderMode;

/**
 设置相机输出图像分辨率，默认宽:720 高:1280
 
 @param preset 图像分辨率
 */
- (void)setCameraOutputResolution:(QHVCLiveOutputPreset)preset;

/**
 截取预览图像
 截取的图像通过[QHVCLiveKitDelegate onTakeSnapshot:] 回调接口返回
 
 @return 是否截取成功
 */
- (QHVCLiveError)takeSnapShot;

#pragma mark - 音频采集相关
/**
 静音

 @param mute 是否静音
 */
- (void)setMute:(BOOL)mute;

/**
 设置音频采样率，单位：hz，默认44100
 
 @param sampleRate 音频采样率
 @return 是否设置成功
 */
- (QHVCLiveError)setAudioSampleRate:(NSInteger)sampleRate;

/**
 设置音频采样声道数，默认1，单声道
 
 @param channels 采样声道数
 @return 是否设置成功
 */
- (QHVCLiveError)setAudioChannels:(NSInteger)channels;

#pragma mark - 编码相关
/**
 编码器开关（默认开启）
 @param on 是否开启
 */
- (void)encoderSwitch:(BOOL)on;

/**
 设置视频编码码率，默认值800kbps
 如果开启码率自适应，该值为初始码率
 
 @param kbps 编码码率
 @return 是否设置成功
 */
- (QHVCLiveError)setVideoEncoderBitrate:(int)kbps;

/**
 设置视频编码器每秒编码帧数，默认15
 
 @param fps 每秒编码帧数
 @return 是否设置成功
 */
- (QHVCLiveError)setVideoEncoderFPS:(int)fps;

/**
 设置视频编码器关键帧间隔，默认2s(单位：秒)
 
 @param interval 关键帧间隔
 @return 是否设置成功
 */
- (QHVCLiveError)setVideoEncoderKeyframeInterval:(int)interval;

/**
 设置视频编码器输出分辨率，默认不改变原始采集分辨率
 
 @param size 编码器输出分辨率
 @return 是否设置成功
 */
- (QHVCLiveError)setVideoEncoderResolution:(CGSize)size;

#pragma mark - 推流相关
/**
 设置用户ID
 @param uid 用户ID
 */
- (void)setUserID:(NSString *)uid;

/**
 设置渠道ID
 @param cid 渠道ID
 */
- (void)setChannelID:(NSString *)cid;
/**
 签名验证
 @param uSign 签名
 */
- (void)setServerSignKey:(NSString *)uSign;

/**
 设置调度地址
 @param schedulUrl 调度地址
 */
- (void)setSchedulUrl:(NSString *)schedulUrl;

/**
 设置流id
 @param streamID 流id
 */
- (void)setStreamID:(NSString *)streamID;

/**
 设置调度参数
 @param params 调度参数
 */
- (void)setSchedulParams:(NSDictionary *)params;

/**
 停止推流
 @param extraInfo 保留字段(1000 切换编码器续推-连麦)
 @return 是否停止成功
 */
- (QHVCLiveError)stopPublishing:(NSInteger)extraInfo;

/**
 开启/关闭视频编码器码率控制，默认开启
 码率控制可以在带宽不足的情况下调整编码码率以自动适应当前带宽
 @param enabled 开启/关闭
 @return 是否这种成功
 */
- (QHVCLiveError)enableVideoEncoderBitrateControl:(BOOL)enabled;

/**
 发送用户自定义数据
 数据体最大不超过4k
 @param data 用户自定义数据
 @param immediate 是否立即发送, true：立即发送，false：随视频数据一起发送
 @return 是否发送成功
 */
- (QHVCLiveError)videoEncoderSendUserData:(NSData *)data withVideoFrame:(BOOL)immediate;

/**
 外部输入视频帧
 @param buffer 视频帧
 @param frameTime 时间戳
 */
- (void)externalInputVideoBuffer:(CVPixelBufferRef)buffer timestamp:(CMTime)frameTime;

#pragma mark - 滤镜相关
/**
 添加水印
 
 @param masks 需要添加的水印图
 @return 是否添加成功
 */
- (QHVCLiveError)addWaterMasks:(NSArray<UIView *> *)masks;

/**
 更新已添加的水印
 需确保更新的水印已经添加过
 
 @param masks 需要更新的水印
 @return 是否更新成功
 */
- (QHVCLiveError)updateWaterMasks:(NSArray<UIView *> *)masks;

/**
 删除已添加的水印
 需确保删除的水印已经添加过
 
 @param masks 需要删除的水印
 @return 是否删除成功
 */
- (QHVCLiveError)removeWaterMasks:(NSArray<UIView *> *)masks;

/**
 显示滤镜效果
 
 @param filterType 滤镜类型
 @return 是否显示成功
 */
- (QHVCLiveError)showFilter:(QHVCLiveFilterType)filterType;

/**
 关闭滤镜效果
 
 @return 是否关闭成功
 */
- (QHVCLiveError)stopFilter;

#pragma mark - 美颜相关
/**
 是否支持美颜功能
 
 @return 是否支持美颜功能
 */
- (BOOL)isSupportBeauty;

/**
 启用美颜功能，默认开启
 */
- (BOOL)openBeauty;

/**
 关闭美颜功能
 */
- (BOOL)closeBeauty;

/**
 设置美颜程度，默认0.5
 范围：0~1
 
 @param factor 美颜程度
 @return 是否设置成功
 */
- (QHVCLiveError)setBeautyFactor:(float)factor;

/**
 设置美白程度，默认0.5
 范围0~1
 
 @param factor 美白程度
 @return 是否设置成功
 */
- (QHVCLiveError)setWhitenFactor:(float)factor;

/**
 设置瘦脸程度，默认0
 范围0~1
 
 @param factor 瘦脸程度
 @return 是否设置成功
 */
- (QHVCLiveError)setFaceFactor:(float)factor;

/**
 设置大眼程度，默认0
 范围0~1
 
 @param factor 大眼程度
 @return 是否设置成功
 */
- (QHVCLiveError)setEyeFactor:(float)factor;

/**
 获取当前美颜程度
 
 @return 美颜程度
 */
- (CGFloat)currentBeautyFactor;

/**
 获取当前美白程度
 
 @return 美白程度
 */
- (CGFloat)currentWhitenFactor;

/**
 获取当前瘦脸程度
 
 @return 瘦脸程度
 */
- (CGFloat)currentFaceFactor;

/**
 获取当前大眼程度
 
 @return 大眼程度
 */
- (CGFloat)currentEyeFactor;

#pragma mark - 脸萌相关
/**
 是否支持萌颜功能
 
 @return 是否支持萌颜功能
 */
- (BOOL)isSupportFaceu;

/**
 显示萌颜
 
 @param sourcePath 萌颜存储路径
 @return 是否显示成功
 */
- (QHVCLiveError)showFaceu:(NSString *)sourcePath;

/**
 停止显示萌颜
 
 @return 是否停止成功
 */
- (QHVCLiveError)stopFaceu;

#pragma mark - 其他
/**
 设置经度、玮度
 用于优化调度，定期由业务调用
 
 @param longitude 经度
 @param latitude 纬度
 @return 是否设置成功
 */
- (QHVCLiveError)setGPSInfo:(CGFloat)longitude latitude:(CGFloat)latitude;

@end
