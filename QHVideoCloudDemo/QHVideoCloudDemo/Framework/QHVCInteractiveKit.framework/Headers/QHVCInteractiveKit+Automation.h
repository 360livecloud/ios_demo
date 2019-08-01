//
//  QHVCInteractiveKit+Automation.h
//  QHVCInteractiveKit
//
//  Created by yangkui on 2018/10/23.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCInteractiveKit.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - SDK Automation delegates -

@protocol QHVCInteractiveAutomationDelegate <NSObject>


/**
 本地推流端发生错误回调
 该回调方法表示SDK运行时出现了（网络或媒体相关的）错误。通常情况下，SDK上报的错误意味着SDK无法自动恢复，需要应用程序干预或提示用户。应用程序可以提示用户启动通话失败，并调用stopAutomaticConversation退出频道。

 @param engine 引擎对象
 @param errorCode 错误代码
 */
- (void)interactiveAutomationEngine:(QHVCInteractiveKit *)engine didOccurError:(QHVCITLErrorCode)errorCode;


/**
 开始自动通话成功回调
 该回调方法表示该客户端成功加入了指定的频道，可以正式开始通话，同时在回调里做后续操作。
 
 @param engine 引擎对象
 @param channel 频道名
 @param uid 用户ID
 */
- (void)interactiveAutomationEngine:(QHVCInteractiveKit *)engine didStartAutomaticConversation:(NSString *)channel withUid:(NSString *)uid;


/**
 用户主动结束自动通话成功回调
 该回调方法表示该客户端成功离开了指定的频道，通话结束，同时在回调里做后续操作。

 @param engine 引擎对象
 @param channel 频道名
 @param uid 用户ID
 */
- (void)interactiveAutomationEngine:(QHVCInteractiveKit *)engine didStopAutomaticConversation:(NSString *)channel withUid:(NSString *)uid;


/**
 借助业务信令通道发送消息

 @param engine 引擎对象
 @param message 消息内容，业务无需解析，对业务透明。
 @param destId 目标设备地址
 */
- (void)interactiveAutomationEngine:(QHVCInteractiveKit *)engine didSendingSignalingMessage:(NSString *)message toDestId:(NSString *)destId;


/**
 创建视频画布对象

 @param engine 引擎对象
 @param uid 用户ID
 @return 视频画布对象
 */
- (UIView *)interactiveAutomationEngine:(QHVCInteractiveKit *)engine didCreateViewWithUid:(NSString *)uid;

@end


/**
 互动直播自动化通话实现
 */
@interface QHVCInteractiveKit (Automation)


/**
 开始通话

 @param delegate 代理回调对象
 @param roomId 房间ID
 @param channelNo 通道序号
 @param userId 用户ID，需要保证全局唯一
 @param beInvitedUserId 被邀请者ID
 @param optionInfoDict 可选操作数据
    例如：@{@"openVideo":@"boolValue",@"dataCollectModel":@"intValue"}
 @return 0 成功, return 非0 表示失败
 */
- (int) startAutomaticConversationWithDelegate:(id<QHVCInteractiveAutomationDelegate>)delegate
                                        roomId:(NSString *)roomId
                                     channelNo:(NSInteger)channelNo
                                        userId:(NSString *)userId
                               beInvitedUserId:(NSString *)beInvitedUserId
                                optionInfoDict:(NSDictionary *)optionInfoDict;


/**
 退出自动通话

 @return 0 成功, return 非0 表示失败
 */
- (int) stopAutomaticConversation;


/**
 接收信令通道消息
 业务信令通道接收SDK的消息，调用此方法通知SDK处理消息内容。

 @param message 消息内容
 @return 0 成功, return 非0 表示失败
 */
- (int) receiveSignalingMessages:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
