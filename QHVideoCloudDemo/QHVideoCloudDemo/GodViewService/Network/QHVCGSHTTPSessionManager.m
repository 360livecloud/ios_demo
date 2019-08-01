//
//  QHVCGSHTTPSessionManager.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2019/5/7.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCGSHTTPSessionManager.h"
#import "QHVCGlobalConfig.h"
#import "QHVCGVConfig.h"
#import "QHVCGVDefine.h"
#import "QHVCLogger.h"
#import "QHVCGVUserSystem.h"
#import <QHVCCommonKit/QHVCCommonKit.h>

@interface QHVCGSHTTPSessionManager ()

@property (nonatomic, strong) QHVCHTTPSessionManager* httpSessionManager;

@end

@implementation QHVCGSHTTPSessionManager

- (id) init {
    self = [super init];
    _httpSessionManager = [QHVCHTTPSessionManager manager];
    //添加JSON解析
    _httpSessionManager.responseSerializer = [QHVCJSONResponseSerializer serializer];
    _httpSessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json", @"text/json", @"text/javascript",@"text/xml",@"text/html",@"image/gif", nil];
    //设置UserAgent
    NSString* userAgent = [QHVCToolDeviceModel getUserAgent];
    [[_httpSessionManager requestSerializer] setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    //设置网络请求超时时间
    [[_httpSessionManager requestSerializer] setTimeoutInterval:QHVCGV_HTTP_TIMEOUT_INTERTVAL];
    return self;
}

- (NSDictionary *)dealwithSuccessData:(id)responseObject {
    NSMutableDictionary* resultDict = [NSMutableDictionary dictionary];
    if (responseObject == nil) {
        [QHVCToolUtils setLongToDictionary:resultDict key:QHVCGV_KEY_ERROR_NUMBER value:QHVCGV_Error_Failed];
        [QHVCToolUtils setStringToDictionary:resultDict key:QHVCGV_KEY_ERROR_MESSAGE value:@"responseObject is nil"];
        [QHVCToolUtils setObjectToDictionary:resultDict key:QHVCGV_KEY_DATA value:@{}];
    } else if([responseObject isKindOfClass:[NSDictionary class]]) {
        NSInteger errNum = [QHVCToolUtils getIntFromDictionary:responseObject key:QHVCGV_KEY_ERROR_NUMBER defaultValue:QHVCGV_Error_Failed];
        [QHVCToolUtils setLongToDictionary:resultDict key:QHVCGV_KEY_ERROR_NUMBER value:errNum];
        NSString* msgContext = [QHVCToolUtils getStringFromDictionary:responseObject key:QHVCGV_KEY_ERROR_MESSAGE defaultValue:nil];
        [QHVCToolUtils setStringToDictionary:resultDict key:QHVCGV_KEY_ERROR_MESSAGE value:msgContext];
        id contextObj = [QHVCToolUtils getObjectFromDictionary:responseObject key:QHVCGV_KEY_DATA defaultValue:nil];
        if (contextObj) {
            [QHVCToolUtils setObjectToDictionary:resultDict key:QHVCGV_KEY_DATA value:[contextObj mutableCopy]];
        } else {
            [QHVCToolUtils setObjectToDictionary:resultDict key:QHVCGV_KEY_DATA value:@{}];
        }
    } else {
        [QHVCToolUtils setLongToDictionary:resultDict key:QHVCGV_KEY_ERROR_NUMBER value:QHVCGV_Error_Failed];
        [QHVCToolUtils setStringToDictionary:resultDict key:QHVCGV_KEY_ERROR_MESSAGE value:@"responseObject is must dictionary"];
        [QHVCToolUtils setObjectToDictionary:resultDict key:QHVCGV_KEY_DATA value:@{}];
    }
    return resultDict;
}


- (NSURLSessionDataTask *)requestDataWithGet:(NSString *)URLString
                               parameterDict:(NSMutableDictionary *)parameterDict
                                     success:(void (^)(NSURLSessionDataTask *dataTask, NSDictionary *dict))success
                                     failure:(void (^)(NSURLSessionDataTask *dataTask, NSDictionary *dict))failure {
    if ([QHVCToolUtils isNullString:URLString]) {
        [QHVCLogger printLogger:QHVC_LOG_LEVEL_ERROR content:@"requestDataWithGet URLString is nil" dict:parameterDict];
        return nil;
    }
    //合并参数并签名构成完成的URL地址
    QHVCGVConfig* config = [QHVCGVConfig sharedInstance];
    NSDictionary* urlDict = [QHVCGSHTTPSessionManager getSecertLink:URLString dict:parameterDict requestMethod:QHVCGV_KEY_GET];
    NSString* url = [QHVCToolUtils getStringFromDictionary:urlDict key:QHVCGV_KEY_URL defaultValue:nil];
    NSString* sign = [QHVCToolUtils getStringFromDictionary:urlDict key:QHVCGV_KEY_SIGN defaultValue:nil];
    if ([QHVCToolUtils isNullString:sign]) {
        [QHVCLogger printLogger:QHVC_LOG_LEVEL_ERROR content:@"requestDataWithGet sign is nil" dict:urlDict];
        return nil;
    }
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_DEBUG content:@"requestDataWithGet" dict:urlDict];
    //设置请求头
    [[_httpSessionManager requestSerializer] setValue:sign forHTTPHeaderField:@"Authorization"];
    NSString* requestUrl = [NSString stringWithFormat:@"%@%@",[config businessServerAddress], url];
    QHVC_WEAK_SELF
    NSURLSessionDataTask * dataTask = [_httpSessionManager GET:requestUrl
                                                    parameters:nil
                                                      progress:^(NSProgress * _Nonnull downloadProgress) {
                                                          
                                                      } success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
                                                          QHVC_STRONG_SELF
                                                          [QHVCLogger printLogger:QHVC_LOG_LEVEL_INFO content:[NSString stringWithFormat:@"request URL success: %@",requestUrl] dict:responseObject];
                                                          NSDictionary * dict = [self dealwithSuccessData:responseObject];
                                                          NSInteger errNum = [QHVCToolUtils getLongFromDictionary:dict key:QHVCGV_KEY_ERROR_NUMBER defaultValue:QHVCGV_Error_Failed];
                                                          if (errNum == QHVCGV_Error_NoError) {
                                                              if (success) {
                                                                  success(task, dict);
                                                              }
                                                          } else {
                                                              if (failure) {
                                                                  failure(task, dict);
                                                              }
                                                          }
                                                      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                          NSMutableDictionary *errDict = [NSMutableDictionary dictionary];
                                                          [QHVCToolUtils setLongToDictionary:errDict key:QHVCGV_KEY_ERROR_NUMBER value:error.code];
                                                          [QHVCToolUtils setStringToDictionary:errDict key:QHVCGV_KEY_ERROR_MESSAGE value:error.domain];
                                                          [QHVCToolUtils setObjectToDictionary:errDict key:QHVCGV_KEY_DATA value:error.localizedDescription];
                                                          [QHVCLogger printLogger:QHVC_LOG_LEVEL_ERROR content:[NSString stringWithFormat:@"request URL failed: %@",requestUrl] dict:errDict];
                                                          if (failure) {
                                                              failure(task, errDict);
                                                          }
                                                      }];
    return dataTask;
}

- (NSURLSessionDataTask *)requestDataWithPost:(NSString *)URLString
                                parameterDict:(NSMutableDictionary *)parameterDict
                                      success:(void (^)(NSURLSessionDataTask *dataTask, NSDictionary* dict))success
                                      failure:(void (^)(NSURLSessionDataTask *dataTask, NSDictionary* dict))failure {
    if ([QHVCToolUtils isNullString:URLString]) {
        [QHVCLogger printLogger:QHVC_LOG_LEVEL_ERROR content:@"requestDataWithPost URLString is nil" dict:parameterDict];
        return nil;
    }
    //合并参数并签名构成完成的URL地址
    QHVCGVConfig* config = [QHVCGVConfig sharedInstance];
    NSDictionary* urlDict = [QHVCGSHTTPSessionManager getSecertLink:URLString dict:parameterDict requestMethod:QHVCGV_KEY_POST];
    NSString* url = [QHVCToolUtils getStringFromDictionary:urlDict key:QHVCGV_KEY_URL defaultValue:nil];
    NSDictionary* requestBodyDict = [QHVCToolUtils getObjectFromDictionary:urlDict key:QHVCGV_KEY_BODY_DATA defaultValue:nil];
    NSString* sign = [QHVCToolUtils getStringFromDictionary:urlDict key:QHVCGV_KEY_SIGN defaultValue:nil];
    if ([QHVCToolUtils isNullString:sign]) {
        [QHVCLogger printLogger:QHVC_LOG_LEVEL_ERROR content:@"requestDataWithPost sign is nil" dict:urlDict];
        return nil;
    }
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_DEBUG content:@"requestDataWithPost" dict:urlDict];
    //设置请求头
    [[_httpSessionManager requestSerializer] setValue:sign forHTTPHeaderField:@"Authorization"];
    NSString* requestUrl = [NSString stringWithFormat:@"%@%@",[config businessServerAddress], url];
    QHVC_WEAK_SELF
    NSURLSessionDataTask * dataTask = [_httpSessionManager POST:requestUrl
                                                     parameters:requestBodyDict
                                      constructingBodyWithBlock:^(id<QHVCMultipartFormData>  _Nonnull formData) {
                                          
                                      } progress:^(NSProgress * _Nonnull uploadProgress) {
                                          
                                      } success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
                                          QHVC_STRONG_SELF
                                          [QHVCLogger printLogger:QHVC_LOG_LEVEL_INFO content:[NSString stringWithFormat:@"request URL success: %@",requestUrl] dict:responseObject];
                                          NSDictionary * dict = [self dealwithSuccessData:responseObject];
                                          NSInteger errNum = [QHVCToolUtils getLongFromDictionary:dict key:QHVCGV_KEY_ERROR_NUMBER defaultValue:QHVCGV_Error_Failed];
                                          if (errNum == QHVCGV_Error_NoError) {
                                              if (success) {
                                                  success(task, dict);
                                              }
                                          } else {
                                              if (failure) {
                                                  failure(task, dict);
                                              }
                                          }
                                      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                          NSMutableDictionary *errDict = [NSMutableDictionary dictionary];
                                          [QHVCToolUtils setLongToDictionary:errDict key:QHVCGV_KEY_ERROR_NUMBER value:error.code];
                                          [QHVCToolUtils setStringToDictionary:errDict key:QHVCGV_KEY_ERROR_MESSAGE value:error.domain];
                                          [QHVCToolUtils setObjectToDictionary:errDict key:QHVCGV_KEY_DATA value:error.localizedDescription];
                                          [QHVCLogger printLogger:QHVC_LOG_LEVEL_ERROR content:[NSString stringWithFormat:@"request URL failed: %@",requestUrl] dict:errDict];
                                          if (failure) {
                                              failure(task, errDict);
                                          }
                                      }];
    return dataTask;
}

- (void)cancelOperations:(NSURLSessionDataTask *)dataTask {
    if (dataTask) {
        [dataTask cancel];
    }
}

- (void)cancelAllOperations {
    if (_httpSessionManager) {
        [_httpSessionManager.operationQueue cancelAllOperations];
    }
}

+ (NSDictionary *) getSecertLink:(NSString *)path
                            dict:(NSMutableDictionary *)dict
                   requestMethod:(NSString *)method {
    QHVCGVConfig* config = [QHVCGVConfig sharedInstance];
    QHVCGlobalConfig* globalConfig = [QHVCGlobalConfig sharedInstance];
    if ([QHVCToolUtils isNullString:path]) {
        return nil;
    }
    if (!dict) {
        dict = [[NSMutableDictionary alloc] init];
    }
    long long currentTime = [QHVCToolUtils getCurrentDateBySecond] + [config serverTimeDeviation];
    //添加每条协议都有的公共字段
    [QHVCToolUtils setStringToDictionary:dict key:QHVCGV_KEY_CHANNEL_ID value:[globalConfig appId]];
    [QHVCToolUtils setLongToDictionary:dict key:QHVCGV_KEY_TIMESTAMP value:currentTime];
    [QHVCToolUtils setStringToDictionary:dict key:QHVCGV_KEY_SESSION_ID value:[config sessionId]];
    [QHVCToolUtils setStringToDictionary:dict key:QHVCGV_KEY_OS_TYPE value:[QHVCToolDeviceModel getSystemName]];
    [QHVCToolUtils setStringToDictionary:dict key:QHVCGV_KEY_MODEL_NAME value:[QHVCToolDeviceModel getCurrentDeviceName]];
    [QHVCToolUtils setStringToDictionary:dict key:QHVCGV_KEY_VERSION value:[globalConfig appVersion]];
    [QHVCToolUtils setStringToDictionary:dict key:QHVCGV_KEY_DEVICE_ID value:[globalConfig deviceId]];
    
    NSString *userId = [QHVCGVUserSystem sharedInstance].userInfo.userId;
    if (userId &&userId.length > 0) {
        [QHVCToolUtils setStringToDictionary:dict key:QHVCGV_KEY_USER_ID value:userId];
    }
    
    NSString* temp = [QHVCToolUtils dictionaryConversionStringByNetData:dict firstSeparator:@"&" secondSeparator:@"="];
    
    //鉴权排序
    NSArray *keys = [dict allKeys];
    NSArray *resultArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id key1, id key2) {
        NSComparisonResult result = [key1 compare:key2];
        return result == NSOrderedDescending; //升序
    }];
    //计算鉴权相关数据
    NSMutableString* tempSign = [NSMutableString string];
    for (NSString * key in resultArray) {
        QHVCGVDataType type = QHVCGV_Data_Type_None;
        id value = [dict objectForKey:key];
        if ([value isKindOfClass:[NSString class]]) {
            if ([QHVCToolUtils isNullString:value]) {
                continue;
            }
            type = QHVCGV_Data_Type_String;
        } else if ([value isKindOfClass:[NSNumber class]]) {
            type = QHVCGV_Data_Type_Number;
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            type = QHVCGV_Data_Type_Dictionary;
        } else if ([value isKindOfClass:[NSArray class]]) {
            type = QHVCGV_Data_Type_Array;
        }
        if (type != QHVCGV_Data_Type_None) {
            if (type == QHVCGV_Data_Type_String) {
                [tempSign appendFormat:@"%@__%@", key, value];
            } else if (type == QHVCGV_Data_Type_Number) {
                [tempSign appendFormat:@"%@__%@", key, value];
            } else if (type == QHVCGV_Data_Type_Dictionary || type == QHVCGV_Data_Type_Array) {
                NSError *error;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value
                                                                   options:NSJSONWritingPrettyPrinted
                                                                     error:&error];
                if (jsonData) {
                    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    [tempSign appendFormat:@"%@__%@",key,jsonString];
                }
            }
        }
    }
    NSString* signMD5 = [QHVCToolUtils getMD5String:tempSign];
    NSMutableDictionary* tempDict = [NSMutableDictionary dictionary];
    NSString* url = path;
    if ([QHVCGV_KEY_POST isEqualToString:method]) {
        [QHVCToolUtils setObjectToDictionary:tempDict key:QHVCGV_KEY_BODY_DATA value:dict];
    } else if ([QHVCGV_KEY_GET isEqualToString:method]) {
        url = [NSString stringWithFormat:@"%@?%@",path,temp];
    }
    [QHVCToolUtils setStringToDictionary:tempDict key:QHVCGV_KEY_URL value:url];
    [QHVCToolUtils setStringToDictionary:tempDict key:QHVCGV_KEY_SIGN value:signMD5];
    return tempDict;
}

@end
