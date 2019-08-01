//
//  QHVCGodViewLocalManager.h
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/9/25.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QHVCNetKit/QHVCNetKit.h>
#import <QHVCCommonKit/QHVCCommonKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QHVCGodViewLocalManagerDelegate <NSObject>

@optional

/**
 借用业务信令通道发送数据
 
 @param destId 设备ID
 @param data 发送的数据体
 */
- (void) onGodSeesSignallingSendData:(NSString *)destId data:(NSString *)data;

/**
 错误监听回调
 
 @param sessionId 会话ID
 @param errorCode 错误码
 */
- (void) onGodSees:(NSString *)sessionId didError:(QHVCNetGodSeesErrorCode)errorCode;

/**
 业务token验证结果回调
 
 @param sessionId 会话ID
 @param status 验证结果，由业务定义
 @param info 附带信息
 */
- (void) onGodSees:(NSString *)sessionId didVerifyToken:(NSInteger)status info:(NSString *)info;

/**
 请求卡录时间轴结果
 
 @param sessionId 会话ID
 @param data 卡录时间数据
 */
- (void) onGodSees:(NSString *)sessionId didRecordTimeline:(NSArray<QHVCNetGodSeesRecordTimeline *> *)data;

/**
 更新当前播放的时间点
 
 @param sessionId 会话ID
 @param timeStampByMS 当前时间戳
 */
- (void) onGodSees:(NSString *)sessionId didRecordUpdateCurrentTimeStamp:(NSUInteger)timeStampByMS;

/**
 卡录已经暂停
 
 @param sessionId 会话ID
 */
- (void) onGodSeesRecordPause:(NSString *)sessionId;

/**
 卡录已经恢复
 
 @param sessionId 会话ID
 */
- (void) onGodSeesRecordResume:(NSString *)sessionId;

/**
 卡录播放完毕
 
 @param sessionId 会话ID
 */
- (void) onGodSeesRecordPlayComplete:(NSString *)sessionId;

/**
 卡录seek完成
 
 @param sessionId 会话ID
 */
- (void) onGodSeesRecordSeekComplete:(NSString *)sessionId;

/**
 倍速播放回调
 
 @param sessionId 会话ID
 @param rate 卡录播放速度值
 */
- (void) onGodSees:(NSString *)sessionId didRecordPlaybackRate:(double)rate;

/**
 监控网络日志信息
 
 @param sessionId 会话ID
 @param info 监控信息
 */
- (void) onGodSees:(NSString *)sessionId didMonitorNetworkInfo:(NSString *)info;

/**
 NetSDK将帧数据抛出，业务端可以将相关数据直接吐给播放器播放。
 注意：此代理只会在开启QHVC_NET_GODSEES_PLAYER_RECEIVE_DATA_MODEL_CALLBACK时才会触发该回调，此时需要业务把该回调数据直接传递给播放器使用。(开启方法：在createGodSeesSession方法的参数中，设置播放器接收数据模式QHVCNetGodSeesPlayerReceiveDataModel为QHVC_NET_GODSEES_PLAYER_RECEIVE_DATA_MODEL_CALLBACK)
 
 @param sessionId 会话ID
 @param frameDataType 数据帧类型
 @param frameData 帧数据
 @param length 帧数据长度
 @param pts 显示时间戳
 @param dts 解码时间戳
 @param isKeyFrame 是否是关键帧
 */
- (void) onGodSees:(NSString *)sessionId didReceiveFrameDataType:(QHVCNetGodSeesFrameDataType)frameDataType
         frameData:(const uint8_t *)frameData
      frameDataLen:(int)length
               pts:(uint64_t)pts
               dts:(uint64_t)dts
        isKeyFrame:(BOOL)isKeyFrame;

@end


@interface QHVCGodViewLocalManager : NSObject

@property(nonatomic, weak) id<QHVCGodViewLocalManagerDelegate> delegate;

+ (instancetype)sharedInstance;

- (void) startLocalServer;

- (void) stopLocalServer;

#pragma mark - 信令相关 -

/**
 帝视接收信令数据
 
 @param data 信令数据
 @return 0成功，非0表示失败
 */
- (int) receiveGodSeesSignallingData:(NSString *)data;

#pragma mark - 安全相关 -

/**
 更新帝视视频流解密秘钥
 
 @param keys 密钥表，形如 [{"27":"sfee23"},{"28":"fsjei"},@{"29":"ejis"}]
 @param serialNumber 设备唯一标识
 @return 0成功，非0表示失败
 */
- (int) updateGodSeesVideoStreamSecurityKeys:(NSArray<NSDictionary<NSString *, NSString *> *> *)keys
                                serialNumber:(NSString *)serialNumber;

/**
 解密帝视媒体数据。
 原地解密数据。
 
 @param secretKey 解密秘钥
 @param decryptionRules 解密规则
 @param frameDataType 待解密的数据类型
 @param originalMediaData 待解密的原始媒体数据
 @param originalDataLength 待解密的原始媒体数据长度
 @param decryptedDataLength 解密后的媒体数据大小
 @return 0成功，非0表示失败
 */
- (int) decryptGodSeesMediaDataWithSecretKey:(NSString *)secretKey
                             decryptionRules:(QHVCNetGodSeesDecryptionRules)decryptionRules
                               frameDataType:(QHVCNetGodSeesFrameDataType)frameDataType
                           originalMediaData:(uint8_t *)originalMediaData
                          originalDataLength:(int)originalDataLength
                         decryptedDataLength:(int *)decryptedDataLength;


#pragma mark - 文件下载 -

/**
 获取设备文件下载的链接
 
 @param fileKey 指定设备上的文件的标识符
 @param clientId 客户端ID,每个设备需要唯一，用户多端登录时用来区分链接
 @param appId 应用appId，在帝视官网后台申请
 @param userId 用户ID
 @param serialNumber 设备唯一标识
 @param businessSign 业务签名,帝视鉴定SDK业务的合法性，签名需要由业务服务器下发，密钥在帝视官网获取
 @param token 待设备验证的标识，该标识由业务服务器验证合法性，字符串长度不能超过63个字符
 @param rangeStart 请求文件内容的起始位置，与http的range语义相同
 @param rangeEnd 请求文件内容的结束位置，与http的range语义相同
 @param resultUrlString 获取的下载链接，如果返回成功的，不为nil，否则为nil
 @return 0成功，非0表示失败
 */
- (int) getDeviceFileDownloadUrlWithFileKey:(NSString *)fileKey
                                   clientId:(NSString *)clientId
                                      appId:(NSString *)appId
                                     userId:(NSString *)userId
                               serialNumber:(NSString *)serialNumber
                               businessSign:(NSString *)businessSign
                                      token:(NSString *)token
                                 rangeStart:(NSUInteger)rangeStart
                                   rangeEnd:(NSUInteger)rangeEnd
                            resultUrlString:(NSString *_Nonnull *_Nullable)resultUrlString;

#pragma mark - 全局公共方法 -

/**
 设置用户ID
 帝视需要强制设置用户ID，请在调用startLocalServer前优先调用该方法，会话链接和用户ID相关
 
 @param userId 用户ID
 */
- (void) setGodSeesUserId:(NSString *)userId;


/**
 启用测试环境
 
 @param testEnv YES：启用；NO：关闭
 @return 0：成功，非0:失败
 */
- (int) enableTestEnvironment:(BOOL)testEnv;


/**
 设置帝视网络连接方式
 可以是多种方式的组合，默认值: netConnectType = QHVC_NET_GODSEES_NETWORK_CONNECT_TYPE_P2P | QHVC_NET_GODSEES_NETWORK_CONNECT_TYPE_RELAY | QHVC_NET_GODSEES_NETWORK_CONNECT_TYPE_DIRECT_IP
 
 @param networkConnectType 网络连接类型
 */
- (void) setGodSeesNetworkConnectType:(QHVCNetGodSeesNetworkConnectType)networkConnectType;


/**
 设置帝视设备IP直连网络地址
 
 @param serialNumber 设备唯一标识
 @param ip ip地址。值为NULL时，删除原来的ip地址
 @param port 设备侦听端口
 @return 0成功，非0表示失败
 */
- (int) setGodSeesDeviceNetworkAddress:(NSString *)serialNumber
                                    ip:(NSString *)ip
                                  port:(NSInteger)port;


/**
 设置p2p连接成功最大等待时间
 调用时机：createGodSeesSession之前调用
 
 @param timeMS 等待时间，单位：毫秒，默认值：1000毫秒
 */
- (void) setGodSeesP2PConnectionSucceedMaxWaitTime:(NSInteger)timeMS;


/**
 开启/关闭视频状态监控
 开启监控，SDK将会触发didNetMonitorInfo回调
 
 @param enable YES 监控,NO 不监控，默认值:NO
 */
- (void) enableGodSeesMonitorVideoState:(BOOL)enable;


/**
 预连接设备
 用于提前建立网络通道，节省用户拉取视频等待时间，提高用户体验
 
 @param serialNumber 需要预连的设备Id
 @param deviceChannelNumber 设备通道号
 @return 0成功，非0表示失败
 */
- (int) preConnectGodSeesDevice:(NSString *)serialNumber
            deviceChannelNumber:(NSInteger)deviceChannelNumber;


/**
 帝视创建网络会话实例
 
 @param sessionId 实例会话ID
 @param clientId 客户端ID,每个设备需要唯一，用户多端登录时用来区分链接
 @param appId 应用appId，在帝视官网后台申请
 @param userId 用户ID
 @param serialNumber 设备唯一标识
 @param deviceChannelNumber 设备管道号，从索引1开始[1, ...]
 @param businessSign 业务签名,帝视鉴定SDK业务的合法性，签名需要由业务服务器下发，密钥在帝视官网获取
 @param sessionType 会话类型:直播/卡录/文件下载等
 @param options 可为nil @{@"streamType":@(QHVCNetGodSeesStreamType),@"playerReceiveDataModel":@(QHVCNetGodSeesPlayerReceiveDataModel)}
 @return 0成功，非0表示失败
 */
- (int) createGodSeesSession:(NSString *)sessionId
                    clientId:(NSString *)clientId
                       appId:(NSString *)appId
                      userId:(NSString *)userId
                serialNumber:(NSString *)serialNumber
         deviceChannelNumber:(NSInteger)deviceChannelNumber
                businessSign:(NSString *)businessSign
                 sessionType:(QHVCNetGodSeesSessionType)sessionType
                     options:(NSDictionary *)options;


/**
 销毁帝视网络会话实例
 
 @param sessionId 实例会话ID
 */
- (int) destroyGodSeesSession:(NSString *)sessionId;


/**
 获取帝视指定会话的播放链接
 
 @param sessionId 实例会话ID
 @return 成功:对应的播放链接；不成功:nil
 */
- (NSString *) getGodSeesPlayUrl:(NSString *)sessionId;


/**
 设备验证业务token
 该方法是异步操作，SDK将会触发didVerifyToken回调，然后，业务才可以进行一系列操作设置。若验证失败，SDK将会触发didError回调，请根据相关错误码进行逻辑处理。
 
 @param sessionId 实例会话ID
 @param token 验证信息，字符串长度不能超过500个字符
 @return 0成功，非0表示失败
 */
- (int) verifyGodSeesBusinessTokenToDevice:(NSString *)sessionId
                                     token:(NSString *)token;

/*
 **************************************************************************************************************
 * 特别注意：下面的方法一定要等设备授权通过后才能调用。
 * 即调用verifyGodSeesBusinessTokenToDevice函数通知设备验证token成功，待回调didVerifyToken执行后，才能调用下面的接口
 **************************************************************************************************************
 */

#pragma mark - 直播相关 -

#pragma mark - 卡录相关 -

/**
 获取卡录时间轴信息
 该方法是异步操作，SDK将会触发didRecordTimeline回调，然后，业务才可以进行一系列操作设置。若加载失败，SDK将会触发didError回调，请根据相关错误码进行逻辑处理。
 
 @param sessionId 实例会话ID
 @return 0成功，非0表示失败
 */
- (int) getGodSeesRecordTimeline:(NSString *)sessionId;


/**
 观看指定时间戳之后的卡录
 该方法是异步操作，SDK将会触发onGodSeesRecordSeekComplete回调，然后，业务才可以进行一系列操作设置。若加载失败，SDK将会触发didError回调，请根据相关错误码进行逻辑处理。
 
 @param sessionId 实例会话ID
 @param timeStampByMS 指定时间点（单位：毫秒）
 @return 0成功，非0表示失败
 */
- (int) setGodSeesRecordSeek:(NSString *)sessionId
                   timeStamp:(NSUInteger)timeStampByMS;


/**
 暂停观看卡录
 该方法是异步操作，SDK将会触发onGodSeesRecordPause回调，然后，业务才可以进行一系列操作设置。若加载失败，SDK将会触发didError回调，请根据相关错误码进行逻辑处理。
 
 @param sessionId 实例会话ID
 @return 0成功，非0表示失败
 */
- (int) setGodSeesRecordPause:(NSString *)sessionId;


/**
 恢复观看卡录
 该方法是异步操作，SDK将会触发onGodSeesRecordResume回调，然后，业务才可以进行一系列操作设置。若加载失败，SDK将会触发didError回调，请根据相关错误码进行逻辑处理。
 
 @param sessionId 实例会话ID
 @return 0成功，非0表示失败
 */
- (int) setGodSeesRecordResume:(NSString *)sessionId;


/**
 设置观看卡录速度
 该方法是异步操作，SDK将会触发didRecordPlaybackRate回调，然后，业务才可以进行一系列操作设置。若加载失败，SDK将会触发didError回调，请根据相关错误码进行逻辑处理。
 
 @param sessionId 实例会话ID
 @param rate 速度倍数，默认:1倍速
 @return 0成功，非0表示失败
 */
- (int) setGodSeesRecordPlayRate:(NSString *)sessionId
                            rate:(double)rate;

@end

NS_ASSUME_NONNULL_END
