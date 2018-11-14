//
//  QHVCLogger.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 16/2/19.
//  Copyright © 2016年 wukongtv. All rights reserved.
//

#import "QHVCLogger.h"

static QHVC_LOGGER_LEVEL_DEFS gloggerLevel = QHVC_LOGGER_LEVEL_ERROR;

@implementation QHVCLogger

+ (void) setLoggerLevel:(QHVC_LOGGER_LEVEL_DEFS)loggerLevel;
{
    gloggerLevel = loggerLevel;
}

/*
 * 获取日志级别
 */
+ (QHVC_LOGGER_LEVEL_DEFS) getLoggerLevel;
{
    return gloggerLevel;
}

+ (void)logFuncDebug:(const char *)func line:(int)line module:(NSString *)module msg:(NSString *)fmt, ...
{
    if ((gloggerLevel & QHVC_LOGGER_LEVEL_DEBUG) == QHVC_LOGGER_LEVEL_DEBUG)
    {
        va_list args;
        va_start(args, fmt);
        [QHVCLogger logInternalFunc:func line:line module:module format:fmt valist:args level:@"DEBUG"];
        va_end(args);
    }
}

+ (void)logFuncInfo:(const char *)func line:(int)line module:(NSString *)module msg:(NSString *)fmt, ...
{
    if ((gloggerLevel & QHVC_LOGGER_LEVEL_INFO) == QHVC_LOGGER_LEVEL_INFO)
    {
        va_list args;
        va_start(args, fmt);
        [self logInternalFunc:func line:line module:module format:fmt valist:args level:@"INFO"];
        va_end(args);
    }
}

+ (void)logFuncWarn:(const char *)func line:(int)line module:(NSString *)module msg:(NSString *)fmt, ...
{
    if ((gloggerLevel & QHVC_LOGGER_LEVEL_WARN) == QHVC_LOGGER_LEVEL_WARN)
    {
        va_list args;
        va_start(args, fmt);
        [self logInternalFunc:func line:line module:module format:fmt valist:args level:@"WARN"];
        va_end(args);
    }
}

+ (void)logFuncProtocol:(const char *)func line:(int)line module:(NSString *)module msg:(NSString *)fmt, ...
{
    if ((gloggerLevel & QHVC_LOGGER_LEVEL_PROTOCOL) == QHVC_LOGGER_LEVEL_PROTOCOL)
    {
        va_list args;
        va_start(args, fmt);
        [self logInternalFunc:func line:line module:module format:fmt valist:args level:@"PROTOCOL"];
        va_end(args);
    }
}

+ (void)logFuncError:(const char *)func line:(int)line module:(NSString *)module msg:(NSString *)fmt, ...
{
    if ((gloggerLevel & QHVC_LOGGER_LEVEL_ERROR) == QHVC_LOGGER_LEVEL_ERROR)
    {
        va_list args;
        va_start(args, fmt);
        [self logInternalFunc:func line:line module:module format:fmt valist:args level:@"ERROR"];
        va_end(args);
    }
}

+ (void)logInternalFunc:(const char*)func line:(int)line module:(NSString *)module format:(NSString *)fmt valist:(va_list)args level:(NSString *)levelStr
{
    @try {
        NSString* fname = func ? [NSString stringWithUTF8String:func] : nil;
        NSString* msg = [[NSString alloc] initWithFormat:@"%@:%@([%@, %@, line:%d])", levelStr, fmt, module, fname, line];
        NSLogv(msg, args);
    }
    @catch (NSException *exception) {
        //Ignored
    }
}

@end
