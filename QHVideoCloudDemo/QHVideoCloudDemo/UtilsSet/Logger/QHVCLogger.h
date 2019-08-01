//
//  QHVCLogger.h
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/3/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, QHVCLogLevel){//日志等级
    QHVC_LOG_LEVEL_TRACE = 0,
    QHVC_LOG_LEVEL_DEBUG = 1,
    QHVC_LOG_LEVEL_INFO  = 2,
    QHVC_LOG_LEVEL_WARN  = 3,
    QHVC_LOG_LEVEL_ERROR = 4,
    QHVC_LOG_LEVEL_ALARM = 5,
    QHVC_LOG_LEVEL_FATAL = 6,
    QHVC_LOG_LEVEL_NONE  = 7,
};

@interface QHVCLogger : NSObject

+ (void)createKeyLoggerByNative;
+ (void)setLoggerLevel:(QHVCLogLevel)level;
+ (void)printLogger:(QHVCLogLevel)logLevel content:(nullable NSString *)content;
+ (void)printLogger:(QHVCLogLevel)logLevel content:(nullable NSString *)content dict:(nullable NSDictionary *)dict;
+ (int)getLoggerId;
+ (QHVCLogLevel)getLoggerLevel;

@end

