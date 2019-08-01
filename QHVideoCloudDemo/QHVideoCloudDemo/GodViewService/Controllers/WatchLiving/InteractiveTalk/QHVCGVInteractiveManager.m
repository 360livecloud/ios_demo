//
//  QHVCGVInteractiveManager.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/10/23.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCGVInteractiveManager.h"
#import "QHVCGVUserSystem.h"
#import "QHVCGVConfig.h"
#import "QHVCLogger.h"

@interface QHVCGVInteractiveManager()<QHVCInteractiveAutomationDelegate>

@property(nonatomic, weak) id<QHVCGVInteractiveAutomationDelegate> delegate;

@end


@implementation QHVCGVInteractiveManager

+ (instancetype) sharedInstance
{
    static QHVCGVInteractiveManager* s_instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        s_instance = [QHVCGVInteractiveManager new];
    });
    return s_instance;
}

- (int) startAutomaticConversation:(id<QHVCGVInteractiveAutomationDelegate>)delegate
{
    [self setDelegate:delegate];
    QHVCGVUserSystem* userSystem = [QHVCGVUserSystem sharedInstance];
    [QHVCInteractiveKit openLogWithLevel:(QHVCITLLogLevel)[QHVCLogger getLoggerLevel]];//设置日志级别
    [[QHVCInteractiveKit sharedInstance] setPublicServiceInfo:[QHVCGlobalConfig sharedInstance].appId
                                                       appKey:[QHVCGlobalConfig sharedInstance].appKey
                                                     userSign:[[QHVCGVUserSystem sharedInstance] getUserSign]];
    NSMutableDictionary* optionInfoDict = [NSMutableDictionary dictionary];
    [QHVCToolUtils setBooleanToDictionary:optionInfoDict key:@"openVideo" value:[QHVCGVConfig sharedInstance].isRTCOpenVideo];
    [QHVCToolUtils setIntToDictionary:optionInfoDict key:@"dataCollectModel" value:QHVCITLDataCollectModeSDK];
    return [[QHVCInteractiveKit sharedInstance] startAutomaticConversationWithDelegate:delegate
                                                                                roomId:userSystem.roomInfo.roomId
                                                                             channelNo:1
                                                                                userId:userSystem.userInfo.talkId
                                                                       beInvitedUserId:userSystem.roomInfo.deviceTalkId
                                                                        optionInfoDict:optionInfoDict];
}

- (int) stopAutomaticConversation
{
    return [[QHVCInteractiveKit sharedInstance] stopAutomaticConversation];
}

/**
 * 强制停止，释放资源
 */
- (void)destory
{
    [QHVCInteractiveKit destory];
}

- (int) receiveSignalingMessages:(NSString *)message
{
    return [[QHVCInteractiveKit sharedInstance] receiveSignalingMessages:message];
}

#pragma mark - QHVCInteractiveAutomationDelegate -
- (void)interactiveAutomationEngine:(QHVCInteractiveKit *)engine didOccurError:(QHVCITLErrorCode)errorCode
{
    if(_delegate && [_delegate respondsToSelector:@selector(interactiveAutomationEngine:didOccurError:)])
    {
        [_delegate interactiveAutomationEngine:self didOccurError:errorCode];
    }
}

- (void)interactiveAutomationEngine:(QHVCInteractiveKit *)engine didStartAutomaticConversation:(NSString *)channel withUid:(NSString *)uid
{
    if(_delegate && [_delegate respondsToSelector:@selector(interactiveAutomationEngine:didStartAutomaticConversation:withUid:)])
    {
        [_delegate interactiveAutomationEngine:self didStartAutomaticConversation:channel withUid:uid];
    }
}

- (void)interactiveAutomationEngine:(QHVCInteractiveKit *)engine didStopAutomaticConversation:(NSString *)channel withUid:(NSString *)uid
{
    if(_delegate && [_delegate respondsToSelector:@selector(interactiveAutomationEngine:didStopAutomaticConversation:withUid:)])
    {
        [_delegate interactiveAutomationEngine:self didStopAutomaticConversation:channel withUid:uid];
    }
}

- (void)interactiveAutomationEngine:(QHVCInteractiveKit *)engine didSendingSignalingMessage:(NSString *)message toDestId:(NSString *)destId
{
    if(_delegate && [_delegate respondsToSelector:@selector(interactiveAutomationEngine:didSendingSignalingMessage:toDestId:)])
    {
        [_delegate interactiveAutomationEngine:self didSendingSignalingMessage:message toDestId:destId];
    }
}

- (UIView *)interactiveAutomationEngine:(QHVCInteractiveKit *)engine didCreateViewWithUid:(NSString *)uid
{
    if(_delegate && [_delegate respondsToSelector:@selector(interactiveAutomationEngine:didCreateViewWithUid:)])
    {
        return [_delegate interactiveAutomationEngine:self didCreateViewWithUid:uid];
    }
    return nil;
}

@end
