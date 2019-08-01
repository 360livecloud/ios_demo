//
//  QHVCGVConfig.h
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/9/18.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QHVCGlobalConfig.h"
#import <QHVCNetKit/QHVCNetKit.h>

#pragma mark - 系统启动配置参数

static NSString *kQHVCPlayerConfigKeyBid            = @"bid";
static NSString *kQHVCPlayerConfigKeyCid            = @"cid";
static NSString *kQHVCPlayerConfigKeySN             = @"sn";
static NSString *kQHVCPlayerConfigKeyUrl            = @"url";
static NSString *kQHVCPlayerConfigKeyDecodeType     = @"decode";
static NSString *kQHVCPlayerConfigKeyIsOutputPacket = @"outputPacket";
static NSString *kQHVCPlayerConfigKeyEncryptKey     = @"encryptKey";

//业务服务器正式地址
#define QHVCGV_RELEASE_ENV_GODVIEW_SERVER_URL   @"http://120.52.32.96"
// 业务服务器测试地址
#define QHVCGV_TEST_ENV_GODVIEW_SERVER_URL      @"http://10.182.222.108:6090"

// 信令服务器正式地址
#define kQHVCGVLVC_RELEASE_ENV_LONGLINK_HOST    @"tcp://125.88.225.238:1883"
// 信令服务器测试地址
#define kQHVCGVLVC_TEST_ENV_LONGLINK_HOST       @"tcp://125.88.225.238:1883"

#define QHVCGV_HTTP_TIMEOUT_INTERTVAL               30//网络请求超时时间（秒）
#define QHVCGV_HEART_TIME_INTERTVAL                 10//心跳上报时间间隔（秒）
#define QHVCGV_ROOMLIST_TIME_INTERTVAL              5//房间列表时间间隔（秒）

#pragma mark - 配置文件名
/// 账户登录配置
#define QHVCGV_GODSEES_ACCOUNT_PLIST_VERSION    1.3
#define QHVCGV_GODVIEW_ACCOUNT_FILE             @"QHVCGodViewMain"
#define QHVCGV_GODVIEW_ACCOUNT_SAVE_PATH        @"/QHVCGodViewAccountCache.plist"
/// 用户设置
#define QHVCGS_GODSEES_SETTING_PLIST_VERSION    1.5
#define QHVCGV_GODVIEW_SETTING_SAVE_PATH        @"QHVCGVSetting"
#define QHVCGV_GODVIEW_SETTING_CACHE_SAVE_PATH  @"/QHVCGodViewSettingCache.plist"
/// 注册配置
#define QHVCGV_GODSEES_REGISTER_PLIST_FILE      @"QHVCGSRegister"

#pragma mark - 卡录视频录制时的临时缓存目录
#define QHVCGV_GODVIEW_RECORD_FILE_DIRECTORY    @"QHVCGodViewRecordFilesTmp"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QHVCGVErrorCode) {//错误码，代码中必须处理该消息
    QHVCGV_Error_NoError = 0,
    QHVCGV_Error_Failed = 1,
    QHVCGV_Error_InvalidArgument = 2,
};

typedef NS_ENUM(NSInteger, QHVCGVDataType)
{
    QHVCGV_Data_Type_None = 0,//无类型
    QHVCGV_Data_Type_String,//字符串
    QHVCGV_Data_Type_Number,//数字
    QHVCGV_Data_Type_Dictionary,//字典
    QHVCGV_Data_Type_Array//数组
};

void runOnMainQueueWithoutDeadlocking(void (^block)(void));

@interface QHVCGVConfig : NSObject

#pragma mark - 业务分配变量 -
@property (nonatomic, strong, nullable) NSString* businessServerAddress;//服务器地址
@property (nonatomic, strong, nullable) NSString *signallingServerAddress; // 信令服务器地址
@property (nonatomic, strong, nullable) NSString* userName;//用户名
@property (nonatomic, strong, nullable) NSString* password;//密码
@property (nonatomic, strong, nullable) NSString* serialNumber;//设备编号
@property (nonatomic, assign) NSInteger deviceChannelNumber;//设备渠道号码
//@property (nonatomic, strong, nullable) NSString* token;//业务认证
@property (nonatomic, strong, nonnull) NSString* sessionId;//会话ID
@property (nonatomic, assign) long long serverTimeDeviation;//服务器时间差
@property (nonatomic, assign) NSInteger userHeartInterval;//用户心跳间隔
@property (nonatomic, assign) NSInteger updateDeviceListInterval;//更新设备列表间隔

#pragma mark - 设置相关
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *accountSettings; //账号相关设置
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *userSettings; // 用户设置
@property (nonatomic, assign) QHVCNetGodSeesNetworkConnectType networkConnectType;//网络连接类型
@property (nonatomic, assign) BOOL shouldShowPerformanceInfo;  // 是否展示性能指标toast
@property (nonatomic, assign) BOOL isRTCOpenVideo;      //  rtc对讲开启视频模式
@property (nonatomic, assign) QHVCNetGodSeesPlayerReceiveDataModel playerReceiveDataModel;//播放器接收数据方式
@property (nonatomic, assign) QHVCNetGodSeesStreamType streamType;//码流类型
@property (nonatomic, assign) BOOL isHardDecode;//是否硬解

#pragma mark - 静态方法 -

+ (nonnull instancetype)sharedInstance;

- (void) setEnableTestEnvironment:(BOOL)enableTestEnvironment;
- (void) readAccountSetting;//读取账号配置
- (void) readUserSettings;  // 读取用户设置
/**
 * 更新账户设置（内存+本地）
 */
- (void)updateAccountSettings:(NSMutableArray<NSMutableDictionary *> *)accountSettings;

/**
 * 更新用户设置（内存+本地）
 */
- (void)updateUserSettings:(NSMutableArray<NSDictionary *> *)userSettings;
- (void)resetUserSettings;
@end

NS_ASSUME_NONNULL_END
