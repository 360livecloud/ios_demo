//
//  QHVCITSLog.h
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/3/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QHVCITSConfig.h"

@interface QHVCITSLog : NSObject

+ (void)createKeyLoggerByNative;
+ (void)setLoggerLevel:(QHVCITSLogLevel)level;
+ (void)printLogger:(QHVCITSLogLevel)logLevel content:(nullable NSString *)content;
+ (void)printLogger:(QHVCITSLogLevel)logLevel content:(nullable NSString *)content dict:(nullable NSDictionary *)dict;
+ (int)getLoggerId;

@end
