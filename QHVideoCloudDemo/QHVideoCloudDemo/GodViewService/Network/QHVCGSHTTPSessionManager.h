//
//  QHVCGSHTTPSessionManager.h
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2019/5/7.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QHVCCommonKit/QHVCCommonKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 本类只是提供访问的便利，只是对请求数据提供文件头信息，比如：请求超时时间、userAgent、参数转换等服务
 * 用法：通常一个功能组构建一个管理对象（比如调度分发系统、房间管理系统、打点统计系统等），便于模块退出时统一取消协议组的请求。
 */

@interface QHVCGSHTTPSessionManager : NSObject

/**
 初始化，设置请求协议的文本格式、userAgent、超时时间等
 
 @return 实例对象
 */
- (id) init;

/**
 以GET方式获取数据
 
 @param URLString 协议URL
 @param parameterDict 请求协议参数字典
 @param success 成功回调
 @param failure 失败回调
 @return 会话对象
 */
- (NSURLSessionDataTask *)requestDataWithGet:(NSString *)URLString
                               parameterDict:(NSMutableDictionary *)parameterDict
                                     success:(void (^)(NSURLSessionDataTask *dataTask, NSDictionary *dict))success
                                     failure:(void (^)(NSURLSessionDataTask *dataTask, NSDictionary *dict))failure;

/**
 以POST方式获取数据
 
 @param URLString 协议URL
 @param parameterDict 请求协议参数字典
 @param success 成功回调
 @param failure 失败回调
 @return 会话对象
 */
- (NSURLSessionDataTask *)requestDataWithPost:(NSString *)URLString
                                parameterDict:(NSMutableDictionary *)parameterDict
                                      success:(void (^)(NSURLSessionDataTask *dataTask, NSDictionary* dict))success
                                      failure:(void (^)(NSURLSessionDataTask *dataTask, NSDictionary* dict))failure;

/**
 取消某个特定的请求操作
 
 @param dataTask 待取消的任务
 */
- (void)cancelOperations:(NSURLSessionDataTask *)dataTask;

/**
 取消本管理对象所有任务
 */
- (void)cancelAllOperations;

@end

NS_ASSUME_NONNULL_END
