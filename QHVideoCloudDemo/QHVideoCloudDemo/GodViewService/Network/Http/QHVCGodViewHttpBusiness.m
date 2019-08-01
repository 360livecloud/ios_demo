//
//  QHVCGodViewHttpBusiness.m
//  QHVideoCloudToolSetDebug
//
//  Created by jiangbingbing on 2018/10/23.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCGodViewHttpBusiness.h"
#import "QHVCGVHTTPSessionManager.h"
#import "QHVCGVDefine.h"
#import "QHVCGVConfig.h"
#import "QHVCGVProtocol.h"
#import "QHVCGVUserSystem.h"
#import <QHVCCommonKit/QHVCCommonKit.h>

void runSynchronouslyOnProtocolProcessingQueue_GodView(void (^block)(void))
{
    dispatch_queue_t processQueue = [[QHVCGlobalConfig sharedInstance] protocolQueue];
    if (dispatch_get_specific([[QHVCGlobalConfig sharedInstance] protocolQueueKey]))
    {
        block();
    }else
    {
        dispatch_sync(processQueue, block);
    }
}

void runAsynchronouslyOnProtocolProcessingQueue_GodView(void (^block)(void))
{
    dispatch_queue_t processQueue = [[QHVCGlobalConfig sharedInstance] protocolQueue];
    if (dispatch_get_specific([[QHVCGlobalConfig sharedInstance] protocolQueueKey]))
    {
        block();
    }else
    {
        dispatch_async(processQueue, block);
    }
}

@implementation QHVCGodViewHttpBusiness

+ (void)executeBlock:(QHVCGVProtocolMonitorDataComplete)dataComplete
            taskData:(NSURLSessionDataTask*)taskData
              result:(BOOL)result;
{
    if (dataComplete)
    {
        dataComplete(taskData, result);
    }
}

+ (void)executeBlock:(QHVCGVProtocolMonitorDataCompleteWithMessage)dataComplete
            taskData:(NSURLSessionDataTask*)taskData
              result:(BOOL)result
             message:(NSString *)message
{
    if (dataComplete)
    {
        dataComplete(taskData, result, message);
    }
}

+ (void)executeBlock:(QHVCGVProtocolMonitorDataCompleteWithDictionary)dataComplete
            taskData:(NSURLSessionDataTask*)taskData
              result:(BOOL)result
                dict:(NSDictionary *)dict;
{
    if (dataComplete)
    {
        dataComplete(taskData, result, dict);
    }
}

+ (void)executeBlock:(QHVCGVProtocolMonitorDataCompleteWithArray)dataComplete
            taskData:(NSURLSessionDataTask*)taskData
              result:(BOOL)result
               array:(NSArray *)array;
{
    if (dataComplete)
    {
        dataComplete(taskData, result, array);
    }
}

+ (void)executeBlock:(QHVCGVProtocolMonitorDataCompleteWithErrorCode)dataComplete
            taskData:(NSURLSessionDataTask*)taskData
              result:(BOOL)result
             message:(NSString *)message
           errorCode:(NSInteger)errorCode
{
    if (dataComplete)
    {
        dataComplete(taskData, result, message, errorCode);
    }
}

+ (void)registerWithParams:(NSMutableDictionary *)params complete:(QHVCGVProtocolMonitorDataCompleteWithDictionary _Nullable )complete {
    [QHVCToolUtils setStringToDictionary:params key:QHVCGV_KEY_IMEI value:[QHVCToolDeviceModel getDeviceUUID]];
    runAsynchronouslyOnProtocolProcessingQueue_GodView(^{
        [[QHVCGVHTTPSessionManager sharedManager] requestDataWithPost:QHVCGVProtocol_Register
                                                        parameterDict:params
                                                              success:^(NSURLSessionDataTask *dataTask, NSDictionary *dict) {
                                                                  if (complete)
                                                                  {
                                                                      complete(dataTask, true, dict);
                                                                  }
                                                              } failure:^(NSURLSessionDataTask *dataTask, NSDictionary *dict) {
                                                                  if (complete)
                                                                  {
                                                                      complete(dataTask, false, dict);
                                                                  }
                                                              }];
    });
}

/**
 * 用户登录
 */
+ (void)loginWithParams:(NSMutableDictionary *)params complete:(QHVCGVProtocolMonitorDataCompleteWithDictionary _Nullable )complete {
    [QHVCToolUtils setStringToDictionary:params key:QHVCGV_KEY_IMEI value:[QHVCToolDeviceModel getDeviceUUID]];
    runAsynchronouslyOnProtocolProcessingQueue_GodView(^{
        [[QHVCGVHTTPSessionManager sharedManager] requestDataWithPost:QHVCGVProtocol_Login
                                                        parameterDict:params
                                                              success:^(NSURLSessionDataTask *dataTask, NSDictionary *dict) {
                                                                  if (complete)
                                                                  {
                                                                      complete(dataTask, true, dict);
                                                                  }
                                                              } failure:^(NSURLSessionDataTask *dataTask, NSDictionary *dict) {
                                                                  if (complete)
                                                                  {
                                                                      complete(dataTask, false, dict);
                                                                  }
                                                              }];
    });
}

+ (void)getBindListComplete:(QHVCGVProtocolMonitorDataCompleteWithDictionary _Nullable )complete {
    runAsynchronouslyOnProtocolProcessingQueue_GodView(^{
        [[QHVCGVHTTPSessionManager sharedManager] requestDataWithPost:QHVCGVProtocol_DeviceList
                                                        parameterDict:[NSMutableDictionary new]
                                                              success:^(NSURLSessionDataTask *dataTask, NSDictionary *dict) {
                                                                  if (complete)
                                                                  {
                                                                      complete(dataTask, true, dict);
                                                                  }
                                                              } failure:^(NSURLSessionDataTask *dataTask, NSDictionary *dict) {
                                                                  if (complete)
                                                                  {
                                                                      complete(dataTask, false, dict);
                                                                  }
                                                              }];
    });
    
}

// 绑定设备
+ (void)bindDeviceWithParams:(NSMutableDictionary *)params complete:(QHVCGVProtocolMonitorDataCompleteWithDictionary _Nullable )complete {
    runAsynchronouslyOnProtocolProcessingQueue_GodView(^{
        [[QHVCGVHTTPSessionManager sharedManager] requestDataWithPost:QHVCGVProtocol_BindDevice
                                                        parameterDict:params
                                                              success:^(NSURLSessionDataTask *dataTask, NSDictionary *dict) {
                                                                  if (complete)
                                                                  {
                                                                      complete(dataTask, true, dict);
                                                                  }
                                                              } failure:^(NSURLSessionDataTask *dataTask, NSDictionary *dict) {
                                                                  if (complete)
                                                                  {
                                                                      complete(dataTask, false, dict);
                                                                  }
                                                              }];
    });
}

// 解绑设备
+ (void)unbindDeviceWithParams:(NSMutableDictionary *)params complete:(QHVCGVProtocolMonitorDataCompleteWithDictionary _Nullable )complete {
    runAsynchronouslyOnProtocolProcessingQueue_GodView(^{
        [[QHVCGVHTTPSessionManager sharedManager] requestDataWithPost:QHVCGVProtocol_unbindDevice
                                                        parameterDict:params
                                                              success:^(NSURLSessionDataTask *dataTask, NSDictionary *dict) {
                                                                  if (complete)
                                                                  {
                                                                      complete(dataTask, true, dict);
                                                                  }
                                                              } failure:^(NSURLSessionDataTask *dataTask, NSDictionary *dict) {
                                                                  if (complete)
                                                                  {
                                                                      complete(dataTask, false, dict);
                                                                  }
                                                              }];
    });
}

/**
 * 获取流密码
 */
+ (void)getStreamPwdWithParams:(NSMutableDictionary *)params complete:(QHVCGVProtocolMonitorDataCompleteWithDictionary _Nullable )complete {
    runAsynchronouslyOnProtocolProcessingQueue_GodView(^{
        [[QHVCGVHTTPSessionManager sharedManager] requestDataWithPost:QHVCGVProtocol_GetStreamPwd
                                                        parameterDict:params
                                                              success:^(NSURLSessionDataTask *dataTask, NSDictionary *dict) {
                                                                  if (complete)
                                                                  {
                                                                      complete(dataTask, true, dict);
                                                                  }
                                                              } failure:^(NSURLSessionDataTask *dataTask, NSDictionary *dict) {
                                                                  if (complete)
                                                                  {
                                                                      complete(dataTask, false, dict);
                                                                  }
                                                              }];
    });
}

/**
 * 修改设备信息
 */
+ (void)modifyInfoWithParams:(NSMutableDictionary *)params complete:(QHVCGVProtocolMonitorDataCompleteWithDictionary _Nullable )complete {
    runAsynchronouslyOnProtocolProcessingQueue_GodView(^{
        [[QHVCGVHTTPSessionManager sharedManager] requestDataWithPost:QHVCGVProtocol_ModifyDeviceInfo
                                                        parameterDict:params
                                                              success:^(NSURLSessionDataTask *dataTask, NSDictionary *dict) {
                                                                  if (complete)
                                                                  {
                                                                      complete(dataTask, true, dict);
                                                                  }
                                                              } failure:^(NSURLSessionDataTask *dataTask, NSDictionary *dict) {
                                                                  if (complete)
                                                                  {
                                                                      complete(dataTask, false, dict);
                                                                  }
                                                              }];
    });
}

/**
 * 获取用户已绑定的设备云存信息
 */
+ (void)getCloudRecordList:(NSMutableDictionary *)params complete:(QHVCGVProtocolMonitorDataCompleteWithDictionary _Nullable )complete {
    runAsynchronouslyOnProtocolProcessingQueue_GodView(^{
        [[QHVCGVHTTPSessionManager sharedManager] requestDataWithPost:QHVCGVProtocol_GetCloudRecordList
                                                        parameterDict:params
                                                              success:^(NSURLSessionDataTask *dataTask, NSDictionary *dict) {
                                                                  if (complete)
                                                                  {
                                                                      complete(dataTask, true, dict);
                                                                  }
                                                              } failure:^(NSURLSessionDataTask *dataTask, NSDictionary *dict) {
                                                                  if (complete)
                                                                  {
                                                                      complete(dataTask, false, dict);
                                                                  }
                                                              }];
    });
}

/**
 * 删除云录
 */
+ (void)deleteCloudRecord:(NSMutableDictionary *)params complete:(QHVCGVProtocolMonitorDataCompleteWithDictionary _Nullable )complete {
    runAsynchronouslyOnProtocolProcessingQueue_GodView(^{
        [[QHVCGVHTTPSessionManager sharedManager] requestDataWithPost:QHVCGVProtocol_DeleteCloudRecord
                                                        parameterDict:params
                                                              success:^(NSURLSessionDataTask *dataTask, NSDictionary *dict) {
                                                                  if (complete)
                                                                  {
                                                                      complete(dataTask, true, dict);
                                                                  }
                                                              } failure:^(NSURLSessionDataTask *dataTask, NSDictionary *dict) {
                                                                  if (complete)
                                                                  {
                                                                      complete(dataTask, false, dict);
                                                                  }
                                                              }];
    });
}

@end
