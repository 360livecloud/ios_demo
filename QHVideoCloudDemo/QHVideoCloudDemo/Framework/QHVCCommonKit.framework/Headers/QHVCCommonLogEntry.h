//
//  QHVCCommonLogEntry.h
//  QHVCCommonKit
//
//  Created by deng on 2017/11/1.
//  Copyright © 2017年 qihoo.QHVCCommonKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Types.h"

@interface QHVCCommonLogEntry : NSObject

/**
 * 启动日志模块
 */
+ (void)startLog;

/**
 * 创建一个Logger，
 * 为兼容旧版本，player和camera的logger已经内部创建好，不需要调用
 * @param logger Logger的名字
 * @return LOG4Z_INVALID_LOGGER_ID表示创建失败 否则为LoggerID
 */
+ (int)createLogger:(NSString *)logger;

/**
 * 获取传输层LoggerID
 * @return 传输层LoggerID
 */
+ (int)transportLoggerId;

/**
 * 获取播放器LoggerID
 * @return 播放器LoggerID
 */
+ (int)playerLoggerId;

/**
 * 获取camera LoggerID
 * @return camera LoggerID
 */
+ (int)cameraLoggerId;

/**
 * 设置日志模块所有Logger的输出函数(默认使用内置方式输出)
 * @param loggerID LoggerID -1表示对所有Logger生效
 * @param cb 输出函数
 */
+ (void)setLogCallback:(int)loggerID
              callback:(print_cb)cb;

/**
 * 设置指定Logger的日志过滤级别(默认为DEBUG)
 * @param loggerId LoggerID
 * @param logLevel 日志过滤级别
 */
+ (void)setLogLevel:(int)loggerId
           logLevel:(enum ELogLevel)logLevel;

/**
 * 设置指定Logger的向文件里写入日志过滤级别(默认为INFO)
 * @param loggerId LoggerID
 * @param logLevel 日志过滤级别
 */
+ (void)setLogLevelForFile:(int)loggerId
                  logLevel:(enum ELogLevel)logLevel;

/**
 * 设置指定Logger的日志文件存储位置(默认不写文件)
 * @param loggerId LoggerID
 * @param path 路径
 */
+ (void)setLogPath:(int)loggerId
              path:(NSString *)path;

/**
 * 设置指定Logger的日志文件相关参数
 * @param loggerId LoggerID
 * @param singleSize 单个日志文件最大大小（单位MB），默认10MB
 * @param persistenceNum 日志文件保存数量（单位个数），默认3个
 */
+ (void)setLogParams:(int)loggerId
          singleSize:(unsigned int)singleSize
      persistenceNum:(unsigned int)persistenceNum;

/**
 * 打印日志
 * @param loggerId LoggerID
 * @param logLevel 日志级别
 * @param data 日志内容格式化字符串
 */
+ (void)printLog:(int)loggerId
        logLevel:(enum ELogLevel)logLevel
            data:(NSString *)data;
@end
