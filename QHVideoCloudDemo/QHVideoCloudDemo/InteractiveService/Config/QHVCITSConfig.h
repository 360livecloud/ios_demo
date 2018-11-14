//
//  QHVCITSConfig.h
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/3/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QHVCCommonKit/QHVCCommonKit.h>
#import <QHVCInteractiveKit/QHVCInteractiveKit.h>

#pragma mark - 枚举定义

typedef NS_ENUM(NSInteger, QHVCITSLogLevel){//日志等级
    QHVCITS_LOG_LEVEL_TRACE = 0,
    QHVCITS_LOG_LEVEL_DEBUG = 1,
    QHVCITS_LOG_LEVEL_INFO  = 2,
    QHVCITS_LOG_LEVEL_WARN  = 3,
    QHVCITS_LOG_LEVEL_ERROR = 4,
    QHVCITS_LOG_LEVEL_ALARM = 5,
    QHVCITS_LOG_LEVEL_FATAL = 6,
    QHVCITS_LOG_LEVEL_NONE  = 7,
};

typedef NS_ENUM(NSInteger, QHVCITSErrorCode) {//错误码，代码中必须处理该消息
    QHVCITS_Error_NoError = 0,
    QHVCITS_Error_Failed = 1,
    QHVCITS_Error_InvalidArgument = 2,
};

typedef NS_ENUM(NSInteger, QHVCITSDataType)
{
    QHVCITS_Data_Type_None = 0,//无类型
    QHVCITS_Data_Type_String,//字符串
    QHVCITS_Data_Type_Number,//数字
    QHVCITS_Data_Type_Dictionary,//字典
    QHVCITS_Data_Type_Array//数组
};

typedef NS_ENUM(NSInteger, QHVCITSRoomType)
{
    QHVCITS_Room_Type_PK = 1,//主播&主播
    QHVCITS_Room_Type_Guest,//主播&嘉宾
    QHVCITS_Room_Type_Party,//轰趴
};

typedef NS_ENUM(NSInteger, QHVCITSTalkType)
{
    QHVCITS_Talk_Type_Normal = 0,//正常
    QHVCITS_Talk_Type_Audio,//仅音频
    QHVCITS_Talk_Type_Video,//仅视频
};

typedef NS_ENUM(NSInteger, QHVCITSIdentity)
{
    QHVCITS_Identity_Audience = 0,//观众
    QHVCITS_Identity_Anchor,//主播
    QHVCITS_Identity_Guest,//嘉宾
};

typedef NS_ENUM(NSInteger, QHVCITSRenderMode)
{
    QHVCITS_Render_SDK = 0,//SDK渲染
    QHVCITS_Render_External,//外部渲染
};

typedef NS_ENUM(NSInteger, QHVCITSRoomLifeCycle)
{
    QHVCITS_RoomLifeCycle_Bind2Role = 0,//绑定到角色
    QHVCITS_RoomLifeCycle_Bind2Room = 1,//绑定到房间
};


#pragma mark - 系统启动配置参数

//正式环境地址
#define QHVCITS_RELEASE_ENV_INTERACTIVE_SERVER_URL   @"http://livedemo.vcloud.360.cn"//房间服务地址

#define QHVCITS_HTTP_TIMEOUT_INTERTVAL               30//网络请求超时时间（秒）
#define QHVCITS_HEART_TIME_INTERTVAL                 10//心跳上报时间间隔（秒）
#define QHVCITS_ROOMLIST_TIME_INTERTVAL              5//房间列表时间间隔（秒）

#pragma mark - 日志参数配置
#define QHVCITS_INTERACTIVE_LOG_ID                   @"interactiveLive_log_id"//互动直播日志ID
#define QHVCITS_INTERACTIVE_LOG_PATH                 @"/com.qihoo.demo/log/interactiveLive/"//互动直播日志保存路径

#pragma mark - 配置文件名
#define QHVCITS_INTERACTIVE_VIDEO_PROFILE_FILE       @"InteractiveVideoProfile"
#define QHVCITS_INTERACTIVE_ACCOUNT_FILE             @"QHVCITLMain"
#define QHVCITS_INTERACTIVE_USER_SETTING_FILE        @"InteractiveSetting"
#define QHVCITS_INTERACTIVE_ACCOUNT_SAVE_PATH        @"/InteractiveAccountCache.plist"
#define QHVCITS_INTERACTIVE_USER_SETTING_SAVE_PATH   @"/InteractiveSettingCache.plist"

#pragma mark - 连麦推流默认配置
#define QHVCITS_VIDEO_WIDTH                          360
#define QHVCITS_VIDEO_HEIGHT                         640
#define QHVCITS_VIDEO_BITRATE                        800
#define QHVCITS_VIDEO_FPS                            15
#define QHVCITS_VIDEO_GOP                            2
#define QHVCITS_ADUIO_FORMAT_AAC                     @"aac"
#define QHVCITS_ADUIO_SAMPLE                         44100
#define QHVCITS_ADUIO_BITRATE                        48
#define QHVCITS_ADUIO_CHANNEL                        1

NS_ASSUME_NONNULL_BEGIN

@interface QHVCITSConfig : NSObject

#pragma mark - 视频云分配渠道变量 -
@property (nonatomic, strong, nonnull) NSString* businessId;//业务ID
@property (nonatomic, strong, nonnull) NSString* channelId;//渠道ID

#pragma mark - 全局性一次性变量 -
@property (nonatomic, strong, nonnull) NSString* interactiveServerUrl;//互动直播服务器地址
@property (nonatomic, assign) BOOL enableTestEnvironment;//使用测试环境
@property (nonatomic, strong, nonnull) NSString* appKey;//appKey
@property (nonatomic, strong, nonnull) NSString* appSecret;//appSecret
@property (nonatomic, strong, nonnull) NSString* sessionId;//会话ID
@property (nonatomic, strong, nonnull) NSString* deviceId;//设备ID
@property (nonatomic, strong, nonnull) NSString* appVersion;//应用版本号
@property (nonatomic, assign) long long serverTimeDeviation;//服务器时间差
@property (nonatomic, assign) NSInteger userHeartInterval;//用户心跳间隔
@property (nonatomic, assign) NSInteger updateRoomListInterval;//更新房间列表间隔
@property (nonatomic, assign) QHVCITLDataCollectMode dataCollectMode;//数据采集模式
@property (nonatomic, assign) BOOL bypassLiveCDNUseSDKService;//旁路直播使用SDK自带的CDN服务
@property (nonatomic, assign) QHVCITSRenderMode businessRenderMode;//业务视频渲染模式，SDK渲染、业务渲染
@property (nonatomic, assign) QHVCITLVideoProfile videoEncoderProfile;//主播视频推流编码-设置中可选择模板设置
@property (nonatomic, assign) QHVCITLVideoProfile videoEncoderProfileForGuest;//嘉宾视频推流编码-设置中可选择模板设置
@property (nonatomic, assign) QHVCITLRenderMode videoViewRenderMode;//视频View渲染方式
@property (nonatomic, assign) NSInteger mergeVideoCanvasWidth;//合流画布的宽
@property (nonatomic, assign) NSInteger mergeVideoCanvasHeight;//合流画布的高

@property (nonatomic, strong, nullable) NSMutableArray<NSMutableDictionary *> *accountSettings; //账号相关设置
@property (nonatomic, strong, nullable) NSMutableArray<NSMutableDictionary *> *userSettings; //主播、嘉宾、观众 音视频相关用户设置
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *videoProfiles;

#pragma mark - 网络队请求列量 -
@property (nonatomic, strong, nullable) dispatch_queue_t protocolQueue;//处理网络收发协议的QUEUE
@property (nonatomic, nullable) void* protocolQueueKey;//处理协议收发的KEY

#pragma mark - 静态方法 -

+ (nonnull NSString *)getVersion;
+ (nonnull instancetype)sharedInstance;

- (void) setEnableTestEnvironment:(BOOL)enableTestEnvironment;
- (void) readAccountSetting;//读取账号设置
- (void) readUserSetting;//读取用户设置

@end

NS_ASSUME_NONNULL_END
