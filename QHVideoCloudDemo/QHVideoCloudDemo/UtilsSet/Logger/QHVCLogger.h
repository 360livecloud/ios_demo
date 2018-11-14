//
//  QHVCLogger.h
//  QHVideoCloudToolSet
//
//  Created by yangkui on 16/2/19.
//  Copyright © 2016年 wukongtv. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    QHVC_LOGGER_LEVEL_DEBUG              = 1 << 1,
    QHVC_LOGGER_LEVEL_INFO               = 1 << 2,
    QHVC_LOGGER_LEVEL_WARN               = 1 << 3,
    QHVC_LOGGER_LEVEL_ERROR              = 1 << 4,
    QHVC_LOGGER_LEVEL_PROTOCOL           = 1 << 5
}QHVC_LOGGER_LEVEL_DEFS;

@interface QHVCLogger : NSObject

#ifdef DEBUG

#define LogDebug(...)    [QHVCLogger logFuncDebug:__FUNCTION__ line:__LINE__ module:@"QHVCDEMO" msg:__VA_ARGS__]
#define LogInfo(...)     [QHVCLogger logFuncInfo:__FUNCTION__ line:__LINE__ module:@"QHVCDEMO" msg:__VA_ARGS__]
#define LogWarn(...)     [QHVCLogger logFuncWarn:__FUNCTION__ line:__LINE__ module:@"QHVCDEMO" msg:__VA_ARGS__]
#define LogError(...)    [QHVCLogger logFuncError:__FUNCTION__ line:__LINE__ module:@"QHVCDEMO" msg:__VA_ARGS__]
#define LogProtocol(...) [QHVCLogger logFuncProtocol:__FUNCTION__ line:__LINE__ module:@"QHVCDEMO" msg:__VA_ARGS__]

#else

#define LogDebug(...)
#define LogInfo(...)
#define LogWarn(...)
#define LogError(...)    [QHVCLogger logFuncError:__FUNCTION__ line:__LINE__ module:@"QHVCDEMO" msg:__VA_ARGS__]
#define LogProtocol(...)

#endif

/*
 * 设置日志级别
 */
+ (void) setLoggerLevel:(QHVC_LOGGER_LEVEL_DEFS)loggerLevel;

/*
 * 获取日志级别
 */
+ (QHVC_LOGGER_LEVEL_DEFS) getLoggerLevel;

+ (void)logFuncDebug:(const char *)func line:(int)line module:(NSString *)module msg:(NSString *)fmt, ...NS_FORMAT_FUNCTION(4, 5);
+ (void)logFuncInfo:(const char *)func line:(int)line module:(NSString *)module msg:(NSString *)fmt, ...NS_FORMAT_FUNCTION(4, 5);
+ (void)logFuncWarn:(const char *)func line:(int)line module:(NSString *)module msg:(NSString *)fmt, ...NS_FORMAT_FUNCTION(4, 5);
+ (void)logFuncError:(const char *)func line:(int)line module:(NSString *)module msg:(NSString *)fmt, ...NS_FORMAT_FUNCTION(4, 5);
+ (void)logFuncProtocol:(const char *)func line:(int)line module:(NSString *)module msg:(NSString *)fmt, ...NS_FORMAT_FUNCTION(4, 5);
@end
