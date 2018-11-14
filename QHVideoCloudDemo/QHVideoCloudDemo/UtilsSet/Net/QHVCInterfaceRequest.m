//
//  QHVCInterfaceRequest.m
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/8/17.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCInterfaceRequest.h"

@implementation QHVCInterfaceRequest

+ (void)snListRequestWithsuccess:(successBlock)success fail:(failBlock)fail
{
    NSString *urlString = [NSString stringWithFormat:@""];
    [QHVCHTTPSession requestWithRequestType:LTHTTPRequestTypeGet urlString:urlString paraments:nil successBlock:^(NSDictionary * _Nullable object, NSError * _Nullable error) {
        success(object, error);
    } failBlock:^(NSError * _Nullable error) {
        fail(error);
    }];
}

+ (void)shortVideoListRequestWithParameter:(NSDictionary *)para success:(successBlock)success fail:(failBlock)fail
{
    NSString *urlString = [NSString stringWithFormat:@""];
    [QHVCHTTPSession requestWithRequestType:LTHTTPRequestTypeGet urlString:urlString paraments:para successBlock:^(NSDictionary * _Nullable object, NSError * _Nullable error) {
        success(object, error);
    } failBlock:^(NSError * _Nullable error) {
        fail(error);
    }];
}

@end
