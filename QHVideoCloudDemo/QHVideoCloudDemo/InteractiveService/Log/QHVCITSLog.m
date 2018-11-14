//
//  QHVCITSLog.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/3/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCITSLog.h"
#import "QHVCITSConfig.h"
#import <QHVCCommonKit/QHVCCommonKit.h>

static int interactiveLiveLogerId = -1;


@implementation QHVCITSLog

+ (void)createKeyLoggerByNative
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        interactiveLiveLogerId = [QHVCCommonLogEntry createLogger:QHVCITS_INTERACTIVE_LOG_ID];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachesDir = [paths objectAtIndex:0];
        NSString *logFilePath = [NSString stringWithFormat:@"%@%@",cachesDir,QHVCITS_INTERACTIVE_LOG_PATH];
        BOOL isSucess = [QHVCToolUtils createDirectoryAtPath:logFilePath];
        if (!isSucess)
        {
            return;
        }
        [QHVCCommonLogEntry startLog];
        [QHVCCommonLogEntry setLogPath:interactiveLiveLogerId path:logFilePath];
        [QHVCCommonLogEntry setLogParams:interactiveLiveLogerId singleSize:1 persistenceNum:9];
        [QHVCCommonLogEntry setLogLevel:interactiveLiveLogerId logLevel:LOG_LEVEL_NONE_WE];
        [QHVCCommonLogEntry setLogLevel:[QHVCCommonLogEntry transportLoggerId] logLevel:LOG_LEVEL_NONE_WE];
        [QHVCCommonLogEntry setLogLevelForFile:interactiveLiveLogerId logLevel:LOG_LEVEL_INFO_WE];
    });
}

+ (void)setLoggerLevel:(QHVCITSLogLevel)level
{
    [QHVCITSLog getLoggerId];
    if (interactiveLiveLogerId == -1)
    {
        return;
    }
    [QHVCCommonLogEntry setLogLevel:interactiveLiveLogerId logLevel:(enum ELogLevel)level];
    [QHVCCommonLogEntry setLogLevel:[QHVCCommonLogEntry transportLoggerId] logLevel:(enum ELogLevel)level];
}

+ (void)printLogger:(QHVCITSLogLevel)logLevel content:(nullable NSString *)content;
{
    if (interactiveLiveLogerId == -1 || content.length <= 0)
    {
        return;
    }
    [QHVCCommonLogEntry printLog:interactiveLiveLogerId logLevel:(enum ELogLevel)logLevel data:content];
}

+ (void)printLogger:(QHVCITSLogLevel)logLevel content:(nullable NSString *)content dict:(nullable NSDictionary *)dict;
{
    if (interactiveLiveLogerId == -1)
    {
        return;
    }
    NSMutableString* temp = [[NSMutableString alloc] init];
    if (![QHVCToolUtils isNullString:content])
    {
        [temp appendString:content];
    }
    if (![QHVCToolUtils dictionaryIsNull:dict])
    {
        NSString* dictString = [QHVCToolUtils dictionaryConversionToString:dict];
        if (![QHVCToolUtils isNullString:dictString])
        {
            [temp appendString:@" "];
            [temp appendString:dictString];
        }
    }
    [QHVCITSLog printLogger:logLevel content:temp];
}

+ (int)getLoggerId
{
    if (interactiveLiveLogerId < 0)
    {
        [QHVCITSLog createKeyLoggerByNative];
    }
    return interactiveLiveLogerId;
}

@end

