//
//  QHVCITSChatManager.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/3/19.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QHVCITSProtocolMonitor.h"

/**
 通话状态
 */
typedef NS_ENUM(NSInteger, QHVCITSChatStatus)
{
    QHVCITSChatStatus_Starting,
    QHVCITSChatStatus_Started,
    QHVCITSChatStatus_Stoped,
};

typedef NS_ENUM(NSInteger, QHVCITSCommand)
{
    QHVCITSCommandAnchorInviteGuest = 10000,//主播邀请观众连麦
    QHVCITSCommandGuestAgreeInvite = 10001,//观众同意主播连麦邀请
    QHVCITSCommandGuestRefuseInvite = 10002,//观众拒绝主播连麦邀请
    
    QHVCITSCommandGuestAskJoin = 10003,//观众发送连麦请求
    QHVCITSCommandAnchorAgreeJoin = 10004,//主播同意连麦请求
    QHVCITSCommandAnchorRefuseJoin = 10005,//主播拒绝连麦请求
    QHVCITSCommandAnchorKickoutGuest = 10006,//主播踢出某个嘉宾
    
    QHVCITSCommandAnchorAskJoinPK = 10010,//主播发送PK请求
    QHVCITSCommandAnchorAgreeJoinPK = 10011,//主播同意PK请求
    QHVCITSCommandAnchorRefuseJoinPK = 10012,//主播拒绝PK请求
    QHVCITSCommandAnchorKickoutAnchorPK = 10013,//主播踢出某个主播PK
    
    QHVCITSCommandGuestJoinNotify = 20000,//嘉宾进入，发送通知
    QHVCITSCommandAnchorQuitNotify = 20001,//主播退出，发送通知
    QHVCITSCommandGuestQuitNotify = 20002,//嘉宾主动退出，发送通知
    QHVCITSCommandGuestKickoutNotify = 20003,//嘉宾被踢出，发送通知
    
    QHVCITSCommandAnchorJoinPKNotify = 20006,//主播加入PK，发送通知
    QHVCITSCommandAnchorQuitPKNotify = 20007,//主播主动退出PK，发送通知
    QHVCITSCommandAnchorKickoutPKNotify = 20008,//主播被踢出PK，发送通知
    QHVCITSCommandAnchorClosePKRoomNotify = 20009,//主播关闭PK房间，发送通知
    QHVCITSCommandPKAnchorClosePKRoomNotify = 20010,//PK主播关闭PK房间，发送通知
};

@protocol QHVCITSChatMessageDelegate <NSObject>

@optional
- (void)onChatDidRegisterClient:(NSString *)clientId;

- (void)onChatRsvPayloadData:(NSArray *)msgArray;

- (void)onChatDidNotifySdkState:(QHVCITSChatStatus)status;

- (void)onChatDidRegisterDT:(BOOL)isSuccess;

- (void)onDidAliasAction:(int)type result:(BOOL)isSuccess error:(NSError *)error;

- (void)onChatDidOccurError:(NSError *)error;

@end

@interface QHVCITSChatManager : NSObject

@property (nonatomic, weak) id<QHVCITSChatMessageDelegate> delegate;

/**
 实例对象

 @return 实例对象
 */
+ (QHVCITSChatManager *)sharedManager;

/**
 连接长连服务器
 */
- (void)connectChatServer;

/**
 断开长连服务器
 */
- (void)disconnectChatServer;

/**
 绑定别名

 @param alias 别名
 */
- (void)bindAlias:(NSString *)alias;

/**
 解绑别名
 */
- (void)unbindAlias;

/**
 向房间成员发送指令消息

 @param cmdType 指令
 @param targetId 目标用户ID
 @param complete 回调函数
 */
- (void)sendCommandMessage:(QHVCITSCommand)cmdType
                  targetId:(NSString *)targetId
                  complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary)complete;

/**
 向指定房间成员发送指令消息
 
 @param roomId 房间ID nil:本房间，否则指定房间
 @param cmdType 指令
 @param targetIdentityArray 目标身份数组,成员只能是主播、嘉宾、观众
 @param complete 回调函数
 */
- (void)sendCommandMessage:(NSString *)roomId
                   cmdType:(QHVCITSCommand)cmdType
       targetIdentityArray:(NSArray *)targetIdentityArray
                   complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary)complete;

@end
