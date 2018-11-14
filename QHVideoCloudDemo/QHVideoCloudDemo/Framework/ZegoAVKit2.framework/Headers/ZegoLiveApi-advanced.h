//
//  ZegoLiveApi-advanced.h
//  zegoavkit
//
//  Copyright © 2016年 Zego. All rights reserved.
//

#ifndef ZegoLiveApi_advanced_h
#define ZegoLiveApi_advanced_h

#import "ZegoLiveApi.h"
#import "ZegoAVDefines.h"
#import "zego-api-defines-oc.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_OSX
#import <AppKit/AppKit.h>
#endif


@protocol ZegoLiveApiRenderDelegate <NSObject>

/// \brief 从外部获取渲染需要的PixelBuffer地址
/// \param width 视频宽度
/// \param height 视频高度
/// \param stride 图像stride padding
- (CVPixelBufferRef)onCreateInputBufferWithWidth:(int)width height:(int)height stride:(int)stride;

/// \breif 视频数据拷贝完成
/// \param pixelBuffer 拷贝完的视频数据
/// \param index 视频播放对应的index
- (void)onPixelBufferCopyed:(CVPixelBufferRef)pixelBuffer index:(RemoteViewIndex)index;

@end


@protocol ZegoLiveApiAudioRecordDelegate <NSObject>

@optional


/// \brief 音频录制回调
/// \param audioData SDK 录制的音频源数据
/// \param sampleRate 采样率，与 [ZegoLiveApi enableSelectedAudioRecord] 中设置的值一致
/// \param numOfChannels 通道数量，单通道
/// \param bitDepth 位深度，16 bit
/// \param type 音源类型，参考 ZegoAPIAudioRecordMask
/// \discussion 开启音频录制并设置成功代理对象后，用户调用此 API 获取 SDK 录制的音频数据。用户可自行对数据进行处理，例如：存储等。SDK 发送音频数据的周期为 20ms。存储数据时注意取 sampleRate、numOfChannels、bitDepth 参数写包头信息。退出房间后或停止录制后，该回调不再被调用
- (void)onAudioRecord:(NSData *)audioData sampleRate:(int)sampleRate numOfChannels:(int)numOfChannels bitDepth:(int)bitDepth type:(unsigned int)type;

/// \brief 音频录制回调
/// \warning Deprecated，请使用 onAudioRecord:sampleRate:numOfChannels:bitDepth:type:
- (void)onAudioRecord:(NSData *)audioData sampleRate:(int)sampleRate numOfChannels:(int)numOfChannels bitDepth:(int)bitDepth __attribute__ ((deprecated));

@end


typedef enum : NSUInteger {
    Play_BeginRetry = 1,
    Play_RetrySuccess = 2,
    
    Publish_BeginRetry = 3,
    Publish_RetrySuccess = 4,
    
    Play_TempDisconnected = 5,
    Publish_TempDisconnected = 6,
    
    Play_VideoBreak = 7,
} ZegoLiveEvent;

typedef NS_ENUM(NSInteger, ZegoCapturePipelineScaleMode) {
    ZegoCapturePipelinePreScale = 0,
    ZegoCapturePipelinePostScale = 1,
};

@protocol ZegoLiveEventDelegate <NSObject>

- (void)zego_onLiveEvent:(ZegoLiveEvent)event info:(NSDictionary<NSString*, NSString*>*)info;

@end

@protocol ZegoVideoFilterFactory;


@protocol ZegoDeviceEventDelegate <NSObject>

/**
 设备事件回调
 
 @param deviceName 设备名，支持摄像头和麦克风设备，参考 ZegoLiveRoomApiDefines.h 中定义
 @param errorCode 错误码。设备无错误不会回调，目前出错后的错误码均为 -1
 @discussion 调用 [ZegoLiveApi -setDeviceEventDelegate] 设置设备事件代理对象后，在此回调中获取设备状态或错误
 */
- (void)zego_onDevice:(NSString *)deviceName error:(int)errorCode;

#if TARGET_OS_OSX

@optional

/**
 音频设备改变状态的回调
 
 @param deviceId 设备ID
 @param deviceName 设备名
 @param deviceType 设备类型，参考 zego-api-defines-oc.h 中 ZegoAPIAudioDeviceType 的定义
 @param state   设备状态，参考 zego-api-defines-oc.h 中 ZegoAPIDeviceState 的定义
 @discussion 调用 [ZegoLiveApi -setDeviceEventDelegate] 设置设备事件代理对象后，在此回调中获取音频设备改变状态的信息
 */
- (void)zego_onAudioDevice:(NSString *)deviceId deviceName:(NSString *)deviceName deviceType:(ZegoAPIAudioDeviceType)deviceType changeState:(ZegoAPIDeviceState)state;

/**
 音频设备音量变化的回调
 
 @param deviceId 设备ID
 @param deviceType 设备类型，参考 zego-api-defines-oc.h 中 ZegoAPIAudioDeviceType 的定义
 @param volume 音量，有效值 0 ~ 100
 @param volumeType  音量类型，参考 zego-api-defines-oc.h 中 ZegoAPIVolumeType 的定义
 @discussion 调用 [ZegoLiveApi -setDeviceEventDelegate] 设置设备事件代理对象后，在此回调中获取音频设备音量变化的信息
 */
- (void)zego_onAudioDevice:(NSString *)deviceId deviceType:(ZegoAPIAudioDeviceType)deviceType changeVolume:(uint32_t)volume volumeType:(ZegoAPIVolumeType)volumeType mute:(bool)mute;

/**
 视频设备改变状态的回调
 
 @param deviceId 设备ID
 @param deviceName 设备名
 @param state   设备状态，参考 zego-api-defines-oc.h 中 ZegoAPIDeviceState 的定义
 @discussion 调用 [ZegoLiveApi -setDeviceEventDelegate] 设置设备事件代理对象后，在此回调中获取视频设备改变状态的信息
 */
- (void)zego_onVideoDevice:(NSString *)deviceId deviceName:(NSString *)deviceName changeState:(ZegoAPIDeviceState)deviceState;

#endif

@end

@interface ZegoLiveApi (Advanced)

/// \brief 获取 SDK 支持的最大同时播放流数
/// \return 最大支持播放流数
+ (int)getMaxPlayChannelCount;

/// \brief 设置业务类型
/// \param type 业务类型，默认为 0
/// \note 确保在创建接口对象前调用
+ (void)setBusinessType:(int)type;

/// \brief 设置外部采集模块
/// \param factory 工厂对象
/// \note 必须在 InitSDK 前调用，并且不能置空
+ (void)setVideoCaptureFactory:(id<ZegoVideoCaptureFactory>)factory;

/// \brief 设置外部渲染
/// \param externalRender 是否外部渲染
/// \note 必须在InitSDK前调用
+ (void)setExtenralRender:(BOOL)externalRender;

/// \brief 作为主播开始直播
/// \param title 直播标题
/// \param streamID 流 ID
/// \param mixStreamID 混流ID
/// \param flag 推流标记(按位取值)，参考 ZegoAPIPublishFlag
/// \return true 成功，等待异步结果回调，否则失败
- (bool)startPublishingWithTitle:(NSString *)title streamID:(NSString *)streamID mixStreamID:(NSString *)mixStreamID mixVideoSize:(CGSize)videoSize flag:(int)flag;

/// \brief 停止直播
/// \param flag 保留字段
/// \param msg 自定义信息，server对接流结束回调包含此字段内容
/// \return true 成功，否则失败
- (bool)stopPublishingWithFlag:(int)flag msg:(NSString *)msg;

/// \brief 更新混流配置
/// \param lstMixStreamInfo 混流配置列表，按列表顺序叠加涂层
/// \note lstMixStreamInfo 设置为nil时停止混流
/// \return true 成功，等待异步结果回调，否则失败
- (bool)updateMixStreamConfig:(NSArray<ZegoMixStreamInfo*> *)lstMixStreamInfo;

/// \brief 设置播放渲染朝向
/// \param rotate 逆时针旋转角度
/// \param index 播放通道
/// \return true 成功，false 失败
- (bool)setRemoteViewRotation:(CAPTURE_ROTATE)rotate viewIndex:(RemoteViewIndex)index;

#if TARGET_OS_IPHONE
/// \brief 设置App的朝向，确定进行横竖屏采集
/// \param orientation app orientation
/// \return true 成功，false 失败
- (bool)setAppOrientation:(UIInterfaceOrientation)orientation;
#endif

/// \brief 开启采集监听
/// \param bEnable true打开，false关闭
/// \return true:调用成功；false:调用失败
- (bool)enableLoopback:(bool)bEnable;

/// \brief 统一设置播放音量
/// \param volume 音量大小 0 ~ 100
- (void)setPlayVolume:(int)volume;

/// \brief 设置单流的播放音量
/// \param volume 音量大小 0 ~ 100
/// \viewIndex 拉流通道index
- (void)setPlayVolume:(int)volume viewIndex:(RemoteViewIndex)viewIndex;

/// \brief 设置采集监听音量
/// \param volume 音量大小 0 ~ 100
- (void)setLoopbackVolume:(int)volume;

/// \brief 获取 SDK 版本1
+ (NSString *)version;

/// \brief 获取 SDK 版本2
+ (NSString *)version2;

/// \brief 混音开关
/// \param enable true 启用混音输入；false 关闭混音输入
/// \return true 成功，否则失败
- (bool)enableAux:(BOOL)enable;

/// \brief 音频录制开关
/// \param enable true 启用音频录制回调；false 关闭音频录制回调
/// \return true 成功，false 失败
/// \warning Deprecated，请使用 enableSelectedAudioRecord
- (bool)enableAudioRecord:(BOOL)enable;

/// \brief 音频录制开关
/// \param config 配置信息, 参考 ZegoAPIAudioRecordConfig
/// \return true 成功，false 失败
/// \note 初始化 SDK 后调用，开启音频录制后，需调用 [ZegoLiveApi setAudioRecordDelegate] 获取音频数据
-(bool)enableSelectedAudioRecord:(ZegoAPIAudioRecordConfig)config;

/// \brief 设置美颜磨皮的采样步长
/// \param step 采样半径 取值范围[1,16]
- (bool)setPolishStep:(float)step;

/// \brief 设置美颜采样颜色阈值
/// \param factor 取值范围[0,16]
/// \return true 成功，否则失败
- (bool)setPolishFactor:(float)factor;

/// \brief 设置美颜美白的亮度修正参数
/// \param factor 取值范围[0,1]， 参数越大亮度越暗
- (bool)setWhitenFactor:(float)factor;

/// \brief 设置锐化参数
/// \param factor 取值范围[0,2]，参数边缘越明显
- (bool)setSharpenFactor:(float)factor;

/// \brief 是否启用前摄像头预览镜像
/// \param enable true 启用，false 不启用
/// \return true 成功，否则失败
- (bool)enablePreviewMirror:(bool)enable;

/// \brief 是否启用摄像头采集结果镜像
/// \param enable true 启用，false 不启用
/// \return true 成功，否则失败
- (bool)enableCaptureMirror:(bool)enable;

/// \brief 是否开启码率控制（在带宽不足的情况下码率自动适应当前带宽)
/// \param enable true 启用，false 不启用
/// \return true 成功，否则失败
- (bool)enableRateControl:(bool)enable;

/// \brief 混音输入播放静音开关
/// \param bMute true: aux 输入播放静音；false: 不静音
- (bool)muteAux:(bool)bMute;

/// \brief 是否启用测试环境
+ (void)setUseTestEnv:(bool)useTestEnv;

/// \brief 调试信息开关
/// \desc 建议在调试阶段打开此开关，方便调试。默认关闭
+ (void)setVerbose:(bool)bOnVerbose;

/// \brief 外部渲染回调
/// \param renderDelegate 外部渲染回调协议
- (void)setRenderDelegate:(id<ZegoLiveApiRenderDelegate>)renderDelegate;

/// \brief 音频录制回调
/// \param audioRecordDelegate 音频录制回调协议
- (void)setAudioRecordDelegate:(id<ZegoLiveApiAudioRecordDelegate>)audioRecordDelegate;

/// \brief 直播事件通知回调
/// \param liveEventDelegate 直播事件通知回调协议
- (void)setLiveEventDelegate:(id<ZegoLiveEventDelegate>)liveEventDelegate;

/// \brief 音视频设备错误通知回调
/// \param deviceEventDelegate 直播事件通知回调协议
- (void)setDeviceEventDelegate:(id<ZegoDeviceEventDelegate>)deviceEventDelegate;

/// \brief 获取当前采集的音量
/// \return 当前采集音量大小
- (float)getCaptureSoundLevel;

/// \brief 获取当前播放视频的音量
/// \param[in] channelIndex 播放通道
/// \return channelIndex对应视频的音量
- (float)getRemoteSoundLevel:(int)channelIndex;

/// \brief 设置外部滤镜模块
/// \param factory 工厂对象
/// \note 必须在 Init 前调用，并且不能置空
+ (void)setVideoFilterFactory:(id<ZegoVideoFilterFactory>)factory;

/// \brief 设置编码器码率控制策略
/// \param strategy 策略配置，参考 ZegoAPIVideoEncoderRateControlStrategy
/// \param crf 当策略为恒定质量（ZEGOAPI_RC_VBR/ZEGOAPI_RC_CRF）有效，取值范围 [0~51]，越小质量越好，建议取值范围 [18, 28]
+ (void)setVideoEncoderRateControlStrategy:(int)strategy encoderCRF:(int)crf;

/// \brief 设置拉流质量监控周期
/// \param timeInMS 时间周期，单位为毫秒，取值范围：(500, 60000)
+ (void)setPlayQualityMoniterCycle:(unsigned int)timeInMS;

/// \brief 设置水印的图片路径
/// \param filePath 图片路径。如果是完整路径则添加 file: 前缀，如：@"file:/var/image.png"；资产则添加 asset: 前缀，如：@"asset:watermark"
- (void)setWaterMarkImagePath:(NSString *)filePath;

/// \brief 设置水印在采集video中的位置
/// \note  左上角为坐标系原点,区域不能超过编码分辨率设置的大小
- (void)setPublishWaterMarkRect:(CGRect)waterMarkRect;

/// \brief 设置水印在预览video中的位置
/// \note 左上角为坐标系原点,区域不能超过preview的大小
- (void)setPreviewWaterMarkRect:(CGRect)waterMarkRect;

/// \brief 暂停模块
/// \param moduleType 模块类型，参考 ZegoAPIModuleType
- (void)pauseModule:(int)moduleType;

/// \brief 恢复模块
/// \param moduleType 模块类型，参考 ZegoAPIModuleType
- (void)resumeModule:(int)moduleType;

/**
 拉流是否接收音频数据
 
 @param index 拉流通道索引
 @param active true 接收，false 不接收
 @return 0 成功，否则失败
 @attention 仅拉 UDP 流有效
 */
- (int)activateAudioPlayStream:(int)index active:(bool)active;

/**
 拉流是否接收视频数据
 
 @param index 拉流通道索引
 @param active true 接收，false 不接收
 @return 0 成功，否则失败
 @attention 仅拉 UDP 流有效
 */
- (int)activateVedioPlayStream:(int)index active:(bool)active;

/// \brief 耳机插入状态下是否使用回声消除
/// \param enable true 使用，false 不使用
/// \note 在推流之前调用
- (void)enableAECWhenHeadsetDetected:(bool)enable;

/// \brief 是否启用软件回声消除
/// \param enable true 使用，false 不使用
- (void)enableSoftwareAEC:(bool)enable;

/// \brief 设置视频采集后的缩放时机
/// \param scaleMode 参考 ZegoCapturePipelineScaleMode
- (void)setCapturePipelineScaleMode:(ZegoCapturePipelineScaleMode)scaleMode;

/// \brief 设置音频码率
/// \param bitrate 码率，单位 b/s
/// \return true 成功，false 失败
- (bool)setAudioBitrate:(int)bitrate;

/// \brief 设置音频设备模式
/// \param mode 模式, 默认 ZEGOAPI_AUDIO_DEVICE_MODE_AUTO
/// \note 在 Init 前调用
+ (void)setAudioDeviceMode:(ZegoAPIAudioDeviceMode)mode;

/// \brief 音频采集自动增益开关
/// \param enable 是否开启
/// \return true 成功，false 失败
- (bool)enableAGC:(bool)enable;

/// \brief 设置混流配置
/// \param config 配置信息，参考 kMixStreamAudioOutputFormat
- (void)setMixStreamConfig:(NSDictionary *)config;

/// \brief 自定义推流配置
/// \param config 配置信息，参考 kPublishCustomTarget
- (void)setPublishConfig:(NSDictionary *)config;

/// \brief 帧顺序检测开关
/// \param enable true 检测帧顺序，不支持B帧；false 不检测帧顺序，支持B帧，可能出现短暂花屏
/// \note  init sdk前调用
+ (void)enableCheckPoc:(bool)enable;

/// \brief 发送媒体次要信息开关
/// \param start true 开启, false 关闭
/// \param onlyAudioPublish true 纯音频直播，不传输视频数据, false 音视频直播，传输视频数据
- (void)setMediaSideFlags:(bool)start onlyAudioPublish:(bool)onlyAudioPublish;

/// \brief 发送媒体次要信息
/// \param inData 媒体次要信息数据
/// \param dataLen 数据长度
/// \param packet 是否外部已经打包好包头，true 已打包, false 未打包
- (void)sendMediaSideInfo:(const unsigned char *)inData dataLen:(int)dataLen packet:(bool)packet;

/// \brief 设置回调, 接收媒体次要信息
/// \param onMediaSideCallback 回调函数指针, index 拉流通道索引, buf 媒体数据, dataLen 数据长度
- (void)setMediaSideCallback:(void(*)(int index, const unsigned char* buf, int dataLen))onMediaSideCallback;

/// \brief 设置延迟模式
/// \param mode 延迟模式，默认 ZEGOAPI_LATENCY_MODE_NORMAL
/// \note 在推流前调用
- (void)setLatencyMode:(ZegoAPILatencyMode)mode;

/// \brief 设置推流音频声道数
/// \param count 声道数，1 或 2，默认为 1（单声道）
/// \note  必须在调用推流前设置
/// \note  setLatencyMode 设置为 ZEGOAPI_LATENCY_MODE_NORMAL 或 ZEGOAPI_LATENCY_MODE_NORMAL2 才能设置双声道，在移动端双声道通常需要配合音频前处理才能体现效果
- (void)setAudioChannelCount:(int)count;

/// \brief 设置混音音量
/// \param volume 0~100
- (void)setAuxVolume:(int)volume;

/// \brief 是否开启离散音频包发送
/// \param enable true 开启，此时关闭麦克风后，不会发送静音包；false 关闭，此时关闭麦克风后会发送静音包
/// \note 在推流前调用，只有纯 UDP 方案才可以调用此接口
- (void)enableDTX:(bool)enable;

/// \brief 是否开启流量控制
/// \param enable true 开启；false 关闭
/// \param properties 流量控制属性 (帧率，分辨率）,参考ZegoAPITrafficControlProperty定义
/// \note 在推流前调用，在纯 UDP 方案才可以调用此接口
/// \note 默认开启流量控制，property为ZEGOAPI_TRAFFIC_FPS
- (void)enableTrafficControl:(bool)enable properties:(NSUInteger)properties;

/// \brief 设置配置信息
/// \param config 配置信息
/// \note  init sdk前调用
+ (void)setConfig:(NSString *)config;

#if TARGET_OS_OSX

/// \brief 系统声卡声音采集开关
/// \param[in] bEnable 是否打开
- (void)enableMixSystemPlayout:(bool)enable;

/// \brief 获取麦克风音量
/// \param[in] deviceid 麦克风deviceid
/// \return -1: 获取失败 0 ~100 麦克风音量
/// \note 切换麦克风后需要重新获取麦克风音量
- (int)getMicDeviceVolume:(NSString *)deviceId;

/// \brief 设置麦克风音量
/// \param[in] deviceid 麦克风deviceid volume 音量 0 ~ 100
- (void)setMicDevice:(NSString *)deviceId volume:(int)volume;

/// \brief 获取扬声器音量
/// \param[in] deviceid 杨声器deviceid
/// \return -1: 获取失败 0 ~100 扬声器音量
/// \note 切换扬声器后需要重新获取音量
- (int)getSpeakerDeviceVolume:(NSString *)deviceId;

/// \brief 设置扬声器音量
/// \param[in] deviceid 杨声器deviceid volume 音量 0 ~ 100
- (void)setSpeakerDevice:(NSString *)deviceId volume:(int)volume;

/// \brief 获取app中扬声器音量
/// \param[in] deviceId 扬声器deviceId
- (int)getSpeakerSimpleVolume:(NSString *)deviceId;

/// \breif 设置app中扬声器音量
/// \param[in] deviceId 扬声器deviceId， volume 音量 0 ~ 100
- (void)setSpeaker:(NSString *)deviceId simpleVolume:(int)volume;

/// \brief 获取扬声器是否静音
/// \param[in] deviceId 扬声器设备Id
- (bool)getSpeakerDeviceMute:(NSString *)deviceId;

/// \breif 设置扬声器静音
/// \param[in] devcieId 扬声器设备Id
/// \param[in] mute 静音
- (void)setSpeakerDevice:(NSString *)deviceId mute:(bool)mute;

/// \brief 获取麦克风是否静音
/// \param[in] deviceId 麦克风设备Id
- (bool)getMicDeviceMute:(NSString *)deviceId;

/// \brief 设置麦克风静音
/// \param[in] devcieId 麦克风设备Id
/// \param[in] mute 静音
- (void)setMicDevice:(NSString *)deviceId mute:(bool)mute;

/// \brief 获取app中扬声器是否静音
/// \param[in] deviceId 扬声器设备Id
- (bool)getSpeakerSimpleMute:(NSString *)deviceId;

/// \brief 设置app中扬声器是否静音
/// \param[in] devcieId 设备Id
/// \param[in] mute 静音
- (void)setSpeaker:(NSString *)deviceId simpleMute:(bool)mute;

/// \brief 获取默认的音频设备
/// \param[in] deviceType 音频类型
- (NSString *)getDefaultAudioDeviceId:(ZegoAPIAudioDeviceType)deviceType;

/// \brief 监听设备的音量变化
/// \param[in] devcieType 音频类型
/// \param[in] devcieId 设备Id
/// \note 设置后如果有音量变化（包括app音量）通过IZegoDeviceStateCallback::OnAudioVolumeChanged回调
- (bool)setAudioVolumeNotify:(NSString *)deviceId type:(ZegoAPIAudioDeviceType)deviceType;

/// \brief 停止设备的音量变化监听
- (void)stopAudioVolumeNotify:(NSString *)deviceId type:(ZegoAPIAudioDeviceType)deviceType;

/// \brief 设置视频设备
/// \param[in] deviceId 设备 Id
/// \note 本接口用于 Mac PC 端的业务开发
+ (bool)setVideoDevice:(NSString *)deviceId;

/// \brief 设置音频设备
/// \param[in] deviceId 设备 Id
/// \param[in] deviceType 设备类型
/// \note 本接口用于 Mac PC 端的业务开发
+ (bool)setAudioDevice:(NSString *)deviceId type:(ZegoAPIAudioDeviceType)deviceType;

/// \brief 获取音频设备列表
/// \param[in] deviceType 设备类型
- (NSArray<ZegoAPIDeviceInfo *> *)getAudioDeviceList:(ZegoAPIAudioDeviceType)deviceType;

/// \brief 获取视频设备列表
- (NSArray<ZegoAPIDeviceInfo *> *)getVideoDeviceList;

#endif


@end

#endif /* ZegoLiveApi_advanced_h */
