//
//  QHVCNet+GodSees.h
//  QHVCNetKit
//
//  Created by yangkui on 2019/4/25.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCNet.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 外部属性定义 -
extern NSString* const kQHVCNetGodSeesOptionsStreamTypeKey;//用于设置码流，类型见QHVCNetGodSeesStreamType
extern NSString* const kQHVCNetGodSeesOptionsPlayerReceiveDataModelKey;//用于设置播放模式，类型见QHVCNetGodSeesPlayerReceiveDataModel
extern NSString* const kQHVCNetGodSeesOptionsMaxReconnectCountKey;//最大重连次数，默认3次

#pragma mark - 枚举定义 -

/**
 SDK错误码
 */
typedef NS_ENUM(NSInteger, QHVCNetGodSeesErrorCode)
{
    QHVC_NET_GODSEES_ERROR_NO_ERROR = 0,                         //无错误
    QHVC_NET_GODSEES_ERROR_ARGUMENT_INVALID,                     //参数无效
    QHVC_NET_GODSEES_ERROR_BUFFER_SIZE_TOO_SMALL,                //BUFFER SIZE太小
    QHVC_NET_GODSEES_ERROR_LOCAL_SERVER_LISTEN_ADDRESS_INVALID,  //LocalServer 本地侦听地址无效
    QHVC_NET_GODSEES_ERROR_FRAME_DECRYPT_KEY_INVALID,            //解密音视频的key无效
    QHVC_NET_GODSEES_ERROR_SESSION_DISCONNECT,                   //网络会话链接断开
    QHVC_NET_GODSEES_ERROR_CLIENT_ID_INVALID,                    //client id无效
    QHVC_NET_GODSEES_ERROR_APP_ID_INVALID,                       //app id无效
    QHVC_NET_GODSEES_ERROR_USER_ID_INVALID,                      //user id无效
    QHVC_NET_GODSEES_ERROR_SESSION_ID_INVALID,                   //session id无效
    QHVC_NET_GODSEES_ERROR_SERIAL_NUMBER_INVALID,                //设备号码无效
    QHVC_NET_GODSEES_ERROR_CHANNEL_NUMBER_INVALID,               //通道号码无效
    QHVC_NET_GODSEES_ERROR_USER_SIGN_INVALID,                    //用户签名无效
    QHVC_NET_GODSEES_ERROR_TOKEN_INVALID,                        //签名无效
};

/**
 网络连接类型
 */
typedef NS_ENUM(NSInteger, QHVCNetGodSeesNetworkConnectType)
{
    QHVC_NET_GODSEES_NETWORK_CONNECT_TYPE_P2P              = 1,//p2p
    QHVC_NET_GODSEES_NETWORK_CONNECT_TYPE_RELAY            = (1<<1),//云端
    QHVC_NET_GODSEES_NETWORK_CONNECT_TYPE_DIRECT_IP        = (1<<2),//IP直连
};

/**
 会话类型
 */
typedef NS_ENUM(NSInteger, QHVCNetGodSeesSessionType)
{
    QHVC_NET_GODSEES_SESSION_TYPE_LIVE = 1,  //直播
    QHVC_NET_GODSEES_SESSION_TYPE_RECORD,    //回放
    QHVC_NET_GODSEES_SESSION_TYPE_FILE_DOWNLOAD, //文件下载
};

/**
 码流类型
 码流大小根据硬件设备性能自定义
 */
typedef NS_ENUM(NSInteger, QHVCNetGodSeesStreamType)
{
    QHVC_NET_GODSEES_STREAM_TYPE_MAIN = 1,  // 主码流
    QHVC_NET_GODSEES_STREAM_TYPE_SUB,       // 子码流
    QHVC_NET_GODSEES_STREAM_TYPE_THIRD,     // 第三码流
};

/**
 播放器接收数据的方式
 */
typedef NS_ENUM(NSInteger,QHVCNetGodSeesPlayerReceiveDataModel)
{
    QHVC_NET_GODSEES_PLAYER_RECEIVE_DATA_MODEL_CALLBACK = 1,  //SDK将音视频帧数据通过回调抛出来，由业务塞给播放器播放。此模式可以在码流里附加自定义数据，同时让业务有机会对音视频帧数据进行中间处理
    QHVC_NET_GODSEES_PLAYER_RECEIVE_DATA_MODEL_HTTP_FLV,      //QHVCNetKit生成标准http-flv格式数据，业务使用本地代理产生的url给播放器进行播放
};

/**
 数据帧类型
 */
typedef NS_ENUM(NSInteger, QHVCNetGodSeesFrameDataType)
{
    QHVC_NET_GODSEES_FRAME_DATA_TYPE_H264 = 1,    // h264
    QHVC_NET_GODSEES_FRAME_DATA_TYPE_H265,        // h265
    QHVC_NET_GODSEES_FRAME_DATA_TYPE_AAC,         // aac
};

/**
 解密规则
 */
typedef NS_ENUM(NSInteger, QHVCNetGodSeesDecryptionRules)
{
    QHVC_NET_GODSEES_DECRYPTION_RULES_NONE = 0,   //无密
    QHVC_NET_GODSEES_DECRYPTION_RULES_XOR = 1,    //XOR方式
    QHVC_NET_GODSEES_DECRYPTION_RULES_RC4,        //RC4方式
};


/**
 卡录数据录制类型
 */
typedef NS_ENUM(NSInteger, QHVCNetGodSeesRecordDataType)
{
    QHVC_NET_GODSEES_RECORD_DATA_TYPE_NORMAL = 0,    //正常模式，全部录制
    QHVC_NET_GODSEES_RECORD_DATA_TYPE_PICTURE_CHANGE,//图像变化模式，简单判断图像内容变化时录制
    QHVC_NET_GODSEES_RECORD_DATA_TYPE_INTELLIGENT,   //智能模式，检测到特定物体出现时录制
};

#pragma mark - 数据结构定义 -

/**
 卡录时间轴数据结构
 */
@interface QHVCNetGodSeesRecordTimeline : NSObject

@property(nonatomic, assign) NSUInteger startMS;//开始时间。单位：毫秒
@property(nonatomic, assign) NSUInteger durationMS;//持续时间。单位：毫秒
@property(nonatomic, assign) QHVCNetGodSeesRecordDataType recordDataType;//数据录制类型

@end

#pragma mark - 代理回调 -

@protocol QHVCNetGodSeesDelegate <NSObject>

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

#pragma mark - SDK实现 -
@interface QHVCNet (GodSees)

@property (nonatomic, weak) id<QHVCNetGodSeesDelegate> godSeesDelegate;//代理回调

#pragma mark - 静态方法 -

#pragma mark - 私有方法 -

/**
 初始化帝视数据，业务禁止调用
 若启动localServer时配置了帝视服务，此方法会在启动localServer后自动调用
 */
- (void) privateGodSeesInitData;

/**
 帝视重新连接视频，业务禁止调用
 适用于：网络发生变化、前后台切换、解锁
 */
- (void) privateGodSeesReconnect;

/**
 通知SDK将要进入前台，业务禁止调用
 */
- (void) privateGodSeesWillEnterForeground;

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
 开启监控，SDK将会触发didMonitorNetworkInfo回调
 
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
