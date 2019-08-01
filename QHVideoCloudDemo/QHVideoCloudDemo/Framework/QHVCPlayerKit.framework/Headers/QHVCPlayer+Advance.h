//
//  QHVCPlayer+Advance.h
//  QHVCPlayerKit
//
//  Created by yinchaoyu on 2017/5/24.
//  Copyright © 2017年 qihoo 360. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>
#import "QHVCPlayer.h"

/**
 直播资源编码类型
 */
typedef NS_ENUM(NSInteger, QHVCPlayerDecodingType)
{
    QHVCMediaInfoDecodeFormateH264    = 0,//正在解码的是h264
    QHVCMediaInfoDecodeFormateH265    = 1,//正在解码的是h265
};

/**
 播放器播放模式
 */
typedef NS_ENUM(NSInteger, QHVCPlayMode)
{
    QHVCPlayModeFluency      = 0,//流畅模式
    QHVCPlayModeLowLatency   = 1,//低延迟模式
};

typedef NS_ENUM(NSInteger, QHVCRecorderFormat)
{
    QHVCRecordFormatDefault = 0,//默认方式（音、视频）
    QHVCRecordFormatOnlyAudio = 1,//仅音频
    QHVCRecordFormatOnlyVideo = 2,//仅视频
};

typedef struct
{
    int width;
    int height;
    int video_bitrate;
    
    int audio_bitrate;
    int samplerate;
    int channels;
    int fps;
}QHVCRecordConfig;

typedef enum
{
    QHVC_PACKET_TYPE_NONE = 0,
    QHVC_PACKET_TYPE_H264,
    QHVC_PACKET_TYPE_H265,
    QHVC_PACKET_TYPE_AAC,
    QHVC_PACKET_TYPE_OPUS
}QHVC_PACKET_TYPE;

typedef struct QHVCPacket
{
    void    * _Nonnull opaque;//packet
    uint8_t * _Nonnull pData;
    int                size;
    QHVC_PACKET_TYPE   flags;
}QHVCPacket;

/**
 播放器advanceDelegate
 */
@protocol QHVCPlayerAdvanceDelegate <NSObject>

@optional

/**
 播放器实例句柄创建
 */
- (void)onPlayerHandlerCreated:(QHVCPlayer *_Nonnull)player;

/**
 播放器销毁
 */
- (void)onPlayerDestoryed:(QHVCPlayer *_Nonnull)player;

/**
 流量计算回调函数

 @param dvbps 播放器下行视频每秒字节数
 @param dabps 播放器下行音频每秒字节数
 @param dvfps 播放器下行视频每秒帧数
 @param dafps 播放器下行音频每秒帧数
 @param fps 当前fps
 @param bitrate 当前bitrate
 */
- (void)onPlayerNetStats:(long)dvbps
                   dabps:(long)dabps
                   dvfps:(long)dvfps
                   dafps:(long)dafps
                     fps:(long)fps
                 bitrate:(long)bitrate
                  player:(QHVCPlayer *_Nonnull)player;

/**
 编码方式

 @param decodingType 编码类型
 @param sn sheduled_sn_url
 @param errorCode errorCode
 */
- (void)onPlayerDecodingType:(QHVCPlayerDecodingType)decodingType sn:(NSString *_Nullable)sn errorCode:(int)errorCode player:(QHVCPlayer *_Nonnull)player;

/**
 直播预览指定次数结束回调
 */
- (void)onPlayerPreviewFinished:(QHVCPlayer *_Nonnull)player;

/**
 播放实时回调音频buffer
 @param sampleBuffer 音频buffer
 */
- (void)onPlayerAudioDataCallback:(CMSampleBufferRef _Nonnull)sampleBuffer;

/**
 播放实时回调视频buffer
 @param pixelBuffer 视频buffer
 */
- (void)onPlayerVideoDataCallback:(CVPixelBufferRef _Nonnull)pixelBuffer;

/**
 返回原始数据包（注意该接口必须同步处理数据）
 @param packet 数据包结构体
 */
- (void)onPlayerOutputPacket:(QHVCPacket)packet;

@end

@interface QHVCPlayer (Advance)

/**
 播放器扩展delegate
 */
@property (nonatomic, weak) _Null_unspecified id<QHVCPlayerAdvanceDelegate> playerAdvanceDelegate;

/**
 * 开始预调度
 
 * @param sn 资源标识
 * @param channelId channelID
 * @param userId 用户ID
 * @param uSign 鉴权签名
 * @return YES表示成功 NO表示失败
 */
+ (BOOL)prepareScheduling:(NSString * _Nonnull)sn
                channelId:(NSString * _Nullable)channelId
                   userId:(NSString * _Nullable)userId
                    uSign:(NSString * _Nonnull)uSign;

/**
 * 开始预调度,需要使用特定调度地址的情况
 * @param scheduleUrl 预调度地址 格式参考http://g2.live.360.cn/
 * @param sn 资源标识
 * @param channelId channelID
 * @param userId 用户ID
 * @param uSign 鉴权签名
 * @return YES表示成功 NO表示失败
 */
+ (BOOL)prepareScheduling:(NSString * _Nonnull)scheduleUrl
                       sn:(NSString * _Nonnull)sn
                channelId:(NSString * _Nullable)channelId
                   userId:(NSString * _Nullable)userId
                    uSign:(NSString * _Nonnull)uSign;

/**
 初始化播放器
 
 @param SN 要播放的SN
 @param userId 用户id
 @param uSign 验证信息
 @param optionsDict 播放器可选属性字典，可传nil，或者根据实际需要选择部分或者全部属性设置，支持的全部属性如下：
 NSDictionary *playProperty =
 {@"position", @"NSString long",//只适用于点播，设置点播开始到位置(毫秒)
 @"scheduleUrl",@"NSString"//调度地址，需要使用自定义的调度地址时使用
 @"hardDecode", @"boolValue"//播放器硬解开关
 @"renderMode", @QHVCPlayerRenderMode//播放器渲染模式
 @"playMode", @QHVCPlayMode//设置播放器播放模式，流畅/低延时
 @"mute", @"boolValue"//开始播放的时候是否静音0/1
 @"previewDuration", @"NSString int"//视频预览时长(毫秒)
 @"previewLoopCount", @"NSString int"//视频预览指定次数结束
 @"streamType", @"QHVCStreamType"//流类型
 @"notificationBarPlay", @"NSString bool"//通知栏播放
 @"audioSessionCategory"：@"intValue"
 @"setPreferredIOBufferDuration"：@"boolValue"
 }
 
 @return 播放器对象
 */
- (QHVCPlayer * _Nullable)initWithSN:(NSString * _Nonnull)SN
                           channelId:(NSString * _Nullable)channelId
                              userId:(NSString * _Nullable)userId
                               uSign:(NSString * _Nonnull)uSign
                            options:(NSDictionary * _Nullable)optionsDict;

/**
 打开播放器流量统计

 @param intervalBySecond 统计计算周期，单位：秒
 @参见 onPlayerNetStats delegate
 */
- (void)openNetStats:(uint)intervalBySecond;

/**
 关闭播放器流量统计
 */
- (void)closeNetStats;

/**
 镜像模式开关，播放器模式状态是非镜像状态，若启用镜像模式，调用该接口

 @param bMirror 镜像：YES，否则：NO
 */
- (void)setMirror:(BOOL)bMirror;

/**
 连麦加入Group
 
 @param groupID group id
 */
- (void)addToGroup:(int)groupID;

/**
 * 通知GPS，时区信息,用于优化调度CDN，定期由业务调用（切换省市，距离较远时调用，不要频繁调用）
 * @param lon 经度
 * @param lat 纬度
 */
- (void)playerGPSZoneLonLat:(double)lon latitude:(double)lat;

/**
 画质增强开关（本地控制模式时生效，控制模式由云端控制）
 @param enable 开启：YES，关闭：NO
 */
- (void)enableImageEnhanced:(BOOL)enable;

/**
 * 设置视频画质增强filter属性
 * @param brightness 亮度  取值范围(-0.2f, 0.35f)
 * @param contrast 对比度 取值范围(0.9f, 1.6f)
 * @param saturation 饱和度 取值范围(0.15f, 2f)
 */
- (void)enhancedImageQuality:(float)brightness contrast:(float)contrast saturation:(float)saturation;

/**
 * 倍速播放
 *
 * @param rate 播放速度，取值1~n（建议n<=5）
 */
- (void)setPlaybackRate:(float)rate;

/**
 获取播放倍速

 @return 倍速值
 */
- (float)getPlaybackRate;

/**
 销毁音频模块(直播生效)
 */
- (void)destroyAudioModule;

/**
 重启音频模块(直播生效)
 */
- (void)reStartAudioModule;

/**
 设置音频数据回调(注意：只能在onPlayerPrepared之后调用)
 @param isOutput yes输出 no不输出
 */
- (void)setAudioDataOutput:(BOOL)isOutput;

/**
 设置输出视频buffer
 @param isOutput yes输出 no不输出
 @param isUseSoftware yes用cpu,no用gpu转换纹理yuv->bgra
 */
- (void)setVideoDataOutput:(BOOL)isOutput useSoftware:(BOOL)isUseSoftware;

/**
 渲染模式输出宽高比例保持短边可见
 */
- (void)renderModeOutAspectScaleKeepShortEdgeVisible:(BOOL)isAlwaysVisible;

/**
 播放器接收外部数据流（要在prepare之后调用才有效）
 @param type 数据流类型
 @param data 数据流
 @param size 数据流长度
 @param pts 显示时间戳
 @param dts 解码时间戳
 @param isKey 是否是关键帧
 */
- (void)inputStream:(QHVC_PACKET_TYPE)type data:(uint8_t *_Nonnull)data size:(int)size pts:(int64_t)pts dts:(int64_t)dts isKey:(int)isKey;

/**
 * 开始录制(注意：此接口与setAudioDataOutput冲突，先设置的生效)
 * 注意：不支持暂停时录制
 *
 * @param filePath 录像存储路径（确保有读写权限）
 * @param recorderFormat 存储格式
 * @param config   配置
 * @return yes:成功  no: 失败
 */
- (BOOL)startRecorder:(NSString *_Nonnull)filePath recorderFormat:(QHVCRecorderFormat)recorderFormat recordConfig:(QHVCRecordConfig *_Nullable)config;

/**
 * 结束录制(异步接口)
 *
 * @return yes:成功  no: 失败
 */
- (BOOL)stopRecorder;


/**
 视频转gif

 @param inputPath 视频路径
 @param outputPath gif路径
 @param sampleInterval 画面取帧间隔
 @param callback 进度状态回调
 */
+ (void)createGifWithVideo:(NSString *_Nonnull)inputPath outPutPath:(NSString *_Nonnull)outputPath sampleInterval:(NSUInteger)sampleInterval callback:(void (^_Nonnull)(float progress, BOOL completed))callback;

@end
