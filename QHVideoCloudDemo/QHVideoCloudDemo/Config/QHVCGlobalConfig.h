//
//  QHVCGlobalConfig.h
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2017/6/15.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height


// -----------------------------------------------------------------------------
// 字体
#define kQHVCFontPingFangHKRegular(s) [UIFont fontWithName:@"PingFangHK-Regular" size:s]
#define kQHVCFontPingFangSCMedium(s)  [UIFont fontWithName:@"PingFangSC-Medium" size:s]


// -----------------------------------------------------------------------------
// 控件
// 系统控件默认高度
#define kQHVCScreenWidth              [[UIScreen mainScreen] bounds].size.width
#define kQHVCScreenHeight             [[UIScreen mainScreen] bounds].size.height
#define kQHVCScreenRect               [[UIScreen mainScreen] bounds]
#define kQHVCScreenScaleTo6          (kQHVCScreenWidth/375.0f)   // 当前屏幕对应iPhone6比例

#define kQHVCGetImageWithName(imgName)    [UIImage imageNamed:imgName]

#define kQHVCIOS8Later  (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1)
#define kQHVCIOS7Later  (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
#define kQHVCIOS6Later  (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_5_1)
#define kQHVCIOS10Later (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max)
#define kQHVCIOS11Later  (floor(NSFoundationVersionNumber) > 1400)

//判断是否是ipad
#define kQHVCIsPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
//判断iPhone4系列
#define kQHVCIPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) && !kQHVCIsPad : NO)
//判断iPhone5系列
#define kQHVCIPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) && !kQHVCIsPad : NO)
//判断iPhone6系列
#define kQHVCIPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) && !kQHVCIsPad : NO)
//判断iphone6+系列
#define kQHVCIPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) && !kQHVCIsPad : NO)
//判断iPhoneX
#define kQHVCIPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !kQHVCIsPad : NO)
//判断iPHoneXr
#define kQHVCIPhoneXr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) && !kQHVCIsPad : NO)
//判断iPhoneXs
#define kQHVCIPhoneXs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !kQHVCIsPad : NO)
//判断iPhoneXs Max
#define kQHVCIPhoneXsMax ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) && !kQHVCIsPad : NO)
// iPhoneX系列
#define kQHVCIPhoneXSerial (kQHVCIPhoneX==YES || kQHVCIPhoneXr ==YES || kQHVCIPhoneXs== YES || kQHVCIPhoneXsMax== YES)
/// iPhone刘海高度
#define kQHVCPhoneFringeHeight        (kQHVCIPhoneXSerial ? 44.0f : 0)
#define kQHVCStatusBarHeight          (kQHVCIPhoneXSerial ? 44.0 : 20.0)
#define kQHVCNavBarHeight             (44.0)
#define kQHVCTabBarHeight             (kQHVCIPhoneXSerial ? 83.0 : 49.0)
#define kQHVCStatusAndNaviBarHeight   (kQHVCStatusBarHeight + kQHVCNavBarHeight)
#define kQHVCBottomSafeAreaHeight     (kQHVCIPhoneXSerial ? 34.0f : 0)

#define kQHVCFONT(n)                [UIFont systemFontOfSize:(n)]
#define kQHVCFONT_B(n)              [UIFont boldSystemFontOfSize:(n)]
#define kQHVCFONT_N(s,n)            [UIFont fontWithName:(s) size:(n)]

// -----------------------------------------------------------------------------
// 辅助

#define QHVC_WEAK_SELF                __weak __typeof(&*self) weakSelf = self;
#define QHVC_STRONG_SELF              __strong __typeof(&*self) self = weakSelf;

#pragma mark - 通用颜色


#pragma mark - 定义模块类型

#define QHVC_MODEL_PUSHSTREAM          @"pushStream"//推流
#define QHVC_MODEL_PLAYING             @"playing"//播放
#define QHVC_MODEL_INTERACTIVE         @"interactive"//互动直播
#define QHVC_MODEL_UPLOADING           @"uploading"//上传
#define QHVC_MODEL_VIDEOEDIT           @"videoEdit"//视频编辑
#define QHVC_MODEL_LOCALSERVER         @"localServer"//本地缓存服务器


#pragma mark - 定义服务器地址



#pragma mark - 定义属性参数

#define QHVC_ATT_ICON                                @"icon"
#define QHVC_ATT_NAME                                @"name"
#define QHVC_ATT_TYPE                                @"type"

#pragma mark - 定义视频云账号公共参数

@class QHVCCommonCloudControl;
//----帝视云平台账号----
#define kQHVCProduct                QHVC_COMMON_PRODUCT_IOT_VIDEOCLOUD //IOT平台
#define kQHVCAppId                  @"videocloud_demo"

//----视频云平台账号----
//#define kQHVCProduct                QHVC_COMMON_PRODUCT_VIDEOCLOUD //视频云平台
//#define kQHVCAppId                  @"videocloud_demo"
#define kQHVCChannelId              @"ilive_demo"//如果是视频云业务，需要关注此参数；如果是帝视业务，则不需要关注此参数。

#pragma mark - 定义互动直播公共参数

#define kQHVCInteractiveAppKey      @"" //如果需要体验，请联系我们
#define kQHVCInteractiveAppSecret   @"" //如果需要体验，请联系我们

#pragma mark - 定义直播推流公共参数

#pragma mark - 定义播放器公共参数

#pragma mark - 定义本地存储公共参数

#pragma mark - 定义上传公共参数
#define kQHVCUploadAppKey           @"" //如果需要体验，请联系我们
#define kQHVCUploadAppSecret        @"" //如果需要体验，请联系我们

#pragma mark - 定义视频编辑公共参数

#pragma mark - 定义帝视公共参数
#define kQHVCGodSeesAppKey          @"" //如果需要体验，请联系我们
#define kQHVCGodSeesAppSecret       @"" //如果需要体验，请联系我们

#pragma mark - 日志参数配置
#define QHVC_DEMO_LOG_ID            @"demo_log_id"//demo日志ID
#define QHVC_DEMO_LOG_PATH          @"/com.qihoo.demo/log/demo/"//互动直播日志保存路径

#pragma mark - 全局公共配置参数



@interface QHVCGlobalConfig : NSObject

#pragma mark - 视频云分配渠道变量 -

@property (nonatomic, strong) NSString* appId;//业务在视频云申请的appId
@property (nonatomic, strong) NSString* channelId;//渠道ID，仅视频云用，帝视项目不用该项。
@property (nonatomic, strong) NSString* appKey;//appKey
@property (nonatomic, strong) NSString* appSecret;//appSecret
@property (nonatomic, strong) NSString* deviceId;//设备ID
@property (nonatomic, strong) NSString* appVersion;//应用版本号
@property (nonatomic, strong) NSString* model;//设备型号

#pragma mark - 网络队请求列量 -
@property (nonatomic, strong, nullable) dispatch_queue_t protocolQueue;//处理网络收发协议的QUEUE
@property (nonatomic, nullable) void* protocolQueueKey;//处理协议收发的KEY

#pragma mark - 静态方法 -
+ (instancetype) sharedInstance;
+ (UIColor *) getStatusBarColor;
+ (void) setStatusBarColor:(UIColor *)color;


/**
 下行请求计算业务签名
 如果同时传了serialNumber、deviceId，则用deviceId计算签名

 @param appId 应用ID
 @param serialNumber 流SN
 @param deviceId 设备ID
 @param appKey 密钥
 @return 签名
 */
+ (NSString *)generateBusinessSubscriptionSignWithAppId:(NSString *)appId
                                           serialNumber:(NSString *)serialNumber
                                               deviceId:(NSString *)deviceId
                                                 appKey:(NSString *)appKey;
@end

NS_ASSUME_NONNULL_END
