//
//  QHVCSessionManager.m
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/8/17.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCSessionManager.h"

static NSString * const APIBaseURLString;

@implementation QHVCSessionManager

+ (instancetype)sharedInstance
{
    static QHVCSessionManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[QHVCSessionManager alloc] initWithBaseURL:[NSURL URLWithString:APIBaseURLString]];
    });
    
    return _sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    if (self = [super initWithBaseURL:url])
    {
        //超时
        self.requestSerializer.timeoutInterval = 20;
        //缓存策略
        self.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        //响应数据类型
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        //contentType
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/x-json",@"text/html",@"application/json",nil];
    }
    return self;
}

@end
