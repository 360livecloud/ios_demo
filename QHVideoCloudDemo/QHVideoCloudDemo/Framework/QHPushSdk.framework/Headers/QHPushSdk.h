//
//  QHPushSdk.h
//  QHPushSdk
//
//  Created by wangdacheng on 2017/10/26.
//  Copyright © 2017年 qihoo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, QHPushSdkStatus) {
    /** 正在启动 */
    QHPushSdkStatus_Starting,
    /** 已经启动 */
    QHPushSdkStatus_Started,
    /** 已经停止 */
    QHPushSdkStatus_Stoped,
};

typedef NS_ENUM(NSInteger, QHPushSdkAliasActionType) {
    /** 绑定别名 */
    QHPushSdkAliasActionType_Bind,
    /** 解绑别名 */
    QHPushSdkAliasActionType_Unbind,
};

@protocol QHPushSdkDelegate;

@interface QHPushSdk : NSObject

#pragma mark - 基本功能

/**
 *  启动pushSdk，并绑定长连接
 *
 *  @param appKey           设置appKey，此appKey从QPush网站平台获取
 *  @param isSupportOpenApi 设置sdk请求的dispatcher，YES:OpenApi NO:push.dc
 *  @param isDev            设置sdk是否运行在测试环境，YES:测试环境 NO:线上环境
 *  @param delegate         回调代理delegate
 */
+ (void)startSdkWithAppKey:(NSString *)appKey isSupportOpenApi:(BOOL)isSupportOpenApi isDev:(BOOL)isDev delegate:(id<QHPushSdkDelegate>)delegate;

/**
 *  停止Sdk，释放资源
 */
+ (void)stopSdk;

/**
 *  向QPush服务端注册DeviceToken
 *
 *  @param deviceToken APNs推送时使用的deviceToken
 */
+ (void)registerDeviceToken:(NSString *)deviceToken;

/**
 *  绑定别名功能
 *  备注：后台可以根据别名进行推送，别名需保证唯一性
 *
 *  @param alias 别名字符串
 */
+ (void)bindAlias:(NSString *)alias;

/**
 *  解绑别名
 */
+ (void)unbindAlias;

#pragma mark - 统计打点

/**
 *  统计App内长连收到消息
 *  备注：长连回调中收到的消息为数组形式，需逐条调用该方法
 *
 *  @param msgId App内长连消息id
 */
+ (void)statisticPayloadData:(NSString *)msgId;

/**
 *  统计APNs通知点击情况
 *
 *  @param userInfo App接收到远程通知回调方法的参数
 */
+ (void)statisticNotificationClicked:(NSDictionary *)userInfo;

#pragma mark - 辅助功能

/**
 *  获取SDK版本号
 *
 *  当前sdk版本：@"2.0"
 *  @return 版本值
 */
+ (NSString *)version;

/**
 *  获取qdas（统计工具sdk）生成的m2
 *
 *  当前sdk版本：@"2.0"
 *  @return 版本值
 */
+ (NSString *)qdasM2;

/**
 *  设置app本地角标值，并同步到服务端
 *
 *  @param num 角标数值
 */
+ (void)setBadge:(NSUInteger)num;

/**
 *  清空当前app在通知栏的全部通知，并将角标置0
 */
+ (void)clearAllNotificationForNotificationBar;

@end


@protocol QHPushSdkDelegate <NSObject>

/**
 *  SDK登录长连接成功返回clientId
 *  说明：启动QHPushSdk时，SDK会自动用AppKey向个推服务器注册SDK，当成功注册时，SDK通知应用注册成功。
 *  备注：注册成功仅表示推送通道建立，如果deviceToken、alias等验证不通过，依然无法接收到推送消息，请确保验证信息正确。
 *
 *  @param clientId 标识用户的clientId
 */
- (void)qhPushSdkDidRegisterClient:(NSString *)clientId;

/**
 *  SDK收到服务端的透传消息数组
 *  备注：
 *  1. msgArray的元素类型是dictionary；
 *  2. dictionary中有3组<key, value>，对应的解析类型分别为<@"msgId", NSString>、<@"appId", NSString>、<@"msgData", NSString>。
 *
 *  @param msgArray 透传消息数组
 */
- (void)qhPushSdkRsvPayloadData:(NSArray *)msgArray;

/**
 *  SDK运行状态通知
 *
 *  @param status 返回SDK运行状态
 */
- (void)qhPushSdkDidNotifySdkState:(QHPushSdkStatus)status;

/**
 *  SDK注册deviceToken回调
 *
 *  @param isSuccess    成功返回 YES, 失败返回 NO
 */
- (void)qhPushSdkDidRegisterDT:(BOOL)isSuccess;

/**
 *  SDK绑定别名回调
 *
 *  @param type         绑定/解绑别名
 *  @param isSuccess    成功返回 YES, 失败返回 NO
 *  @param error        成功返回nil, 错误返回相应error信息
 */
- (void)qhPushSdkDidAliasAction:(QHPushSdkAliasActionType)type result:(BOOL)isSuccess error:(NSError *)error;

/**
 *  SDK遇到错误消息返回error
 *
 *  @param error    PushSDK内部发生错误
 */
- (void)qhPushSdkDidOccurError:(NSError *)error;

@end

