//
//  QHVCHTTPSession.h
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/8/17.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LTHTTPRequestType)
{
    LTHTTPRequestTypeGet = 1,
    LTHTTPRequestTypePost,
    LTHTTPRequestTypePut,
    LTHTTPRequestTypeHead,
    LTHTTPRequestTypeDelete
};

typedef void(^successBlock)( NSDictionary *_Nullable object,NSError * _Nullable error);
typedef void(^failBlock)(NSError * _Nullable error);

@interface QHVCHTTPSession : NSObject

+ (nullable NSURLSessionDataTask *)requestWithRequestType:(LTHTTPRequestType)type
                                                urlString:(nonnull NSString *)urlString
                                                paraments:(nullable id)paraments
                                             successBlock:(nullable successBlock)success
                                                failBlock:(nullable failBlock)fail;

+ (void)cancelAllRequest;

+ (void)cancelHttpRequestWithRequestType:(nullable NSString *)requestType requestUrlString:(nullable NSString *)string;

@end
