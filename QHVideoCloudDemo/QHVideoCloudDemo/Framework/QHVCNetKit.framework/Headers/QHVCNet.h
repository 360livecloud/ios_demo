//
//  QHVCNet.h
//  QHVCNet
//
//  Created by yangkui on 2017/8/29.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//需要开启服务的KEY，值见：QHVCNetServiceType，如果需要同时开启多个服务，多个服务的值相加即可，例如：QHVCNetServicePrecache|QHVCNetServiceGodSees
extern NSString* const kQHVCNetOptionsServicesKey;

#pragma mark - 枚举定义 -

/**
 * 日志等级
 */
typedef NS_ENUM(NSInteger, QHVCNetLogLevel)
{
    QHVCNetLogLevelTrace = 0,//trace
    QHVCNetLogLevelDebug = 1,//debug
    QHVCNetLogLevelInfo  = 2,//info
    QHVCNetLogLevelWarn  = 3,//warn
    QHVCNetLogLevelError = 4,//error
    QHVCNetLogLevelAlarm = 5,//alarm
    QHVCNetLogLevelFatal = 6,//fatal
    QHVCNetLogLevelNone  = 7,//none
};

/**
 *  网络状态
 */
typedef NS_ENUM(NSInteger, QHVCNetNetworkStatus)
{
    QHVCNetNetworkNotReachable = 0,
    QHVCNetNetworkReachableViaWiFi,
    QHVCNetNetworkReachableViaWWAN
};

/**
 * QHVCNetKit提供的服务类型
 */
typedef NS_OPTIONS(NSInteger, QHVCNetServiceType)
{
    QHVCNetServicePrecache          =   1   <<  0,      // 预缓存服务
    QHVCNetServiceGodSees           =   1   <<  1       // 帝视服务
};

#pragma mark - SDK具体实现 -

@interface QHVCNet: NSObject

#pragma mark - 基础功能 -

/**
 该方法生成一个单例QHVCNet
 
 @return QHVCNet对象
 */
+ (instancetype)sharedInstance;

/**
 获取QHVCNetKit的版本信息

 @return 字符串版本号
 */
- (NSString *) getVersion;

/**
 开启LocalServer， 全局只用调用一次， 需要和stopLocalServer配对使用
 
 @param cacheDir 缓存目录，要保证是一个当前存在且有读写权限的文件夹
 @param deviceId 设备Id， 统计上报会带上，追查问题用
 @param appId 业务Id， 统计上报会带上，追查问题用
 @param cacheSizeInMB 初始缓存大小 单位：MB
 @param options @{kQHVCNetOptionsServicesKey:@(QHVCNetServicePrecache | QHVCNetServiceGodsees)}
 */
- (void)startLocalServer:(NSString *)cacheDir
                deviceId:(NSString *)deviceId
                   appId:(NSString *)appId
               cacheSize:(int)cacheSizeInMB
                 options:(NSDictionary *)options;

/**
 停止本地服务， 需要和startLocalServer配对使用
 */
- (void)stopLocalServer;

/**
 获取localserver播放的链接
 
 @param rid 资源的唯一标识，由于url在加防盗链时是可变的，所以需要一个唯一标识来匹配缓存文件
 @param url 资源的链接
 @return 走预缓存播放的链接，不成功将会返回空
 */
- (NSString *)getLocalServerPlayUrl:(NSString *)rid url:(NSString *)url;

/**
 获取localserver播放的链接
 
 @param rid 资源的唯一标识，由于url在加防盗链时是可变的，所以需要一个唯一标识来匹配缓存文件
 @param url 资源的链接
 @param options @{@"open_p2p":@"boolValue",@"open_localserver":@"boolValue"}
 @return 走预缓存播放的链接，不成功将会返回空
 */
- (NSString *)getLocalServerPlayUrl:(NSString *)rid url:(NSString *)url options:(NSDictionary * _Nullable)options;

/**
 是否开启LocalServer
 
 @return YES 开启 NO 未开启
 */
- (BOOL)isStartLocalServer;

/**
 设置日志开关
 
 @param logLevel 日志等级
 @param detailInfo 日志是否包含详细信息（时间、进程号、线程号）
 NSLog和Android的Log函数可以自带这些信息时，可以设置成0
 存入文件或其他不带详细信息的日日志打印函数的场合建议把detailInfo设置成1
 */
- (void)setLogLevel:(QHVCNetLogLevel)logLevel
         detailInfo:(int)detailInfo
           callback:(void(^)(const char* buf, size_t buf_size))callback;

/**
 设置和调整缓存占用空间大小。 这个接口可以中途调用，可以调用多次
 
 @param cacheSizeInMB 缓存空间的大小， 单位:MB
 @return yes:成功 no:失败
 */
- (BOOL)setCacheSize:(int)cacheSizeInMB;

/**
 * 获取网络状态
 */
- (QHVCNetNetworkStatus)networkStatus;

/**
 恢复/禁止QHVCNetKit的所有访问网络主动拉取数据的行为
 
 @param enable YES:允许，NO：禁止，默认：允许
 */
- (void)enableNetwork:(BOOL)enable;

/**
 是否允许QHVCNetKit所有访问网络主动拉取数据的行为
 
 @return YES：允许，NO：禁止
 */
- (BOOL)isEnableNetwork;

/**
 获取p2p信息
 
 @return 详情
 */
- (nullable NSDictionary *)getP2pInfo;

@end

NS_ASSUME_NONNULL_END
