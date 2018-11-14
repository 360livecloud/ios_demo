//
//  QHVCITSProtocolMonitor.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/3/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCITSProtocolMonitor.h"
#import "QHVCITSDefine.h"
#import "QHVCITSConfig.h"
#import "QHVCITSProtocol.h"

void runSynchronouslyOnProtocolProcessingQueue_ITS(void (^block)(void))
{
    dispatch_queue_t processQueue = [[QHVCITSConfig sharedInstance] protocolQueue];
    if (dispatch_get_specific([[QHVCITSConfig sharedInstance] protocolQueueKey]))
    {
        block();
    }else
    {
        dispatch_sync(processQueue, block);
    }
}

void runAsynchronouslyOnProtocolProcessingQueue_ITS(void (^block)(void))
{
    dispatch_queue_t processQueue = [[QHVCITSConfig sharedInstance] protocolQueue];
    if (dispatch_get_specific([[QHVCITSConfig sharedInstance] protocolQueueKey]))
    {
        block();
    }else
    {
        dispatch_async(processQueue, block);
    }
}

@implementation QHVCITSProtocolMonitor

+ (void)executeBlock:(QHVCITSProtocolMonitorDataComplete)dataComplete
            taskData:(NSURLSessionDataTask*)taskData
              result:(BOOL)result;
{
    if (dataComplete)
    {
        dataComplete(taskData, result);
    }
}

+ (void)executeBlock:(QHVCITSProtocolMonitorDataCompleteWithMessage)dataComplete
            taskData:(NSURLSessionDataTask*)taskData
              result:(BOOL)result
             message:(NSString *)message
{
    if (dataComplete)
    {
        dataComplete(taskData, result, message);
    }
}

+ (void)executeBlock:(QHVCITSProtocolMonitorDataCompleteWithDictionary)dataComplete
            taskData:(NSURLSessionDataTask*)taskData
              result:(BOOL)result
                dict:(NSDictionary *)dict;
{
    if (dataComplete)
    {
        dataComplete(taskData, result, dict);
    }
}

+ (void)executeBlock:(QHVCITSProtocolMonitorDataCompleteWithArray)dataComplete
            taskData:(NSURLSessionDataTask*)taskData
              result:(BOOL)result
               array:(NSArray *)array;
{
    if (dataComplete)
    {
        dataComplete(taskData, result, array);
    }
}

+ (void)executeBlock:(QHVCITSProtocolMonitorDataCompleteWithErrorCode)dataComplete
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

//若协议请求的时候，需要特别添加的参数，可以在本类封装的方法中根据实际情况封装

+ (void) getUserLogin:(QHVCITSHTTPSessionManager *_Nonnull)httpManager
                 dict:(NSMutableDictionary *_Nullable)dict
             complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary _Nullable )complete
{
    if (httpManager == nil)
    {
        return;
    }
    if ([QHVCToolUtils dictionaryIsNull:dict])
    {
        dict = [NSMutableDictionary dictionary];
    }
    [QHVCToolUtils setStringToDictionary:dict key:QHVCITS_KEY_DEVICE_ID value:[[QHVCITSConfig sharedInstance] deviceId]];
    
    runAsynchronouslyOnProtocolProcessingQueue_ITS(^{
        [httpManager requestDataWithPost:QHVCITSPROTOCOL_USER_LOGIN
                          parameterDict:dict
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

+ (void) getRoomList:(QHVCITSHTTPSessionManager *_Nonnull)httpManager
                dict:(NSMutableDictionary *_Nullable)dict
            complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary _Nullable )complete
{
    if (httpManager == nil)
    {
        return;
    }
    if ([QHVCToolUtils dictionaryIsNull:dict])
    {
        dict = [NSMutableDictionary dictionary];
    }
    
    runAsynchronouslyOnProtocolProcessingQueue_ITS(^{
        [httpManager requestDataWithPost:QHVCITSPROTOCOL_GET_ROOM_LIST
                          parameterDict:dict
                                success:^(NSURLSessionDataTask *dataTask, NSDictionary *dict) {
                                    if (complete)
                                    {
                                        complete(dataTask, true, dict);
                                    }
                                }
                                failure:^(NSURLSessionDataTask *dataTask, NSDictionary *dict) {
                                    if (complete)
                                    {
                                        complete(dataTask, false, dict);
                                    }
                                }];
    });
}

+ (void) getRoomInfo:(QHVCITSHTTPSessionManager *_Nonnull)httpManager
                dict:(NSMutableDictionary *_Nullable)dict
            complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary _Nullable )complete
{
    if (httpManager == nil)
    {
        return;
    }
    if ([QHVCToolUtils dictionaryIsNull:dict])
    {
        dict = [NSMutableDictionary dictionary];
    }
    runAsynchronouslyOnProtocolProcessingQueue_ITS(^{
        [httpManager requestDataWithPost:QHVCITSPROTOCOL_GET_ROOM_INFO
                          parameterDict:dict
                                success:^(NSURLSessionDataTask *dataTask, NSDictionary *dict) {
                                    if(complete)
                                    {
                                        complete(dataTask, true, dict);
                                    }
                                } failure:^(NSURLSessionDataTask *dataTask, NSDictionary *dict) {
                                    if(complete)
                                    {
                                        complete(dataTask, false, dict);
                                    }
                                }];
    });
}

+ (void) createRoom:(QHVCITSHTTPSessionManager *_Nonnull)httpManager
               dict:(NSMutableDictionary *_Nullable)dict
           complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary _Nullable )complete;
{
    if (httpManager == nil)
    {
        return;
    }
    if ([QHVCToolUtils dictionaryIsNull:dict])
    {
        dict = [NSMutableDictionary dictionary];
    }
    runAsynchronouslyOnProtocolProcessingQueue_ITS(^{
        
        [httpManager requestDataWithPost:QHVCITSPROTOCOL_CREATE_ROOM
                          parameterDict:dict
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

+ (void) joinRoom:(QHVCITSHTTPSessionManager *_Nonnull)httpManager
             dict:(NSMutableDictionary *_Nullable)dict
         complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary _Nullable)complete;
{
    if (httpManager == nil)
    {
        return;
    }
    if ([QHVCToolUtils dictionaryIsNull:dict])
    {
        dict = [NSMutableDictionary dictionary];
    }
    runAsynchronouslyOnProtocolProcessingQueue_ITS(^{
        [httpManager requestDataWithPost:QHVCITSPROTOCOL_JOIN_ROOM
                          parameterDict:dict
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

+ (void) getRoomUserList:(QHVCITSHTTPSessionManager *_Nonnull)httpManager
                    dict:(NSMutableDictionary *_Nullable)dict
                complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary _Nullable)complete
{
    if (httpManager == nil)
    {
        return;
    }
    if ([QHVCToolUtils dictionaryIsNull:dict])
    {
        dict = [NSMutableDictionary dictionary];
    }
    runAsynchronouslyOnProtocolProcessingQueue_ITS(^{
        [httpManager requestDataWithPost:QHVCITSPROTOCOL_GET_ROOM_USER_LIST
                          parameterDict:dict
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

+ (void) changeUserIdentity:(QHVCITSHTTPSessionManager *_Nonnull)httpManager
                      dict:(NSMutableDictionary *_Nullable)dict
                  complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary _Nullable)complete
{
    if (httpManager == nil)
    {
        return;
    }
    if ([QHVCToolUtils dictionaryIsNull:dict])
    {
        dict = [NSMutableDictionary dictionary];
    }
    runAsynchronouslyOnProtocolProcessingQueue_ITS(^{
        [httpManager requestDataWithPost:QHVCITSPROTOCOL_CHANGE_USER_IDENTITY
                          parameterDict:dict
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

+ (void) userLeaveRoom:(QHVCITSHTTPSessionManager *_Nonnull)httpManager
                  dict:(NSMutableDictionary *_Nullable)dict
              complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary _Nullable )complete
{
    if (httpManager == nil)
    {
        return;
    }
    if ([QHVCToolUtils dictionaryIsNull:dict])
    {
        dict = [NSMutableDictionary dictionary];
    }
    runAsynchronouslyOnProtocolProcessingQueue_ITS(^{
        [httpManager requestDataWithPost:QHVCITSPROTOCOL_USER_LEAVE_ROOM
                          parameterDict:dict
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

+ (void) dismissRoom:(QHVCITSHTTPSessionManager *_Nonnull)httpManager
                dict:(NSMutableDictionary *_Nullable)dict
            complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary _Nullable )complete;
{
    if (httpManager == nil)
    {
        return;
    }
    if ([QHVCToolUtils dictionaryIsNull:dict])
    {
        dict = [NSMutableDictionary dictionary];
    }
    runAsynchronouslyOnProtocolProcessingQueue_ITS(^{
        
        [httpManager requestDataWithPost:QHVCITSPROTOCOL_DISMISS_ROOM
                          parameterDict:dict
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

+ (void) updateUserHeartbeat:(QHVCITSHTTPSessionManager *)httpManager
                        dict:(NSMutableDictionary *)dict
                    complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary _Nullable )complete
{
    if (httpManager == nil)
    {
        return;
    }
    if ([QHVCToolUtils dictionaryIsNull:dict])
    {
        dict = [NSMutableDictionary dictionary];
    }
    runAsynchronouslyOnProtocolProcessingQueue_ITS(^{

        [httpManager requestDataWithPost:QHVCITSPROTOCOL_USER_HEART
                          parameterDict:dict
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
