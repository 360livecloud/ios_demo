//
//  QHVCCommonCloudControl.h
//  QHVCCommonKit
//
//  Created by deng on 2017/11/1.
//  Copyright © 2017年 qihoo.QHVCCommonKit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QHVCCommonCloudControl : NSObject

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

+ (NSDictionary *)fetchCommonCCInfo;

/**
 * 获取互动直播云控相关信息
 * @返回值 返回值为nil 使用默认值
 */
+ (NSDictionary *)fetchInteractCCInfo;

@end
