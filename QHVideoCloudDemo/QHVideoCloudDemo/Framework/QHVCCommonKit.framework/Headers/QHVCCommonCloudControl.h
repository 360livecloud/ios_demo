//
//  QHVCCommonCloudControl.h
//  QHVCCommonKit
//
//  Created by deng on 2017/11/1.
//  Copyright © 2017年 qihoo.QHVCCommonKit. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, QHVCCommonProduct)
{
    QHVC_COMMON_PRODUCT_VIDEOCLOUD           = 0,
    QHVC_COMMON_PRODUCT_IOT_VIDEOCLOUD       = 1,
};

@interface QHVCCommonCloudControl : NSObject

/**
 获取公共平台参数

 @return 公共参数
 */
+ (NSDictionary *)fetchCommonPlatformInfo;

/**
 * 获取服务器云控相关信息
 */
+ (void)fetchRemoteCCInfo;

/**
 * 获取播放器云控相关信息
 * @返回值 返回值为nil 使用默认值
 */
+ (NSDictionary *)fetchPlayerCCInfo;

/**
 * 获取推流云控相关信息
 * @返回值 返回值为nil 使用默认值
 */
+ (NSDictionary *)fetchPublisherCCInfo;

/**
 * 获取上传云控相关信息
 * @返回值 返回值为nil 使用默认值
 */
+ (NSDictionary *)fetchUploadCCInfo;

/**
 获取公共模块云控相关信息

 @return 返回值为nil 使用默认值
 */
+ (NSDictionary *)fetchCommonCCInfo;

/**
 * 获取互动直播云控相关信息
 * @返回值 返回值为nil 使用默认值
 */
+ (NSDictionary *)fetchInteractCCInfo;

/**
 * 获取network云控相关信息
 * @返回值 返回值为nil 使用默认值
 */
+ (NSDictionary *)fetchNetworkCCInfo;

@end
