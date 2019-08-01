//
//  QHVCGodViewLocalManager.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/9/25.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCGodViewLocalManager.h"
#import "QHVCGVConfig.h"
#import "QHVCLogger.h"

@interface QHVCGodViewLocalManager()<QHVCNetGodSeesDelegate>

@end


@implementation QHVCGodViewLocalManager

+ (instancetype)sharedInstance;
{
    static QHVCGodViewLocalManager * s_instance = NULL;
    static dispatch_once_t predic; dispatch_once(&predic, ^{
        s_instance = [QHVCGodViewLocalManager new];
    });
    return s_instance;
}

- (void) startLocalServer
{
    QHVCNet* netkit = [QHVCNet sharedInstance];
    [netkit setLogLevel:(QHVCNetLogLevel)[QHVCLogger getLoggerLevel] detailInfo:0 callback:^(const char *buf, size_t buf_size) {
        NSLog(@"NetSDK netLog:%@", [NSString stringWithUTF8String:buf]);
    }];
    [netkit setGodSeesDelegate:self];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    path = [path stringByAppendingPathComponent:@"videoCache"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path])
    {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [netkit startLocalServer:path deviceId:[QHVCToolDeviceModel getDeviceUUID] appId:@"Demo" cacheSize:500 options:@{kQHVCNetOptionsServicesKey:@(QHVCNetServiceGodSees | QHVCNetServicePrecache)}];
}

- (void)stopLocalServer
{
    QHVCNet*localServer = [QHVCNet sharedInstance];
    [localServer setGodSeesDelegate:nil];
    [localServer stopLocalServer];
}

#pragma mark - 信令相关 -

- (int) receiveGodSeesSignallingData:(NSString *)data
{
    return [[QHVCNet sharedInstance] receiveGodSeesSignallingData:data];
}

#pragma mark - 安全相关 -

- (int) updateGodSeesVideoStreamSecurityKeys:(NSArray<NSDictionary<NSString *, NSString *> *> *)keys
                                serialNumber:(NSString *)serialNumber
{
    return [[QHVCNet sharedInstance] updateGodSeesVideoStreamSecurityKeys:keys serialNumber:serialNumber];
}

- (int) decryptGodSeesMediaDataWithSecretKey:(NSString *)secretKey
                             decryptionRules:(QHVCNetGodSeesDecryptionRules)decryptionRules
                               frameDataType:(QHVCNetGodSeesFrameDataType)frameDataType
                           originalMediaData:(uint8_t *)originalMediaData
                          originalDataLength:(int)originalDataLength
                         decryptedDataLength:(int *)decryptedDataLength
{
    return [[QHVCNet sharedInstance] decryptGodSeesMediaDataWithSecretKey:secretKey
                                                          decryptionRules:decryptionRules
                                                            frameDataType:frameDataType
                                                        originalMediaData:originalMediaData
                                                       originalDataLength:originalDataLength
                                                      decryptedDataLength:decryptedDataLength];
}


#pragma mark - 文件下载 -

- (int) getDeviceFileDownloadUrlWithFileKey:(NSString *)fileKey
                                   clientId:(NSString *)clientId
                                      appId:(NSString *)appId
                                     userId:(NSString *)userId
                               serialNumber:(NSString *)serialNumber
                               businessSign:(NSString *)businessSign
                                      token:(NSString *)token
                                 rangeStart:(NSUInteger)rangeStart
                                   rangeEnd:(NSUInteger)rangeEnd
                            resultUrlString:(NSString *_Nonnull *_Nullable)resultUrlString
{
    return [[QHVCNet sharedInstance] getDeviceFileDownloadUrlWithFileKey:fileKey
                                                                clientId:clientId
                                                                   appId:appId
                                                                  userId:userId
                                                            serialNumber:serialNumber
                                                            businessSign:businessSign
                                                                   token:token
                                                              rangeStart:rangeStart
                                                                rangeEnd:rangeEnd
                                                         resultUrlString:resultUrlString];
}

#pragma mark - 全局公共方法 -

- (int) enableTestEnvironment:(BOOL)testEnv {
    return [[QHVCNet sharedInstance] enableTestEnvironment:testEnv];
}

- (void) setGodSeesNetworkConnectType:(QHVCNetGodSeesNetworkConnectType)networkConnectType
{
    [[QHVCNet sharedInstance] setGodSeesNetworkConnectType:networkConnectType];
}

- (int) setGodSeesDeviceNetworkAddress:(NSString *)serialNumber
                                    ip:(NSString *)ip
                                  port:(NSInteger)port
{
    return [[QHVCNet sharedInstance] setGodSeesDeviceNetworkAddress:serialNumber
                                                                 ip:ip
                                                               port:port];
}

- (void) setGodSeesP2PConnectionSucceedMaxWaitTime:(NSInteger)timeMS
{
    [[QHVCNet sharedInstance] setGodSeesP2PConnectionSucceedMaxWaitTime:timeMS];
}

- (void) enableGodSeesMonitorVideoState:(BOOL)enable
{
    [[QHVCNet sharedInstance] enableGodSeesMonitorVideoState:enable];
}

- (int) preConnectGodSeesDevice:(NSString *)serialNumber
            deviceChannelNumber:(NSInteger)deviceChannelNumber
{
    return [[QHVCNet sharedInstance] preConnectGodSeesDevice:serialNumber deviceChannelNumber:deviceChannelNumber];
}

- (int) createGodSeesSession:(NSString *)sessionId
                    clientId:(NSString *)clientId
                       appId:(NSString *)appId
                      userId:(NSString *)userId
                serialNumber:(NSString *)serialNumber
         deviceChannelNumber:(NSInteger)deviceChannelNumber
                businessSign:(NSString *)businessSign
                 sessionType:(QHVCNetGodSeesSessionType)sessionType
                     options:(NSDictionary *)options
{
    return [[QHVCNet sharedInstance] createGodSeesSession:sessionId
                                                 clientId:clientId
                                                    appId:appId
                                                   userId:userId
                                             serialNumber:serialNumber
                                      deviceChannelNumber:deviceChannelNumber
                                             businessSign:businessSign
                                              sessionType:sessionType
                                                  options:options];
}

- (int) destroyGodSeesSession:(NSString *)sessionId
{
    return [[QHVCNet sharedInstance] destroyGodSeesSession:sessionId];
}

- (NSString *) getGodSeesPlayUrl:(NSString *)sessionId
{
    return [[QHVCNet sharedInstance] getGodSeesPlayUrl:sessionId];
}

- (int) verifyGodSeesBusinessTokenToDevice:(NSString *)sessionId
                                     token:(NSString *)token
{
    return [[QHVCNet sharedInstance] verifyGodSeesBusinessTokenToDevice:sessionId token:token];
}

/*
 **************************************************************************************************************
 * 特别注意：下面的方法一定要等设备授权通过后才能调用。
 * 即调用verifyGodSeesBusinessTokenToDevice函数通知设备验证token成功，待回调didVerifyToken执行后，才能调用下面的接口
 **************************************************************************************************************
 */

#pragma mark - 直播相关 -

#pragma mark - 卡录相关 -

- (int) getGodSeesRecordTimeline:(NSString *)sessionId
{
    return [[QHVCNet sharedInstance] getGodSeesRecordTimeline:sessionId];
}

- (int) setGodSeesRecordSeek:(NSString *)sessionId
                   timeStamp:(NSUInteger)timeStampByMS
{
    return [[QHVCNet sharedInstance] setGodSeesRecordSeek:sessionId timeStamp:timeStampByMS];
}

- (int) setGodSeesRecordPause:(NSString *)sessionId
{
    return [[QHVCNet sharedInstance] setGodSeesRecordPause:sessionId];
}

- (int) setGodSeesRecordResume:(NSString *)sessionId
{
    return [[QHVCNet sharedInstance] setGodSeesRecordResume:sessionId];
}

- (int) setGodSeesRecordPlayRate:(NSString *)sessionId
                            rate:(double)rate
{
    return [[QHVCNet sharedInstance] setGodSeesRecordPlayRate:sessionId rate:rate];
}

#pragma mark - QHVCNetGodseesDelegate实现 -

- (void) onGodSeesSignallingSendData:(NSString *)destId data:(NSString *)data
{
    if (_delegate && [_delegate respondsToSelector:@selector(onGodSeesSignallingSendData:data:)])
    {
        [_delegate onGodSeesSignallingSendData:destId data:data];
    }
}

- (void) onGodSees:(NSString *)sessionId didError:(QHVCNetGodSeesErrorCode)errorCode
{
    if (_delegate && [_delegate respondsToSelector:@selector(onGodSees:didError:)])
    {
        [_delegate onGodSees:sessionId didError:errorCode];
    }
}

- (void) onGodSees:(NSString *)sessionId didVerifyToken:(NSInteger)status info:(NSString *)info
{
    if (_delegate && [_delegate respondsToSelector:@selector(onGodSees:didVerifyToken:info:)])
    {
        [_delegate onGodSees:sessionId didVerifyToken:status info:info];
    }
}

- (void) onGodSees:(NSString *)sessionId didRecordTimeline:(NSArray<QHVCNetGodSeesRecordTimeline *> *)data
{
    if (_delegate && [_delegate respondsToSelector:@selector(onGodSees:didRecordTimeline:)])
    {
        [_delegate onGodSees:sessionId didRecordTimeline:data];
    }
}

- (void) onGodSees:(NSString *)sessionId didRecordUpdateCurrentTimeStamp:(NSUInteger)timeStampByMS
{
    if (_delegate && [_delegate respondsToSelector:@selector(onGodSees:didRecordUpdateCurrentTimeStamp:)])
    {
        [_delegate onGodSees:sessionId didRecordUpdateCurrentTimeStamp:timeStampByMS];
    }
}

- (void) onGodSeesRecordPause:(NSString *)sessionId
{
    if (_delegate && [_delegate respondsToSelector:@selector(onGodSeesRecordPause:)])
    {
        [_delegate onGodSeesRecordPause:sessionId];
    }
}

- (void) onGodSeesRecordResume:(NSString *)sessionId
{
    if (_delegate && [_delegate respondsToSelector:@selector(onGodSeesRecordResume:)])
    {
        [_delegate onGodSeesRecordResume:sessionId];
    }
}

- (void) onGodSeesRecordPlayComplete:(NSString *)sessionId
{
    if (_delegate && [_delegate respondsToSelector:@selector(onGodSeesRecordPlayComplete:)])
    {
        [_delegate onGodSeesRecordPlayComplete:sessionId];
    }
}

- (void) onGodSeesRecordSeekComplete:(NSString *)sessionId
{
    if (_delegate && [_delegate respondsToSelector:@selector(onGodSeesRecordSeekComplete:)])
    {
        [_delegate onGodSeesRecordSeekComplete:sessionId];
    }
}


- (void) onGodSees:(NSString *)sessionId didRecordPlaybackRate:(double)rate
{
    if (_delegate && [_delegate respondsToSelector:@selector(onGodSees:didRecordPlaybackRate:)])
    {
        [_delegate onGodSees:sessionId didRecordPlaybackRate:rate];
    }
}

- (void) onGodSees:(NSString *)sessionId didMonitorNetworkInfo:(NSString *)info
{
    if (_delegate && [_delegate respondsToSelector:@selector(onGodSees:didMonitorNetworkInfo:)])
    {
        [_delegate onGodSees:sessionId didMonitorNetworkInfo:info];
    }
}

- (void) onGodSees:(NSString *)sessionId didReceiveFrameDataType:(QHVCNetGodSeesFrameDataType)frameDataType
         frameData:(const uint8_t *)frameData
      frameDataLen:(int)length
               pts:(uint64_t)pts
               dts:(uint64_t)dts
        isKeyFrame:(BOOL)isKeyFrame
{
    if (_delegate && [_delegate respondsToSelector:@selector(onGodSees:didReceiveFrameDataType:frameData:frameDataLen:pts:dts:isKeyFrame:)])
    {
        [_delegate onGodSees:sessionId didReceiveFrameDataType:frameDataType
                   frameData:frameData
                frameDataLen:length
                         pts:pts
                         dts:dts
                  isKeyFrame:isKeyFrame];
    }
}
@end
