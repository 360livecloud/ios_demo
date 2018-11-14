//
//  QHVCHTTPSession.m
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/8/17.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCHTTPSession.h"
#import "QHVCSessionManager.h"

@implementation QHVCHTTPSession

+ (nullable NSURLSessionDataTask *)GET:(nonnull NSString *)urlString
                             paraments:(nullable id)paraments
                          successBlock:(nullable successBlock)success
                             failBlock:(nullable failBlock)fail
{
    return [[QHVCSessionManager sharedInstance] GET:urlString parameters:paraments progress:^(NSProgress * _Nonnull downloadProgress) {} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(error);
    }];
}

+ (nullable NSURLSessionDataTask *)POST:(nonnull NSString *)urlString
                              paraments:(nullable id)paraments
                           successBlock:(nullable successBlock)success
                              failBlock:(nullable failBlock)fail
{
    return [[QHVCSessionManager sharedInstance] POST:urlString parameters:paraments progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(error);
    }];
}

+ (nullable NSURLSessionDataTask *)PUT:(nonnull NSString *)urlString
                             paraments:(nullable id)paraments
                          successBlock:(nullable successBlock)success
                             failBlock:(nullable failBlock)fail
{
    return [[QHVCSessionManager sharedInstance] PUT:urlString parameters:paraments success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"dict start ----\n%@   \n ---- end  -- ", dict);
        success(responseObject,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", [error localizedDescription]);
        fail(error);
    }];
}

+ (nullable NSURLSessionDataTask *)HEAD:(nonnull NSString *)urlString
                              paraments:(nullable id)paraments
                           successBlock:(nullable successBlock)success
                              failBlock:(nullable failBlock)fail
{
    return [[QHVCSessionManager sharedInstance] HEAD:urlString parameters:paraments success:^(NSURLSessionDataTask * _Nonnull task) {
        NSLog(@"%@", task);
        success(nil,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", [error localizedDescription]);
        fail(error);
    }];
}

+ (nullable NSURLSessionDataTask *)DELETE:(nonnull NSString *)urlString
                                paraments:(nullable id)paraments
                             successBlock:(nullable successBlock)success
                                failBlock:(nullable failBlock)fail
{
    return [[QHVCSessionManager sharedInstance] DELETE:urlString parameters:paraments success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"dict start ----\n%@   \n ---- end  -- ", dict);
        success(responseObject,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", [error localizedDescription]);
        fail(error);
    }];
}

+ (nullable NSURLSessionDataTask *)requestWithRequestType:(LTHTTPRequestType)type urlString:(NSString *)urlString paraments:(id)paraments successBlock:(successBlock)success failBlock:(failBlock)fail
{
    NSURLSessionDataTask * task = nil;
    switch (type)
    {
        case LTHTTPRequestTypeGet:
        {
            task = [QHVCHTTPSession GET:urlString paraments:paraments successBlock:^(NSDictionary * _Nullable object, NSError * _Nullable error) {
                success(object, error);
            } failBlock:^(NSError * _Nullable error) {
                fail(error);
            }];
        }
            break;
        case LTHTTPRequestTypePost:
        {
            task = [QHVCHTTPSession POST:urlString paraments:paraments successBlock:^(NSDictionary * _Nullable object, NSError * _Nullable error) {
                success(object, error);
            } failBlock:^(NSError * _Nullable error) {
                fail(error);
            }];
        }
            break;
        case LTHTTPRequestTypePut:
        {
            task = [QHVCHTTPSession PUT:urlString paraments:paraments successBlock:^(NSDictionary * _Nullable object, NSError * _Nullable error) {
                success(object, error);
            } failBlock:^(NSError * _Nullable error) {
                fail(error);
            }];
        }
            break;
        case LTHTTPRequestTypeHead:
        {
            task = [QHVCHTTPSession HEAD:urlString paraments:paraments successBlock:^(NSDictionary * _Nullable object, NSError * _Nullable error) {
                success(object, error);
            } failBlock:^(NSError * _Nullable error) {
                fail(error);
            }];
        }
            break;
        case LTHTTPRequestTypeDelete:
        {
            task = [QHVCHTTPSession DELETE:urlString paraments:paraments successBlock:^(NSDictionary * _Nullable object, NSError * _Nullable error) {
                success(object, error);
            } failBlock:^(NSError * _Nullable error) {
                fail(error);
            }];
        }
            break;
    }
    return task;
}

+ (void)cancelAllRequest
{
    [[QHVCSessionManager sharedInstance].operationQueue cancelAllOperations];
}

+ (void)cancelHttpRequestWithRequestType:(NSString *)requestType requestUrlString:(NSString *)string
{
    NSError * error;
    NSString * urlToPeCanced = [[[[QHVCSessionManager sharedInstance].requestSerializer
                                  requestWithMethod:requestType URLString:string parameters:nil error:&error] URL] path];
    
    for (NSOperation * operation in [QHVCSessionManager sharedInstance].operationQueue.operations)
    {
        if ([operation isKindOfClass:[NSURLSessionTask class]])
        {
            //http method
            BOOL hasMatchRequestType = [requestType isEqualToString:[[(NSURLSessionTask *)operation currentRequest] HTTPMethod]];
            //请求的url
            BOOL hasMatchRequestUrlString = [urlToPeCanced isEqualToString:[[[(NSURLSessionTask *)operation currentRequest] URL] path]];
            if (hasMatchRequestType && hasMatchRequestUrlString)
            {
                [operation cancel];
            }
        }
    }
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil)
    {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

@end
