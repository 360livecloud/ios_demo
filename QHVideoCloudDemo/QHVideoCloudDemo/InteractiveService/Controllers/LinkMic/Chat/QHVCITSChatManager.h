//
//  QHVCITSChatManager.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/3/19.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QHVCIMKit/QHVCIM.h>

typedef NS_ENUM(NSInteger, QHVCITSCommand)
{
    QHVCITSCommandAnchorInviteGuest = 10000,//主播邀请观众连麦
    QHVCITSCommandGuestAgreeInvite = 10001,//观众同意主播连麦邀请
    QHVCITSCommandGuestRefuseInvite = 10002,//观众拒绝主播连麦邀请
    
    QHVCITSCommandGuestAskJoin = 10003,//观众发送连麦请求
    QHVCITSCommandAnchorAgreeJoin = 10004,//主播同意连麦请求
    QHVCITSCommandAnchorRefuseJoin = 10005,//主播拒绝连麦请求
    QHVCITSCommandAnchorKickoutGuest = 10006,//主播踢出某个嘉宾
    
    QHVCITSCommandGuestJoinNotify = 20000,//嘉宾进入，发送通知
    QHVCITSCommandAnchorQuitNotify = 20001,//主播退出，发送通知
    QHVCITSCommandGuestQuitNotify = 20002,//嘉宾主动退出，发送通知
    QHVCITSCommandGuestKickoutNotify = 20003,//嘉宾被踢出，发送通知
};

@interface QHVCITSChatManager : NSObject

+ (void)setChatMessageDelegate:(id<QHVCIMMessageDelegate>)delegate;

+ (void)connect:(void (^)(NSString *userId))successBlock
          error:(void (^)(QHVCIMConnectErrorCode status))errorBlock;
+ (void)disconnect;

+ (void)joinChatroom:(NSString *)roomId;
+ (void)quitChatroom:(NSString *)roomId;

+ (void)sendCommandMessage:(QHVCIMConversationType)conversationType
                   cmdType:(QHVCITSCommand)cmdType
                  targetId:(NSString *)targetId
                   success:(void (^)(long messageId))successBlock
                     error:(void (^)(QHVCIMErrorCode errorCode,
                                     long messageId))errorBlock;

+ (NSDictionary *)jsonFormatToDic:(NSData *)data;

@end
