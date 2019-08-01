//
//  QHVCInteractiveKit.h
//  QHVCInteractiveKit
//
//  Created by yangkui on 2018/1/25.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 枚举对象定义 -

typedef NS_ENUM(NSInteger, QHVCITLLogLevel){//日志等级
    QHVCITL_LOG_LEVEL_TRACE = 0,
    QHVCITL_LOG_LEVEL_DEBUG = 1,
    QHVCITL_LOG_LEVEL_INFO  = 2,
    QHVCITL_LOG_LEVEL_WARN  = 3,
    QHVCITL_LOG_LEVEL_ERROR = 4,
    QHVCITL_LOG_LEVEL_ALARM = 5,
    QHVCITL_LOG_LEVEL_FATAL = 6,
    QHVCITL_LOG_LEVEL_NONE  = 7,
};

typedef NS_ENUM(NSInteger, QHVCITLWarningCode) {//警告代码，代码中可以忽略该消息
    QHVCITL_Warn_InvalidView = 8,
    QHVCITL_Warn_InitVideo = 16,
    QHVCITL_Warn_Pending = 20,
    QHVCITL_Warn_NoAvailableChannel = 103,
    QHVCITL_Warn_LookupChannelTimeout = 104,
    QHVCITL_Warn_LookupChannelRejected = 105,
    QHVCITL_Warn_OpenChannelTimeout = 106,
    QHVCITL_Warn_OpenChannelRejected = 107,
    QHVCITL_Warn_SwitchLiveVideoTimeout = 111,
    // sdk:vos, callmanager, peermanager: 100~1000
    QHVCITL_Warn_SetClientRoleTimeout = 118,
    QHVCITL_Warn_SetClientRoleNotAuthorized = 119,
    QHVCITL_Warn_CodeOpenChannelInvalidTicket = 121,
    QHVCITL_Warn_CodeOpenChannelTryNextVos = 122,
    QHVCITL_Warn_AudioMixingOpenError = 701,
    
    QHVCITL_Warn_Adm_RuntimePlayoutWarning = 1014,
    QHVCITL_Warn_Adm_RuntimeRecordingWarning = 1016,
    QHVCITL_Warn_Adm_RecordAudioSilence = 1019,
    QHVCITL_Warn_Adm_PlaybackMalfunction = 1020,
    QHVCITL_Warn_Adm_RecordMalfunction = 1021,
    QHVCITL_Warn_Adm_Interruption = 1025,
    QHVCITL_Warn_Adm_RecordAudioLowlevel = 1031,
    QHVCITL_Warn_Adm_PlayoutAudioLowlevel = 1032,
    QHVCITL_Warn_Apm_Howling = 1051,
    QHVCITL_Warn_Adm_GlitchState = 1052,
    QHVCITL_Warn_Adm_ImproperSettings = 1053,
};

typedef NS_ENUM(NSInteger, QHVCITLErrorCode) {//错误码，代码中必须处理该消息
    QHVCITL_Error_NoError = 0,
    QHVCITL_Error_Failed = 1,
    QHVCITL_Error_InvalidArgument = 2,
    QHVCITL_Error_NotReady = 3,
    QHVCITL_Error_NotSupported = 4,
    QHVCITL_Error_Refused = 5,
    QHVCITL_Error_BufferTooSmall = 6,
    QHVCITL_Error_NotInitialized = 7,
    QHVCITL_Error_InvalidView = 8,
    QHVCITL_Error_NoPermission = 9,
    QHVCITL_Error_TimedOut = 10,
    QHVCITL_Error_Canceled = 11,
    QHVCITL_Error_TooOften = 12,
    QHVCITL_Error_BindSocket = 13,
    QHVCITL_Error_NetDown = 14,
    QHVCITL_Error_NoBufs = 15,
    QHVCITL_Error_InitVideo = 16,
    QHVCITL_Error_JoinChannelRejected = 17,
    QHVCITL_Error_LeaveChannelRejected = 18,
    QHVCITL_Error_AlreadyInUse = 19,
    QHVCITL_Error_Abort = 20,
    QHVCITL_Error_InitNetEngine = 21,
    QHVCITL_Error_ResourceLimited = 22,
    
    QHVCITL_Error_InvalidAppId = 101,
    QHVCITL_Error_InvalidChannelName = 102,
    QHVCITL_Error_ChannelKeyExpired = 109,
    QHVCITL_Error_InvalidChannelKey = 110,
    QHVCITL_Error_NotInChannel = 113,
    QHVCITL_Error_SizeTooLarge = 114,
    QHVCITL_Error_BitrateLimit = 115,
    QHVCITL_Error_TooManyDataStreams = 116,
    QHVCITL_Error_DecryptionFailed = 120,
    
    QHVCITL_Error_EncryptedStreamNotAllowedPublish = 130,
    QHVCITL_Error_PublishFailed = 150,
    
    QHVCITL_Error_LoadMediaEngine = 1001,
    QHVCITL_Error_StartCall = 1002,
    QHVCITL_Error_StartCamera = 1003,
    QHVCITL_Error_StartVideoRender = 1004,
    QHVCITL_Error_Adm_GeneralError = 1005,
    QHVCITL_Error_Adm_JavaResource = 1006,
    QHVCITL_Error_Adm_SampleRate = 1007,
    QHVCITL_Error_Adm_InitPlayout = 1008,
    QHVCITL_Error_Adm_StartPlayout = 1009,
    QHVCITL_Error_Adm_StopPlayout = 1010,
    QHVCITL_Error_Adm_InitRecording = 1011,
    QHVCITL_Error_Adm_StartRecording = 1012,
    QHVCITL_Error_Adm_StopRecording = 1013,
    QHVCITL_Error_Adm_RuntimePlayoutError = 1015,
    QHVCITL_Error_Adm_RuntimeRecordingError = 1017,
    QHVCITL_Error_Adm_RecordAudioFailed = 1018,
    QHVCITL_Error_Adm_PlayAbnormalFrequency = 1020,
    QHVCITL_Error_Adm_RecordAbnormalFrequency = 1021,
    QHVCITL_Error_Adm_InitLoopback  = 1022,
    QHVCITL_Error_Adm_StartLoopback = 1023,
    QHVCITL_Error_Adm_NoRecordingDevice = 1359,
    QHVCITL_Error_Adm_NoPlayoutDevice = 1360,
    
    // VDM error code starts from 1500
    QHVCITL_Error_Vdm_Camera_Not_Authorized = 1501,
    
    // VCM error code starts from 1600
    QHVCITL_Error_Vcm_Unknown_Error = 1600,
    QHVCITL_Error_Vcm_Encoder_Init_Error = 1601,
    QHVCITL_Error_Vcm_Encoder_Encode_Error = 1602,
    QHVCITL_Error_Vcm_Encoder_Set_Error = 1603,
    
    // 水熊 error code starts from 4000
    QHVCITL_Error_Argument_Missing = 4000,//参数缺失
    QHVCITL_Error_Internal_Exceptional = 4101,//服务内部异常
    QHVCITL_Error_Request_Expired = 4102,//请求已过期
    QHVCITL_Error_Authentication = 4103,//签名验证失败
    QHVCITL_Error_Invalid_Service = 4201,//渠道ID服务不存在
    QHVCITL_Error_Service_Unavailable = 4202,//渠道ID服务未开通
    QHVCITL_Error_Create_Room = 4301,//创建房间失败
    QHVCITL_Error_Join_Room = 4302,//加入房间失败
    QHVCITL_Error_Quit_Room = 4303,//退出房间失败
    QHVCITL_Error_Get_Room_Info = 4304,//获取房间信息失败
    QHVCITL_Error_Update_Member_Attribute = 4305,//更新成员属性失败
    QHVCITL_Error_Update_Room_Attribute = 4306,//更新房间属性失败
    QHVCITL_Error_Update_Heartbeat = 4307,//心跳更新失败
    QHVCITL_Error_Room_Already_Exists = 4308,//房间已存在
    QHVCITL_Error_Invalid_Server_Name = 4309,//渠道ID不可用
    QHVCITL_Error_Generate_RTC_CTX = 4310,//生成连麦信息失败
    QHVCITL_Error_Unavailable_Configuration = 4311,//没有可用的连麦配置
    QHVCITL_Error_Not_Available_Live_Setting = 4312,//没有可用的直播配置
    QHVCITL_Error_Already_Join_Room = 4313,//已加入过房间，不能重复加入
    
    // 混流错误
    QHVCITL_Error_MixStream_Input_Not_Exist = -150,//混流的输入流不存在
    QHVCITL_Error_MixStream_Failed = -151,//混流失败
    QHVCITL_Error_MixStream_Stop_Failed = -152,//停止混流失败
    QHVCITL_Error_MixStream_Input_Parameter_Error = -153,//输入参数错误
    QHVCITL_Error_MixStream_Output_Parameter_Error = -154,//输出参数错误
    QHVCITL_Error_MixStream_Input_Ratio_Error = -155,//输入分辨率格式错误
    QHVCITL_Error_MixStream_Output_Ratio_Error = -156,//输出分辨率格式错误
    QHVCITL_Error_MixStream_Not_Open = -157,//混流没开
    
    QHVCITL_Error_TempBroken = -200,//直播临时中断
    QHVCITL_Error_FatalError = -201,//直播遇到严重的问题
    QHVCITL_Error_CreateStreamError = -202,//创建直播流失败
    QHVCITL_Error_FetchStreamError = -203,//获取流信息失败
    QHVCITL_Error_NoStreamError = -204,//无流信息
    QHVCITL_Error_LogicServerNetWrokError  = -205,//逻辑服务器网络错误
    QHVCITL_Error_DNSResolveError = -206,//DNS 解释失败
    QHVCITL_Error_NotLoginError = -207,//未登录
    QHVCITL_Error_UnknownError = -208,//未知错误
    QHVCITL_Error_PublishBadNameError = -209,
    QHVCITL_Error_HttpDNSResolveError = -210,
};

typedef NS_ENUM(NSInteger, QHVCITLDataCollectMode) {//数据采集方式
    QHVCITLDataCollectModeSDK         =  1,//SDK自采集
    QHVCITLDataCollectModeUser        =  2,//用户采集
};

typedef NS_ENUM(NSInteger, QHVCITLChannelProfile) {//频道属性
    QHVCITL_ChannelProfile_Communication = 0,
    QHVCITL_ChannelProfile_LiveBroadcasting = 1,
    QHVCITL_ChannelProfile_Game = 2,
};

typedef NS_ENUM(NSInteger, QHVCITLClientRole) {//角色属性
    QHVCITL_ClientRole_Broadcaster = 1,
    QHVCITL_ClientRole_Audience = 2,
};

typedef NS_ENUM(NSInteger, QHVCITLVideoProfile) {//视频属性
                                             // res       fps  kbps
    QHVCITL_VideoProfile_240P_3 = 22,        // 240x240   15   140
    QHVCITL_VideoProfile_240P_4 = 23,        // 424x240   15   220
    QHVCITL_VideoProfile_360P = 30,          // 640x360   15   400
    QHVCITL_VideoProfile_360P_3 = 32,        // 360x360   15   260
    QHVCITL_VideoProfile_360P_4 = 33,        // 640x360   15   600
    QHVCITL_VideoProfile_360P_6 = 35,        // 360x360   15   400
    QHVCITL_VideoProfile_360P_9 = 38,        // 640x360   15   800
    QHVCITL_VideoProfile_480P_3 = 42,        // 480x480   15   400
    QHVCITL_VideoProfile_480P_6 = 45,        // 480x480   30   600
    QHVCITL_VideoProfile_480P_8 = 47,        // 848x480   15   610
    QHVCITL_VideoProfile_480P_9 = 48,        // 848x480   30   930
    QHVCITL_VideoProfile_720P = 50,          // 1280x720  15   1130
    QHVCITL_VideoProfile_720P_3 = 52,        // 1280x720  30   1710
    QHVCITL_VideoProfile_504P_1 = 100,       // 896x504   15   800
    QHVCITL_VideoProfile_576P_1 = 110,       // 1024x576  15   900
    QHVCITL_VideoProfile_DEFAULT = QHVCITL_VideoProfile_360P,
};

typedef NS_ENUM(NSUInteger, QHVCITLQuality) {//网络质量
    QHVCITL_Quality_Unknown = 0,
    QHVCITL_Quality_Excellent = 1,
    QHVCITL_Quality_Good = 2,
    QHVCITL_Quality_Poor = 3,
    QHVCITL_Quality_Bad = 4,
    QHVCITL_Quality_VBad = 5,
    QHVCITL_Quality_Down = 6,
};

typedef NS_ENUM(NSInteger, QHVCITLMediaType) {//流媒体类型
    QHVCITL_MediaType_None = 0,
    QHVCITL_MediaType_AudioOnly = 1,
    QHVCITL_MediaType_VideoOnly = 2,
    QHVCITL_MediaType_AudioAndVideo = 3,
};

typedef NS_ENUM(NSUInteger, QHVCITLUserOfflineReason) {//用户离线原因
    QHVCITL_UserOffline_Quit = 0,//用户主动离开
    QHVCITL_UserOffline_Dropped = 1,//因过长时间收不到对方数据包，超时掉线。注意：由于SDK使用的是不可靠通道，也有可能对方主动离开本方没收到对方离开消息而误判为超时掉线
    QHVCITL_UserOffline_BecomeAudience = 2,//当用户身份从主播切换为观众时触发,如果播放使用的业务自己管理拉取逻辑，将不会触发这个状态。
};

typedef NS_ENUM(NSInteger, QHVCITLVideoStreamType) {//视频流类型
    QHVCITL_VideoStream_High = 0,//高码率
    QHVCITL_VideoStream_Low = 1,//低码率
};

typedef NS_ENUM(NSInteger, QHVCITLRtmpStreamLifeCycle){//推流生命周期属性
    QHVCITL_RtmpStream_LifeCycle_Bind_To_Channel = 1,//绑定到频道
    QHVCITL_RtmpStream_LifeCycle_Bind_To_Owner = 2,//绑定到主播
};

typedef NS_ENUM(NSUInteger, QHVCITLRenderMode) {//画面渲染模式
    QHVCITL_Render_ScaleAspectFill    = 1,//等比缩放填充整View，可能有部分被裁减
    QHVCITL_Render_ScaleAspectFit     = 2,//等比缩放，可能有黑边
    QHVCITL_Render_ScaleToFill        = 3,//填充整个View
};

typedef NS_ENUM(NSUInteger, QHVCITLVideoRemoteState) {//远端流状态
    QHVCITL_VideoRemoteState_Stopped = 0,//远端视频停止
    QHVCITL_VideoRemoteState_Running = 1,//远端视频正常播放
    QHVCITL_VideoRemoteState_Frozen = 2,//远端视频卡住，可能因为网络连接问题导致
};


typedef NS_ENUM(NSInteger, QHVCITLAudioSampleRateType) {//音频采样率
    QHVCITL_AudioSampleRateType_32000 = 32000,
    QHVCITL_AudioSampleRateType_44100 = 44100,
    QHVCITL_AudioSampleRateType_48000 = 48000,
};

typedef NS_ENUM(NSInteger, QHVCITLAudioProfile) {//音频Profile
    // sample rate, bit rate, mono/stereo, speech/music codec
    QHVCITL_AudioProfile_Default = 0,                // use default settings
    QHVCITL_AudioProfile_SpeechStandard = 1,         // 32Khz, 18kbps, mono, speech
    QHVCITL_AudioProfile_MusicStandard = 2,          // 48Khz, 48kbps, mono, music
    QHVCITL_AudioProfile_MusicStandardStereo = 3,    // 48Khz, 56kbps, stereo, music
    QHVCITL_AudioProfile_MusicHighQuality = 4,       // 48Khz, 128kbps, mono, music
    QHVCITL_AudioProfile_MusicHighQualityStereo = 5, // 48Khz, 192kbps, stereo, music
};

typedef NS_ENUM(NSInteger, QHVCITLAudioScenario) {//音频应用场景
    QHVCITL_AudioScenario_Default = 0,//默认设置
    QHVCITL_AudioScenario_ChatRoomEntertainment = 1,//娱乐应用，需要频繁上下麦的场景
    QHVCITL_AudioScenario_Education = 2,//教育应用，流畅度和稳定性优先
    QHVCITL_AudioScenario_GameStreaming = 3,//游戏直播应用，需要外放游戏音效也直播出去的场景。如需实现高保真的音乐传输，建议选择该场景
    QHVCITL_AudioScenario_ShowRoom = 4,//秀场应用，音质优先和更好的专业外设支持
    QHVCITL_AudioScenario_ChatRoomGaming = 5//游戏开黑
};

typedef NS_ENUM(NSInteger, QHVCITLAudioOutputRouting){//语音路由
    QHVCITL_AudioOutputRouting_Default = -1,//使用默认的语音路由
    QHVCITL_AudioOutputRouting_Headset = 0,//使用耳机为语音路由
    QHVCITL_AudioOutputRouting_Earpiece = 1,//使用听筒为语音路由
    QHVCITL_AudioOutputRouting_HeadsetNoMic = 2,//使用不带麦的耳机为语音路由
    QHVCITL_AudioOutputRouting_Speakerphone = 3,//使用话筒为语音路由
    QHVCITL_AudioOutputRouting_Loudspeaker = 4,//使用扬声器为语音路由
    QHVCITL_AudioOutputRouting_HeadsetBluetooth = 5//使用蓝牙耳机为语音路由
};

typedef NS_ENUM(NSInteger, QHVCITLAudioEqualizationBandFrequency) {//语音音效均衡
    QHVCITL_AudioEqualization_Band31 = 0,
    QHVCITL_AudioEqualization_Band62 = 1,
    QHVCITL_AudioEqualization_Band125 = 2,
    QHVCITL_AudioEqualization_Band250 = 3,
    QHVCITL_AudioEqualization_Band500 = 4,
    QHVCITL_AudioEqualization_Band1K = 5,
    QHVCITL_AudioEqualization_Band2K = 6,
    QHVCITL_AudioEqualization_Band4K = 7,
    QHVCITL_AudioEqualization_Band8K = 8,
    QHVCITL_AudioEqualization_Band16K = 9,
};

typedef NS_ENUM(NSInteger, QHVCITLAudioReverbType) {//混响音效类型
    QHVCITL_AudioReverb_DryLevel = 0, // (dB, [-20,10]), 原始声音效果，即所谓的 dry signal
    QHVCITL_AudioReverb_WetLevel = 1, // (dB, [-20,10]), 早期反射信号效果，即所谓的 wet signal
    QHVCITL_AudioReverb_RoomSize = 2, // ([0，100]), 所需混响效果的房间尺寸
    QHVCITL_AudioReverb_WetDelay = 3, // (ms, [0, 200]), wet signal 的初始延迟长度，以毫秒为单位
    QHVCITL_AudioReverb_Strength = 4, // ([0，100]), 后期混响长度
};

typedef NS_ENUM(NSInteger, QHVCITLMediaDeviceType) {//媒体设备类型
    QHVCITL_MediaDeviceType_AudioUnknown = -1,//未知语音设备类型
    QHVCITL_MediaDeviceType_AudioRecording = 0,//录音类语音设备
    QHVCITL_MediaDeviceType_AudioPlayout = 1,//播放类语音设备
    QHVCITL_MediaDeviceType_VideoRender = 2,//渲染类视频设备
    QHVCITL_MediaDeviceType_VideoCapture = 3,//采集类视频设备
};

typedef NS_ENUM(NSUInteger, QHVCITLAudioFrameType) {//音频格式类型
    QHVCITL_AudioFrame_type_PCM16 = 0,  //PCM 16bit 小端
};


typedef NS_ENUM(NSUInteger, QHVCITLVideoPixelFormat) {
    QHVCITLVideoPixelFormat_I420   = 1,
    QHVCITLVideoPixelFormat_BGRA   = 2,
    QHVCITLVideoPixelFormat_NV12   = 8,
};

typedef NS_ENUM(NSInteger, QHVCITLVideoRotation) {
    QHVCITLVideoRotation_None      = 0,
    QHVCITLVideoRotation_90        = 1,
    QHVCITLVideoRotation_180       = 2,
    QHVCITLVideoRotation_270       = 3,
};

typedef NS_ENUM(NSInteger, QHVCITLVideoBufferType) {
    QHVCITL_VideoBufferType_PixelBuffer = 1,
    QHVCITL_VideoBufferType_RawData     = 2,
};


#pragma mark - 数据结构定义 -
/**
 视频画布信息
 */
@interface QHVCITLVideoCanvas : NSObject
@property (strong, nonatomic, nullable) UIView* view;//视频显示视窗
@property (assign, nonatomic) QHVCITLRenderMode renderMode; // 渲染模式
@property (strong, nonatomic, nonnull) NSString* uid; // 用户ID
@end

/**
 频道内音视频统计信息，包括瞬时值、累计值
 */
@interface QHVCITLChannelStats : NSObject
@property (assign, nonatomic) NSUInteger duration;//通话时长，累计值
@property (assign, nonatomic) NSUInteger txBytes;//发送字节数，累计值
@property (assign, nonatomic) NSUInteger rxBytes;//接收字节数，累计值
@property (assign, nonatomic) NSUInteger txAudioKBitrate;//瞬时值
@property (assign, nonatomic) NSUInteger rxAudioKBitrate;//瞬时值
@property (assign, nonatomic) NSUInteger txVideoKBitrate;//瞬时值
@property (assign, nonatomic) NSUInteger rxVideoKBitrate;//瞬时值
@property (assign, nonatomic) NSInteger userCount;//用户数
@property (assign, nonatomic) double cpuAppUsage;//APP占用CPU
@property (assign, nonatomic) double cpuTotalUsage;//整个CPU占用
@end

/**
 本地发送视频统计信息
 */
@interface QHVCITLLocalVideoStats : NSObject
@property (assign, nonatomic) NSUInteger sentBitrate;//（上次统计后）发送的字节数
@property (assign, nonatomic) NSUInteger sentFrameRate;//（上次统计后）发送的帧数
@end

/**
 接收远端视频统计信息
 */
@interface QHVCITLRemoteVideoStats : NSObject
@property (strong, nonatomic, nonnull) NSString* uid;//用户ID，指定是哪个用户的视频流
@property (assign, nonatomic) NSUInteger width;//视频流宽（像素）
@property (assign, nonatomic) NSUInteger height;//视频流高（像素）
@property (assign, nonatomic) NSUInteger receivedBitrate;//（上次统计后）接收到的码率(kbps)
@property (assign, nonatomic) NSUInteger receivedFrameRate;//（上次统计后）接收帧率(fps)
@property (assign, nonatomic) QHVCITLVideoStreamType rxStreamType;//流的质量
@end

/**
 音量信息
 */
@interface QHVCITLAudioVolumeInfo : NSObject
@property (strong, nonatomic, nonnull) NSString* uid;
@property (assign, nonatomic) NSUInteger volume;
@end

/**
 音频数据格式定义
 */
@interface QHVCITLAudioFrame : NSObject
@property (assign, nonatomic) QHVCITLAudioFrameType type;//声音数据格式
@property (assign, nonatomic) NSInteger samples;//该帧的样本数量
@property (assign, nonatomic) NSInteger bytesPerSample;//每个样本的字节数: PCM (16位)含两个字节
@property (assign, nonatomic) NSInteger channels;//频道数量
@property (assign, nonatomic) NSInteger sampleRate;//采样率
@property (assign, nonatomic) NSInteger bufferLength;//数据长度
@property (assign, nonatomic, nullable) void* buffer;//数据缓冲区
@property (assign, nonatomic) NSInteger renderTimeMs;//渲染音频流的时间戳。用户在进行音频流渲染时使用该时间戳同步音频流的渲染。
@end

/**
 视频数据格式定义
 */
@interface QHVCITLVideoFrame : NSObject
@property(assign, nonatomic) QHVCITLVideoPixelFormat format;//视频格式
@property(assign, nonatomic) NSInteger width;//视频宽
@property(assign, nonatomic) NSInteger height;//视频高
@property(assign, nonatomic) NSInteger yStride;//stride of Y data buffer
@property(assign, nonatomic) NSInteger uStride;//stride of U data buffer
@property(assign, nonatomic) NSInteger vStride;//stride of V data buffer
@property(assign, nonatomic, nullable) void* yBuffer;//Y data buffer
@property(assign, nonatomic, nullable) void* uBuffer;//U data buffer
@property(assign, nonatomic, nullable) void* vBuffer;//V data buffer
@property(assign, nonatomic) NSInteger rotation;// rotation of this frame (0, 90, 180, 270)
@property(assign, nonatomic) NSInteger renderTimeMs;//渲染的时间戳
@end

/**
 任意一路视频合流位置定义
 */
@interface QHVCITLVideoCompositingRegion : NSObject
@property (copy, nonatomic, nonnull) NSString* uid;//待显示在该区域的主播用户uid，唯一
@property (assign, nonatomic) CGRect rect;//坐标（x,y,w,h）
@property (assign, nonatomic) NSInteger zOrder; //zOrder[1, 100], 0表示该区域图像位于最下层，而100表示该区域图像位于最上层。
@property (assign, nonatomic) double alpha; //alpha[0, 1.0] 0表示图像为透明的，1表示图像为完全不透明的
@property (assign, nonatomic) QHVCITLRenderMode renderMode;//QHVCITL_Render_ScaleAspectFill: 经过裁减的,QHVCITL_Render_ScaleAspectFit: 缩放到合适大小

- (NSDictionary * _Nonnull)transformToDictionary;

@end

/**
 房间视频合流布局定义
 */
@interface QHVCITLVideoCompositingLayout : NSObject
@property (assign, nonatomic) NSInteger canvasWidth;//整个屏幕(画布)的宽度
@property (assign, nonatomic) NSInteger canvasHeight;//整个屏幕(画布)的高度
@property (copy, nonatomic, nullable) UIColor* backgroundColor;//背景颜色
@property (retain, nonatomic, nonnull) NSArray<QHVCITLVideoCompositingRegion *>* regions; //频道内每位主播在屏幕上均可以有一个区域显示自己的头像或视频。

- (NSDictionary * _Nonnull)transformToDictionary;

@end

/**
 合流转推配置
 */
@interface QHVCITLMixerPublisherConfiguration : NSObject
@property (copy, nonatomic, nullable) NSString* publishUrl;//合流推流地址
@property (assign, nonatomic) QHVCITLRtmpStreamLifeCycle lifeCycle;//流的生命周期属性
@property (assign, nonatomic) NSInteger width;//视频分辨率宽
@property (assign, nonatomic) NSInteger height;//视频分辨率高
@property (assign, nonatomic) NSInteger framerate;//帧率
@property (assign, nonatomic) NSInteger bitrate;//码率
@property (nonatomic, assign) NSInteger gop;//视频最大I帧间隔
@property (nonatomic, strong, nullable) NSString* audioFormat;//声音编码格式，AAC
@property (nonatomic, assign) QHVCITLAudioSampleRateType audioSample;//声音采样率
@property (nonatomic, assign) NSInteger audioBitrate;//声音码率
@property (nonatomic, assign) NSInteger audioChannel;//声音声道数

- (NSDictionary * _Nonnull)transformToDictionary;

@end

#pragma mark - SDK delegates -
@class QHVCInteractiveKit;
@protocol QHVCInteractiveDelegate <NSObject>
@optional

#pragma mark - SDK common delegates
/**
 发生警告回调
 该回调方法表示SDK运行时出现了（网络或媒体相关的）警告。通常情况下，SDK上报的警告信息应用程序可以忽略，SDK会自动恢复。
 
 @param engine 引擎对象
 @param warningCode 警告代码
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine didOccurWarning:(QHVCITLWarningCode)warningCode;


/**
 本地推流端发生错误回调
 该回调方法表示SDK运行时出现了（网络或媒体相关的）错误。通常情况下，SDK上报的错误意味着SDK无法自动恢复，需要应用程序干预或提示用户。比如启动通话失败时，SDK会上报QHVCITL_Error_StartCall(1002)错误。应用程序可以提示用户启动通话失败，并调用leaveChannel退出频道。
 
 @param engine 引擎对象
 @param errorCode 错误代码
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine didOccurError:(QHVCITLErrorCode)errorCode;


/**
 加载互动直播引擎数据成功回调
 该回调方法表示SDK加载引擎数据成功。该回调成功后，业务可以进行一系列参数的设置，之后调用joinChannel以及后续操作。
 
 @param engine 引擎对象
 @param dataDict 参数字典，将会返回业务所需的必要信息
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine didLoadEngineData:(nullable NSDictionary *)dataDict;


/**
 本地网络连接中断回调
 在SDK和服务器失去了网络连接时，触发该回调。失去连接后，除非APP主动调用leaveChannel，SDK会一直自动重连。
 
 @param engine 引擎对象
 */
- (void)interactiveEngineConnectionDidInterrupted:(QHVCInteractiveKit *)engine;


/**
 本地网络连接丢失回调
 在SDK和服务器失去了网络连接后，会触发interactiveEngineConnectionDidInterrupted回调，并自动重连。在一定时间内（默认10秒）如果没有重连成功，触发interactiveEngineConnectionDidLost回调。除非APP主动调用leaveChannel，SDK仍然会自动重连。
 
 @param engine 引擎对象
 */
- (void)interactiveEngineConnectionDidLost:(QHVCInteractiveKit *)engine;


/**
 连接已被禁止回调
 当你被服务端禁掉连接的权限时，会触发该回调。意外掉线之后，SDK 会自动进行重连，重连多次都失败之后，该回调会被触发，判定为连接不可用。

 @param engine 引擎对象
 */
- (void)interactiveEngineConnectionDidBanned:(QHVCInteractiveKit *)engine;


/**
 统计数据回调
 该回调定期上报Interactive Engine的运行时的状态，每两秒触发一次。
 
 @param engine 引擎对象
 @param stats 统计值
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine reportStats:(QHVCITLChannelStats *)stats;


#pragma mark - Local user common delegates

/**
 加入频道成功回调
 该回调方法表示该客户端成功加入了指定的频道。
 
 @param engine 引擎对象
 @param channel 频道名
 @param uid 用户ID
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine didJoinChannel:(NSString *)channel withUid:(NSString *)uid;


/**
 重新加入频道回调
 有时候由于网络原因，客户端可能会和服务器失去连接，SDK会进行自动重连，自动重连成功后触发此回调方法，提示有用户重新加入了频道，且频道ID和用户ID均已分配。
 
 @param engine 引擎对象
 @param channel 频道名
 @param uid 用户ID
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine didRejoinChannel:(NSString *)channel withUid:(NSString *)uid;


/**
 上下麦回调
 直播场景下，当用户上下麦时会触发此回调，即主播切换为观众时，或观众切换为主播时。

 @param engine 引擎对象
 @param oldRole 切换前的角色
 @param newRole 切换后的角色
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine didClientRoleChanged:(QHVCITLClientRole)oldRole newRole:(QHVCITLClientRole)newRole;


/**
 用户主动离开频道回调
 
 @param engine 引擎对象
 @param stats 本次通话数据统计，包括时长、发送和接收数据量等
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine didLeaveChannelWithStats:(nullable QHVCITLChannelStats *)stats;


/**
 频道内网络质量报告回调
 该回调定期触发，向APP报告频道内通话中用户当前的上行、下行网络质量。
 
 @param engine 引擎对象
 @param uid 用户ID。表示该回调报告的是持有该ID的用户的网络质量。
 @param txQuality 该用户的上行网络质量。
 @param rxQuality 该用户的下行网络质量。
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine networkQuality:(NSString *)uid txQuality:(QHVCITLQuality)txQuality rxQuality:(QHVCITLQuality)rxQuality;


#pragma mark - Local user audio delegates

/**
 第一个音频帧被发送

 @param engine 引擎对象
 @param elapsed 从会话开始的经过时间(ms)。
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine firstLocalAudioFrame:(NSInteger)elapsed;


/**
 语音路由已发生变化回调
 当语音路由发生变化时，SDK 会触发此回调。

 @param engine 引擎对象
 @param routing 设置语音路由
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine didAudioRouteChanged:(QHVCITLAudioOutputRouting)routing;


/**
 本地伴奏播放已结束回调
 当调用 startAudioMixing 播放伴奏音乐结束后，会触发该回调。如果调用 startAudioMixing 失败，会在 didOccurError 回调里，返回错误码 WARN_AUDIO_MIXING_OPEN_ERROR 。

 @param engine 引擎对象
 */
- (void)interactiveEngineLocalAudioMixingDidFinish:(QHVCInteractiveKit *)engine;


/**
 本地音效播放已结束回调

 @param engine 引擎对象
 @param soundId 指定音效的 ID。每个音效均有唯一的ID
 */
- (void)interactiveEngineDidAudioEffectFinish:(QHVCInteractiveKit *)engine soundId:(NSInteger)soundId;


#pragma mark - Local user video delegates

/**
 摄像头启用回调
 提示已成功打开摄像头，可以开始捕获视频。

 @param engine 引擎对象
 */
- (void)interactiveEngineCameraDidReady:(QHVCInteractiveKit *)engine;


/**
 相机对焦区域已改变回调
 该回调表示相机的对焦区域发生了改变

 @param engine 引擎对象
 @param rect 镜头内表示对焦区域的长方形
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine cameraFocusDidChangedToRect:(CGRect)rect;


/**
 视频功能停止回调
 提示视频功能已停止。应用程序如需在停止视频后对 view 做其他处理（比如显示其他画面），可以在这个回调中进行。

 @param engine 引擎对象
 */
- (void)interactiveEngineVideoDidStop:(QHVCInteractiveKit *)engine;


/**
 本地首帧视频显示回调

 @param engine 引擎对象
 @param size 视频流尺寸（宽度和高度）
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine firstLocalVideoFrameWithSize:(CGSize)size;


/**
 本地视频统计回调
 报告更新本地视频统计信息，该回调方法每两秒触发一次。
 
 @param engine 引擎对象
 @param stats sentBytes（上次统计后）发送的字节数 sentFrames（上次统计后）发送的帧数
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine localVideoStats:(QHVCITLLocalVideoStats *)stats;


#pragma mark - Remote user common delegates
/**
 用户加入回调
 提示有用户加入了频道。如果该客户端加入频道时已经有人在频道中，SDK也会向应用程序上报这些已在频道中的用户。
 
 @param engine 引擎对象
 @param uid 用户ID，如果joinChannel中指定了uid，则此处返回该ID；否则使用连麦服务器自动分配的ID。
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine didJoinedOfUid:(NSString *)uid;


/**
 某个用户离线回调
 提示有用户离开了频道（或掉线）。
 
 @param engine 引擎对象
 @param uid 用户ID
 @param reason 离线原因
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine didOfflineOfUid:(NSString *)uid reason:(QHVCITLUserOfflineReason)reason;


#pragma mark - Remote user audio delegates

/**
 接收远程用户的第一个音频帧。

 @param engine 引擎对象
 @param uid 用户ID
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine firstRemoteAudioFrameOfUid:(NSString *)uid;


/**
 用户音频静音回调
 提示有用户用户将通话静音/取消静音。
 
 @param engine 引擎对象
 @param muted Yes:静音, No:取消静音
 @param uid 用户ID
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine didAudioMuted:(BOOL)muted byUid:(NSString *)uid;


/**
 音量提示回调
 提示谁在说话及其音量，默认禁用。可通过enableAudioVolumeIndication方法设置。
 
 @param engine 引擎对象
 @param speakers 说话者（数组）。每个speaker()：uid: 说话者的用户ID,volume：说话者的音量（0~255）
 @param totalVolume 混音后的）总音量（0~255）
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine reportAudioVolumeIndicationOfSpeakers:(nullable NSArray *)speakers totalVolume:(NSInteger)totalVolume;


/**
 监测到活跃用户回调

 @param engine 引擎对象
 @param speakerUid 该活跃用户的 uid 。如有需要，您可以在 App 上实现指定功能，例如，出现新的活跃用户时，该用户的图像会被自动放大
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine activeSpeaker:(NSUInteger)speakerUid;


/**
 远端伴奏播放已开始回调
 当远端有用户调用 startAudioMixing 播放伴奏音乐，会触发该回调。在合唱应用中可以利用这个回调作为本端歌词播放的触发条件。

 @param engine 引擎对象
 */
- (void)interactiveEngineRemoteAudioMixingDidStart:(QHVCInteractiveKit *)engine;



/**
 远端伴奏播放已结束回调
 当远端有用户调用 stopAudioMixing 停止伴奏音乐，会触发该回调。

 @param engine 引擎对象
 */
- (void)interactiveEngineRemoteAudioMixingDidFinish:(QHVCInteractiveKit *)engine;


/**
 语音质量回调
 在通话中，该回调方法每两秒触发一次，报告当前通话的（嘴到耳）音频质量。
 
 @param engine 引擎对象
 @param uid 用户ID
 @param quality 声音质量评分
 @param delay 延迟（毫秒）
 @param lost 丢包率（百分比）
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine audioQualityOfUid:(NSString *)uid quality:(QHVCITLQuality)quality delay:(NSUInteger)delay lost:(NSUInteger)lost;


#pragma mark - Remote user video delegates
/**
 远端首帧视频接收解码回调
 提示已收到第一帧远程视频流并解码。
 
 @param engine 引擎对象
 @param uid 用户ID，指定是哪个用户的视频流
 @param size 视频流尺寸（宽度和高度）
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine firstRemoteVideoDecodedOfUid:(NSString *)uid size:(CGSize)size;


/**
 远端首帧视频显示回调
 提示第一帧远端视频画面已经显示在屏幕上。
 如果是主播推混流，这里需要在回调里面强制更新一下混流布局配置:
 setVideoCompositingLayout:(QHVCITLVideoCompositingLayout*)layout;
 
 @param engine 引擎对象
 @param uid 用户ID，指定是哪个用户的视频流
 @param size 视频流尺寸（宽度和高度）
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine firstRemoteVideoFrameOfUid:(NSString *)uid size:(CGSize)size;


/**
 本地或远端用户更改视频大小的事件
 
 @param engine 引擎对象
 @param uid 用户ID
 @param size 视频新Size
 @param rotation 视频新的旋转角度
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine videoSizeChangedOfUid:(NSString *)uid size:(CGSize)size rotation:(NSInteger)rotation;


/**
 远端视频流状态发生改变回调
 该回调方法表示远端的视频流状态发生了改变。
 
 @param engine 引擎对象
 @param uid 发生视频流状态改变的远端用户的 ID
 @param state 远端视频流状态
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine remoteVideoStateChangedOfUid:(NSString *)uid state:(QHVCITLVideoRemoteState)state;


/**
 用户停止/重新发送视频回调
 提示有其他用户暂停发送/恢复发送其视频流。
 
 @param engine 引擎对象
 @param muted Yes：该用户已暂停发送其视频流 No：该用户已恢复发送其视频流
 @param uid 用户ID
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine didVideoMuted:(BOOL)muted byUid:(NSString *)uid;


/**
 用户启用/关闭视频回调
 提示有其他用户启用/关闭了视频功能。关闭视频功能是指该用户只能进行语音通话，不能显示、发送自己的视频，也不能接收、显示别人的视频。
 
 @param engine 引擎对象
 @param enabled Yes：该用户已启用了视频功能 No：该用户已关闭了视频功能
 @param uid 用户ID
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine didVideoEnabled:(BOOL)enabled byUid:(NSString *)uid;


/**
 远端视频统计回调
 报告更新远端视频统计信息，该回调方法每两秒触发一次。
 
 @param engine 引擎对象
 @param stats 统计信息
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine remoteVideoStats:(QHVCITLRemoteVideoStats *)stats;


/**
 抓取视频截图回调
 该回调方法由takeStreamSnapshot触发，返回的是对应uid当前流的图像
 
 @param engine 引擎对象
 @param img 截图对象
 @param uid 用户ID
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine takeStreamSnapshot:(CGImageRef)img uid:(NSString *)uid;

@end


#pragma mark - VideoFrame delegates -
/**
 视频输出回调
 */
@protocol QHVCInteractiveVideoFrameDelegate <NSObject>
@optional

/**
 创建一个CVPixelBufferRef对象的内存地址给SDK，接收到的图像将会存放到这个对象上，然后调用renderPixelBuffer方法进行通知
 
 @param engine 引擎对象
 @param width 视频宽
 @param height 视频高
 @param stride stride值
 */
- (CVPixelBufferRef)interactiveEngine:(QHVCInteractiveKit *)engine createInputBufferWithWidth:(int)width height:(int)height stride:(int)stride;

/**
 远端视频数据拷贝完毕后进行回调，通知业务进行渲染
 
 @param engine 引擎对象
 @param uid 用户ID
 @param pixelBuffer 视频对象，数据为一个CVPixelBufferRef对象
 */
- (void)interactiveEngine:(QHVCInteractiveKit *)engine renderPixelBuffer:(NSString *)uid pixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end


#pragma mark - AudioFrame delegates -
/**
 音频输出回调
 */
@protocol QHVCInteractiveAudioFrameDelegate <NSObject>
@optional

/**
 该方法获取本地采集的音频数据，可以在此时机处理前置声音效果。
 
 @param audioFrame 声音数据
 */
- (void)onRecordLocalAudioFrame:(QHVCITLAudioFrame *)audioFrame;

/**
 该方法获取上行、下行所有数据混音后的数据。
 
 @param audioFrame 声音数据
 */
- (void)onMixedAudioFrame:(QHVCITLAudioFrame *)audioFrame;

@end


#pragma mark - 互动直播实现方法 -
@interface QHVCInteractiveKit : NSObject
#pragma mark - 定义全局静态方法
/**
 获取SDK版本号
 
 @return SDK版本号
 */
+ (NSString *) getVersion;


/**
 开启日志
 
 @param level 日志等级
 */
+ (void) openLogWithLevel:(QHVCITLLogLevel)level;


/**
 设置日志输出callback
 
 @param callback 回调block
 */
+ (void) setLogOutputCallBack:(void(^_Nullable)(int loggerID, QHVCITLLogLevel level, const char * _Nullable data))callback;


/**
 获取实例方法

 @return 返回静态实例对象
 */
+ (instancetype) sharedInstance;

/**
 销毁引擎实例
 */
+ (void)destory;


#pragma mark - 通用公共方法

/**
 设置公共业务信息
 该方法需要在所有实例方法之前调用，用于设置业务所需要的一些必要信息，便于业务区分、统计使用。
 
 @param channelId 渠道Id，用于区分公司或部门下拥有多款应用
 @param appKey 平台为每个应用分配的唯一ID
 @param userSign 用户签名
 @return 0 成功, 非0 表示失败。
 */
- (int) setPublicServiceInfo:(NSString *)channelId
                      appKey:(NSString *)appKey
                    userSign:(NSString *)userSign;


/**
 加载互动直播引擎数据，进行准备工作。
 调用该方法前，必须先调用setPublicServiceInfo进行业务信息准备，在该方法必须调用后才能调用其它实例方法。该方法是异步执行，待回调执行之后才能执行其它实例方法。若加载成功，SDK将会触发didLoadEngineData回调，然后，业务可以进行一系列参数的设置，之后调用joinChannel以及后续操作。若加载失败，SDK将会触发didOccurError回调，请根据相关错误码进行逻辑处理。

 @param delegate 托管对象
 @param roomId 房间ID
 @param userId 用户ID，必须是数字
 @param sessionId 会话ID，用于标识业务会话请求，每一次完整的流程之后，该值需要重新设置
 @param dataCollectModel 数据采集模式，SDK采集/用户采集
 @param optionInfoDict 可选字典，若需旁路直播功能等可通过该字典设置
 例如:
 @{@"pull_addr":@"",//拉流地址
   @"push_addr":@"",//推流地址
  };
 @return 0 成功, 非0 表示失败。
 */
- (int) loadEngineDataWithDelegate:(id<QHVCInteractiveDelegate>)delegate
                            roomId:(NSString *)roomId
                            userId:(NSString *)userId
                         sessionId:(nullable NSString *)sessionId
                  dataCollectModel:(QHVCITLDataCollectMode)dataCollectModel
                    optionInfoDict:(nullable NSDictionary *)optionInfoDict;


/**
 加入频道
 该方法是异步操作，SDK将会触发didJoinChannel回调，然后，业务才可以进行一系列操作设置。若加载失败，SDK将会触发didOccurError回调，请根据相关错误码进行逻辑处理。
 该方法让用户加入通话频道，在同一个频道内的用户可以互相通话，多个用户加入同一个频道，可以群聊。 使用不同 App ID 的应用程序是不能互通的。如果已在通话中，用户必须调用 leaveChannel() 退出当前通话，才能进入下一个频道。 SDK 在通话中使用 iOS 系统的 AVAudioSession 共享对象进行录音和播放，应用程序对该对象的操作可能会影响 SDK 的音频相关功能。
 
 @return 0 成功, 非0 表示失败.
 */
- (int)joinChannel;


/**
 离开频道
 离开频道，即挂断或退出通话。
 
 该方法是异步操作，当调用 joinChannel() API 方法后，必须调用 leaveChannel() 结束通话，否则无法开始下一次通话。 不管当前是否在通话中，都可以调用 leaveChannel()，没有副作用。该方法会把会话相关的所有资源释放掉。调用返回时并没有真正退出频道。在真正退出频道后，SDK 会触发 didLeaveChannelWithStats 回调。
 如果你调用了 leaveChannel() 后立即调用 destroy()，SDK 将无法触发 didLeaveChannelWithStats 回调。
 
 @return 0 成功, 非0 表示失败.
 */
- (int)leaveChannel;


/**
 设置角色云端属性
 SDK提供云端角色绑定功能，用户可在视频云后台配置相关组合属性，通过SDK调用此方法绑定。若本地单独调用了相关组合属性中的API，被调用的API参数以本地设置为主，否则就以云端设置为主。

 @param roleName 云端角色名
 @return 0 成功, 非0 表示失败.
 */
- (int)setCloudRoleAttribute:(NSString *_Nonnull)roleName;


/**
 设置频道模式
 该方法用于设置频道模式(Profile)。需知道应用程序的使用场景(例如通信模式或直播模式),从而使用不同的优化手段。
 同一频道内只能同时设置一种模式。
 该方法必须在加入频道前调用和进行设置，进入频道后无法再设置。
 
 @param profile 频道模式
 @return 0 成功, return 非0 表示失败
 */
- (int)setChannelProfile:(QHVCITLChannelProfile)profile;


/**
 设置用户角色
 在加入频道前，用户需要通过本方法设置观众(默认)或主播模式。在加入频道后，用户可以通过本方法切换用户模式。
 
 @param role 直播场景里的用户角色
 @return 0 成功, return 非0 表示失败
 */
- (int)setClientRole:(QHVCITLClientRole)role;


/**
 设置一些SDK的特殊参数
 
 @param options 必须是json格式
 @return 0 成功, return 非0 表示失败
 */
- (int)setParameters:(NSString *)options;


/**
 启用测试环境
 
 @param testEnv YES：启用；NO：关闭
 @return 0：成功，非0:失败
 */
- (int)enableTestEnvironment:(BOOL)testEnv;

#pragma mark - 视频通用方法

/**
 启动视频外部渲染，一定要在loadEngineDataWithDelegate之前调用
 
 @param externalVideoRender TURE:打开外部图像渲染，FALSE:SDK渲染,默认:FALSE
 */
- (void) setExtenralVideoRender:(BOOL)externalVideoRender;


/**
 开启视频模式
 该方法用于开启视频模式。可以在加入频道前或者通话中调用，在加入频道前调用，则自动开启视频模式，在通话中调用则由音频模式切换为视频模式。使用disableVideo方法可关闭视频模式。
 
 @return 0 成功, 非0 表示失败.
 */
- (int)enableVideo;


/**
 关闭视频模式
 该方法用于关闭视频。可以在加入频道前或者通话中调用，在加入频道前调用，则自动开启纯音频模式，在通话中调用则由视频模式切换为纯音频频模式。使用enableVideo方法可开启视频模式。
 
 @return 0 成功, return 非0 表示失败.
 */
- (int)disableVideo;


/**
 禁用本地视频功能
 禁用/启用本地视频功能。该方法用于只看不发的视频场景。该方法不需要本地有摄像头。
 
 @param enabled YES: 开启本地视频采集和渲染（默认）,NO: 关闭使用本地摄像头设备
 @return 0 成功, return 非0 表示失败.
 */
- (int)enableLocalVideo:(BOOL)enabled;


/**
 设置本地视频属性
 该方法设置视频编码属性。
 每个Profile对应一套视频参数，如分辨率、帧率、码率等。当设备的摄像头不支持指定的分辨率时，SDK会自动选择一个合适的摄像头分辨率，但是编码分辨率仍然用setVideoProfile 指定的。
 该方法仅设置编码器编出的码流属性，可能跟最终显示的属性不一致，例如编码码流分辨率为640x480，码流的旋转属性为90度，则显示出来的分辨率为竖屏模式。
 应在调用joinChannel/startPreview前设置视频属性。
 
 @param profile 视频属性
 @param swapWidthAndHeight 是否交换宽和高，true：交换宽和高，false：不交换宽和高(默认)
 @return 0 成功, return 非0 表示失败
 */
- (int)setVideoProfile:(QHVCITLVideoProfile)profile
    swapWidthAndHeight:(BOOL)swapWidthAndHeight;


/**
 自定义本地视频参数
 
 @param width 视频宽
 @param height 视频高
 @param frameRate 帧率
 @param andBitrate 码率
 @return 0 成功, return !0 表示失败
 */
- (int)setVideoProfileEx: (NSInteger)width
               andHeight: (NSInteger)height
            andFrameRate: (NSInteger)frameRate
              andBitrate: (NSInteger)andBitrate;


/**
 该方法允许用户设置视频的优化选项。
 
 @param preferFrameRateOverImageQuality true: 画质和流畅度里，优先保证画质(默认),false: 画质和流畅度里，优先保证流畅度
 @return 0 成功, return 非0 表示失败
 */
- (int)setVideoQualityParameters:(BOOL)preferFrameRateOverImageQuality;


/**
 设置本地视频显示属性
 该方法设置本地视频显示信息。应用程序通过调用此接口绑定本地视频流的显示视窗(view)，并设置视频显示模式。
 在应用程序开发中， 通常在初始化后调用该方法进行本地视频设置，然后再加入频道。退出频道后，绑定仍然有效，如果需要解除绑定，可以指定空(NULL)View调用setupLocalVideo。
 
 @param local 设置视频属性
 @return 0 成功, return 非0 表示失败
 */
- (int)setupLocalVideo:(nullable QHVCITLVideoCanvas *)local;


/**
 设置本地视频显示模式，该方法设置本地视频显示模式。应用程序可以多次调用此方法更改显示模式。
 
 @param mode 视频显示模式
 @return 0 成功, return 非0 表示失败
 */
- (int)setLocalRenderMode:(QHVCITLRenderMode) mode;


/**
 开启视频预览
 该方法用于启动本地视频预览。在开启预览前，必须先调用setupLocalVideo设置预览窗口及属性，且必须调用enableVideo开启视频功能。如果在调用joinChannel进入频道之前调用了startPreview启动本地视频预览，在调用leaveChannel退出频道之后本地预览仍然处于启动状态，如需要关闭本地预览，需要额外调用stopPreview一次。
 
 @return 0 成功, return 非0 表示失败
 */
- (int)startPreview;


/**
 停止视频预览
 该方法用于停止本地视频预览。
 
 @return 0 成功, return 非0 表示失败
 */
- (int)stopPreview;


/**
 切换前置/后置摄像头
 该方法用于在前置/后置摄像头间切换。
 
 @return 0 成功, return 非0 表示失败
 */
- (int)switchCamera;


/**
 设置远端视频显示视图
 该方法绑定远程用户和显示视图，即设定uid指定的用户用哪个视图显示。调用该接口时需要指定远程视频的uid，一般可以在进频道前提前设置好，如果应用程序不能事先知道对方的uid，可以在应用程序收到didJoinedOfUid事件时设置。
 如果启用了视频录制功能，视频录制服务会做为一个哑客户端加入频道，因此其他客户端也会收到它的didJoinedOfUid事件，APP不应给它绑定视图（因为它不会发送视频流），如果APP不能识别哑客户端，可以在firstRemoteVideoDecodedOfUid事件触发时再绑定视图。解除某个用户的绑定视图可以把view设置为空。退出频道后，SDK会把远程用户的绑定关系清除掉。
 
 @param remote 设置视频属性
 @return 0 成功, return 非0 表示失败
 */
- (int)setupRemoteVideo:(QHVCITLVideoCanvas *)remote;


/**
 设置远端视频显示模式
 该方法设置远端视频显示模式。应用程序可以多次调用此方法更改显示模式。
 
 @param uid 用户ID，指定远程视频来自哪个用户。
 @param mode 视频显示模式
 @return 0 成功, return 非0 表示失败
 */
- (int)setRemoteRenderMode:(NSString *)uid
                      mode:(QHVCITLRenderMode)mode;


/**
 移除远端观看视频
 
 @param remote 待移除的视频
 @return 0 成功, return 非0 表示失败
 */
- (int)removeRemoteVideo:(QHVCITLVideoCanvas *)remote;


/**
 暂停发送本地视频流
 暂停/恢复发送本地视频流。该方法用于允许/禁止往网络发送本地视频流。
 
 @param mute Yes: 暂停发送本地视频流，No: 恢复发送本地视频流
 @return 0 成功, return 非0 表示失败
 */
- (int)muteLocalVideoStream:(BOOL)mute;


/**
 暂停所有远端视频流
 本方法用于允许/禁止播放所有人的视频流。
 
 @param mute Yes: 停止播放接收到的所有视频流，No: 允许播放接收到的所有视频流
 @return 0 成功, return 非0 表示失败
 */
- (int)muteAllRemoteVideoStreams:(BOOL)mute;


/**
 暂停指定远端视频流
 该方法用于允许/禁止播放指定的远端视频流。
 
 @param uid 用户ID
 @param mute Yes: 停止播放接收到的视频流，No: 允许播放接收到的视频流
 @return 0 成功, return 非0 表示失败
 */
- (int)muteRemoteVideoStream:(NSString *)uid
                        mute:(BOOL)mute;


/**
 获取连麦流的快照，数据返回通过takeStreamSnapshot返回
 
 @param uid 用户ID
 @return 0: 方法调用成功，非0: 方法调用失败
 */
- (int)takeStreamSnapshot:(NSString *)uid;

#pragma mark - 视频双流控制
/**
 开启、关闭双流模式
 
 @param enabled true开启双流模式，FALSE使用单流模式
 @return 0 成功, return 非0 表示失败
 */
- (int)enableDualStreamMode:(BOOL)enabled;


/**
 设置视频大小流
 该方法指定接收远端用户的视频流大小。使用该方法可以根据视频窗口的大小动态调整对应视频流的大小，以节约带宽和计算资源。
 SDK默认收到视频小流，节省带宽。如需使用视频大流，调用本方法进行切换。
 
 @param uid 用户ID
 @param streamType 设置视频流大小
 @return 0 成功, return 非0 表示失败
 */
- (int)setRemoteVideoStream: (NSString *) uid
                       type: (QHVCITLVideoStreamType) streamType;


/**
 设置小流视频参数，此方法只有在enableDualStreamMode开启时才生效，而且要在joinChannel之前调用。
 
 @param width 视频宽
 @param height 视频高
 @param fps 帧率
 @param bitrate 码率
 @return 0 成功，非0失败
 */
- (int)setLowStreamVideoProfile:(int)width
                         height:(int)height
                            fps:(int)fps
                        bitrate:(int)bitrate;


#pragma mark - 音频通用方法
/**
 启动音频外部渲染，一定要在loadEngineDataWithDelegate之前调用
 
 @param externalAudioRender TURE:启动外部音频处理，FALSE:不启动外部音频处理,默认:FALSE
 */
- (void) setExtenralAudioRender:(BOOL)externalAudioRender;


/**
 开启语音模式
 该方法开启语音模式(默认为开启状态)。
 
 @return 0 成功, return 非0 表示失败
 */
- (int)enableAudio;


/**
 关闭语音模式
 
 @return 0 成功, return 非0 表示失败
 */
- (int)disableAudio;


/**
 开启扬声器
 该方法打开外放(扬声器)。调用该方法后，SDK 将返回 onAudioRouteChanged 回调提示状态已更改
 
 @param enableSpeaker Yes： 如果用户已在频道内，无论之前语音是路由到耳机，蓝牙，还是听筒，调用该 API 后均会默认切换到从外放(扬声器)出声，如果用户尚未加入频道，调用该API后，无论用户是否有耳机或蓝牙设备，在加入频道时均会默认从外放(扬声器)出声 No: 语音会根据默认路由出声
 @return 0 成功, return 非0 表示失败
 */
- (int)setEnableSpeakerphone:(BOOL)enableSpeaker;


/**
 是否是扬声器状态
 该方法检查扬声器是否已开启
 
 @return Yes:表明输出到扬声器 No：表明输出到非扬声器(听筒，耳机等)
 */
- (BOOL)isSpeakerphoneEnabled;


/**
 设置默认的语音路径
 该方法设置接收到的语音从听筒或扬声器出声。如果用户不调用本方法，语音默认从听筒出声。
 
 @param defaultToSpeaker YES: 从扬声器出声 NO: 从听筒出声
 @return 0 成功, return 非0 表示失败
 */
- (int)setDefaultAudioRouteToSpeakerphone:(BOOL)defaultToSpeaker;


/**
 设置音质
 该方法用于设置音频参数和应用场景。

 @param profile 设置采样率，码率，编码模式和声道数
 @param scenario 设置音频应用场景
 @return 0 成功, return 非0 表示失败
 */
- (int)setAudioProfile:(QHVCITLAudioProfile)profile
              scenario:(QHVCITLAudioScenario)scenario;


/**
 调节录音信号音量

 @param volume 录音信号音量可在 0~400 范围内进行调节.0: 静音 100: 原始音量 400: 最大可为原始音量的 4 倍(自带溢出保护)
 @return 0 成功, return 非0 表示失败
 */
- (int)adjustRecordingSignalVolume:(NSInteger)volume;


/**
 调节播放信号音量

 @param volume 播放信号音量可在 0~400 范围内进行调节.0: 静音 100: 原始音量 400: 最大可为原始音量的 4 倍(自带溢出保护)
 @return 0 成功, return 非0 表示失败
 */
- (int)adjustPlaybackSignalVolume:(NSInteger)volume;


/**
 启用说话者音量提示
 该方法允许SDK定期向应用程序反馈当前谁在说话以及说话者的音量。
 
 @param interval 指定音量提示的时间间隔。<=0 ：禁用音量提示功能，正常取值范围[100,3000]：提示间隔，单位为毫秒。建议设置到大于200毫秒。
 @param smooth 平滑系数。默认可以设置为3。
 @return 0 成功, return 非0 表示失败
 */
- (int)enableAudioVolumeIndication:(NSInteger)interval
                            smooth:(NSInteger)smooth;


/**
 将自己静音
 静音/取消静音。该方法用于允许/禁止往网络发送本地音频流。
 
 @param mute True：麦克风静音，False：取消静音
 @return 0 成功, return 非0 表示失败
 */
- (int)muteLocalAudioStream:(BOOL)mute;


/**
 静音指定用户音频
 静音指定远端用户/对指定远端用户取消静音。本方法用于允许/禁止播放远端用户的音频流。
 
 @param uid 指定用户
 @param mute True：停止播放指定用户的音频流，False：恢复播放指定用户的音频流
 @return 0 成功, return 非0 表示失败
 */
- (int)muteRemoteAudioStream:(NSString *)uid
                        mute:(BOOL)mute;


/**
 静音所有远端音频
 该方法用于允许/禁止播放远端用户的音频流，即对所有远端用户进行静音与否。
 
 @param mute True：停止播放所接收的音频流，False：恢复播放所接收的音频流
 @return 0 成功, return 非0 表示失败
 */
- (int)muteAllRemoteAudioStreams:(BOOL)mute;


/**
 启用耳机监听
 该方法打开或关闭耳机监听功能。

 @param enabled YES: 启用耳机监听功能; NO: 禁用耳机监听功能(默认)
 @return 0 成功, return 非0 表示失败
 */
- (int)enableInEarMonitoring:(BOOL)enabled;


/**
 设置耳返音量
 该方法设置耳返的音量。

 @param volume 设置耳返音量，取值范围在 [0.100]，默认值为 100
 @return 0 成功, return 非0 表示失败
 */
- (int)setInEarMonitoringVolume:(NSInteger)volume;


/**
 设置音效
 该方法改变本地说话人声音的音调

 @param pitch 语音频率可以 [0.5, 2.0] 范围内设置。默认值为 1.0
 @return 0 成功, return 非0 表示失败
 */
- (int)setLocalVoicePitch:(double)pitch;


/**
 设置本地语音音效均衡

 @param bandFrequency 取值范围是 [0-9]，分别代表音效的 10 个 band 的中心频率 [31，62，125，250，500，1k，2k，4k，8k，16k]Hz
 @param gain 每个 band 的增益，单位是 dB，每一个值的范围是 [-15，15]
 @return 0 成功, return 非0 表示失败
 */
- (int)setLocalVoiceEqualizationOfBandFrequency:(QHVCITLAudioEqualizationBandFrequency)bandFrequency withGain:(NSInteger)gain;


/**
 设置本地音效混响

 @param reverbType 混响音效类型。该方法共有 5 个混响音效类型，分别如 QHVCITLAudioReverbType 列出
 @param value 各混响音效 Key 所对应的值
 @return 0 成功, return 非0 表示失败
 */
- (int)setLocalVoiceReverbOfType:(QHVCITLAudioReverbType)reverbType withValue:(NSInteger)value;


/**
 是否启用软件回声消除
 
 @param enable 是否开启软件回声消除
 @return 0: 方法调用成功，非0: 方法调用失败
 */
- (int)enableSoftwareAEC:(BOOL)enable;


#pragma mark - 音频混音

/**
 开始播放伴奏
 指定本地音频文件来和麦克风采集的音频流进行混音和替换(用音频文件替换麦克风采集的音频流)， 可以通过参数选择是否让对方听到本地播放的音频和指定循环播放的次数。该 API 也支持播放在线音乐。

 @param filePath 指定需要混音的本地音频文件名和文件路径名，支持以下音频格式: mp3, aac, m4a, 3gp, wav, flac
 @param loopback True: 只有本地可以听到混音或替换后的音频流，False: 本地和对方都可以听到混音或替换后的音频流
 @param replace True: 音频文件内容将会替换本地录音的音频流，False: 音频文件内容将会和麦克风采集的音频流进行混音
 @param cycle 指定音频文件循环播放的次数:正整数: 循环的次数，-1: 无限循环
 @return 0: 方法调用成功，非0: 方法调用失败
 */
- (int)startAudioMixing:(NSString *  _Nonnull)filePath
               loopback:(BOOL)loopback
                replace:(BOOL)replace
                  cycle:(NSInteger)cycle;


/**
 停止播放伴奏

 @return 0: 方法调用成功，非0: 方法调用失败
 */
- (int)stopAudioMixing;


/**
 暂停播放伴奏

 @return 0: 方法调用成功，非0: 方法调用失败
 */
- (int)pauseAudioMixing;


/**
 恢复播放伴奏

 @return 0: 方法调用成功，非0: 方法调用失败
 */
- (int)resumeAudioMixing;


/**
 调节伴奏音量
 该方法调节混音里伴奏的音量大小

 @param volume 伴奏音量范围为 0~100。默认 100 为原始文件音量
 @return 0: 方法调用成功，非0: 方法调用失败
 */
- (int)adjustAudioMixingVolume:(NSInteger)volume;


/**
 获取伴奏时长
 该方法获取伴奏时长，单位为毫秒。

 @return 如果返回 0，则代表该方法调用失败。
 */
- (int)getAudioMixingDuration;


/**
 获取伴奏播放进度
 该方法获取当前伴奏播放进度，单位为毫秒

 @return 伴奏播放进度
 */
- (int)getAudioMixingCurrentPosition;


/**
 拖动语音进度条

 @param pos 该方法可以拖动播放音频文件的进度条，这样你可以根据实际情况播放文件，而不是非得从头到尾播放一个文件。
 @return 0: 方法调用成功，非0: 方法调用失败
 */
- (int)setAudioMixingPosition:(NSInteger)pos;

#pragma mark - 音频音效

/**
 获取音效音量
 该方法获取音效的音量，范围为 [0.0, 1.0]。

 @return 音效的音量
 */
- (double)getEffectsVolume;


/**
 设置音效音量
 
 @param volume 取值范围为 [0.0, 100.0]。 100.0 为默认值
 @return 0: 方法调用成功，非0: 方法调用失败
 */
- (int)setEffectsVolume:(double)volume;


/**
 实时调整音效音量

 @param soundId 指定音效的 ID。每个音效均有唯一的 ID
 @param volume 取值范围为 [0.0, 100.0]。 100.0 为默认值
 @return 0: 方法调用成功，非0: 方法调用失败
 */
- (int)setVolumeOfEffect:(int)soundId
              withVolume:(double)volume;


/**
 播放指定音效

 @param soundId 指定音效的 ID。每个音效均有唯一的 ID
 @param filePath 音效文件的绝对路径
 @param loopCount 设置音效循环播放的次数：0：播放音效一次，1：循环播放音效两次，-1：无限循环播放音效，直至调用 stopEffect 或 stopAllEffects 后停止
 @param pitch 设置音效的音调 取值范围为 [0.5, 2]。默认值为 1.0，表示不需要修改音调。取值越小，则音调越低
 @param pan 设置是否改变音效的空间位置。取值范围为 [-1, 1]：0：音效出现在正前方，-1：音效出现在左边，1：音效出现在右边
 @param gain 设置是否改变单个音效的音量。取值范围为 [0.0, 100.0]。默认值为 100.0。取值越小，则音效的音量越低
 @param publish 设置是否将音效传到远端,true：音效在本地播放的同时，会发布到云上，因此远端用户也能听到该音效,false：音效不会发布到 Agora 云上，因此只能在本地听到该音效
 @return 0: 方法调用成功，非0: 方法调用失败
 */
- (int)playEffect:(int)soundId
         filePath:(NSString * _Nullable)filePath
        loopCount:(int)loopCount
            pitch:(double)pitch
              pan:(double)pan
             gain:(double)gain
          publish:(BOOL)publish;


/**
 停止播放指定音效

 @param soundId 指定音效的 ID。每个音效均有唯一的 ID
 @return 0: 方法调用成功，非0: 方法调用失败
 */
- (int)stopEffect:(int)soundId;


/**
 停止播放所有音效

 @return 0: 方法调用成功，非0: 方法调用失败
 */
- (int)stopAllEffects;


/**
 预加载音效
 该方法将指定音效文件(压缩的语音文件)预加载至内存

 @param soundId 指定音效的 ID。每个音效均有唯一的 ID
 @param filePath 音效文件的绝对路径
 @return 0: 方法调用成功，非0: 方法调用失败
 */
- (int)preloadEffect:(int)soundId
            filePath:(NSString * _Nullable) filePath;


/**
 释放音效
 该方法将指定预加载的音效从内存里释放出来

 @param soundId 指定音效的 ID。每个音效均有唯一的 ID
 @return 0: 方法调用成功，非0: 方法调用失败
 */
- (int)unloadEffect:(int)soundId;


/**
 暂停音效播放
 该方法暂停播放指定音效。

 @param soundId 指定音效的 ID。每个音效均有唯一的 ID
 @return 0: 方法调用成功，非0: 方法调用失败
 */
- (int)pauseEffect:(int)soundId;


/**
 暂停所有音效播放

 @return 0: 方法调用成功，非0: 方法调用失败
 */
- (int)pauseAllEffects;


/**
 恢复播放指定音效

 @param soundId 0: 方法调用成功，非0: 方法调用失败
 @return 0: 方法调用成功，非0: 方法调用失败
 */
- (int)resumeEffect:(int)soundId;


/**
 恢复播放所有音效

 @return 0: 方法调用成功，非0: 方法调用失败
 */
- (int)resumeAllEffects;

#pragma mark - 自定义视频源


#pragma mark - 合流布局相关方法
/**
 n+m路转推（n路分流+m路合流），合流信息预设接口
 请确保要在joinChannel之前调用。
 
 @param mixerPublisherConfiguration 合流转推配置信息
 @return 0 成功, 非0 表示失败.
 */
- (int)setMixStreamInfo:(QHVCITLMixerPublisherConfiguration *)mixerPublisherConfiguration;


/**
 设置画中画布局
 该方法设置直播场景里的画中画布局。
 1、您需要首先定义一个画布(canvas): 画布的宽和高(即视频的分辨率), 背景颜色，和您想在屏幕上显示的视频总数。
 2、您需要在画布上定义每个视频的位置和尺寸(无论画布定义的宽和高有多大，每个视频用0到1的相对位置和尺寸进行定义)，图片所在的图层，图片的透明度，视频是经过裁减的还是缩放到合适大小等等。
 
 @param layout 布局参数
 @return 0 成功, return 非0 表示失败
 */
- (int)setVideoCompositingLayout:(nullable QHVCITLVideoCompositingLayout *)layout;


/**
 取消画中画布局设置
 当该合流任务取消时，需要调用此方法。
 
 @return 0: 方法调用成功，非0: 方法调用失败
 */
- (int)clearVideoCompositingLayout;


#pragma mark - 外部数据采集相关
/**
 开启数据采集
 */
- (void)openCollectingData;


/**
 关闭数据采集
 */
- (void)closeCollectingData;


/**
 采集数据
 
 @param buffer CVPixelBufferRef
 @param time 时间戳
 */
- (void)incomingCollectingCapturedData:(CVPixelBufferRef)buffer
                             timeStamp:(CMTime)time;


#pragma mark - 外部处理音视频方法设置


/**
 设置视频回调代理，此代理生效必须在此之前打开视频处理开关
 
 @param videoFrameDelegate 视频处理对象
 */
- (void)setVideoFrameDelegate:(nullable id<QHVCInteractiveVideoFrameDelegate>)videoFrameDelegate;


/**
 设置音频回调代理，此代理生效必须在此之前打开音频处理开关
 
 @param audioFrameDelegate 音频处理对象
 */
- (void)setAudioFrameDelegate:(nullable id<QHVCInteractiveAudioFrameDelegate>)audioFrameDelegate;

@end

NS_ASSUME_NONNULL_END
