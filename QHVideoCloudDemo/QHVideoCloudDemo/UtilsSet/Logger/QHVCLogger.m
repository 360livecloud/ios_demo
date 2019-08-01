//
//  QHVCLogger.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/3/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCLogger.h"
#import <QHVCCommonKit/QHVCCommonKit.h>
#import "QHVCGlobalConfig.h"

static int demoLogerId = -1;
static QHVCLogLevel demoLogLevel = QHVC_LOG_LEVEL_NONE;

@implementation QHVCLogger

+ (void)createKeyLoggerByNative
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        demoLogerId = [QHVCCommonLogEntry createLogger:QHVC_DEMO_LOG_ID];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachesDir = [paths objectAtIndex:0];
        NSString *logFilePath = [NSString stringWithFormat:@"%@%@",cachesDir,QHVC_DEMO_LOG_PATH];
        BOOL isSucess = [QHVCToolUtils createDirectoryAtPath:logFilePath];
        if (!isSucess)
        {
            return;
        }
        [QHVCCommonLogEntry startLog];
        [QHVCCommonLogEntry setLogPath:demoLogerId path:logFilePath];
        [QHVCCommonLogEntry setLogParams:demoLogerId singleSize:1 persistenceNum:9];
        [QHVCCommonLogEntry setLogLevel:demoLogerId logLevel:LOG_LEVEL_NONE_WE];
        [QHVCCommonLogEntry setLogLevel:[QHVCCommonLogEntry transportLoggerId] logLevel:LOG_LEVEL_NONE_WE];
        [QHVCCommonLogEntry setLogLevelForFile:demoLogerId logLevel:LOG_LEVEL_INFO_WE];
    });
}

+ (void)setLoggerLevel:(QHVCLogLevel)level
{
    [QHVCLogger getLoggerId];
    if (demoLogerId == -1)
    {
        return;
    }
    demoLogLevel = level;
    [QHVCCommonLogEntry setLogLevel:demoLogerId logLevel:(enum ELogLevel)level];
    [QHVCCommonLogEntry setLogLevel:[QHVCCommonLogEntry transportLoggerId] logLevel:(enum ELogLevel)level];
}

+ (void)printLogger:(QHVCLogLevel)logLevel content:(nullable NSString *)content;
{
    if (demoLogerId == -1 || content.length <= 0)
    {
        return;
    }
    [QHVCCommonLogEntry printLog:demoLogerId logLevel:(enum ELogLevel)logLevel data:content];
}

+ (void)printLogger:(QHVCLogLevel)logLevel content:(nullable NSString *)content dict:(nullable NSDictionary *)dict;
{
    if (demoLogerId == -1)
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
    [QHVCLogger printLogger:logLevel content:temp];
}

+ (int)getLoggerId
{
    if (demoLogerId < 0)
    {
        [QHVCLogger createKeyLoggerByNative];
    }
    return demoLogerId;
}

+ (QHVCLogLevel)getLoggerLevel
{
    return demoLogLevel;
}

@end
