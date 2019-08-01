//
//  QHVCGVHTTPSessionManager.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/11/6.
//  Copyright © 2018 yangkui. All rights reserved.
//

#import "QHVCGVHTTPSessionManager.h"
#import "QHVCGVConfig.h"
#import "QHVCGVDefine.h"
#import "QHVCLogger.h"
#import "QHVCGVUserSystem.h"
#import <QHVCCommonKit/QHVCCommonKit.h>

#define QHVCGVHTTPRequestSecretKey          @"465a88a07cc1dab18abda500ae3b9bf0"


@implementation QHVCGVHTTPSessionManager

+ (instancetype)sharedManager {
    static QHVCGVHTTPSessionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [QHVCGVHTTPSessionManager new];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        //添加JSON解析
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json", @"text/json", @"text/javascript",@"text/xml",@"text/html",@"image/gif", nil];
//        //设置UserAgent
//        NSString* userAgent = [QHVCToolDeviceModel getUserAgent];
//        [[_httpSessionManager requestSerializer] setValue:userAgent forHTTPHeaderField:@"User-Agent"];
        //设置网络请求超时时间
//        [[_httpSessionManager requestSerializer] setTimeoutInterval:QHVCGV_HTTP_TIMEOUT_INTERTVAL];
    }
    return self;
}


- (NSDictionary *)dealwithSuccessData:(id)responseObject
{
    NSMutableDictionary* resultDict = [NSMutableDictionary dictionary];
    if (responseObject == nil)
    {
        [QHVCToolUtils setLongToDictionary:resultDict key:QHVCGV_KEY_ERROR_NUMBER value:QHVCGV_Error_Failed];
        [QHVCToolUtils setStringToDictionary:resultDict key:QHVCGV_KEY_ERROR_MESSAGE value:@"responseObject is nil"];
        [QHVCToolUtils setObjectToDictionary:resultDict key:QHVCGV_KEY_DATA value:@{}];
    }else if([responseObject isKindOfClass:[NSDictionary class]])
    {
        NSInteger errNum = [QHVCToolUtils getIntFromDictionary:responseObject key:QHVCGV_KEY_ERROR_NUMBER defaultValue:QHVCGV_Error_Failed];
        [QHVCToolUtils setLongToDictionary:resultDict key:QHVCGV_KEY_ERROR_NUMBER value:errNum];
        NSString* msgContext = [QHVCToolUtils getStringFromDictionary:responseObject key:QHVCGV_KEY_ERROR_MESSAGE defaultValue:nil];
        [QHVCToolUtils setStringToDictionary:resultDict key:QHVCGV_KEY_ERROR_MESSAGE value:msgContext];
        id contextObj = [QHVCToolUtils getObjectFromDictionary:responseObject key:QHVCGV_KEY_DATA defaultValue:nil];
        if (contextObj)
        {
            [QHVCToolUtils setObjectToDictionary:resultDict key:QHVCGV_KEY_DATA value:[contextObj mutableCopy]];
        }else
        {
            [QHVCToolUtils setObjectToDictionary:resultDict key:QHVCGV_KEY_DATA value:@{}];
        }
    }else
    {
        [QHVCToolUtils setLongToDictionary:resultDict key:QHVCGV_KEY_ERROR_NUMBER value:QHVCGV_Error_Failed];
        [QHVCToolUtils setStringToDictionary:resultDict key:QHVCGV_KEY_ERROR_MESSAGE value:@"responseObject is must dictionary"];
        [QHVCToolUtils setObjectToDictionary:resultDict key:QHVCGV_KEY_DATA value:@{}];
    }
    return resultDict;
}

- (NSURLSessionDataTask *)requestDataWithGet:(NSString *)URLString
                               parameterDict:(NSMutableDictionary *)parameterDict
                                     success:(void (^)(NSURLSessionDataTask *dataTask, NSDictionary *dict))success
                                     failure:(void (^)(NSURLSessionDataTask *dataTask, NSDictionary *dict))failure
{
    if ([QHVCToolUtils isNullString:URLString])
    {
        [QHVCLogger printLogger:QHVC_LOG_LEVEL_ERROR content:@"requestDataWithGet URLString is nil, dict:" dict:parameterDict];
        return nil;
    }
    //合并参数并签名构成完成的URL地址
//    QHVCGVConfig* config = [QHVCGVConfig sharedInstance];
    NSDictionary* urlDict = [self getSecertLink:URLString dict:parameterDict requestMethod:QHVCGV_KEY_GET];
    NSString* url = [QHVCToolUtils getStringFromDictionary:urlDict key:QHVCGV_KEY_URL defaultValue:nil];
    NSString* sign = [QHVCToolUtils getStringFromDictionary:urlDict key:QHVCGV_KEY_SIGN defaultValue:nil];
    if ([QHVCToolUtils isNullString:sign])
    {
        [QHVCLogger printLogger:QHVC_LOG_LEVEL_ERROR content:@"requestDataWithGet sign is nil, dict:" dict:urlDict];
        return nil;
    }
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_DEBUG content:@"requestDataWithGet :" dict:urlDict];
    //设置请求头
    [[self requestSerializer] setValue:sign forHTTPHeaderField:@"Authorization"];
//    NSString* requestUrl = [NSString stringWithFormat:@"%@%@",[config interactiveServerUrl], url];
    NSString *requestUrl = url;
    WEAK_SELF_GODVIEW
    NSURLSessionDataTask * dataTask = [self GET:requestUrl
                                                    parameters:nil
                                                      progress:^(NSProgress * _Nonnull downloadProgress) {
                                                          
                                                      } success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
                                                          STRONG_SELF_GODVIEW
                                                          [QHVCLogger printLogger:QHVC_LOG_LEVEL_INFO content:[@"request URL success :" stringByAppendingString:requestUrl] dict:urlDict];
                                                          
                                                          NSDictionary * dict = [self dealwithSuccessData:responseObject];
                                                          NSInteger errNum = [QHVCToolUtils getLongFromDictionary:dict key:QHVCGV_KEY_ERROR_NUMBER defaultValue:QHVCGV_Error_Failed];
                                                          if (errNum == QHVCGV_Error_NoError)
                                                          {
                                                              if (success)
                                                              {
                                                                  success(task, dict);
                                                              }
                                                          }else
                                                          {
                                                              if (failure)
                                                              {
                                                                  failure(task, dict);
                                                              }
                                                          }
                                                      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                          NSMutableDictionary *errDict = [NSMutableDictionary dictionary];
                                                          [QHVCToolUtils setLongToDictionary:errDict key:QHVCGV_KEY_ERROR_NUMBER value:error.code];
                                                          [QHVCToolUtils setStringToDictionary:errDict key:QHVCGV_KEY_ERROR_MESSAGE value:error.domain];
                                                          [QHVCToolUtils setObjectToDictionary:errDict key:QHVCGV_KEY_DATA value:error.localizedDescription];
                                                          [QHVCLogger printLogger:QHVC_LOG_LEVEL_ERROR content:[@"request URL failed:" stringByAppendingString:requestUrl] dict:errDict];
                                                          if (failure)
                                                          {
                                                              failure(task, errDict);
                                                          }
                                                      }];
    return dataTask;
}

- (NSURLSessionDataTask *)requestDataWithPost:(NSString *)URLString
                                parameterDict:(NSMutableDictionary *)parameterDict
                                      success:(void (^)(NSURLSessionDataTask *dataTask, NSDictionary* dict))success
                                      failure:(void (^)(NSURLSessionDataTask *dataTask, NSDictionary* dict))failure
{
    if ([QHVCToolUtils isNullString:URLString])
    {
        [QHVCLogger printLogger:QHVC_LOG_LEVEL_ERROR content:@"requestDataWithPost URLString is nil dict:" dict:parameterDict];
        return nil;
    }
    //合并参数并签名构成完成的URL地址
    NSDictionary* urlDict = [self getSecertLink:URLString dict:parameterDict requestMethod:QHVCGV_KEY_POST];
    NSString* url = [QHVCToolUtils getStringFromDictionary:urlDict key:QHVCGV_KEY_URL defaultValue:nil];
    NSDictionary* requestBodyDict = [QHVCToolUtils getObjectFromDictionary:urlDict key:QHVCGV_KEY_BODY_DATA defaultValue:nil];
    NSString* sign = [QHVCToolUtils getStringFromDictionary:urlDict key:QHVCGV_KEY_SIGN defaultValue:nil];
    if ([QHVCToolUtils isNullString:sign])
    {
        [QHVCLogger printLogger:QHVC_LOG_LEVEL_ERROR content:@"requestDataWithPost sign is nil dict:" dict:urlDict];
        return nil;
    }
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_DEBUG content:@"requestDataWithPost dict:" dict:urlDict];
    //设置请求头
    [[self requestSerializer] setValue:sign forHTTPHeaderField:@"Authorization"];
    QHVCGVConfig* config = [QHVCGVConfig sharedInstance];
    NSString* requestUrl = [NSString stringWithFormat:@"%@%@",[config businessServerAddress], url];
    WEAK_SELF_GODVIEW
    NSURLSessionDataTask * dataTask = [self POST:requestUrl
                                                     parameters:requestBodyDict
                                      constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                                          
                                      } progress:^(NSProgress * _Nonnull uploadProgress) {
                                          
                                      } success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
                                          STRONG_SELF_GODVIEW
                                          [QHVCLogger printLogger:QHVC_LOG_LEVEL_INFO content:[NSString stringWithFormat:@"request URL success: %@  dict:",requestUrl] dict:responseObject];
                                          NSDictionary * dict = [self dealwithSuccessData:responseObject];
                                          NSInteger errNum = [QHVCToolUtils getLongFromDictionary:dict key:QHVCGV_KEY_ERROR_NUMBER defaultValue:QHVCGV_Error_Failed];
                                          if (errNum == QHVCGV_Error_NoError)
                                          {
                                              if (success)
                                              {
                                                  success(task, dict);
                                              }
                                          }else
                                          {
                                              if (failure)
                                              {
                                                  failure(task, dict);
                                              }
                                          }
                                      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                          NSMutableDictionary *errDict = [NSMutableDictionary dictionary];
                                          [QHVCToolUtils setLongToDictionary:errDict key:QHVCGV_KEY_ERROR_NUMBER value:error.code];
                                          [QHVCToolUtils setStringToDictionary:errDict key:QHVCGV_KEY_ERROR_MESSAGE value:error.domain];
                                          [QHVCToolUtils setObjectToDictionary:errDict key:QHVCGV_KEY_DATA value:error.localizedDescription];
                                          [QHVCLogger printLogger:QHVC_LOG_LEVEL_ERROR content:[NSString stringWithFormat:@"request URL failed: %@  dict:",requestUrl] dict:errDict];
                                          if (failure)
                                          {
                                              failure(task, errDict);
                                          }
                                      }];
    return dataTask;
}

- (void)cancelOperations:(NSURLSessionDataTask *)dataTask
{
    if (dataTask)
    {
        [dataTask cancel];
    }
}

- (void)cancelAllOperations
{
    [self.operationQueue cancelAllOperations];
}

- (NSDictionary *) getSecertLink:(NSString *)path
                            dict:(NSMutableDictionary *)dict
                   requestMethod:(NSString *)method
{
//    QHVCGVConfig* config = [QHVCGVConfig sharedInstance];
    if ([QHVCToolUtils isNullString:path])
    {
        return nil;
    }
    if (!dict)
    {
        dict = [[NSMutableDictionary alloc] init];
    }
    
    NSString *userId = [QHVCGVUserSystem sharedInstance].userInfo.userId;
    if (userId &&userId.length > 0) {
        [QHVCToolUtils setStringToDictionary:dict key:QHVCGV_KEY_USER_ID value:userId];
    }
    // 时间戳
    long long currentTime = [QHVCToolUtils getCurrentDateByMilliscond];
    
    NSString *urlString = [path stringByAppendingFormat:@"?r=%lld&from=ios",currentTime];
    NSString *tempSign = [NSString stringWithFormat:@"from=iosr=%lld%@",currentTime,QHVCGVHTTPRequestSecretKey];
    NSString* signMD5 = [QHVCToolUtils getMD5String:tempSign];
    
    NSMutableDictionary* tempDict = [NSMutableDictionary dictionary];
    if ([QHVCGV_KEY_POST isEqualToString:method])
    {
        [QHVCToolUtils setObjectToDictionary:tempDict key:QHVCGV_KEY_BODY_DATA value:dict];
    }
    [QHVCToolUtils setStringToDictionary:tempDict key:QHVCGV_KEY_URL value:urlString];
    [QHVCToolUtils setStringToDictionary:tempDict key:QHVCGV_KEY_SIGN value:signMD5];
    return tempDict;
}


@end
