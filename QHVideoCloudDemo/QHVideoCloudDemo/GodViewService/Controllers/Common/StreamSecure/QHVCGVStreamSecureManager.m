//
//  QHVCGVStreamSecureManager.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/11/12.
//  Copyright © 2018 yangkui. All rights reserved.
//

#import "QHVCGVStreamSecureManager.h"
#import "QHVCGodViewHttpBusiness.h"
#import "QHVCGodViewLocalManager.h"
#import "QHVCGVStreamSecureOperation.h"
#import "QHVCLogger.h"

/// timer周期性检查的时间间隔
static NSInteger const kQHVCGVSecureManagerCheckInterval                =  1;
/// 某个设备密码网络请求失败，重新获取的初始间隔
static NSInteger const kQHVCGVSecureManagerRetryIntervalInit            =  30;
/// 拉取密码的最大网络并发数
static NSInteger const kQHVCGVSecureManagerMaxConcurrentOperationCount  =  3;

@implementation QHVCGVStreamPasswordModel

@end


@interface QHVCGVStreamSecureManager ()
/// 周期性检查已有设备是否需要更新密码
@property (nonatomic,strong) NSTimer *checkTimer;
/// 密码数据
@property (nonatomic,strong) NSArray<QHVCGVStreamPasswordModel *> *streamPwds;
/// 从服务器拉取密码的网络请求队列
@property (nonatomic,strong) NSOperationQueue *passwordFetchQueue;
@end

@implementation QHVCGVStreamSecureManager

- (instancetype)init {
    if (self = [super init]) {
        self.passwordFetchQueue = [NSOperationQueue new];
        _passwordFetchQueue.maxConcurrentOperationCount = kQHVCGVSecureManagerMaxConcurrentOperationCount;
        self.checkTimer = [NSTimer scheduledTimerWithTimeInterval:kQHVCGVSecureManagerCheckInterval target:self selector:@selector(refreshPwdsFromServerIfNeed) userInfo:nil repeats:YES];
    }
    return self;
}

#pragma mark - Publics
+ (instancetype)sharedManager {
    static QHVCGVStreamSecureManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [QHVCGVStreamSecureManager new];
    });
    return manager;
}

/**
 * 获取deviceSN对应设备的秘钥
 */
- (NSArray<NSDictionary *> *)getPwdsWithSN:(NSString *)deviceSN {
    if ([QHVCToolUtils isNullString:deviceSN]) {
        return nil;
    }
    NSArray *tmpArray = [_streamPwds copy];
    for (QHVCGVStreamPasswordModel *pwdModel in tmpArray) {
        if ([deviceSN isEqualToString:pwdModel.sn]) {
            return pwdModel.pwds;
        }
    }
    return nil;
}

/**
 * 设备列表界面 更新密码
 */
- (void)updatePwdsByDevicelist:(NSArray <QHVCGVStreamPasswordModel *> *)pwds {
    for (QHVCGVStreamPasswordModel *pwdModel in pwds) {
        pwdModel.nextRefreshDate = [pwdModel.lastPwdDate dateByAddingTimeInterval:pwdModel.refreshInterval];
    }
    [self.passwordFetchQueue cancelAllOperations];
    self.streamPwds = pwds;
}

/**
 * 移除对deviceSN这个设备的安全管理
 */
- (void)removeSecureManagerWithSN:(NSString *)deviceSN {
    if ([QHVCToolUtils isNullString:deviceSN]) {
        return;
    }
    NSMutableArray *tmpArray = [_streamPwds mutableCopy];
    for (QHVCGVStreamPasswordModel *pwdModel in tmpArray) {
        if ([pwdModel.sn isEqualToString:deviceSN]) {
            [tmpArray removeObject:pwdModel];
            break;
        }
    }
    NSArray *operations = [self.passwordFetchQueue.operations copy];
    for (QHVCGVStreamSecureOperation *op in operations) {
        if ([op.deviceSN isEqualToString:deviceSN]) {
            [op cancel];
        }
    }
    _streamPwds = tmpArray;
}

/**
 * 检测设备的密码是否过期
 * @return YES 过期，NO未过期
 */
- (BOOL)isPasswordExpireWithSN:(NSString *)deviceSN {
    if ([QHVCToolUtils isNullString:deviceSN]) {
        return YES;
    }
    NSArray *tmpArray = [_streamPwds copy];
    for (QHVCGVStreamPasswordModel *pwdModel in tmpArray) {
        if ([deviceSN isEqualToString:pwdModel.sn]) {
            NSTimeInterval expire = [pwdModel.lastPwdDate timeIntervalSince1970] + pwdModel.refreshInterval;
            NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
            return now >= expire;
        }
    }
    return YES;
}

/**
 * 立即从服务器获取密码
 */
- (void)updatePwdsFromServerWithSN:(NSString *)deviceSN completion:(void(^)(BOOL success,NSDictionary *responseDict))completion {
    if ([QHVCToolUtils isNullString:deviceSN]) {
        if (completion) {
            completion(NO,nil);
        }
        return;
    }
    // 不走网络请求队列，立即开启网络请求
    [QHVCGodViewHttpBusiness getStreamPwdWithParams:[@{@"binded_sn":deviceSN} mutableCopy] complete:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable responseDict) {
        [self dealPasswordWithResponseDict:responseDict success:success deviceSN:deviceSN];
        if (completion) {
            completion(success,responseDict);
        }
    }];
}

#pragma mark - Privates

/**
 * 根据需要从服务器端更新秘钥
 * 此方法周期性调用，内部检测每个秘钥是否需要刷新
 */
- (void)refreshPwdsFromServerIfNeed {
    if (_streamPwds.count < 1) {
        return;
    }
    NSArray *tmpPwdModels = [_streamPwds copy];
    for (QHVCGVStreamPasswordModel *pwdModel in tmpPwdModels) {
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval needRefresh = [pwdModel.nextRefreshDate timeIntervalSince1970];
        if (now >= needRefresh) {
            // 不管后续接口调用结果，直接将时间累加间隔,避免网络请求的过程中，再次触发刷新，在接口调用完后，会更新这个时间
            [QHVCLogger printLogger:QHVC_LOG_LEVEL_DEBUG content:[NSString stringWithFormat:@"流加密 - 重新获取密码 sn:%@",pwdModel.sn]];
            pwdModel.nextRefreshDate = [[NSDate date] dateByAddingTimeInterval:pwdModel.refreshInterval];
            [self refreshPwdsWithSN:pwdModel.sn completion:nil];
        }
    }
}

- (void)refreshPwdsWithSN:(NSString *)deviceSN completion:(void(^)(BOOL success,NSDictionary *responseDict))completion {
    if ([QHVCToolUtils isNullString:deviceSN]) {
        if (completion) {
            completion(NO,nil);
        }
        return;
    }
    QHVCGVStreamSecureOperation *secureOperation = [QHVCGVStreamSecureOperation new];
    secureOperation.deviceSN = deviceSN;
    secureOperation.callback = ^(BOOL success, NSDictionary *responseDict) {
        [QHVCLogger printLogger:QHVC_LOG_LEVEL_DEBUG content:[NSString stringWithFormat:@"流加密 - 获取密码 sn:%@  响应:%@",deviceSN,responseDict]];
        [self dealPasswordWithResponseDict:responseDict success:success deviceSN:deviceSN];
        if (completion) {
            completion(success,responseDict);
        }
    };
    [self.passwordFetchQueue addOperation:secureOperation];
}

- (void)dealPasswordWithResponseDict:(NSDictionary *)responseDict success:(BOOL)success deviceSN:(NSString *)deviceSN {
    if (success) {
        NSDictionary *data = [QHVCToolUtils getObjectFromDictionary:responseDict key:@"data" defaultValue:nil];
        if (![QHVCToolUtils dictionaryIsNull:data]) {
            NSUInteger interval = [QHVCToolUtils getIntFromDictionary:data key:@"interval" defaultValue:600];
            id pwds = [QHVCToolUtils getObjectFromDictionary:data key:@"pwds" defaultValue:nil];
            [self updatePwdInfoToStreamPwds:pwds sn:deviceSN interval:interval];
        }
    }
    else {
        // 设置下次更新的时间
        NSArray *tmpArray = [_streamPwds copy];
        for (QHVCGVStreamPasswordModel *pwdModel in tmpArray) {
            if ([pwdModel.sn isEqualToString:deviceSN]) {
                pwdModel.retryInterval *= 2;
                if (pwdModel.retryInterval > pwdModel.refreshInterval) {
                    pwdModel.retryInterval = pwdModel.refreshInterval;
                }
                pwdModel.nextRefreshDate = [[NSDate date] dateByAddingTimeInterval:pwdModel.retryInterval];
            }
        }
    }
}

- (void)setCurrentWatchingSN:(NSString *)currentWatchingSN {
    _currentWatchingSN = currentWatchingSN;
    if (currentWatchingSN != nil) {
        NSArray *tmpArray = [_streamPwds copy];
        [QHVCLogger printLogger:QHVC_LOG_LEVEL_DEBUG content:[NSString stringWithFormat:@"秘钥 - 更新serialNumer:%@ 的秘钥",currentWatchingSN]];
        for (QHVCGVStreamPasswordModel *pwdModel in tmpArray) {
            if ([pwdModel.sn isEqualToString:currentWatchingSN]) {
                [[QHVCGodViewLocalManager sharedInstance] updateGodSeesVideoStreamSecurityKeys:pwdModel.pwds serialNumber:pwdModel.sn];
                [QHVCLogger printLogger:QHVC_LOG_LEVEL_DEBUG content:[NSString stringWithFormat:@"秘钥 - 找到秘钥，已更新:%@",pwdModel.pwds]];
            }
        }
    }
}

- (void)updatePwdInfoToStreamPwds:(NSArray *)pwds sn:(NSString *)deviceSN interval:(NSUInteger)interval {
    NSArray *tmpArray = [_streamPwds copy];
    for (QHVCGVStreamPasswordModel *pwdModel in tmpArray) {
        if ([pwdModel.sn isEqualToString:deviceSN]) {
            pwdModel.pwds = pwds;
            pwdModel.refreshInterval = interval;
            pwdModel.retryInterval = kQHVCGVSecureManagerRetryIntervalInit;
            pwdModel.lastPwdDate = [NSDate date];
            pwdModel.nextRefreshDate = [pwdModel.lastPwdDate dateByAddingTimeInterval:interval];
        }
    }
    if ([self.currentWatchingSN isEqualToString:deviceSN]) {
        [[QHVCGodViewLocalManager sharedInstance] updateGodSeesVideoStreamSecurityKeys:pwds serialNumber:deviceSN];
    }
}

@end
