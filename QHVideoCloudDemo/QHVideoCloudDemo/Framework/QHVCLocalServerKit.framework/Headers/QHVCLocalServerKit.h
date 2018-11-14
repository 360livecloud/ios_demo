//
//  QHVCLocalServerKit.h
//  QHVCLocalServerKit
//
//  Created by yangkui on 2017/8/29.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, QHVCLocalServerLogLevel)
{
    QHVC_LOCALSERVER_LOG_LEVEL_NONE = 0,
    QHVC_LOCALSERVER_LOG_LEVEL_FATAL = 1,
    QHVC_LOCALSERVER_LOG_LEVEL_WARN  = 2,
    QHVC_LOCALSERVER_LOG_LEVEL_INFO  = 3,
    QHVC_LOCALSERVER_LOG_LEVEL_DEBUG = 4
};

//使用下载功能一定要先开启localServer
@protocol QHVCLocalServerCachePersistenceDelegate <NSObject>

@optional

- (void)onStart:(NSString *)rid;

- (void)onProgress:(NSString *)rid position:(long long)position total:(long long)total speed:(double)speed;

- (void)onSuccess:(NSString *)rid;

- (void)onFailed:(NSString *)rid errCode:(int)errCode errMsg:(NSString *)errMsg;

@end

@interface QHVCLocalServerKit : NSObject

@property (nonatomic, weak) id<QHVCLocalServerCachePersistenceDelegate> cachePersistenceDelegate;

/**
 该方法生成一个单例LocalServer
 
 @return QHLiveCloudLocalServer对象
 */
+ (instancetype)sharedInstance;


/**
 获取LocalServer的版本信息 

 @return 字符串版本号
 */
- (NSString *) getVersion;

/**
 设置日志开关
 
 @param logLevel 日志等级
 @param detailInfo 日志是否包含详细信息（时间、进程号、线程号）
 NSLog和Android的Log函数可以自带这些信息时，可以设置成0
 存入文件或其他不带详细信息的日日志打印函数的场合建议把detailInfo设置成1
 */
- (void)setLogLevel:(QHVCLocalServerLogLevel)logLevel detailInfo:(int)detailInfo callback:(void(^)(const char* buf, size_t buf_size))callback;

/**
 设置和调整缓存占用空间大小。 这个接口可以中途调用，可以调用多次

 @param cacheSizeInMB 缓存空间的大小， 单位:MB
 @return yes:成功 no:失败
 */
- (BOOL)setCacheSize:(int)cacheSizeInMB;

/**
 清除缓存（当前正在播放任务的缓存不会清除）
 */
- (void)clearCache;

/**
 添加预缓存任务
 
 @param rid 资源的唯一标识，由于url在加防盗链时是可变的，所以需要一个唯一标识来匹配缓存文件
 @param url 资源的链接
 @param preCacheSizeInKB 预缓存多少的数据量，单位KB
 */
- (void)preloadCacheFile:(NSString *)rid url:(NSString *)url preCacheSize:(int)preCacheSizeInKB;


/**
 获取走LocalServer播放的链接
 
 @param rid 资源的唯一标识，由于url在加防盗链时是可变的，所以需要一个唯一标识来匹配缓存文件
 @param url 资源的链接
 @return 走LocalServer播放的链接，不成功将会返回空
 */
- (NSString *)getPlayUrl:(NSString *)rid url:(NSString *)url;

/**
 取消预缓存任务
 
 @param rid 资源的唯一标识，由于url在加防盗链时是可变的，所以需要一个唯一标识来匹配缓存文件
 */
- (void)cancelPreCache:(NSString *)rid;

/**
 设置移动网络预缓存开关，防止在移动网络下额外花费流量。
 
 @param onoff YES:开  FALSE:关， 默认：开
 */
- (void)enablePrecacheForMobileNetwork:(BOOL)onoff;

/**
 是否允许移动网络环境下开启预缓存

 @return YES 允许， NO 不允许
 */
- (BOOL)isEnablePrecacheForMobileNetwork;

/**
 返回指定的缓存已完成的数据量以及总数据量

 @param rid 资源的唯一标识，由于url在加防盗链时是可变的，所以需要一个唯一标识来匹配缓存文件
 @param url 资源的链接
 @param callback 返回结果，cachedSize：已经缓存文件大小，totalSize：总文件大小，单位：字节
 */
- (void)getFileCachedSize:(NSString *)rid url:(NSString *)url callback:(void(^)(unsigned long long cachedSize, unsigned long long totalSize))callback;

/**
 返回指定的缓存在给定偏移后连续可用的数据量

 @param rid 资源的唯一标识，由于url在加防盗链时是可变的，所以需要一个唯一标识来匹配缓存文件
 @param url 资源的链接
 @param offset 偏移量
 @return 指定偏移后连续可用的数据量
 */
-(unsigned long long)getFileAvailedSize:(NSString *)rid url:(NSString *)url offset:(unsigned long long)offset;

/**
 恢复/禁止LocalServer所有访问网络主动拉取数据的行为

 @param enableCache YES:允许，NO：禁止，默认：允许
 */
- (void)enableCache:(BOOL)enableCache;

/**
 是否允许LocalServer所有预缓存访问网络主动拉取数据的行为

 @return YES：允许，NO：禁止
 */
- (BOOL)isEnableCache;

/**
 开启LocalServer， 全局只用调用一次， 需要和stopServer配对使用

 @param cacheDir 缓存目录，要保证是一个当前存在且有读写权限的文件夹
 @param deviceId 设备Id， 统计上报会带上，追查问题用
 @param appId 业务Id， 统计上报会带上，追查问题用
 @param cacheSizeInMB 初始缓存大小 单位：MB
 */
- (void)startServer:(NSString *)cacheDir deviceId:(NSString *)deviceId appId:(NSString *)appId cacheSize:(int)cacheSizeInMB;

/**
 停止LocalServer， 需要和startServer配对使用
 */
- (void)stopServer;

/**
 是否开启LocalServer

 @return YES 开启 NO 未开启
 */
- (BOOL)isStartLocalServer;

#pragma mark CachePersistence
/**
 * 重建某个缓存的持久化任务（默认暂停状态，需要开始，调用resumeCachePersistence）
 *
 * @param rid 资源的唯一标识，由于url在加防盗链时是可变的，所以需要一个唯一标识来匹配缓存文件
 * @param url 资源的链接
 * @param path 持久化磁盘路径
 * @return true 表示成功，否则表示失败
 */
- (BOOL)rebuildPersistence:(NSString *)rid url:(NSString *)url path:(NSString *)path;

/**
 * 对某个缓存开始持久化任务
 *
 * @param rid 资源的唯一标识，由于url在加防盗链时是可变的，所以需要一个唯一标识来匹配缓存文件
 * @param url 资源的链接
 * @param path 持久化磁盘路径
 * @return true 表示成功，否则表示失败
 */
- (BOOL)cachePersistence:(NSString *)rid url:(NSString *)url path:(NSString *)path;

/**
 * 取消对某个缓存的持久化任务
 *
 * @param rid 资源的唯一标识，由于url在加防盗链时是可变的，所以需要一个唯一标识来匹配缓存文件
 * @param deleteFile 是否同时删除已持久化的文件
 * @return true 表示成功，否则表示失败
 */
- (BOOL)cancelCachePersistence:(NSString *)rid deleteFile:(BOOL)deleteFile;

/**
 * 暂停对某个缓存的持久化任务
 *
 * @param rid 资源的唯一标识，由于url在加防盗链时是可变的，所以需要一个唯一标识来匹配缓存文件
 * @return true 表示成功，否则表示失败
 */
- (BOOL)pauseCachePersistence:(NSString *)rid;

/**
 * 恢复对某个缓存的持久化任务
 *
 * @param rid 资源的唯一标识，由于url在加防盗链时是可变的，所以需要一个唯一标识来匹配缓存文件
 * @return true 表示成功，否则表示失败
 */
- (BOOL)resumeCachePersistence:(NSString *)rid;

/**
 * 查询某个持久化任务已完成的数据量以及总数据量
 *
 * @param rid 资源的唯一标识，由于url在加防盗链时是可变的，所以需要一个唯一标识来匹配缓存文件
 * @param callback cachedSize：已经缓存文件大小，totalSize：总文件大小，单位：字节
 */
- (void)getCachePersistenceSize:(NSString *)rid callback:(void(^)(unsigned long long cachedSize, unsigned long long totalSize))callback;

/**
 * 查询某个持久化任务是否完成
 *
 * @param rid 资源的唯一标识，由于url在加防盗链时是可变的，所以需要一个唯一标识来匹配缓存文件
 * @return true 持久化完成，false 未持久化完成
 */
- (BOOL)isCachePersistenceFinished:(NSString *)rid;

@end
