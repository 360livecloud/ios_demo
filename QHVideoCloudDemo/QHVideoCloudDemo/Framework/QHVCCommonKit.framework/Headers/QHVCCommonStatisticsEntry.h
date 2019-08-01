//
//  QHVCCommonStatisticsEntry.h
//  QHVCCommonKit
//
//  Created by deng on 2017/9/8.
//  Copyright © 2017年 qihoo 360. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Types.h"
#import "statistics_entryS.h"

@interface QHVCCommonStatisticsEntry : NSObject

/**
 * 设置打点地址和云控地址 格式参考默认地址: http://qos.live.360.cn/vc.gif http://fb.live.360.cn/fb.gif http://sdk.live.360.cn/
 * @param url 打点地址
 * @param urlFB feedback地址
 * @param urlMicFB Mic feedback地址
 */
+ (void)setNotifyUrl:(NSString *)url
         feedbackUrl:(NSString *)urlFB
      micFeedbackUrl:(NSString *)urlMicFB;

/**
 * 用户点击开始时调用 必须作为每个session第一个调用的SDK接口
 * @param sessionId 会话唯一标识
 * @param userId 用户ID
 * @param channelId channelID
 * @param net 网络类型
 * @param sn 资源标识
 * @param kvList 以&和=分隔和连接的kv列表, 例如&k1=v1&k2=v2&k3=v3
 */
+ (void)userStart:(NSString *)sessionId
           userId:(NSString *)userId
        channelId:(NSString *)channelId
              net:(NSString *)net
               sn:(NSString *)sn
           kvList:(NSDictionary *)kvList;

/**
 * 调用notify_player_destroy或notify_pub_destroy后，没必要调用该接口
 * 否则必须调用；与这两个接口调用规则一致
 * @param sessionId 会话唯一标识
 */
+ (void)userDestroy:(NSString *)sessionId;

/**
 * 用户点击结束时调用
 * @param sessionId 会话唯一标识
 */
+ (void)userStop:(NSString *)sessionId;

/**
 用户点击结束时调用
 @param sessionId 会话唯一标识
 @param paras kvlist
 */
+ (void)userStop:(NSString *)sessionId params:(const char *)paras;

/**
 * 用户app切到后台时调用
 * @param sessionId 会话唯一标识
 */
+ (void)userBackground:(NSString *)sessionId;

/**
 * 用户app回到前台时调用
 * @param sessionId 会话唯一标识
 */
+ (void)userForeground:(NSString *)sessionId;

/**
 * 播放器初始化时调用
 * @param sessionId 会话唯一标识
 */
+ (void)playerInit:(NSString *)sessionId;

/**
 * 播放器开始工作时调用
 * @param sessionId 会话唯一标识
 */
+ (void)playerOpen:(NSString *)sessionId;

/**
 * 播放器开始缓冲数据时调用
 * @param sessionId 会话唯一标识
 */
+ (void)playerBuffering:(NSString *)sessionId;

/**
 * 播放器开始播放时调用
 * @param sessionId 会话唯一标识
 */
+ (void)playerPlaying:(NSString *)sessionId;

/**
 * 用户操纵播放位置时调用
 * @param sessionId 会话唯一标识
 * @param position 定位位置标识
 */
+ (void)playerSeek:(NSString *)sessionId
          position:(unsigned int)position;

/**
 * 播放器销毁时调用
 * @param sessionId 会话唯一标识
 * @param reason 关闭原因 由业务传下来
 */
+ (void)playerDestroy:(NSString *)sessionId
               reason:(int)reason;

/**
 * 播放器出错时调用
 * @param sessionId 会话唯一标识
 * @param errMsg 错误信息
 * @param errCode 错误码
 */
+ (void)playerError:(NSString *)sessionId
             errMsg:(NSString *)errMsg
            errCode:(int)errCode;

/**
 * 播放器上报端到端延迟时调用
 * @param sessionId 会话唯一标识
 * @param jplayer 是否直播
 * @param frameCount frame缓冲个数
 * @param currentTime 调用方当前时间
 * @param hostTime 解析出来的主播时间
 * @param diff 服务端返回的diff
 * @param diffAV 当前音视频差
 * @param cacheDuration 播放器buffer缓冲的时间
 * @param delta 端到端延迟
 */
+ (void)playerDelay:(NSString *)sessionId
            jplayer:(int)jplayer
         frameCount:(int)frameCount
        currentTime:(long long)currentTime
           hostTime:(long long)hostTime
               diff:(long long)diff
             diffAV:(long long)diffAV
      cacheDuration:(long)cacheDuration
              delta:(long)delta;

/**
 * 上报播放时是否启用硬解
 * @param sessionId 会话唯一标识
 * @param isHwDecode 是否启用硬解
 * @param isFailed 上次解码是否失败
 */
+ (void)playerDecodeType:(NSString *)sessionId
              isHwDecode:(BOOL)isHwDecode
                isFailed:(BOOL)isFailed;

/**
 * 推流开始工作时调用
 * @param sessionId 会话唯一标识
 */
+ (void)publishOpen:(NSString *)sessionId;

/**
 * 推流销毁时调用
 * @param sessionId 会话唯一标识
 */
+ (void)publishDestroy:(NSString *)sessionId;

/**
 * 上报feedback打点
 * @param sessionId 会话唯一标识
 * @param deltaInMS 本次上报与上次的间隔
 * @param deltaBeginInMS 本次上报与第一次的间隔
 * @param uri 推流地址完整uri
 * @param newPublishAddr 暂时不使用
 * @param info 相关数据，请参考comn/Types.h
 */
+ (void)streamStatusExport:(NSString *)sessionId
                 deltaInMS:(long)deltaInMS
            deltaBeginInMS:(long)deltaBeginInMS
                       uri:(NSString *)uri
            newPublishAddr:(NSString *)newPublishAddr
                      info:(const StreamStatus *)info;

/**
 * 连麦feedback打点
 * @param sessionId 会话唯一标识
 * @param kvList 以&和=分隔和连接的kv列表, 例如&k1=v1&k2=v2&k3=v3，v部分必须urlencode
 * @param cb feedback结果回调
 * @param ctx 上下文
 */
+ (void)rtcStreamStatus:(NSString *)sessionId
                 kvList:(NSDictionary *)kvList
            rtcCallback:(rtc_notify_cb)cb
                    ctx:(void *)ctx;

/**
 * 连麦合流feedback打点
 * @param sessionId 会话唯一标识
 * @param kvList 以&和=分隔和连接的kv列表, 例如&k1=v1&k2=v2&k3=v3，v部分必须urlencode
 * @param cb feedback结果回调
 * @param ctx 上下文
 */
+ (void)rtcMergeStreamStatus:(NSString *)sessionId
                      kvList:(NSDictionary *)kvList
                 rtcCallback:(rtc_notify_cb)cb
                         ctx:(void *)ctx;

/**
 * 设置打点的pro字段
 * @param sessionId 会话唯一标识
 * @param type 值
 */
+ (void)setOEM:(NSString *)sessionId
          type:(NSString *)type;

/**
 * 通知wifi强度数值
 * @param quality wifi强度数值
 */
+ (void)setWIFIQuality:(int)quality;

/**
 * 通知cpu, gpu使用率
 * @param cpuStatus cpu使用率
 * @param gpuStatus gpu使用率
 */
+ (void)setUsageStatus:(double)cpuStatus
             gpuStatus:(double)gpuStatus;

/**
 * 通知GPS，时区信息
 * @param longitude 经度
 * @param latitude 纬度
 */
+ (void)setGPSZoneInfo:(double)longitude
              latitude:(double)latitude;

/**
 * 小视频上传打点
 * @param info 打点完整信息
 */
+ (void)setShortvideoUpload:(NSString *)info;

/**
 * 上传过程打点
 * @param sessionId 会话唯一标识
 * @param type stage type
 * @param info 相关信息
 */
+ (void)setUploadData:(NSString *)sessionId
                 type:(StageType)type
                 info:(const UploadDataInfo *)info;

/**
 * 通用打点
 * @param sessionId 会话唯一标识
 * @param businessSubID 业务子类型
 * @param stage stage
 * @param error error
 * @param kvList 以&和=分隔和连接的kv列表, 例如&k1=v1&k2=v2&k3=v3，v部分必须urlencode
 */
+ (void)setCommonStat:(NSString *)sessionId
        businessSubID:(NSString *)businessSubID
                stage:(int)stage
                error:(int)error
               kvList:(NSDictionary *)kvList;

/**
 * 获取服务器时间与本地时间的差
 * @param pdiff 出参，服务器时间与本地时间的差，单位毫秒
 * @return 1 表示成功 0 表示失败，暂未获得服务器时间与本地时间的差
 */
+ (int)serverLocalTimeDiff:(long long *)pdiff;

/**
 * 通知处理了一帧数据
 * @param sessionId 会话唯一标识
 * @param type 帧类型，暂未使用
 * @param len 帧大小，单位字节
 * @param timestamp 时间戳，暂未使用
 */
+ (void)notifyFrames:(NSString *)sessionId
           frameType:(unsigned int)type
            frameLen:(unsigned int)len
           timestamp:(unsigned long long)timestamp;

/**
 * 通知调度开始
 * @param sessionId 会话唯一标识
 */
+ (void)scheduleStart:(NSString *)sessionId;

/**
 * 通知连接开始
 * @param sessionId 会话唯一标识
 */
+ (void)connectionStart:(NSString *)sessionId;

/**
 * 通知连接结果
 * @param sessionId 会话唯一标识
 * @param errCode 一级错误码，具体可参考wiki
 * @param errDetail 二级错误码, 具体可参考wiki
 * @param dnsTime DNS解析时间
 * @param type 连接类型, 具体可参考wiki
 * @param uri 连接目标uri
 * @param ip 连接目标ip
 * @param port 连接目标端口
 */
+ (void)connectionResult:(NSString *)sessionId
                 errCode:(int)errCode
               errDetail:(int)errDetail
                 dnsTime:(unsigned int)dnsTime
                    type:(int)type
                     uri:(NSString *)uri
                      ip:(NSString *)ip
                    port:(unsigned short)port;

/**
 * 通知连接断开
 * @param sessionId 会话唯一标识
 */
+ (void)connectionBreak:(NSString *)sessionId
                errCode:(int)errCode
              errDetail:(int)errDetail;

/**
 *  @功能 获取统计基本信息
 *  @返回值 info
 @{@"businessId":@"",//第三方设置的业务ID
 @"deviceId":@"",//第三方设置的设备id
 @"appVersion":@""//第三方设置的业务版本号
 };
 */
+ (NSDictionary *)statisticsInfo;

/**
 更新H264转码状态
 @param sid 会话id
 @param isTrans 是否开启
 */
+ (void)notify_set_trans264:(NSString *)sid transH264:(BOOL)isTrans;

@end
