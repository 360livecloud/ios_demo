//
//  QHVCEditConfig.h
//  QHVCEditKit
//
//  Created by liyue-g on 2019/4/28.
//  Copyright © 2019 liyue-g. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QHVCEditDefinitions.h"

@interface QHVCEditConfig : NSObject

#pragma mark - app信息

/**
 设置app信息，需和申请到的信息保持一致（必填）
 申请方式：登录官网https://live.360.cn/，进入「用户中心」进行申请

 @param appInfo 应用信息，字典内所有值均为NSString类型
 appInfo = @{
             @"channelId":cid,       //渠道唯一标识
             @"accessKey":ak,        //业务唯一标识
             @"userSign":usign,      //用户签名, 签名方式详见demo
             @"random":random,       //随机数，可用时间戳替代
             @"timestamp":timestamp, //时间戳
 };
 */
+ (void)setAppInfo:(NSDictionary *)appInfo;


/**
 设置用户唯一标识，方便问题追溯（建议）

 @param userId 用户唯一标识
 */
+ (void)setUserId:(NSString *)userId;


/**
 设置离线授权信息，离线鉴权存在时优先离线鉴权，否则使用云端鉴权

 @param info 鉴权信息
 */
+ (void)setLocalAuthorizationInfo:(NSString*)info;


/**
 高级版本请求鉴权，鉴权成功才可使用高级版本功能，若不主动调用此接口，会在使用高级功能时自动鉴权（建议）

 @param complete 鉴权结果
 */
+ (void)requestAdvancedAuthorization:(void(^)(QHVCEditAuthError err, NSString* errMessage))complete;


#pragma mark - 版本号

/**
 获取版本号
 */
+ (NSString *)getVersion;

#pragma mark - Logger

/**
 设置SDK日志控制台输出级别
 
 @param level SDK日志控制台输出级别
 */
+ (void)setSDKLogLevel:(QHVCEditLogLevel)level;

@end

