//
//  QHVCGVConfig.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/9/18.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCGVConfig.h"
#import "QHVCGodViewLocalManager.h"
#import <QHVCInteractiveKit/QHVCInteractiveKit.h>
#import "QHVCGVDefine.h"

static NSString *kQHVCGVConfig_GodViewAccountPlistVersionKey   = @"GodViewAccountPlistVersionKey";
static NSString *kQHVCGVConfig_GodViewSettingPlistVersionKey   = @"GodViewSettingPlistVersionKey";

void runOnMainQueueWithoutDeadlocking(void (^block)(void))
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}


@implementation QHVCGVConfig

+ (instancetype) sharedInstance
{
    static QHVCGVConfig* s_instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        s_instance = [QHVCGVConfig new];
    });
    return s_instance;
}

- (id)init
{
    self = [super init];
    [self setBusinessServerAddress:QHVCGV_RELEASE_ENV_GODVIEW_SERVER_URL];
    _userHeartInterval = QHVCGV_HEART_TIME_INTERTVAL;
    _updateDeviceListInterval = QHVCGV_ROOMLIST_TIME_INTERTVAL;
    return self;
}

- (void)setEnableTestEnvironment:(BOOL)enableTestEnvironment {
    [self setBusinessEnableTestEnvironment:enableTestEnvironment];
    [self setEnableSignallingTestEnvironment:enableTestEnvironment];
    [[QHVCGodViewLocalManager sharedInstance] enableTestEnvironment:enableTestEnvironment];
    [[QHVCInteractiveKit sharedInstance] enableTestEnvironment:enableTestEnvironment];
}

- (void) setBusinessEnableTestEnvironment:(BOOL)enableTestEnvironment
{
    if (enableTestEnvironment)
    {
        [self setBusinessServerAddress:QHVCGV_TEST_ENV_GODVIEW_SERVER_URL];
    }else
    {
        [self setBusinessServerAddress:QHVCGV_RELEASE_ENV_GODVIEW_SERVER_URL];
    }
}

- (void)setEnableSignallingTestEnvironment:(BOOL)enableTestEnvironment {
    if (enableTestEnvironment) {
        [self setSignallingServerAddress:kQHVCGVLVC_TEST_ENV_LONGLINK_HOST];
    }
    else {
        [self setSignallingServerAddress:kQHVCGVLVC_RELEASE_ENV_LONGLINK_HOST];
    }
}

#pragma mark - 账号相关设置
- (void) readAccountSetting
{
    NSMutableArray<NSMutableDictionary *> *accountSettings = [NSMutableArray arrayWithContentsOfFile:[self accountCacheSavePath]];
    
    CGFloat accountPlistVersion = [[NSUserDefaults standardUserDefaults] floatForKey:kQHVCGVConfig_GodViewAccountPlistVersionKey];
    
    if (accountSettings.count <= 0 || accountPlistVersion < QHVCGV_GODSEES_ACCOUNT_PLIST_VERSION - 0.0005) {
        NSString* path = [[NSBundle mainBundle] pathForResource:QHVCGV_GODVIEW_ACCOUNT_FILE ofType:@"plist"];
        accountSettings = [NSMutableArray arrayWithContentsOfFile:path];
        [accountSettings writeToFile:[self accountCacheSavePath] atomically:YES];
        
        [[NSUserDefaults standardUserDefaults] setFloat:QHVCGV_GODSEES_ACCOUNT_PLIST_VERSION forKey:kQHVCGVConfig_GodViewAccountPlistVersionKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self setAccountSettings:accountSettings];
}

- (void) setAccountSettings:(NSMutableArray<NSMutableDictionary *> *)accountSettings {
    _accountSettings = accountSettings;
    QHVCGlobalConfig* globalConfig = [QHVCGlobalConfig sharedInstance];
    if (accountSettings == nil) {
        globalConfig.appId = @"";
        globalConfig.appKey = @"";
        globalConfig.appSecret = @"";
        _userName = nil;
        _password = nil;
        return;
    }
    globalConfig.appId = accountSettings[0][@"value"];
    globalConfig.appKey = accountSettings[1][@"value"];
    globalConfig.appSecret = accountSettings[2][@"value"];
    _userName = accountSettings[3][@"value"];
    _password = accountSettings[4][@"value"];
}

- (void)updateAccountSettings:(NSMutableArray<NSMutableDictionary *> *)accountSettings {
    [self setAccountSettings:accountSettings];
    [accountSettings writeToFile:[self accountCacheSavePath] atomically:YES];
}

#pragma mark - 用户设置
- (void) readUserSettings
{
    NSMutableArray<NSDictionary *> *userSettings = [NSMutableArray arrayWithContentsOfFile:[self userSettingCacheSavePath]];
    
    CGFloat userPlistVersion = [[NSUserDefaults standardUserDefaults] floatForKey:kQHVCGVConfig_GodViewSettingPlistVersionKey];
    
    if (userSettings.count <= 0 || userPlistVersion < (QHVCGS_GODSEES_SETTING_PLIST_VERSION - 0.0005)) {
        NSString* path = [[NSBundle mainBundle] pathForResource:QHVCGV_GODVIEW_SETTING_SAVE_PATH ofType:@"plist"];
        userSettings = [NSMutableArray arrayWithContentsOfFile:path];
        [userSettings writeToFile:[self userSettingCacheSavePath] atomically:YES];
        
        [[NSUserDefaults standardUserDefaults] setFloat:QHVCGS_GODSEES_SETTING_PLIST_VERSION forKey:kQHVCGVConfig_GodViewSettingPlistVersionKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self setUserSettings:userSettings];
}

- (void) setUserSettings:(NSMutableArray<NSDictionary *> *)userSettings
{
    _userSettings = userSettings;
    if (userSettings == nil)
    {
        return;
    }
    // 调试环境
    NSArray *publicConfig = [QHVCToolUtils getObjectFromDictionary:userSettings[0] key:@"config" defaultValue:nil];
    BOOL debugEnv = [QHVCToolUtils getBooleanFromDictionary:publicConfig[0] key:QHVCGV_KEY_INDEX defaultValue:NO];
    [self setEnableTestEnvironment:debugEnv];
    int connectType = [QHVCToolUtils getIntFromDictionary:publicConfig[1] key:QHVCGV_KEY_INDEX defaultValue:0];
    if(connectType == 0)
    {
        self.networkConnectType = QHVC_NET_GODSEES_NETWORK_CONNECT_TYPE_P2P | QHVC_NET_GODSEES_NETWORK_CONNECT_TYPE_RELAY | QHVC_NET_GODSEES_NETWORK_CONNECT_TYPE_DIRECT_IP;
    } else if(connectType == 1){
        self.networkConnectType = QHVC_NET_GODSEES_NETWORK_CONNECT_TYPE_P2P;
    } else if(connectType == 2){
        self.networkConnectType = QHVC_NET_GODSEES_NETWORK_CONNECT_TYPE_RELAY;
    } else if(connectType == 3){
        self.networkConnectType = QHVC_NET_GODSEES_NETWORK_CONNECT_TYPE_DIRECT_IP;
    }
    self.shouldShowPerformanceInfo = [QHVCToolUtils getBooleanFromDictionary:publicConfig[2] key:QHVCGV_KEY_INDEX defaultValue:YES];
    self.isRTCOpenVideo = [QHVCToolUtils getBooleanFromDictionary:publicConfig[3] key:QHVCGV_KEY_INDEX defaultValue:YES];
    self.isHardDecode = [QHVCToolUtils getBooleanFromDictionary:publicConfig[4] key:QHVCGV_KEY_INDEX defaultValue:NO];
    BOOL playerReceiveDataModelFlv = [QHVCToolUtils getBooleanFromDictionary:publicConfig[5] key:QHVCGV_KEY_INDEX defaultValue:YES];
    self.playerReceiveDataModel = playerReceiveDataModelFlv?QHVC_NET_GODSEES_PLAYER_RECEIVE_DATA_MODEL_HTTP_FLV:QHVC_NET_GODSEES_PLAYER_RECEIVE_DATA_MODEL_CALLBACK;
    self.streamType = [QHVCToolUtils getIntFromDictionary:publicConfig[6] key:QHVCGV_KEY_INDEX defaultValue:0] + 1;
}

- (void)updateUserSettings:(NSMutableArray<NSDictionary *> *)userSettings {
    [userSettings writeToFile:[self userSettingCacheSavePath] atomically:YES];
    [self readUserSettings];
}

- (void)resetUserSettings {
    NSString* path = [[NSBundle mainBundle] pathForResource:QHVCGV_GODVIEW_SETTING_SAVE_PATH ofType:@"plist"];
    NSMutableArray<NSDictionary *> *userSettings = [NSMutableArray arrayWithContentsOfFile:path];
    [self setUserSettings:userSettings];
    [userSettings writeToFile:[self userSettingCacheSavePath] atomically:YES];
}

#pragma mark - 目录
- (NSString *)accountCacheSavePath {
    NSString *accountSettingCachePath = [[self cacheDirectory] stringByAppendingString:QHVCGV_GODVIEW_ACCOUNT_SAVE_PATH];
    return accountSettingCachePath;
}

- (NSString *)userSettingCacheSavePath {
    NSString *userSettingCachePath = [[self cacheDirectory] stringByAppendingString:QHVCGV_GODVIEW_SETTING_CACHE_SAVE_PATH];
    return userSettingCachePath;
}

- (NSString *)cacheDirectory {
    NSURL *path = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    return path.relativePath;
}

@end
