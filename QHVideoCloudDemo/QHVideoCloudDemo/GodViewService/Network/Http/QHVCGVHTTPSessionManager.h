//
//  QHVCGVHTTPSessionManager.h
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/11/6.
//  Copyright © 2018 yangkui. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHVCGVHTTPSessionManager : AFHTTPSessionManager

+ (instancetype)sharedManager;

- (NSURLSessionDataTask *)requestDataWithGet:(NSString *)URLString
                               parameterDict:(NSMutableDictionary *)parameterDict
                                     success:(void (^)(NSURLSessionDataTask *dataTask, NSDictionary *dict))success
                                     failure:(void (^)(NSURLSessionDataTask *dataTask, NSDictionary *dict))failure;

- (NSURLSessionDataTask *)requestDataWithPost:(NSString *)URLString
                                parameterDict:(NSMutableDictionary *)parameterDict
                                      success:(void (^)(NSURLSessionDataTask *dataTask, NSDictionary* dict))success
                                      failure:(void (^)(NSURLSessionDataTask *dataTask, NSDictionary* dict))failure;

- (void)cancelOperations:(NSURLSessionDataTask *)dataTask;

- (void)cancelAllOperations;

@end

NS_ASSUME_NONNULL_END
