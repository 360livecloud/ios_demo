//
//  QHVCITSChatManager.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/3/19.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCITSChatManager.h"
#import "QHVCITSUserSystem.h"
#import <QHPushSdk/QHPushSdk.h>
#import <QHVCCommonKit/QHVCCommonKit.h>
#import "QHVCLogger.h"
#import "QHVCITSDefine.h"
#import "QHVCITSConfig.h"

@interface QHVCITSChatManager()<QHPushSdkDelegate>

@property (nonatomic, strong) QHVCITSHTTPSessionManager* httpManager;

@end

@implementation QHVCITSChatManager

+ (QHVCITSChatManager *)sharedManager
{
    static dispatch_once_t onceToken;
    static QHVCITSChatManager *_sharedManager;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (void)connectChatServer
{
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_INFO content:@"connectChatServer"];
    _httpManager = [QHVCITSHTTPSessionManager new];
    [QHPushSdk startSdkWithAppKey:QHVCITS_QHPUSH_APPKEY isSupportOpenApi:YES isDev:NO delegate:self];
}

- (void)disconnectChatServer
{
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_INFO content:@"disconnectChatServer"];
    _delegate = nil;
    _httpManager = nil;
    [QHPushSdk stopSdk];
}

- (void)bindAlias:(NSString *)alias
{
    [QHPushSdk bindAlias:alias];
}

- (void)unbindAlias
{
    [QHPushSdk unbindAlias];
}

- (void)sendCommandMessage:(QHVCITSCommand)cmdType
                  targetId:(NSString *)targetId
                   complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary)complete
{
    //准备信令消息体数据
    NSMutableDictionary* muteProtocolDict = [NSMutableDictionary dictionary];
    NSString *currentRoomId = currentRoomId = [QHVCITSUserSystem sharedInstance].roomInfo.roomId;
    NSString *userId = [QHVCITSUserSystem sharedInstance].userInfo.userId;
    [QHVCToolUtils setStringToDictionary:muteProtocolDict key:QHVCITS_KEY_ROOM_ID value:currentRoomId];
    [QHVCToolUtils setStringToDictionary:muteProtocolDict key:QHVCITS_KEY_USER_ID value:userId];
    [QHVCToolUtils setIntToDictionary:muteProtocolDict key:QHVCITS_KEY_CMD value:cmdType];
    [QHVCToolUtils setStringToDictionary:muteProtocolDict key:QHVCITS_KEY_TARGET_ID value:targetId];
    NSData *data = [QHVCToolUtils createJsonDataWithDictionary:muteProtocolDict];
    NSString* dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //准备网络协议数据
    NSMutableDictionary* muteNetDict = [NSMutableDictionary dictionary];
    [QHVCToolUtils setStringToDictionary:muteNetDict key:QHVCITS_KEY_CONTENT value:[QHVCToolUtils urlEncode:dataString]];
    [QHVCToolUtils setStringToDictionary:muteNetDict key:QHVCITS_KEY_TARGET_ID value:targetId];
    [QHVCITSProtocolMonitor sendUserMessage:_httpManager
                                       dict:muteNetDict
                                   complete:complete];
}

- (void)sendCommandMessage:(NSString *)roomId
                   cmdType:(QHVCITSCommand)cmdType
       targetIdentityArray:(NSArray *)targetIdentityArray
                   complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary)complete
{
    //准备信令消息体数据
    NSMutableDictionary* muteProtocolDict = [NSMutableDictionary dictionary];
    NSString *currentRoomId = roomId;
    if ([QHVCToolUtils isNullString:currentRoomId])
    {
        currentRoomId = [QHVCITSUserSystem sharedInstance].roomInfo.roomId;
    }
    NSString *userId = [QHVCITSUserSystem sharedInstance].userInfo.userId;
    [QHVCToolUtils setStringToDictionary:muteProtocolDict key:QHVCITS_KEY_ROOM_ID value:currentRoomId];
    [QHVCToolUtils setStringToDictionary:muteProtocolDict key:QHVCITS_KEY_USER_ID value:userId];
    [QHVCToolUtils setIntToDictionary:muteProtocolDict key:QHVCITS_KEY_CMD value:cmdType];
    NSString* identityString = nil;
    for (NSNumber* tmp in targetIdentityArray)
    {
        if ([QHVCToolUtils isNullString:identityString])
        {
            identityString = [NSString stringWithFormat:@"%d",tmp.intValue];
        }else
        {
            identityString = [NSString stringWithFormat:@"%@,%d",identityString,tmp.intValue];
        }
    }
    [QHVCToolUtils setStringToDictionary:muteProtocolDict key:QHVCITS_KEY_IDENTITY value:identityString];
    NSData *data = [QHVCToolUtils createJsonDataWithDictionary:muteProtocolDict];
    NSString* dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //准备网络协议数据
    NSMutableDictionary* muteNetDict = [NSMutableDictionary dictionary];
    [QHVCToolUtils setStringToDictionary:muteNetDict key:QHVCITS_KEY_CONTENT value:[QHVCToolUtils urlEncode:dataString]];
    [QHVCToolUtils setStringToDictionary:muteNetDict key:QHVCITS_KEY_ROOM_ID value:currentRoomId];
    [QHVCToolUtils setStringToDictionary:muteNetDict key:QHVCITS_KEY_IDENTITY value:identityString];
    [QHVCITSProtocolMonitor sendRoomMessage:_httpManager
                                       dict:muteNetDict
                                   complete:complete];
}

#pragma mark - QHPushSdkDelegate -

/**
 *  SDK登录长连接成功返回clientId
 *  说明：启动QHPushSdk时，SDK会自动用AppKey向个推服务器注册SDK，当成功注册时，SDK通知应用注册成功。
 *  备注：注册成功仅表示推送通道建立，如果deviceToken、alias等验证不通过，依然无法接收到推送消息，请确保验证信息正确。
 *
 *  @param clientId 标识用户的clientId
 */
- (void)qhPushSdkDidRegisterClient:(NSString *)clientId
{
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_INFO content:[NSString stringWithFormat:@"qhPushSdkDidRegisterClient:clientid=%@",clientId]];
    if (_delegate && [_delegate respondsToSelector:@selector(onChatDidRegisterClient:)])
    {
        [_delegate onChatDidRegisterClient:clientId];
    }
}

/**
 *  SDK收到服务端的透传消息数组
 *  备注：
 *  1. msgArray的元素类型是dictionary；
 *  2. dictionary中有3组<key, value>，对应的解析类型分别为<@"msgId", NSString>、<@"appId", NSString>、<@"msgData", NSString>。
 *
 *  @param msgArray 透传消息数组
 */
- (void)qhPushSdkRsvPayloadData:(NSArray *)msgArray
{
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_INFO content:[NSString stringWithFormat:@"qhPushSdkRsvPayloadData:msgArray=%@",msgArray]];
    if (_delegate && [_delegate respondsToSelector:@selector(onChatRsvPayloadData:)])
    {
        [_delegate onChatRsvPayloadData:msgArray];
    }
}

/**
 *  SDK运行状态通知
 *
 *  @param status 返回SDK运行状态
 */
- (void)qhPushSdkDidNotifySdkState:(QHPushSdkStatus)status
{
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_INFO content:[NSString stringWithFormat:@"qhPushSdkDidNotifySdkState:status=%ld",status]];
    if (_delegate && [_delegate respondsToSelector:@selector(onChatDidNotifySdkState:)])
    {
        [_delegate onChatDidNotifySdkState:(QHVCITSChatStatus)status];
    }
}

/**
 *  SDK注册deviceToken回调
 *
 *  @param isSuccess    成功返回 YES, 失败返回 NO
 */
- (void)qhPushSdkDidRegisterDT:(BOOL)isSuccess
{
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_INFO content:[NSString stringWithFormat:@"qhPushSdkDidRegisterDT:isSuccess=%@",[NSNumber numberWithBool:isSuccess]]];
    if (_delegate && [_delegate respondsToSelector:@selector(onChatDidRegisterDT:)])
    {
        [_delegate onChatDidRegisterDT:isSuccess];
    }
}

/**
 *  SDK绑定别名回调
 *
 *  @param type         绑定/解绑别名
 *  @param isSuccess    成功返回 YES, 失败返回 NO
 *  @param error        成功返回nil, 错误返回相应error信息
 */
- (void)qhPushSdkDidAliasAction:(QHPushSdkAliasActionType)type result:(BOOL)isSuccess error:(NSError *)error
{
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_INFO content:[NSString stringWithFormat:@"qhPushSdkDidAliasAction:type = %ld, isSuccess=%@, error = %@", type, [NSNumber numberWithBool:isSuccess], error]];
    if (_delegate && [_delegate respondsToSelector:@selector(onDidAliasAction:result:error:)])
    {
        [_delegate onDidAliasAction:type result:isSuccess error:error];
    }
}

/**
 *  SDK遇到错误消息返回error
 *
 *  @param error    PushSDK内部发生错误
 */
- (void)qhPushSdkDidOccurError:(NSError *)error
{
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_INFO content:[NSString stringWithFormat:@"qhPushSdkDidOccurError:error=%@",error]];
    if (_delegate && [_delegate respondsToSelector:@selector(onChatDidOccurError:)])
    {
        [_delegate onChatDidOccurError:error];
    }
}

@end
