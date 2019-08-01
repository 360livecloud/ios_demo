//
//  QHVCITSConfig.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/3/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCITSConfig.h"
#import "QHVCGlobalConfig.h"
#import "QHVCITSDefine.h"

@implementation QHVCITSConfig

+ (nonnull NSString *)getVersion
{
    return @"1.0.0.0";
}

+ (nonnull instancetype)sharedInstance
{
    static QHVCITSConfig * s_instance = NULL;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        s_instance = [QHVCITSConfig new];
    });
    return s_instance;
}

- (id)init
{
    self = [super init];
    [self setInteractiveServerUrl:QHVCITS_RELEASE_ENV_INTERACTIVE_SERVER_URL];
    _protocolQueue = dispatch_queue_create("its.protocol.process.queue", NULL);
    dispatch_queue_set_specific(_protocolQueue, _protocolQueueKey, (__bridge void *)self, NULL);
    _userHeartInterval = QHVCITS_HEART_TIME_INTERTVAL;
    _updateRoomListInterval = QHVCITS_ROOMLIST_TIME_INTERTVAL;
    _bypassLiveCDNUseSDKService = NO;
    _dataCollectMode = QHVCITLDataCollectModeSDK;
    _businessRenderMode = QHVCITS_Render_SDK;
    _videoEncoderProfile = QHVCITL_VideoProfile_360P_9;
    _videoEncoderProfileForGuest = QHVCITL_VideoProfile_360P_9;
    _videoViewRenderMode = QHVCITL_Render_ScaleAspectFill;
    _mergeVideoCanvasWidth = QHVCITS_VIDEO_WIDTH;
    _mergeVideoCanvasHeight = QHVCITS_VIDEO_HEIGHT;
    
    NSString* path = [[NSBundle mainBundle] pathForResource:QHVCITS_INTERACTIVE_VIDEO_PROFILE_FILE ofType:@"plist"];
    _videoProfiles = [NSMutableArray arrayWithContentsOfFile:path];
    
    return self;
}

- (void) setEnableTestEnvironment:(BOOL)enableTestEnvironment
{
    _enableTestEnvironment = enableTestEnvironment;
    if (enableTestEnvironment)
    {
        [self setInteractiveServerUrl:QHVCITS_TEST_ENV_INTERACTIVE_SERVER_URL];
    }else
    {
        [self setInteractiveServerUrl:QHVCITS_RELEASE_ENV_INTERACTIVE_SERVER_URL];
    }
}

- (void) readAccountSetting
{
    NSURL *path = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSString* accountSettingCachePath = [path.relativePath stringByAppendingString:QHVCITS_INTERACTIVE_ACCOUNT_SAVE_PATH];
    NSMutableArray<NSMutableDictionary *> *accountSettings = [NSMutableArray arrayWithContentsOfFile:accountSettingCachePath];
    if (accountSettings.count <= 0) {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"QHVCITLMain" ofType:@"plist"];
        accountSettings = [NSMutableArray arrayWithContentsOfFile:path];
    }
    [self setAccountSettings:accountSettings];
}

- (void) setAccountSettings:(NSMutableArray<NSMutableDictionary *> *)accountSettings
{
    if (accountSettings == nil)
    {
        _businessId = nil;
        _channelId = nil;
        _appKey = nil;
        _appSecret = nil;
        _accountSettings = nil;
        return;
    }
    _businessId = accountSettings[0][QHVCITS_KEY_VALUE];
    if ([QHVCToolUtils isNullString:_businessId])
    {
        _businessId = kQHVCAppId;
        [QHVCToolUtils setStringToDictionary:accountSettings[0] key:QHVCITS_KEY_VALUE value:_businessId];
    }
    _channelId = accountSettings[1][QHVCITS_KEY_VALUE];
    if ([QHVCToolUtils isNullString:_channelId])
    {
        _channelId = kQHVCChannelId;
        [QHVCToolUtils setStringToDictionary:accountSettings[1] key:QHVCITS_KEY_VALUE value:_channelId];
    }
    _appKey = accountSettings[2][QHVCITS_KEY_VALUE];
    if ([QHVCToolUtils isNullString:_appKey])
    {
        _appKey = kQHVCInteractiveAppKey;
        [QHVCToolUtils setStringToDictionary:accountSettings[2] key:QHVCITS_KEY_VALUE value:_appKey];
    }
    _appSecret = accountSettings[3][@"value"];
    if ([QHVCToolUtils isNullString:_appSecret])
    {
        _appSecret = kQHVCInteractiveAppSecret;
        [QHVCToolUtils setStringToDictionary:accountSettings[3] key:QHVCITS_KEY_VALUE value:_appSecret];
    }
    _accountSettings = accountSettings;
}

- (void) readUserSetting
{
    NSURL *path = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSString* userSettingCachePath = [path.relativePath stringByAppendingString:QHVCITS_INTERACTIVE_USER_SETTING_SAVE_PATH];
    NSMutableArray<NSMutableDictionary *> *userSettings = [NSMutableArray arrayWithContentsOfFile:userSettingCachePath];
    if (userSettings.count <= 0) {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"InteractiveSetting" ofType:@"plist"];
        userSettings = [NSMutableArray arrayWithContentsOfFile:path];
    }
    [self setUserSettings:userSettings];
}

- (void) setUserSettings:(NSMutableArray<NSMutableDictionary *> *)userSettings
{
    _userSettings = userSettings;
    if (userSettings == nil)
    {
        return;
    }
    NSArray *publicConfig = userSettings[0][@"config"];
    NSString *debugEnv = [publicConfig[0] objectForKey:@"index"];
    [self setEnableTestEnvironment:[debugEnv boolValue]];
    
    NSString *dataCollect = [publicConfig[1] objectForKey:@"index"];
    [self setDataCollectMode:(QHVCITLDataCollectMode)(dataCollect.integerValue+1)];
    
    
    NSString *anchorVideoProfile = userSettings[1][@"index"];
    NSString *anchorProfileIndex = _videoProfiles[anchorVideoProfile.integerValue][@"profileIndex"];
    _videoEncoderProfile = anchorProfileIndex.integerValue;

    NSString *guestVideoProfile = userSettings[2][@"index"];
    NSString *guestProfileIndex = _videoProfiles[guestVideoProfile.integerValue][@"profileIndex"];
    _videoEncoderProfileForGuest = guestProfileIndex.integerValue;
}

@end
