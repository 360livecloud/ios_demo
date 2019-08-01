//
//  QHVCGSProtocolMonitor.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2019/5/7.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCGSProtocolMonitor.h"
#import "QHVCGVConfig.h"

void runSynchronouslyOnProtocolProcessingQueue_GS(void (^block)(void))
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

void runAsynchronouslyOnProtocolProcessingQueue_GS(void (^block)(void))
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

@implementation QHVCGSProtocolMonitor

+ (void)executeBlock:(QHVCGSProtocolMonitorDataComplete)dataComplete
            taskData:(NSURLSessionDataTask*)taskData
              result:(BOOL)result;
{
    if (dataComplete)
    {
        dataComplete(taskData, result);
    }
}

+ (void)executeBlock:(QHVCGSProtocolMonitorDataCompleteWithMessage)dataComplete
            taskData:(NSURLSessionDataTask*)taskData
              result:(BOOL)result
             message:(NSString *)message
{
    if (dataComplete)
    {
        dataComplete(taskData, result, message);
    }
}

+ (void)executeBlock:(QHVCGSProtocolMonitorDataCompleteWithDictionary)dataComplete
            taskData:(NSURLSessionDataTask*)taskData
              result:(BOOL)result
                dict:(NSDictionary *)dict;
{
    if (dataComplete)
    {
        dataComplete(taskData, result, dict);
    }
}

+ (void)executeBlock:(QHVCGSProtocolMonitorDataCompleteWithArray)dataComplete
            taskData:(NSURLSessionDataTask*)taskData
              result:(BOOL)result
               array:(NSArray *)array;
{
    if (dataComplete)
    {
        dataComplete(taskData, result, array);
    }
}

+ (void)executeBlock:(QHVCGSProtocolMonitorDataCompleteWithErrorCode)dataComplete
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

+ (void) getUserLogin:(QHVCGSHTTPSessionManager *_Nonnull)httpManager
                 dict:(NSMutableDictionary *_Nullable)dict
             complete:(QHVCGSProtocolMonitorDataCompleteWithDictionary _Nullable )complete
{
    if (httpManager == nil)
    {
        return;
    }
    if ([QHVCToolUtils dictionaryIsNull:dict])
    {
        dict = [NSMutableDictionary dictionary];
    }
//    [QHVCToolUtils setStringToDictionary:dict key:QHVCGS_KEY_DEVICE_ID value:[[QHVCGSConfig sharedInstance] deviceId]];
//    [QHVCToolUtils setStringToDictionary:dict key:QHVCGS_KEY_CLIENT_ID value:[[QHVCGSConfig sharedInstance] clientId]];
//    runAsynchronouslyOnProtocolProcessingQueue_ITS(^{
//        [httpManager requestDataWithPost:QHVCGSPROTOCOL_USER_LOGIN
//                           parameterDict:dict
//                                 success:^(NSURLSessionDataTask *dataTask, NSDictionary *dict) {
//                                     if (complete)
//                                     {
//                                         complete(dataTask, true, dict);
//                                     }
//                                 } failure:^(NSURLSessionDataTask *dataTask, NSDictionary *dict) {
//                                     if (complete)
//                                     {
//                                         complete(dataTask, false, dict);
//                                     }
//                                 }];
//    });
}

@end
