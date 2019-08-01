//
//  QHVCNet+QHVCNetPersistence.h
//  QHVCNet
//
//  Created by jiangbingbing on 2018/12/12.
//  Copyright © 2018 yangkui. All rights reserved.
//

#import "QHVCNet.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *注意：使用下载功能一定要先开启localServer
 */

@protocol QHVCNetCachePersistenceDelegate <NSObject>

@optional

- (void)onCachePersistenceStart:(NSString *)rid;

- (void)onCachePersistenceProgress:(NSString *)rid position:(long long)position total:(long long)total speed:(double)speed;

- (void)onCachePersistenceSuccess:(NSString *)rid;

- (void)onCachePersistenceFailed:(NSString *)rid errCode:(int)errCode errMsg:(NSString *)errMsg;

@end

@interface QHVCNet(QHVCNetPersistence)

@property (nonatomic, weak) id<QHVCNetCachePersistenceDelegate> cachePersistenceDelegate;

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

NS_ASSUME_NONNULL_END
