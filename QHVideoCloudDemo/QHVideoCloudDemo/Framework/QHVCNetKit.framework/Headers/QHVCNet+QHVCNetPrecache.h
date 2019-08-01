//
//  QHVCNet+QHVCNetPrecache.h
//  QHVCNet
//
//  Created by jiangbingbing on 2018/12/11.
//  Copyright © 2018 yangkui. All rights reserved.
//

#import "QHVCNet.h"

NS_ASSUME_NONNULL_BEGIN

@interface QHVCNet(QHVCNetPrecache)

/**
 添加预缓存任务
 
 @param rid 资源的唯一标识，由于url在加防盗链时是可变的，所以需要一个唯一标识来匹配缓存文件
 @param url 资源的链接
 @param preCacheSizeInKB 预缓存多少的数据量，单位KB
 */
- (void)preloadCacheFile:(NSString *)rid url:(NSString *)url preCacheSize:(int)preCacheSizeInKB;

/**
 取消预缓存任务
 
 @param rid 资源的唯一标识，由于url在加防盗链时是可变的，所以需要一个唯一标识来匹配缓存文件
 */
- (void)cancelPreCache:(NSString *)rid;

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
 清除缓存（当前正在播放任务的缓存不会清除）
 */
- (void)clearPrecache;

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

@end

NS_ASSUME_NONNULL_END
