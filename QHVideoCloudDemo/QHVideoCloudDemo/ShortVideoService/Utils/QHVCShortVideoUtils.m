//
//  QHVCShortVideoUtils.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2019/6/19.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCShortVideoUtils.h"
#import <QHVCCommonKit/QHVCCommonKit.h>
#import <QHVCEditKit/QHVCEditKit.h>

@implementation QHVCShortVideoUtils

+ (void)setAppInfo
{
    /*
    appInfo 应用信息，字典内所有值均为NSString类型
    appInfo = @{
                @"channelId":cid,       //渠道唯一标识
                @"accessKey":ak,        //业务唯一标识
                @"userSign":usign,      //用户签名, 签名方式详见文档或demo
                @"random":random,       //随机数，可用时间戳替代
                @"timestamp":timestamp, //时间戳
                };

     其中，userSign计算方式如下：
     - 参数列表：
     ak:用户ak
     r：请求当前的时间戳、如果请求时间与服务器时间差大于60S，服务端将拒绝请求
     random: 随机数
     
     1.参数按字典顺序依次拼接, 去掉"&",例如：k1=v1&k2=v2&k3=v3变为k1=v1k2=v2k3=v3
     2.在上述转换后的字符串末尾追加上应用的secretKey
     3.用MD5算出上述串的MD5值作为userSign
     */
    
    NSString* time = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    NSString* random = [NSString stringWithFormat:@"%ld", labs((long)arc4random())];
    NSString* value = [NSString stringWithFormat:@"ak=%@r=%@random=%@", demo_access_key, time, random];
    NSString* sign = [value stringByAppendingString:(NSString *)demo_secret_key];
    NSString* usign = [QHVCToolUtils getMD5String:sign];
    
    NSString* cid = @"demo";
    NSString* ak = (NSString *)demo_access_key;
    NSDictionary* dict = @{
        @"channelId":cid,
        @"accessKey":ak,
        @"userSign":usign,
        @"random":random,
        @"timestamp":time,
    };
    [QHVCEditConfig setAppInfo:dict];
}

@end
