
#ifndef __CLIENT_NET_THE_SCHEDULE_ENTRYS_H_
#define __CLIENT_NET_THE_SCHEDULE_ENTRYS_H_

#ifdef __cplusplus
extern "C"{
#endif

/**
 * 调度结果回调函数原型
 * @param e 事件 请参考Types.h
 * @param sid 会话唯一标识
 * @param param 事件对应参数 请参考Types.h
 * @param ctx 上下文
 */
typedef void (*schedule_cb)(enum EEvent e, const char *sid, const void *param, void *ctx);

/**
 * 预调度参数
 */
typedef struct
{
    const char *uri; ///< 预调度地址 格式参考http://g2.live.360.cn/
    int delay; ///< 延迟多少秒收到数据
    enum EProto proto; ///< 协议 请参考Types.h
    const char *sn; ///< 资源标识
    const char *encode; ///< 转码标识 默认为H.264
    const char *rate; ///< 转码质量 默认为SD标清
    const char *streamType; ///< 流类型(audio, video, all) 默认为all
    const char *cid; ///< channelID
    const char *uid; ///< 用户ID
    const char *net; ///< 网络类型
    const char *sign; ///< 鉴权签名
} schedule_pre_params;

/**
 * 调度参数
 */
typedef struct
{
    const char *uri; ///< 调度地址 格式参考http://g2.live.360.cn/
    int delay; ///< 推流时无效 观看时表示延迟多少秒收到数据
    const char *rtc; ///< 是否是连麦的流 空字符串或NULL表示不是 否则表示是
    const char *userData; ///< 用户数据，透传到调度
    enum EType type; ///< 行为 请参考Types.h
    enum EProto proto; ///< 协议 请参考Types.h
    const char *encode; ///< 转码标识 默认为H.264
    const char *rate; ///< 转码质量 默认为SD标清
    const char *streamType; ///< 流类型(audio, video, all) 默认为all
    const char *ssn; ///< 主播开流的SN 只有嘉宾开流时需要
    const char *pksn; ///< PK模式另一个主播的SN
    const char *sign; ///< 鉴权签名
    schedule_cb cb; ///< 调度结果回调
    void *ctx; ///< 上下文
} schedule_params;

#ifdef __cplusplus
}
#endif

#endif

