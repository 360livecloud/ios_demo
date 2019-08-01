//
//  QHVCGlobalConfig.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2017/6/15.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCGlobalConfig.h"
#import <QHVCCommonKit/QHVCCommonKit.h>

@implementation QHVCGlobalConfig

+ (instancetype) sharedInstance {
    static QHVCGlobalConfig* s_instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        s_instance = [QHVCGlobalConfig new];
    });
    return s_instance;
}

- (id)init {
    self = [super init];
    _protocolQueue = dispatch_queue_create("qhvc.videocloud.demo.protocol.process.queue", NULL);
    dispatch_queue_set_specific(_protocolQueue, _protocolQueueKey, (__bridge void *)self, NULL);
    _appId = kQHVCAppId;
    _channelId = kQHVCChannelId;
    _deviceId = [QHVCToolDeviceModel getDeviceUUID];
    _appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    _model = [QHVCToolDeviceModel getCurrentDeviceName];
    return self;
}

static UIColor* statusBarColor;

+ (UIColor *) getStatusBarColor
{
    return statusBarColor;
}

+ (void) setStatusBarColor:(UIColor *)color
{
    statusBarColor = color;
}

+ (NSString *)generateBusinessSubscriptionSignWithAppId:(NSString *)appId
                                           serialNumber:(NSString *)serialNumber
                                               deviceId:(NSString *)deviceId
                                                 appKey:(NSString *)appKey {
    NSString *channelTag = @"channel__";
    NSString *appName = appId;
    NSString *snTag = @"sn__";
    NSString *sn = serialNumber;
    if (![QHVCToolUtils isNullString:deviceId]) {
        sn = deviceId;
    }
    NSString *keyTag = @"key_";
    NSString *key = appKey;
    NSString *sign = [NSString stringWithFormat:@"%@%@%@%@%@%@", channelTag, appName, snTag, sn, keyTag, key];
    return [QHVCToolUtils getMD5String:sign];
}

@end
