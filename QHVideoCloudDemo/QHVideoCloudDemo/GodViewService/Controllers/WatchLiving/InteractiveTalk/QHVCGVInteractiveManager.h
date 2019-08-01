//
//  QHVCGVInteractiveManager.h
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/10/23.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QHVCCommonKit/QHVCCommonKit.h>
#import <QHVCInteractiveKit/QHVCInteractiveKit.h>
#import <QHVCInteractiveKit/QHVCInteractiveKit+Automation.h>

NS_ASSUME_NONNULL_BEGIN

@class QHVCGVInteractiveManager;
@protocol QHVCGVInteractiveAutomationDelegate <NSObject>


/**
 本地推流端发生错误回调
 该回调方法表示SDK运行时出现了（网络或媒体相关的）错误。通常情况下，SDK上报的错误意味着SDK无法自动恢复，需要应用程序干预或提示用户。应用程序可以提示用户启动通话失败，并调用stopAutomaticConversation退出频道。
 
 @param engine 引擎对象
 @param errorCode 错误代码
 */
- (void)interactiveAutomationEngine:(QHVCGVInteractiveManager *)engine didOccurError:(QHVCITLErrorCode)errorCode;


/**
 开始自动通话成功回调
 该回调方法表示该客户端成功加入了指定的频道，可以正式开始通话，同时在回调里做后续操作。
 
 @param engine 引擎对象
 @param channel 频道名
 @param uid 用户ID
 */
- (void)interactiveAutomationEngine:(QHVCGVInteractiveManager *)engine didStartAutomaticConversation:(NSString *)channel withUid:(NSString *)uid;


/**
 用户主动结束自动通话成功回调
 该回调方法表示该客户端成功离开了指定的频道，通话结束，同时在回调里做后续操作。
 
 @param engine 引擎对象
 @param channel 频道名
 @param uid 用户ID
 */
- (void)interactiveAutomationEngine:(QHVCGVInteractiveManager *)engine didStopAutomaticConversation:(NSString *)channel withUid:(NSString *)uid;


/**
 借助业务信令通道发送消息
 
 @param engine 引擎对象
 @param message 消息内容，业务无需解析，对业务透明。
 @param destId 目标设备地址
 */
- (void)interactiveAutomationEngine:(QHVCGVInteractiveManager *)engine didSendingSignalingMessage:(NSString *)message toDestId:(NSString *)destId;

/**
 创建视频画布对象
 
 @param engine 引擎对象
 @param uid 用户ID
 @return 视频画布对象
 */
- (UIView *)interactiveAutomationEngine:(QHVCGVInteractiveManager *)engine didCreateViewWithUid:(NSString *)uid;

@end

/**
 帝视互动通话管理
 */
@interface QHVCGVInteractiveManager : NSObject

+ (instancetype) sharedInstance;

- (int) startAutomaticConversation:(id<QHVCGVInteractiveAutomationDelegate>)delegate;

- (int) stopAutomaticConversation;

/**
 * 强制停止，释放资源
 */
- (void)destory;

- (int) receiveSignalingMessages:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
