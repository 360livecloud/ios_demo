//
//  QHVCCommonCoreEntry.h
//  QHVCCommonKit
//
//  Created by deng on 2017/9/8.
//  Copyright © 2017年 qihoo 360. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Types.h"
#import "core_entryS.h"

@interface QHVCCommonCoreEntry : NSObject

/**
 * 通知SDK app启动
 * 必须在app启动的第一时间调用，且在整个app生命周期只调用一次
 * @param businessId 业务ID
 * @param appVer 端版本
 * @param deviceId 机器id
 * @param model 型号
 */
+ (void)coreOnAppStart:(NSString *)businessId
                appVer:(NSString *)appVer
              deviceId:(NSString *)deviceId
                 model:(NSString *)model
        optionalParams:(OptionalParams *)ops;
/**
 * 网络变化时通知传输层进行相应处理
 * @param type 网络变化类型
 */
+ (void)coreNetworkChange:(NetworkChangeType)type;

+ (void)initLua:(NSString *)libPath;
+ (void)initFastUdx:(NSString *)libPath;

/**
 *  @功能 获取基础库sdk版本号
 *  @返回值 sdk版本号（e.g. 2.0.0.0）
 */
+ (NSString *)sdkVersion;

@end
