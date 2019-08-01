//
//  QHVCGVStreamSecureManager.h
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/11/12.
//  Copyright © 2018 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHVCGVStreamPasswordModel : NSObject
/// 序列号
@property (nonatomic,copy) NSString *sn;
/// 上次更新密码的时间
@property (nonatomic,copy) NSDate *lastPwdDate;
/// 密码列表
@property (nonatomic,strong) NSArray<NSDictionary *> *pwds;
/// 重新获取的时间间隔
@property(nonatomic,assign) NSUInteger refreshInterval;

// -------------用于刷新机制------------------------
/// 密码刷新失败时，重新获取的时间间隔(重试机制 2倍速累加)
@property(nonatomic,assign) NSUInteger retryInterval;

/// 下次去服务器更新的时间
@property (nonatomic,strong) NSDate *nextRefreshDate;

@end



@interface QHVCGVStreamSecureManager : NSObject
// 当前观看设备的sn
@property (nonatomic,copy, nullable) NSString *currentWatchingSN;

+ (instancetype)sharedManager;

/**
 * 设备列表界面 更新密码
 */
- (void)updatePwdsByDevicelist:(NSArray <QHVCGVStreamPasswordModel *> *)pwds;

/**
 * 获取deviceSN对应设备的秘钥
 */
- (NSArray<NSDictionary *> *)getPwdsWithSN:(NSString *)deviceSN;


/**
 * 移除对deviceSN这个设备的安全管理
 */
- (void)removeSecureManagerWithSN:(NSString *)deviceSN;

/**
 * 检测设备的密码是否过期
 * @return YES 过期，NO未过期
 */
- (BOOL)isPasswordExpireWithSN:(NSString *)deviceSN;

/**
 * 立即从服务器获取密码
 */
- (void)updatePwdsFromServerWithSN:(NSString *)deviceSN completion:(void(^)(BOOL success,NSDictionary *responseDict))completion;

@end

NS_ASSUME_NONNULL_END
