//
//  QHVCITSGuestViewController.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/3/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCITSLinkMicViewController.h"
#import "QHVCITSProtocolMonitor.h"
#import "QHVCITSLog.h"
#import "QHVCITSUserSystem.h"
#import "QHVCITSRoomUserListView.h"
#import "QHVCITSChatManager.h"
#import "UIView+Toast.h"
#import "UIViewAdditions.h"
#import "QHVCITRoleView.h"
#import "QHVCITSRoomUserListView.h"
#import "QHVCITSLinkMicViewController+Control.h"
#import "QHVCITSLinkMicViewController+Hongpa.h"
#import "QHVCConfig.h"
#import "QHVCInteractiveViewController.h"
#import "QHVCToast.h"
#import <QHVCLiveKit/QHVCLiveKit.h>

@interface QHVCITSVideoCompositingLayout : NSObject

@property (assign, nonatomic) NSInteger canvasWidth;
@property (assign, nonatomic) NSInteger canvasHeight;
@property (copy, nonatomic, nullable) UIColor* backgroundColor;
@property (retain, nonatomic, nonnull) NSMutableArray<QHVCITLVideoCompositingRegion *>* regions;

@end

@implementation QHVCITSVideoCompositingLayout

@end

@interface QHVCITSLinkMicViewController ()<QHVCIMMessageDelegate,UIAlertViewDelegate,QHVCInteractiveDelegate, QHVCInteractiveVideoFrameDelegate, QHVCInteractiveAudioFrameDelegate, QHVCLiveKitDelegate>
{
    IBOutlet UIView *_preview;
    IBOutlet UILabel *_roomName;
    IBOutlet UILabel *_roomIdLabel;
    IBOutlet UILabel *_anchorIdLabel;
    IBOutlet UILabel *_onlineCount;
    IBOutlet UITextView *_infoTextView;
    IBOutlet UIButton *_interactiveBtn;
    IBOutlet UIImageView *_audioOnlyImageView;
    QHVCITSRoomUserListView *_userListView;
    QHVCITSRoomUserListView *_audioGuestListView;
    QHVCLive *_liveEngine;
    QHVCITSIdentity _expectedRole;
}

@property (nonatomic, strong) QHVCITSHTTPSessionManager* httpManager;
@property (nonatomic, strong, nullable) QHVCITSVideoCompositingLayout* mixStreamVideoLayout;//合流布局对象
@property (nonatomic, strong) NSTimer* heartbeatTimer;//心跳监测定时器
@property (nonatomic, strong) NSTimer* updateRoomListTimer;//更新房间列表定时器

@end

@implementation QHVCITSLinkMicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _openSpeakerphone = YES;
    _openFrontCamera = YES;
    _muteMicrophone = NO;
    _muteLocalVideo = NO;
    _muteAllRemoteVideo = NO;
    
    //初始化UI相关对象
    [self setInteractiveBtnTitle];
    [self initActionCollectionView];
    [self updateRoomUIInfo];
    
    if ([QHVCITSUserSystem sharedInstance].roomInfo.roomType == QHVCITS_Room_Type_Party) {
        _hongpaTableView.hidden = NO;
        [_preview bringSubviewToFront:_hongpaTableView];
    }
    //创建全局变量
    _httpManager = [QHVCITSHTTPSessionManager new];
    _videoSessionArray = [NSMutableArray array];
    
    //无论那种方式进入房间，首先获取房间信息，根据房间信息返回结果处理相关流程
    [self prepareForRoomInfo];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

#pragma mark - UI Action -

- (IBAction)closeBtnAction:(UIButton *)sender
{
    [self leavelChannel];
}

- (IBAction)debugRoomInfo:(UIButton *)sender
{
    NSDictionary *infos = @{@"roomId":[QHVCITSUserSystem sharedInstance].roomInfo.roomId,
                            @"sdk_ver":[QHVCInteractiveKit getVersion]
                            };
    _infoTextView.text = infos.description;
}

- (IBAction)debugNetworkInfo:(UIButton *)sender
{
    _infoTextView.text = @"";
}

- (IBAction)interactiveBtnAction:(UIButton *)sender//互动申请
{
    QHVCITSIdentity identity = [[QHVCITSUserSystem sharedInstance] userInfo].identity;
    NSString *currentUserId = [[QHVCITSUserSystem sharedInstance] userInfo].userId;
    
    if ([currentUserId isEqualToString:[QHVCITSUserSystem sharedInstance].roomInfo.bindRoleId]) {
        [self inviteGuest];
    }
    else
    {
        if(identity == QHVCITS_Identity_Audience)
        {
            [self applyLinkmic];
        }
        else
        {
            [self endLinkmic];
        }
    }
}

- (void)inviteGuest
{
    if (_userListView)
    {
        [_userListView removeFromSuperview];
        _userListView = nil;
    } else
    {
        WEAK_SELF_LINKMIC
        NSString* roleType = [NSString stringWithFormat:@"%ld",QHVCITS_Identity_Guest];//嘉宾邀请目前只显示嘉宾信息
        [self sendFetchRoomInteractiveRoleList:roleType complete:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable dict) {
            STRONG_SELF_LINKMIC
            if (success)
            {
                NSArray* array = [QHVCToolUtils getObjectFromDictionary:dict key:QHVCITS_KEY_DATA defaultValue:nil];
                [self showUserList:array];
            }else
            {
                [QHVCToast makeToast:@"请求嘉宾列表失败"];
            }
        }];
    }
}

- (void)showUserList:(NSArray *)array
{
    _userListView = [[NSBundle mainBundle] loadNibNamed:[[QHVCITSRoomUserListView class] description] owner:self options:nil][0];
    _userListView.frame = CGRectMake(15, 130, self.view.width - 30, 220);
    [_controlView addSubview:_userListView];
    [_userListView setUsersData:array];
    
    WEAK_SELF_LINKMIC
    _userListView.kickoutCompletion = ^(NSString *guestId) {
        STRONG_SELF_LINKMIC
        [self anchorKickoutGuest:guestId];
        [self inviteGuest];
    };
}

- (void)applyLinkmic
{
    NSString* bindRoleId = [[QHVCITSUserSystem sharedInstance] roomInfo].bindRoleId;
    
    if (![bindRoleId isEqualToString:@"0"])
    {
        [QHVCITSChatManager sendCommandMessage:QHVCIMConversationTypePrivate cmdType:QHVCITSCommandGuestAskJoin targetId:bindRoleId success:^(long messageId) {
            [QHVCToast makeToast:@"加入互动请求已发送"];
        } error:^(QHVCIMErrorCode errorCode, long messageId) {
            [QHVCToast makeToast:@"请求发送失败，请稍后再试"];
        }];
    }
    else//hongpa模式
    {
        _expectedRole = QHVCITS_Identity_Anchor;
        [self setClientRoleIdentity:QHVCITS_Identity_Anchor];
    }
}

- (void)endLinkmic
{
    _expectedRole = QHVCITS_Identity_Audience;
    [self setClientRoleIdentity:QHVCITS_Identity_Audience];
}

- (void) changeRoleIdentity:(QHVCITSIdentity)expectedRole
{
    WEAK_SELF_LINKMIC
    [self sendChangeRoleIdentity:expectedRole complete:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable dict) {
        STRONG_SELF_LINKMIC
        if (success)
        {
            QHVCITSUserModel* userInfo = [[QHVCITSUserSystem sharedInstance] userInfo];
            QHVCITSRoomModel* roomInfo = [[QHVCITSUserSystem sharedInstance] roomInfo];
            userInfo.identity = expectedRole;
            
            if (expectedRole == QHVCITS_Identity_Audience) {
                [QHVCToast makeToast:@"退出连麦成功"];
                [QHVCITSChatManager sendCommandMessage:QHVCIMConversationTypeChartroom cmdType:QHVCITSCommandGuestQuitNotify targetId:roomInfo.roomId success:nil error:nil];
            }
            else
            {
                [QHVCToast makeToast:@"连麦成功"];
                [QHVCITSChatManager sendCommandMessage:QHVCIMConversationTypeChartroom cmdType:QHVCITSCommandGuestJoinNotify targetId:roomInfo.roomId success:nil error:nil];
            }
            [self setInteractiveBtnTitle];
            [self updateControlView:roomInfo.talkType];
            [self updateRoomRoleList];
        }
        else
        {
            NSString* errMsg = [QHVCToolUtils getStringFromDictionary:dict key:QHVCITS_KEY_ERROR_MESSAGE defaultValue:@"申请互动改变身份失败"];
            [QHVCToast makeToast:errMsg];
        }
    }];
}

//以下部分是SDK接入实现部分
#pragma mark - QHVCInteractiveDelegate -

/**
 发生警告回调
 该回调方法表示SDK运行时出现了（网络或媒体相关的）警告。通常情况下，SDK上报的警告信息应用程序可以忽略，SDK会自动恢复。
 
 @param engine 引擎对象
 @param warningCode 警告代码
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine didOccurWarning:(QHVCITLWarningCode)warningCode;
{
    [QHVCITSLog printLogger:QHVCITS_LOG_LEVEL_WARN content:[NSString stringWithFormat:@"didOccurWarning:%ld",warningCode]];
}

/**
 本地推流端发生错误回调
 该回调方法表示SDK运行时出现了（网络或媒体相关的）错误。通常情况下，SDK上报的错误意味着SDK无法自动恢复，需要应用程序干预或提示用户。比如启动通话失败时，SDK会上报QHVCITL_Error_StartCall(1002)错误。应用程序可以提示用户启动通话失败，并调用leaveChannel退出频道。
 
 @param engine 引擎对象
 @param errorCode 错误代码
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine didOccurError:(QHVCITLErrorCode)errorCode;
{
    [QHVCITSLog printLogger:QHVCITS_LOG_LEVEL_ERROR content:[NSString stringWithFormat:@"didOccurError:%ld",errorCode]];
    [self receiveLinkMicSDKError:errorCode];
}

/**
 加载互动直播引擎数据成功回调
 该回调方法表示SDK加载引擎数据成功。该回调成功后，业务可以进行一系列参数的设置，之后调用joinChannel以及后续操作。
 
 @param engine 引擎对象
 @param dataDict 参数字典，将会返回业务所需的必要信息
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine didLoadEngineData:(nullable NSDictionary *)dataDict;
{
    [self joinChannel];
}

/**
 音量提示回调
 提示谁在说话及其音量，默认禁用。可通过enableAudioVolumeIndication方法设置。
 
 @param engine 引擎对象
 @param speakers 说话者（数组）。每个speaker()：uid: 说话者的用户ID,volume：说话者的音量（0~255）
 @param totalVolume 混音后的）总音量（0~255）
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine reportAudioVolumeIndicationOfSpeakers:(nullable NSArray *)speakers totalVolume:(NSInteger)totalVolume;
{
    
}

/**
 本地首帧视频显示回调
 提示第一帧本地视频画面已经显示在屏幕上。
 
 @param engine 引擎对象
 @param size 视频流尺寸（宽度和高度）
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine firstLocalVideoFrameWithSize:(CGSize)size;
{
    [QHVCITSLog printLogger:QHVCITS_LOG_LEVEL_INFO content:[NSString stringWithFormat:@"firstLocalVideoFrameWithSize:%@",NSStringFromCGSize(size)]];
}

/**
 远端首帧视频接收解码回调
 提示已收到第一帧远程视频流并解码。
 
 @param engine 引擎对象
 @param uid 用户ID，指定是哪个用户的视频流
 @param size 视频流尺寸（宽度和高度）
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine firstRemoteVideoDecodedOfUid:(nonnull NSString *)uid size:(CGSize)size;
{
    [QHVCITSLog printLogger:QHVCITS_LOG_LEVEL_INFO content:[NSString stringWithFormat:@"firstRemoteVideoDecodedOfUid:%@, size:%@",uid,NSStringFromCGSize(size)]];
}

/**
 本地或远端用户更改视频大小的事件
 
 @param engine 引擎对象
 @param uid 用户ID
 @param size 视频新Size
 @param rotation 视频新的旋转角度
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine videoSizeChangedOfUid:(nonnull NSString *)uid size:(CGSize)size rotation:(NSInteger)rotation;
{
    [QHVCITSLog printLogger:QHVCITS_LOG_LEVEL_INFO content:[NSString stringWithFormat:@"videoSizeChangedOfUid:%@,size:%@,rotation:%ld",uid,NSStringFromCGSize(size),rotation]];
}

/**
 远端首帧视频显示回调
 提示第一帧远端视频画面已经显示在屏幕上。
 如果是主播推混流，这里需要在回调里面强制更新一下混流布局配置:
 setVideoCompositingLayout:(QHVCITLVideoCompositingLayout*)layout;
 
 @param engine 引擎对象
 @param uid 用户ID，指定是哪个用户的视频流
 @param size 视频流尺寸（宽度和高度）
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine firstRemoteVideoFrameOfUid:(nonnull NSString *)uid size:(CGSize)size;
{
    [QHVCITSLog printLogger:QHVCITS_LOG_LEVEL_INFO content:[NSString stringWithFormat:@"firstRemoteVideoFrameOfUid:%@,size:%@",uid,NSStringFromCGSize(size)]];
}


/**
 用户加入回调
 提示有用户加入了频道。如果该客户端加入频道时已经有人在频道中，SDK也会向应用程序上报这些已在频道中的用户。
 
 @param engine 引擎对象
 @param uid 用户ID，如果joinChannel中指定了uid，则此处返回该ID；否则使用连麦服务器自动分配的ID。
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine didJoinedOfUid:(nonnull NSString *)uid;
{
    
}

/**
 某个用户离线回调
 提示有用户离开了频道（或掉线）。
 
 @param engine 引擎对象
 @param uid 用户ID
 @param reason 离线原因
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine didOfflineOfUid:(nonnull NSString *)uid reason:(QHVCITLUserOfflineReason)reason;
{
    [QHVCITSLog printLogger:QHVCITS_LOG_LEVEL_INFO content:[NSString stringWithFormat:@"didOfflineOfUid:%@,reason:%ld",uid,reason]];
    
    [QHVCToast makeToast:[NSString stringWithFormat:@"userId %@离开了频道，reason %@",uid,@(reason)]];
    
    //主播掉线-走主播退出房间流程
    if ([uid isEqualToString:[QHVCITSUserSystem sharedInstance].roomInfo.bindRoleId]&&
        (reason == QHVCITL_UserOffline_Quit||QHVCITL_UserOffline_Dropped)) {
        [self anchorQuitNotify];
    }
}

/**
 用户音频静音回调
 提示有用户用户将通话静音/取消静音。
 
 @param engine 引擎对象
 @param muted Yes:静音, No:取消静音
 @param uid 用户ID
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine didAudioMuted:(BOOL)muted byUid:(nonnull NSString *)uid;
{
    
}

/**
 用户停止/重新发送视频回调
 提示有其他用户暂停发送/恢复发送其视频流。
 
 @param engine 引擎对象
 @param muted Yes：该用户已暂停发送其视频流 No：该用户已恢复发送其视频流
 @param uid 用户ID
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine didVideoMuted:(BOOL)muted byUid:(nonnull NSString *)uid;
{
    
}

/**
 音频路由改变
 
 @param engine 引擎对象
 @param routing 新的输出设备
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine didAudioRouteChanged:(QHVCITLAudioOutputRouting)routing;
{
    
}

/**
 用户启用/关闭视频回调
 提示有其他用户启用/关闭了视频功能。关闭视频功能是指该用户只能进行语音通话，不能显示、发送自己的视频，也不能接收、显示别人的视频。
 
 @param engine 引擎对象
 @param enabled Yes：该用户已启用了视频功能 No：该用户已关闭了视频功能
 @param uid 用户ID
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine didVideoEnabled:(BOOL)enabled byUid:(nonnull NSString *)uid;
{
    
}

/**
 本地视频统计回调
 报告更新本地视频统计信息，该回调方法每两秒触发一次。
 
 @param engine 引擎对象
 @param stats sentBytes（上次统计后）发送的字节数 sentFrames（上次统计后）发送的帧数
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine localVideoStats:(nonnull QHVCITLLocalVideoStats *)stats;
{
    
}

/**
 远端视频统计回调
 报告更新远端视频统计信息，该回调方法每两秒触发一次。
 
 @param engine 引擎对象
 @param stats 统计信息
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine remoteVideoStats:(nonnull QHVCITLRemoteVideoStats *)stats;
{
    
}

/**
 摄像头启用回调
 提示已成功打开摄像头，可以开始捕获视频。
 
 @param engine 引擎对象
 */
- (void)interactiveEngineCameraDidReady:(nonnull QHVCInteractiveKit *)engine;
{
    
}

/**
 视频功能停止回调
 提示视频功能已停止。应用程序如需在停止视频后对view做其他处理（比如显示其他画面），可以在这个回调中进行。
 
 @param engine 引擎对象
 */
- (void)interactiveEngineVideoDidStop:(nonnull QHVCInteractiveKit *)engine;
{
    
}

/**
 本地网络连接中断回调
 在SDK和服务器失去了网络连接时，触发该回调。失去连接后，除非APP主动调用leaveChannel，SDK会一直自动重连。
 
 @param engine 引擎对象
 */
- (void)interactiveEngineConnectionDidInterrupted:(nonnull QHVCInteractiveKit *)engine;
{
    
}

/**
 本地网络连接丢失回调
 在SDK和服务器失去了网络连接后，会触发interactiveEngineConnectionDidInterrupted回调，并自动重连。在一定时间内（默认10秒）如果没有重连成功，触发interactiveEngineConnectionDidLost回调。除非APP主动调用leaveChannel，SDK仍然会自动重连。
 
 @param engine 引擎对象
 */
- (void)interactiveEngineConnectionDidLost:(nonnull QHVCInteractiveKit *)engine;
{
    
}

/**
 加入频道成功回调
 该回调方法表示该客户端成功加入了指定的频道。
 
 @param engine 引擎对象
 @param channel 频道名
 @param uid 用户ID
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine didJoinChannel:(nonnull NSString *)channel withUid:(nonnull NSString *)uid;
{
    [QHVCITSLog printLogger:QHVCITS_LOG_LEVEL_INFO content:[NSString stringWithFormat:@"didJoinChannel %@ uid:%@",channel,uid]];
    [self receiveJoinChannelSucess];
}

/**
 重新加入频道回调
 有时候由于网络原因，客户端可能会和服务器失去连接，SDK会进行自动重连，自动重连成功后触发此回调方法，提示有用户重新加入了频道，且频道ID和用户ID均已分配。
 
 @param engine 引擎对象
 @param channel 频道名
 @param uid 用户ID
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine didRejoinChannel:(nonnull NSString *)channel withUid:(nonnull NSString *)uid;
{
    
}

/**
 统计数据回调
 该回调定期上报Interactive Engine的运行时的状态，每两秒触发一次。
 
 @param engine 引擎对象
 @param stats 统计值
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine reportStats:(nonnull QHVCITLChannelStats *)stats;
{
    
}

/**
 用户主动离开频道回调
 
 @param engine 引擎对象
 @param stats 本次通话数据统计，包括时长、发送和接收数据量等
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine didLeaveChannelWithStats:(nullable QHVCITLChannelStats *)stats;
{
    [self didLeaveChannelSucess];
}

/**
 语音质量回调
 在通话中，该回调方法每两秒触发一次，报告当前通话的（嘴到耳）音频质量。
 
 @param engine 引擎对象
 @param uid 用户ID
 @param quality 声音质量评分
 @param delay 延迟（毫秒）
 @param lost 丢包率（百分比）
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine audioQualityOfUid:(nonnull NSString *)uid quality:(QHVCITLQuality)quality delay:(NSUInteger)delay lost:(NSUInteger)lost;
{
    
}

/**
 频道内网络质量报告回调
 该回调定期触发，向APP报告频道内通话中用户当前的上行、下行网络质量。
 
 @param engine 引擎对象
 @param uid 用户ID。表示该回调报告的是持有该ID的用户的网络质量。当uid为0时，返回的是本地用户的网络质量。当前版本仅报告本地用户的网络质量。
 @param txQuality 该用户的上行网络质量。
 @param rxQuality 该用户的下行网络质量。
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine networkQuality:(nonnull NSString *)uid txQuality:(QHVCITLQuality)txQuality rxQuality:(QHVCITLQuality)rxQuality;
{
    
}

/**
 抓取视频截图回调
 该回调方法由takeStreamSnapshot触发，返回的是对应uid当前流的图像
 
 @param engine 引擎对象
 @param img 截图对象
 @param uid 用户ID
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine takeStreamSnapshot:(nonnull CGImageRef)img uid:(nonnull NSString *)uid;
{
    
}

/**
 上下麦回调
 直播场景下，当用户上下麦时会触发此回调，即主播切换为观众时，或观众切换为主播时。
 
 @param engine 引擎对象
 @param oldRole 切换前的角色
 @param newRole 切换后的角色
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine didClientRoleChanged:(QHVCITLClientRole)oldRole newRole:(QHVCITLClientRole)newRole
{
    [self changeRoleIdentity:_expectedRole];
}

#pragma mark - QHVCInteractiveVideoFrameDelegate -

/**
 创建一个CVPixelBufferRef对象的内存地址给SDK，接收到的图像将会存放到这个对象上，然后调用renderPixelBuffer方法进行通知
 
 @param engine 引擎对象
 @param width 视频宽
 @param height 视频高
 @param stride stride值
 */
- (nonnull CVPixelBufferRef)interactiveEngine:(nonnull QHVCInteractiveKit *)engine createInputBufferWithWidth:(int)width height:(int)height stride:(int)stride;
{
    return nil;
}

/**
 远端视频数据拷贝完毕后进行回调，通知业务进行渲染
 
 @param engine 引擎对象
 @param uid 用户ID
 @param pixelBuffer 视频对象，数据为一个CVPixelBufferRef对象
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine renderPixelBuffer:(nonnull NSString *)uid pixelBuffer:(nonnull CVPixelBufferRef)pixelBuffer;
{
    
}

#pragma mark - QHVCInteractiveAudioFrameDelegate -

/**
 该方法获取本地采集的音频数据，可以在此时机处理前置声音效果。
 
 @param audioFrame 声音数据
 */
- (void)onRecordLocalAudioFrame:(nonnull QHVCITLAudioFrame *)audioFrame;
{
    
}

/**
 该方法获取上行、下行所有数据混音后的数据。
 
 @param audioFrame 声音数据
 */
- (void)onMixedAudioFrame:(nonnull QHVCITLAudioFrame *)audioFrame;
{
    
}

#pragma mark - QHVCLiveKitDelegate -
- (void)onVideoCaptureBuffer:(CMSampleBufferRef _Nullable )buffer
{
    QHVCInteractiveKit* engineKit = [QHVCInteractiveKit sharedInstance];
    CFRetain(buffer);
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(buffer);
    [engineKit incomingCollectingCapturedData:imageBuffer timeStamp:CMTimeMake(CACurrentMediaTime() * 1000, 15)];
    CFRelease(buffer);
}

#pragma mark - 加入房间流程 -

//更新房间信息，判断房间是否存在
- (void) prepareForRoomInfo
{
    WEAK_SELF_LINKMIC
    [self sendFetchRoomInfo:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable dict) {
        STRONG_SELF_LINKMIC
        if (success)
        {
            QHVCITSRoomModel* roomInfo = [[QHVCITSUserSystem sharedInstance] roomInfo];
            NSDictionary* dataDict = [QHVCToolUtils getObjectFromDictionary:dict key:QHVCITS_KEY_DATA defaultValue:nil];
            [roomInfo parseServerData:dataDict];
            [self updateRoomUIInfo];
            [self initInteractiveEngineKit];
        }else
        {
            NSString* errMsg = [QHVCToolUtils getStringFromDictionary:dict key:QHVCITS_KEY_ERROR_MESSAGE defaultValue:nil];
            [QHVCToast makeToast:errMsg];
            [self forceLeaveRoom];
        }
    }];
}

//准备互动直播需要的信息，根据返回结果处理：连麦引擎初始化、启动IM
- (void) joinBusinessServerRoom:(QHVCITSProtocolMonitorDataCompleteWithDictionary)complete
{
    QHVCITSUserModel* userInfo = [[QHVCITSUserSystem sharedInstance] userInfo];
    QHVCITSRoomModel* roomInfo = [[QHVCITSUserSystem sharedInstance] roomInfo];
    if ([QHVCToolUtils isNullString:roomInfo.roomId])
    {
        [QHVCToast makeToast:@"房间ID为空"];
        [self forceLeaveRoom];
        return;
    }
    if ([QHVCToolUtils isNullString:userInfo.userId])
    {
        [QHVCToast makeToast:@"用户ID为空"];
        [self forceLeaveRoom];
        return;
    }
    if (userInfo.identity == QHVCITS_Identity_Anchor) {
        if (complete) {
            complete(nil,YES,nil);
        }
        return;
    }
    //观众身份发送加入业务房间指令，根据服务器返回的实际信息更新本地业务信息
    WEAK_SELF_LINKMIC
    [self sendJoinBusinessServerRoom:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable dict) {
        STRONG_SELF_LINKMIC
        if (success)
        {
            QHVCITSUserModel* userInfo = [[QHVCITSUserSystem sharedInstance] userInfo];
            NSDictionary* dataDict = [QHVCToolUtils getObjectFromDictionary:dict key:QHVCITS_KEY_DATA defaultValue:nil];
            QHVCITSIdentity identity = [QHVCToolUtils getIntFromDictionary:dataDict key:QHVCITS_KEY_IDENTITY defaultValue:userInfo.identity];
            userInfo.identity = identity;
            [self updateRoomUIInfo];
            if (complete) {
                complete(nil,YES,nil);
            }
        }else
        {
            NSString* errMsg = [QHVCToolUtils getStringFromDictionary:dict key:QHVCITS_KEY_ERROR_MESSAGE defaultValue:nil];
            [QHVCToast makeToast:errMsg];
            [self forceLeaveRoom];
        }
    }];
}

/**
 初始化互动直播引擎数据
 */
- (void)initInteractiveEngineKit
{
    NSString* userSign = [[QHVCITSUserSystem sharedInstance] getUserSign];
    [QHVCInteractiveKit openLogWithLevel:QHVCITL_LOG_LEVEL_DEBUG];//设置日志级别
    [[QHVCInteractiveKit sharedInstance] enableTestEnvironment:[QHVCITSConfig sharedInstance].enableTestEnvironment];//设置测试环境
    [[QHVCInteractiveKit sharedInstance] setPublicServiceInfo:[[QHVCITSConfig sharedInstance] channelId]
                                                       appKey:[[QHVCITSConfig sharedInstance] appKey]
                                                     userSign:userSign];
    
    [[QHVCITSConfig sharedInstance] setBypassLiveCDNUseSDKService:YES];
    //如果用户需要使用视频云的CDN服务，请在这里请求CDN服务流程，之后再把相关数据带给SDK
    if([[QHVCITSConfig sharedInstance] bypassLiveCDNUseSDKService])
    {
        [self prepareForBypassLiveInfo];
    }else
    {
        [self loadingEngineData:nil];
    }
}


/**
 加载连麦引擎
 */
- (void)loadingEngineData:(NSDictionary *)optionDict
{
    //如果是需要视频外部渲染处理，需要在此处提前设置启动参数
    
    NSString* roomId = [[QHVCITSUserSystem sharedInstance] roomInfo].roomId;
    NSString* userId = [[QHVCITSUserSystem sharedInstance] userInfo].userId;
    NSString* sessionId = [NSString stringWithFormat:@"session_%@_%@_%@_%lld",[[QHVCITSConfig sharedInstance] channelId],roomId,userId,[QHVCToolUtils getCurrentDateBySecond]];
    [[QHVCInteractiveKit sharedInstance] loadEngineDataWithDelegate:self
                                                             roomId:roomId
                                                             userId:userId
                                                          sessionId:sessionId
                                                   dataCollectModel:[[QHVCITSConfig sharedInstance] dataCollectMode]
                                                     optionInfoDict:optionDict];
}

//添加本地会话对象
- (QHVCITSVideoSession *)addLocalSession:(QHVCITSIdentity)identity
{
    NSString* userId = [[QHVCITSUserSystem sharedInstance] userInfo].userId;
    UIView* view = [self createBroadcasterView:userId identity:identity];
    QHVCITSVideoSession *localSession = [[QHVCITSVideoSession alloc] initWithUid:userId view:view];
    [self.videoSessionArray addObject:localSession];
    
    if ([QHVCITSUserSystem sharedInstance].roomInfo.roomType == QHVCITS_Room_Type_Party)
    {
        [_hongpaTableView reloadData];
    } else
    {
        if (identity == QHVCITS_Identity_Anchor)
        {
            [_preview insertSubview:localSession.videoView atIndex:0];
        } else if (identity == QHVCITS_Identity_Guest)
        {
            [_preview addSubview:localSession.videoView];
        }
    }
    return localSession;
}

//加入连麦频道
- (int)joinChannel
{
    QHVCInteractiveKit* engineKit = [QHVCInteractiveKit sharedInstance];
    [engineKit setChannelProfile:QHVCITL_ChannelProfile_LiveBroadcasting];
    [engineKit enableAudioVolumeIndication:1000 smooth:3];
    QHVCITSIdentity identity = [[QHVCITSUserSystem sharedInstance] userInfo].identity;
    [self setClientRoleIdentity:identity];
    int code = [engineKit joinChannel];
    if (code != QHVCITL_Error_NoError)
    {
        [self leavelChannel];
    }
    return code;
}

- (void) setClientRoleIdentity:(QHVCITSIdentity)identity
{
    QHVCInteractiveKit* engineKit = [QHVCInteractiveKit sharedInstance];
    QHVCITSTalkType talkType = [[QHVCITSUserSystem sharedInstance] roomInfo].talkType;
    if (identity == QHVCITS_Identity_Audience)
    {
        [self endVideoCompositingTask];
        [engineKit setClientRole:QHVCITL_ClientRole_Audience];
        if (talkType == QHVCITS_Talk_Type_Audio)
        {
            //TODO:暂时未做
        }else
        {
            [engineKit enableVideo];
            [engineKit enableAudio];
            [engineKit setEnableSpeakerphone:NO];
            [engineKit enableLocalVideo:NO];
            QHVCITLDataCollectMode dataCollectMode = [[QHVCITSConfig sharedInstance] dataCollectMode];
            QHVCITSUserModel* userInfo = [[QHVCITSUserSystem sharedInstance] userInfo];
            QHVCITSVideoSession* deleteSession = [self fetchSessionOfUid:userInfo.userId];
            [self removeVideoSession:deleteSession];
            if(dataCollectMode == QHVCITLDataCollectModeSDK)
            {
                [engineKit stopPreview];
            }else if (dataCollectMode == QHVCITLDataCollectModeUser)
            {
                [engineKit closeCollectingData];
                [self QHVCLiveSDKStopPreview];
            }
        }
    }else
    {
        //设置合流信息
        [self settingMergeData];
        //设置连麦引擎其它参数
        [engineKit setClientRole:QHVCITL_ClientRole_Broadcaster];
        if (talkType == QHVCITS_Talk_Type_Audio)
        {
            //TODO:暂时未做
        }else
        {
            [engineKit enableAudio];
            [engineKit enableVideo];
            [engineKit enableDualStreamMode:YES];
            [engineKit setEnableSpeakerphone:YES];
            [engineKit enableLocalVideo:YES];
            if (identity == QHVCITS_Identity_Anchor) {
                [engineKit setVideoProfile:[QHVCITSConfig sharedInstance].videoEncoderProfile swapWidthAndHeight:NO];
            }
            else if(identity == QHVCITS_Identity_Guest)
            {
                [engineKit setVideoProfile:[QHVCITSConfig sharedInstance].videoEncoderProfileForGuest swapWidthAndHeight:NO];
            }
            
            [engineKit setLowStreamVideoProfile:180 height:320 fps:15 bitrate:200];
            QHVCITLDataCollectMode dataCollectMode = [[QHVCITSConfig sharedInstance] dataCollectMode];
            if(dataCollectMode == QHVCITLDataCollectModeSDK)
            {
                QHVCITSVideoSession* localSession = [self addLocalSession:identity];
                [engineKit setupLocalVideo:localSession.canvas];
                [engineKit setLocalRenderMode:[QHVCITSConfig sharedInstance].videoViewRenderMode];
                [engineKit startPreview];
            }else if (dataCollectMode == QHVCITLDataCollectModeUser)
            {//初始化本地SDK
                QHVCITSVideoSession* localSession = [self addLocalSession:identity];
                [self QHVCLiveSDKStartPreview:localSession];
                [engineKit openCollectingData];
            }
        }
    }
}

//角色已经成功加入频道,可以考虑把相关UI的遮罩去掉
- (void) receiveJoinChannelSucess
{
    QHVCITSRoomModel* roomInfo = [[QHVCITSUserSystem sharedInstance] roomInfo];
    WEAK_SELF_LINKMIC
    [self joinBusinessServerRoom:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable dict) {
        STRONG_SELF_LINKMIC
        //启动信令系统
        [self joinChatroom:roomInfo.roomId];
        //启动心跳
        [self startHeartbeatTimer];
        //启动定时刷新房间列表
        [self startUpdateRoomListTimer];
    }];
}

//处理连麦SDK的错误码
- (void) receiveLinkMicSDKError:(QHVCITLErrorCode)errorCode
{
    if (errorCode == QHVCITL_Error_Authentication) {
        [self returnToLogin];
    } else
    {
        [self leavelRoom];
    }
}

//启动预览
- (void) QHVCLiveSDKStartPreview:(QHVCITSVideoSession *)localSession
{
    _liveEngine = [QHVCLive sharedInstance];
    _liveEngine.liveDelegate = self;
    
    [_liveEngine setCameraOutputResolution:QHVCLiveOutputPreset1280x720];
    
    [_liveEngine encoderSwitch:NO];
    [_liveEngine setVideoEncoderFPS:15];
//    [_liveEngine setVideoEncoderBitrate:500];
//    [_liveEngine setVideoEncoderKeyframeInterval:2];
//    [_liveEngine setVideoEncoderResolution:CGSizeMake(720, 1280)];
    
    [_liveEngine setPreviewView:localSession.videoView];
    [_liveEngine setFrontCameraMirrored:YES];
    [_liveEngine startCapture];
    if (1)
    {
        [_liveEngine setVideoOrientation:QHVCLiveVideoOrientationPortrait];
    }
}

//停止预览
- (void) QHVCLiveSDKStopPreview
{
    _liveEngine.liveDelegate = nil;
    [_liveEngine stopCapture];
    _liveEngine = nil;
}

#pragma mark - 旁路直播信息准备 -

- (void) prepareForBypassLiveInfo
{
    QHVCITSUserSystem* userSystem = [QHVCITSUserSystem sharedInstance];
    QHVCITSConfig* config = [QHVCITSConfig sharedInstance];
    NSString* streamId = [NSString stringWithFormat:@"%@_%@_%@_%@_%lld",config.businessId, config.channelId, userSystem.roomInfo.roomId, userSystem.userInfo.userId, [QHVCToolUtils getCurrentDateByMilliscond]];
    NSString* publishUrl = [NSString stringWithFormat:@"rtmp://ps0.live.huajiao.com/live_huajiao_v2/%@",streamId];
    NSString* pullUrl = [NSString stringWithFormat:@"http://pl0.live.huajiao.com/live_huajiao_v2/%@.flv",streamId];
    NSLog(@"prepareForBypassLiveInfo publishUrl= %@,pullUrl = %@",publishUrl,pullUrl);
    NSMutableDictionary* infoDict = [NSMutableDictionary dictionary];
    [QHVCToolUtils setStringToDictionary:infoDict key:@"pull_addr" value:pullUrl];
    [QHVCToolUtils setStringToDictionary:infoDict key:@"push_addr" value:publishUrl];
    [QHVCITSLog printLogger:QHVCITS_LOG_LEVEL_INFO content:@"prepareForBypassLiveInfo" dict:infoDict];
    [self loadingEngineData:infoDict];
}

#pragma mark - 合流任务相关实现 -

- (void) settingMergeData
{
    QHVCITLMixerPublisherConfiguration* mixStreamConfig = [QHVCITLMixerPublisherConfiguration new];
    QHVCITSUserSystem* userSystem = [QHVCITSUserSystem sharedInstance];
    QHVCITSConfig* config = [QHVCITSConfig sharedInstance];
    NSString* streamId = [NSString stringWithFormat:@"%@_%@_%@_%@_%lld",config.businessId, config.channelId, userSystem.roomInfo.roomId, userSystem.userInfo.userId, [QHVCToolUtils getCurrentDateByMilliscond]];
    mixStreamConfig.publishUrl = [NSString stringWithFormat:@"rtmp://ps0.live.huajiao.com/live_huajiao_v2/%@",streamId];
    NSLog(@"settingMergeData mixStreamConfig.publishUrl =%@",mixStreamConfig.publishUrl);
    mixStreamConfig.lifeCycle = QHVCITL_RtmpStream_LifeCycle_Bind_To_Owner;
    mixStreamConfig.width = config.mergeVideoCanvasWidth;
    mixStreamConfig.height = config.mergeVideoCanvasHeight;
    [QHVCITSLog printLogger:QHVCITS_LOG_LEVEL_INFO content:@"settingMergeData" dict:[mixStreamConfig transformToDictionary]];
    QHVCInteractiveKit* engineKit = [QHVCInteractiveKit sharedInstance];
    int code = [engineKit setMixStreamInfo:mixStreamConfig];
    if (code != QHVCITL_Error_NoError)
    {
        [QHVCToast makeToast:@"互动直播引擎未初始化"];
    }else
    {//初始化合流布局对象
        _mixStreamVideoLayout = [QHVCITSVideoCompositingLayout new];
        _mixStreamVideoLayout.canvasWidth = kScreenWidth;
        _mixStreamVideoLayout.canvasHeight = kScreenHeight;
        _mixStreamVideoLayout.regions = [NSMutableArray array];
    }
}

- (BOOL)existMixStreamVideoLayout:(NSString *)uid
{
    if ([QHVCToolUtils isNullString:uid])
    {
        return false;
    }
    NSArray* array = _mixStreamVideoLayout.regions;
    for (QHVCITLVideoCompositingRegion *region in array)
    {
        if ([region.uid isEqualToString:uid])
        {
            return true;
        }
    }
    return false;
}

- (void) updateMixStreamLayout
{
    if (![self mixStreamVideoLayout])
    {
        return;
    }
    NSMutableArray<QHVCITSVideoSession *> *tempVideoSessionArray = [_videoSessionArray mutableCopy];
    //判定视频会话列表中哪些对象属于新增
    for (QHVCITSVideoSession * session in tempVideoSessionArray)
    {
        if(![self existMixStreamVideoLayout:session.userId])
        {
            QHVCITLVideoCompositingRegion* region = [QHVCITLVideoCompositingRegion new];
            region.uid = session.userId;
            region.rect = CGRectMake(session.videoView.x, session.videoView.y, session.videoView.width, session.videoView.height);
            region.renderMode = QHVCITL_Render_ScaleAspectFill;
            [_mixStreamVideoLayout.regions addObject:region];
        }
    }
    //判定合流对象中哪些需要删除
    NSMutableArray* deleateArray = [NSMutableArray array];
    for (QHVCITLVideoCompositingRegion *region in _mixStreamVideoLayout.regions)
    {
        QHVCITSVideoSession* session = [self fetchSessionOfUid:region.uid];
        if (!session)
        {
            [deleateArray addObject:region];
        }
    }
    for (QHVCITLVideoCompositingRegion * region in deleateArray)
    {
        [[_mixStreamVideoLayout regions] removeObject:region];
    }
    //更新合流对象中的布局
    for (QHVCITLVideoCompositingRegion *region in _mixStreamVideoLayout.regions)
    {
        QHVCITSVideoSession* session = [self fetchSessionOfUid:region.uid];
        region.rect = CGRectMake(session.videoView.x, session.videoView.y, session.videoView.width, session.videoView.height);
        region.renderMode = QHVCITL_Render_ScaleAspectFill;
    }
    QHVCITLVideoCompositingLayout* compositingLayout = [QHVCITLVideoCompositingLayout new];
    compositingLayout.canvasWidth = _mixStreamVideoLayout.canvasWidth;
    compositingLayout.canvasHeight = _mixStreamVideoLayout.canvasHeight;
    compositingLayout.backgroundColor = _mixStreamVideoLayout.backgroundColor;
    compositingLayout.regions = [[_mixStreamVideoLayout regions] copy];
    [[QHVCInteractiveKit sharedInstance] setVideoCompositingLayout:compositingLayout];
}

- (void) endVideoCompositingTask
{
    if ([self mixStreamVideoLayout])
    {
        [[QHVCInteractiveKit sharedInstance] clearVideoCompositingLayout];
        _mixStreamVideoLayout = nil;
    }
}


#pragma mark - 互动过程中相关操作 -

- (void)updateRemoteSession:(NSString *)userId
{
    QHVCITSVideoSession *fetchedSession = [self fetchSessionOfUid:userId];
    if (fetchedSession == nil)
    {
        QHVCInteractiveKit* engineKit = [QHVCInteractiveKit sharedInstance];
        QHVCITSRoomModel *roomInfo = [[QHVCITSUserSystem sharedInstance] roomInfo];
        BOOL owner = [roomInfo.bindRoleId isEqualToString:userId];
        UIView* view = [self createBroadcasterView:userId identity:owner?QHVCITS_Identity_Anchor:QHVCITS_Identity_Guest];
        QHVCITSVideoSession *newSession = nil;
        if ([QHVCITSConfig sharedInstance].businessRenderMode == QHVCITS_Render_External)
        {
            //            QHLCExternRenderViewController* temp = [QHLCExternRenderViewController new];
            //            newSession = [[QHLCVideoSession alloc] initWithUid:userId view:temp.view controller:temp drag:YES];
            //            [self addChildViewController:temp];
        }else
        {
            newSession = [[QHVCITSVideoSession alloc] initWithUid:userId view:view];
        }
        if (owner)
        {
            [engineKit setRemoteVideoStream:userId type:QHVCITL_VideoStream_High];
            
            if ([QHVCITSUserSystem sharedInstance].roomInfo.roomType != QHVCITS_Room_Type_Party) {
                [_preview insertSubview:newSession.videoView atIndex:0];
            }
        }else
        {
            [engineKit setRemoteVideoStream:userId type:QHVCITL_VideoStream_Low];
            
            if ([QHVCITSUserSystem sharedInstance].roomInfo.roomType != QHVCITS_Room_Type_Party) {
                [_preview addSubview:newSession.videoView];
            }
        }
        [self.videoSessionArray addObject:newSession];
        if ([QHVCITSUserSystem sharedInstance].roomInfo.roomType == QHVCITS_Room_Type_Party) {
            [_hongpaTableView reloadData];
        }
        [engineKit setupRemoteVideo:newSession.canvas];
    }
}

- (QHVCITSVideoSession *)fetchSessionOfUid:(NSString *)userId
{
    if ([QHVCToolUtils isNullString:userId])
    {
        return nil;
    }
    for (QHVCITSVideoSession *session in self.videoSessionArray)
    {
        if ([session.userId isEqualToString:userId])
        {
            return session;
        }
    }
    return nil;
}

- (BOOL)searchSessionFromArray:(NSString*)userId array:(NSArray *)array
{
    if ([QHVCToolUtils isNullString:userId])
    {
        return NO;
    }
    for (NSDictionary* dict in array)
    {
        NSString* tempUid = [QHVCToolUtils getStringFromDictionary:dict key:QHVCITS_KEY_USER_ID defaultValue:nil];
        if ([userId isEqualToString:tempUid])
        {
            return YES;
        }
    }
    return NO;
}

- (void) updateVideoSessions:(NSArray *)roleList
{
    if (roleList == nil)
    {
        return;
    }
    NSString* currentUserId = [[QHVCITSUserSystem sharedInstance] userInfo].userId;
    for (NSDictionary* dict in roleList)
    {
        NSString* userId = [QHVCToolUtils getStringFromDictionary:dict key:QHVCITS_KEY_USER_ID defaultValue:nil];
        if (![QHVCToolUtils isNullString:userId] && ![currentUserId isEqualToString:userId])
        {
            [self updateRemoteSession:userId];
        }
    }
    //最新列表中和已有列表中比较，判定哪些没有,把没有的删除掉
    NSMutableArray* deleteSessionArray = [NSMutableArray array];
    for (QHVCITSVideoSession *session in self.videoSessionArray)
    {
        if (![self searchSessionFromArray:session.userId array:roleList])
        {
            [deleteSessionArray addObject:session];
        }
    }
    for (int i = 0; i < deleteSessionArray.count; i++)
    {
        QHVCITSVideoSession *deleteSession = deleteSessionArray[i];
        [self removeVideoSession:deleteSession];
    }
}

- (void) removeVideoSession:(QHVCITSVideoSession *)deleteSession
{
    if (!deleteSession)
    {
        return;
    }
    [[QHVCInteractiveKit sharedInstance] removeRemoteVideo:deleteSession.canvas];
    [self.videoSessionArray removeObject:deleteSession];
    
    if ([QHVCITSUserSystem sharedInstance].roomInfo.roomType == QHVCITS_Room_Type_Party) {
        [_hongpaTableView reloadData];
    }
    else
    {
        [deleteSession.videoView removeFromSuperview];
    }
    if (deleteSession.glViewController)
    {
        [deleteSession.glViewController removeFromParentViewController];
    }
}

- (UIView *) createBroadcasterView:(NSString *)userId identity:(QHVCITSIdentity)identity
{
    UIView* view = nil;
    if ([QHVCITSUserSystem sharedInstance].roomInfo.roomType == QHVCITS_Room_Type_Party) {
        CGSize size = [self fetchCellSize];
        view = [[QHVCITRoleView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) userId:userId];
    }
    else
    {
        if (identity == QHVCITS_Identity_Anchor)
        {
            view = [[QHVCITRoleView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) userId:userId];
        }
        else if (identity == QHVCITS_Identity_Guest)
        {
            int width = 90;
            int height = 160;
            int startx = 10;
            int starty = 120;
            int endx = _preview.width - width - startx;
            int endy = _preview.height - height - 50;
            CGFloat x = [QHVCToolUtils getRandomNumber:startx end:endx];
            CGFloat y = [QHVCToolUtils getRandomNumber:starty end:endy];
            view = [[QHVCITRoleView alloc] initWithFrame:CGRectMake(x, y, width, height) userId:userId];
        }
    }
    
    return view;
}

- (void) startHeartbeatTimer
{
    if (![NSThread isMainThread])
    {
        WEAK_SELF_LINKMIC
        dispatch_async(dispatch_get_main_queue(), ^{
            STRONG_SELF_LINKMIC
            [self startHeartbeatTimer];
            return;
        });
    }
    if (_heartbeatTimer == nil || ![_heartbeatTimer isValid])
    {
        _heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:[[QHVCITSConfig sharedInstance] userHeartInterval] target:self selector:@selector(sendUserHeart) userInfo:nil repeats:YES];
    }
}

- (void) cancelHeartbeatTimer
{
    if (_heartbeatTimer && [_heartbeatTimer isValid])
    {
        [_heartbeatTimer invalidate];
        _heartbeatTimer = nil;
    }
}

//发送用户心跳
- (void) sendUserHeart
{
    QHVCITSUserModel* userInfo = [[QHVCITSUserSystem sharedInstance] userInfo];
    QHVCITSRoomModel* roomInfo = [[QHVCITSUserSystem sharedInstance] roomInfo];
    NSMutableDictionary* roomDict = [NSMutableDictionary dictionary];
    [QHVCToolUtils setStringToDictionary:roomDict key:QHVCITS_KEY_USER_ID value:userInfo.userId];
    [QHVCToolUtils setStringToDictionary:roomDict key:QHVCITS_KEY_ROOM_ID value:roomInfo.roomId];
    [QHVCITSProtocolMonitor updateUserHeartbeat:_httpManager
                                           dict:roomDict
                                       complete:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable dict) {
                                           
                                       }];
}

- (void) startUpdateRoomListTimer
{
    if (![NSThread isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startUpdateRoomListTimer];
            return;
        });
    }
    if (_updateRoomListTimer == nil || ![_updateRoomListTimer isValid])
    {
        _updateRoomListTimer = [NSTimer scheduledTimerWithTimeInterval:[[QHVCITSConfig sharedInstance] updateRoomListInterval] target:self selector:@selector(updateRoomRoleList) userInfo:nil repeats:YES];
        [_updateRoomListTimer fire];
    }
}

- (void) cancelUpdateRoomListTimer
{
    if (_updateRoomListTimer && [_updateRoomListTimer isValid])
    {
        [_updateRoomListTimer invalidate];
        _updateRoomListTimer = nil;
    }
}

//更新房间成员列表信息
- (void) updateRoomRoleList
{
    NSString* roleType = [NSString stringWithFormat:@"%ld,%ld",QHVCITS_Identity_Anchor,QHVCITS_Identity_Guest];
    WEAK_SELF_LINKMIC
    [self sendFetchRoomInteractiveRoleList:roleType complete:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable dict) {
        STRONG_SELF_LINKMIC
        if (success)
        {
            NSArray* roleListArray = [QHVCToolUtils getObjectFromDictionary:dict key:QHVCITS_KEY_DATA defaultValue:nil];
            [_onlineCount setText:[NSNumber numberWithInteger:roleListArray.count].stringValue];//定时更新房间人数
            [self updateVideoSessions:roleListArray];
            //如果有合流任务，启动合流布局更新
            if ([self mixStreamVideoLayout])
            {
                [self updateMixStreamLayout];
            }
        }
        else
        {
            NSString *errorNo = dict[@"errno"];
            [QHVCToast makeToast:dict[@"errmsg"]];
            if(errorNo.integerValue == 10001)//该房间不存在
            {
                [self leavelChannel];
            }
        }
    }];
}

#pragma mark - 离开房间相关操作 -

- (void)leavelRoom
{
    WEAK_SELF_LINKMIC
    [self sendQuitBusinessServerRoom:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable dict) {
        STRONG_SELF_LINKMIC
        [self forceLeaveRoom];
    }];
}

//强制退出房间，当正常退出失败时启用此方法
- (void)forceLeaveRoom
{
    [self cleanBusinessData];
    //界面跳转
    [self.navigationController popViewControllerAnimated:YES];
}

//角色离开连麦频道成功,清空相关数据
- (void) didLeaveChannelSucess
{
    [self leavelRoom];
}

//清空业务数据
- (void) cleanBusinessData
{
    //通知其它连麦角色，该角色已经退出连麦
    QHVCITSIdentity identity = [[QHVCITSUserSystem sharedInstance] userInfo].identity;
    NSString *currentUserId = [[QHVCITSUserSystem sharedInstance] userInfo].userId;
    NSString* roomId = [[QHVCITSUserSystem sharedInstance] roomInfo].roomId;
    if ([currentUserId isEqualToString:[[QHVCITSUserSystem sharedInstance] roomInfo].bindRoleId])
    {
        [QHVCITSChatManager sendCommandMessage:QHVCIMConversationTypeChartroom cmdType:QHVCITSCommandAnchorQuitNotify targetId:roomId success:nil error:nil];
    }
    else if (identity != QHVCITS_Identity_Audience)
    {
        [QHVCITSChatManager sendCommandMessage:QHVCIMConversationTypeChartroom cmdType:QHVCITSCommandGuestQuitNotify targetId:roomId success:nil error:nil];
    }
    //退出聊天室
    [QHVCITSChatManager quitChatroom:roomId];
    
    [_httpManager cancelAllOperations];
    _httpManager = nil;
    //清空连麦相关变量
    [self cleanInteractiveEngineData];
    [self cancelHeartbeatTimer];
    [self cancelUpdateRoomListTimer];
}

//退出连麦频道
- (int) leavelChannel
{
    QHVCInteractiveKit* engineKit = [QHVCInteractiveKit sharedInstance];
    int result = [engineKit leaveChannel];
    if (result != 0)
    {
        [self leavelRoom];
    }
    return result;
}

//退出连麦频道成功,清空相关资源
- (void) cleanInteractiveEngineData
{
    QHVCInteractiveKit* engineKit = [QHVCInteractiveKit sharedInstance];
    for (int i = 0; i < self.videoSessionArray.count; i++)
    {
        QHVCITSVideoSession *session = self.videoSessionArray[i];
        [engineKit removeRemoteVideo:session.canvas];
        [session.videoView removeFromSuperview];
        [session.glViewController removeFromParentViewController];
    }
    [self.videoSessionArray removeAllObjects];
    self.videoSessionArray = nil;
    
    QHVCITLDataCollectMode dataCollectMode = [[QHVCITSConfig sharedInstance] dataCollectMode];
    if(dataCollectMode == QHVCITLDataCollectModeSDK)
    {
        [engineKit setupLocalVideo:nil];
    }else if (dataCollectMode == QHVCITLDataCollectModeUser)
    {
        [engineKit closeCollectingData];
        _liveEngine.liveDelegate = nil;
        [_liveEngine stopCapture];
        _liveEngine = nil;
    }
    [QHVCInteractiveKit destory];
}

- (void)returnToLogin
{
    WEAK_SELF_LINKMIC
    [self sendQuitBusinessServerRoom:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable dict) {
        STRONG_SELF_LINKMIC
        [self cleanBusinessData];
        
        NSArray<__kindof UIViewController *> *viewControllers = [self.navigationController viewControllers];
        for (UIViewController *vc in viewControllers) {
            if ([vc isKindOfClass:[QHVCInteractiveViewController class]]) {
                [self.navigationController popToViewController:vc animated:YES];
                
                [QHVCToast makeToast:@"请输入正确的配置信息！"];
                return;
            }
        }
    }];
}

#pragma mark - 业务服务器交互 -
- (void)sendJoinBusinessServerRoom:(QHVCITSProtocolMonitorDataCompleteWithDictionary)complete
{
    QHVCITSUserModel* userInfo = [[QHVCITSUserSystem sharedInstance] userInfo];
    QHVCITSRoomModel* roomInfo = [[QHVCITSUserSystem sharedInstance] roomInfo];
    NSMutableDictionary* joinRoomDict = [NSMutableDictionary dictionary];
    [QHVCToolUtils setStringToDictionary:joinRoomDict key:QHVCITS_KEY_USER_ID value:userInfo.userId];
    [QHVCToolUtils setStringToDictionary:joinRoomDict key:QHVCITS_KEY_ROOM_ID value:roomInfo.roomId];
    [QHVCToolUtils setIntToDictionary:joinRoomDict key:QHVCITS_KEY_IDENTITY value:userInfo.identity];

    [QHVCITSProtocolMonitor joinRoom:_httpManager
                                dict:joinRoomDict
                            complete:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable dict) {
                                [QHVCITSLog printLogger:QHVCITS_LOG_LEVEL_DEBUG content:@"joinServerRoom" dict:dict];
                                if (!success)
                                {
                                    complete(nil, false, dict);
                                }else
                                {
                                    complete(nil, true, dict);
                                }
                            }];
}

- (void)sendQuitBusinessServerRoom:(QHVCITSProtocolMonitorDataCompleteWithDictionary)complete
{
    QHVCITSUserModel* userInfo = [[QHVCITSUserSystem sharedInstance] userInfo];
    QHVCITSRoomModel* roomInfo = [[QHVCITSUserSystem sharedInstance] roomInfo];
    NSMutableDictionary* roomDict = [NSMutableDictionary dictionary];
    [QHVCToolUtils setStringToDictionary:roomDict key:QHVCITS_KEY_USER_ID value:userInfo.userId];
    [QHVCToolUtils setStringToDictionary:roomDict key:QHVCITS_KEY_ROOM_ID value:roomInfo.roomId];
    if ([userInfo.userId isEqualToString:roomInfo.bindRoleId])//房主退出
    {
        [QHVCITSProtocolMonitor dismissRoom:_httpManager
                                       dict:roomDict
                                   complete:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable dict) {
                                       [QHVCITSLog printLogger:QHVCITS_LOG_LEVEL_DEBUG content:@"dismissRoom" dict:dict];
                                       if (complete)
                                       {
                                           complete(taskData, success, dict);
                                       }
                                   }];
    } else
    {
        [QHVCITSProtocolMonitor userLeaveRoom:_httpManager
                                         dict:roomDict
                                     complete:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable dict) {
                                         [QHVCITSLog printLogger:QHVCITS_LOG_LEVEL_DEBUG content:@"userLeaveRoom" dict:dict];
                                         if (complete)
                                         {
                                             complete(taskData, success, dict);
                                         }
                                     }];
    }
}

- (void)sendFetchRoomInfo:(QHVCITSProtocolMonitorDataCompleteWithDictionary _Nullable )complete
{
    QHVCITSUserModel* userInfo = [[QHVCITSUserSystem sharedInstance] userInfo];
    QHVCITSRoomModel* roomInfo = [[QHVCITSUserSystem sharedInstance] roomInfo];
    NSMutableDictionary* roomInfoDict = [NSMutableDictionary dictionary];
    [QHVCToolUtils setStringToDictionary:roomInfoDict key:QHVCITS_KEY_USER_ID value:userInfo.userId];
    [QHVCToolUtils setStringToDictionary:roomInfoDict key:QHVCITS_KEY_ROOM_ID value:roomInfo.roomId];
    [QHVCToolUtils setIntToDictionary:roomInfoDict key:QHVCITS_KEY_ROOM_TYPE value:roomInfo.roomType];
    
    [QHVCITSProtocolMonitor getRoomInfo:_httpManager
                                   dict:roomInfoDict
                               complete:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable dict) {
                                   [QHVCITSLog printLogger:QHVCITS_LOG_LEVEL_DEBUG content:@"getRoomInfo" dict:dict];
                                   if (complete)
                                   {
                                       complete(taskData, success, dict);
                                   }
                               }];
}

- (void)sendFetchRoomInteractiveRoleList:(NSString *)roleType complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary)complete
{
    QHVCITSUserModel* userInfo = [[QHVCITSUserSystem sharedInstance] userInfo];
    QHVCITSRoomModel* roomInfo = [[QHVCITSUserSystem sharedInstance] roomInfo];
    NSMutableDictionary* roomUserDict = [NSMutableDictionary dictionary];
    [QHVCToolUtils setStringToDictionary:roomUserDict key:QHVCITS_KEY_USER_ID value:userInfo.userId];
    [QHVCToolUtils setStringToDictionary:roomUserDict key:QHVCITS_KEY_ROOM_ID value:roomInfo.roomId];
    [QHVCToolUtils setStringToDictionary:roomUserDict key:QHVCITS_KEY_IDENTITY value:roleType];
    [QHVCITSProtocolMonitor getRoomUserList:_httpManager
                                       dict:roomUserDict
                                   complete:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable dict) {
                                       [QHVCITSLog printLogger:QHVCITS_LOG_LEVEL_DEBUG content:@"getRoomUserList" dict:dict];
                                       if (complete)
                                       {
                                           complete(taskData, success, dict);
                                       }
                                   }];
}

- (void)sendChangeRoleIdentity:(QHVCITSIdentity)expectedRole complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary)complete
{
    QHVCITSUserModel* userInfo = [[QHVCITSUserSystem sharedInstance] userInfo];
    QHVCITSRoomModel* roomInfo = [[QHVCITSUserSystem sharedInstance] roomInfo];
    NSMutableDictionary* identityDict = [NSMutableDictionary dictionary];
    [QHVCToolUtils setStringToDictionary:identityDict key:QHVCITS_KEY_USER_ID value:userInfo.userId];
    [QHVCToolUtils setStringToDictionary:identityDict key:QHVCITS_KEY_ROOM_ID value:roomInfo.roomId];
    [QHVCToolUtils setIntToDictionary:identityDict key:QHVCITS_KEY_IDENTITY value:expectedRole];
    
    [QHVCITSProtocolMonitor changeUserIdentity:_httpManager
                                          dict:identityDict
                                      complete:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable dict) {
                                          [QHVCITSLog printLogger:QHVCITS_LOG_LEVEL_DEBUG content:@"changeUserIdentity" dict:dict];
                                          if (complete)
                                          {
                                              complete(taskData, success, dict);
                                          }
                                      }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - QHVCIMMessageDelegate -

- (void)didRecieveNewMessage:(QHVCIMMessage *)message left:(int)left
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([message.content isMemberOfClass:[QHVCIMTextContent class]]) {
//            NSLog(@"it is text msg %@",[(QHVCIMTextContent *)message.content content]);
        }
        else if ([message.content isMemberOfClass:[QHVCIMCommandContent class]])
        {
            [self handleCommandMessage:message];
        }
    });
}

- (void)handleCommandMessage:(QHVCIMMessage *)message
{
    QHVCIMCommandContent *content = (QHVCIMCommandContent *)message.content;
    
    if (content.data.length > 0) {
        NSDictionary *dict = [QHVCITSChatManager jsonFormatToDic:[content.data dataUsingEncoding:NSUTF8StringEncoding]];
        NSString *cmdId = dict[@"cmd"];
        NSString *roomId = dict[@"target"];
        //只处理房间内的私聊、通知
        if (![roomId isEqualToString:[QHVCITSUserSystem sharedInstance].roomInfo.roomId]) {
            return;
        }
        if (cmdId.integerValue == QHVCITSCommandGuestAskJoin)
        {
            [self guestAskJoin:message.senderUserId];
        } else if (cmdId.integerValue == QHVCITSCommandAnchorRefuseJoin)
        {
            [QHVCToast makeToast:@"主播拒绝了你的连麦请求"];
        } else if (cmdId.integerValue == QHVCITSCommandAnchorAgreeJoin)
        {
            [QHVCToast makeToast:@"主播同意了你的连麦请求"];
            _expectedRole = QHVCITS_Identity_Guest;
            [self setClientRoleIdentity:QHVCITS_Identity_Guest];
        }
        else if (cmdId.integerValue == QHVCITSCommandAnchorKickoutGuest)
        {
            [QHVCToast makeToast:@"主播把你踢出了"];
            [self endLinkmic];
        }
        else if (cmdId.integerValue == QHVCITSCommandGuestJoinNotify||
                 cmdId.integerValue == QHVCITSCommandGuestQuitNotify||
                 cmdId.integerValue == QHVCITSCommandGuestKickoutNotify)
        {
            [self updateRoomRoleList];
        }
        else if (cmdId.integerValue == QHVCITSCommandAnchorQuitNotify)
        {
            [self anchorQuitNotify];
        }
    }
}

#pragma mark - IM相关方法实现 -
- (void)joinChatroom:(NSString *)roomId
{
    [QHVCITSChatManager setChatMessageDelegate:self];
    [QHVCITSChatManager joinChatroom:roomId];
}

#pragma mark - 观众发送连麦请求

- (void)guestAskJoin:(NSString *)guestId
{
    UIAlertController *alertOne = [UIAlertController alertControllerWithTitle:@"互动申请" message:@"观众申请与您进行互动直播" preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertOne animated:YES completion:nil];
    
    __weak typeof(self) weakSelf = self;
    UIAlertAction *refuse = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf anchorRespondGuestRequest:guestId result:QHVCITSCommandAnchorRefuseJoin];
    }];
    [alertOne addAction:refuse];
    
    UIAlertAction *agree = [UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf anchorRespondGuestRequest:guestId result:QHVCITSCommandAnchorAgreeJoin];
    }];
    [alertOne addAction:agree];
}

- (void)anchorRespondGuestRequest:(NSString *)guestId result:(QHVCITSCommand)result
{
    [QHVCITSChatManager sendCommandMessage:QHVCIMConversationTypePrivate cmdType:result targetId:guestId success:^(long messageId) {
        [QHVCToast makeToast:@"请求发送成功"];
    } error:^(QHVCIMErrorCode errorCode, long messageId) {
        [QHVCToast makeToast:@"请求发送失败，请稍后再试"];
    }];
}

#pragma mark - 主播退出，发送通知

- (void)anchorQuitNotify
{
    UIAlertController *alertOne = [UIAlertController alertControllerWithTitle:@"" message:@"主播已离开房间" preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertOne animated:YES completion:nil];
    
    WEAK_SELF_LINKMIC
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        STRONG_SELF_LINKMIC
        [self audienceRespondAnchorQuitNotify];
    }];
    [alertOne addAction:confirm];
}

- (void)audienceRespondAnchorQuitNotify
{
    [self leavelChannel];
}

#pragma mark - 主播踢出某个嘉宾
- (void)anchorKickoutGuest:(NSString *)guestId
{
    [self anchorRespondGuestRequest:guestId result:QHVCITSCommandAnchorKickoutGuest];
}

#pragma mark  - Private Method -

- (void)setInteractiveBtnTitle
{
    QHVCITSIdentity identity = [[QHVCITSUserSystem sharedInstance] userInfo].identity;
    NSString *currentUserId = [[QHVCITSUserSystem sharedInstance] userInfo].userId;
    
    if ([currentUserId isEqualToString:[QHVCITSUserSystem sharedInstance].roomInfo.bindRoleId]) {
        [_interactiveBtn setTitle:@"嘉宾邀请" forState:UIControlStateNormal];
    }
    else
    {
        if(identity == QHVCITS_Identity_Audience)
        {
            if ([QHVCITSUserSystem sharedInstance].roomInfo.roomType == QHVCITS_Room_Type_Party) {
                [_interactiveBtn setTitle:@"加入互动" forState:UIControlStateNormal];
            }
            else
            {
                [_interactiveBtn setTitle:@"互动申请" forState:UIControlStateNormal];
            }
        }
        else
        {
            if ([QHVCITSUserSystem sharedInstance].roomInfo.roomType == QHVCITS_Room_Type_Party){
                [_interactiveBtn setTitle:@"退出互动" forState:UIControlStateNormal];
            }
            else
            {
                [_interactiveBtn setTitle:@"结束互动" forState:UIControlStateNormal];
            }
        }
    }
}

- (void)updateRoomUIInfo
{
    QHVCITSRoomModel* roomInfo = [[QHVCITSUserSystem sharedInstance] roomInfo];
    [_roomName setText:roomInfo.roomName];
    [_roomIdLabel setText:roomInfo.roomId];
    [_onlineCount setText:[NSString stringWithFormat:@"%ld",roomInfo.num]];
    if (![roomInfo.bindRoleId isEqualToString:@"0"]) {
        _anchorIdLabel.text = [NSString stringWithFormat:@"主播Id:%@",roomInfo.bindRoleId];
    }
    [self setInteractiveBtnTitle];
    [self updateControlView:roomInfo.talkType];
}

- (void)dealloc
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    NSLog(@"QHVCITSLinkMicViewController dealloc !!!!");
}
@end
