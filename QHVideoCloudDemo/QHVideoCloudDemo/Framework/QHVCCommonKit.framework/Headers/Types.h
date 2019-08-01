
#ifndef __CLIENT_NET_TYPES_H_
#define __CLIENT_NET_TYPES_H_

#include <stddef.h>

#if (defined(WIN32) || defined(WIN64))
    #include <WinSock2.h>
#else
    #include <sys/socket.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#if (defined(WIN32) || defined(WIN64))
    #define EXPORT_API __declspec(dllexport)
#else
    #define EXPORT_API __attribute__ ((visibility("default")))
#endif

typedef int CORE_HANDLE;

/// 日志级别 
enum ELogLevel
{
    LOG_LEVEL_TRACE_WE = 0,
    LOG_LEVEL_DEBUG_WE,
    LOG_LEVEL_INFO_WE,
    LOG_LEVEL_WARN_WE,
    LOG_LEVEL_ERROR_WE,
    LOG_LEVEL_ALARM_WE,
    LOG_LEVEL_FATAL_WE,
    LOG_LEVEL_NONE_WE, 
};

/// 行为
enum EType
{
    ETYPE_UNKNOWN = -1, ///< 无效值 内部使用
    ETYPE_PLAY = 0, ///< 观看
    ETYPE_PUBLISH = 1, ///< 推流
    ETYPE_PRE = 9 ///< 预调度内部使用
};

/// 协议
enum EProto
{
    EPROTO_UNKNOWN = 0, /**< 无效协议 */
    EPROTO_AUTO = 1, /**< 自动 */
    EPROTO_RELAY = 2, /**< Relay */
    EPROTO_RTMP = 3, /**< RTMP */
    EPROTO_RTMP_1 = 4, /**< 强制走网宿的某一个ps链路 */
    EPROTO_FLV = 5, /**< FLV */
    EPROTO_MP4 = 6, /**< MP4 */
    EPROTO_M3U8 = 7 /**< M3U8 */
};

/// 发送数据时帧类型
enum EFrameTypeSend
{
    FRAME_AUDIO_SEND = 0, /**< 音频帧 */
    FRAME_VIDEO_SEND = 1 /**< 视频帧 */
};

/// 事件回调时的事件类型
enum EEvent
{
    EVENT_UNKNOWN = 0, /**< 非法事件 */
    EVENT_CONNECTED, /**< 成功连接到服务器(BinaryInfo*) */
    EVENT_CONNECT_FAILED, /**< 连接失败(无参数或int*) */
    EVENT_DISCONNECTED, /**< 连接断开(无参数) */
    EVENT_SN_ARRIVAL, /**< 调度成功(ServerAddrs*) */
    EVENT_SN_FAILED = 5, /**< 调度失败(int*) */
    EVENT_STREAM_CONNECT_FAIL, /**< 开流失败(无参数) */
    EVENT_STREAM_CONNECT, /**< 开流成功(无参数) */
    EVENT_STREAM_FINISH, /**< 主播推流结束(无参数) */
    EVENT_WRITELOCAL_FAILED, /**< 本地录制失败(无参数或WriteLocalEvent*) */
    EVENT_DROP_FRAME = 10, /**< 丢帧，内部事件 */
    EVENT_NEED_RESCHEDULING, /**< 需要重新调度(unsigned int*) */
    EVENT_NOT_HEALTHY_TRANS, /**< 推流效果较差（无参数）*/
    EVENT_RECONNECTING_START, /**< 开始重连（无参数） */
    EVENT_START_CHANNEL_OK, ///< 申请嘉宾成功(int*，嘉宾id)
    EVENT_STOP_CHANNEL_OK = 15, ///< 取消嘉宾成功(int*, 嘉宾id)
    EVENT_START_CHANNEL_FAILED, ///< 申请嘉宾失败(无参数)
    EVENT_START_PREVIEW, ///< 开始预览(int*，嘉宾id)
    EVENT_CHANNEL_ADD, ///< 增加一个嘉宾(UserOne*)
    EVENT_CHANNEL_DELETE, ///< 减少一个嘉宾(UserOne*)
    EVENT_CHANNEL_KICK = 20, ///< 踢掉一个嘉宾(int*, 嘉宾id)
    EVENT_SET_CHANNEL_AUDIO, ///< 关闭或打开一个嘉宾的声音(StatusToUpper*)
    EVENT_SET_CHANNEL_VIDEO, ///< 关闭或打开一个嘉宾的画面(StatusToUpper*)
    EVENT_SET_CHANNEL_NUM, ///< 设置嘉宾最大数量(int*)
    EVENT_APPLY_FOR_CHANNEL, ///< 申请一个嘉宾(char*，嘉宾名字)
	EVENT_USE_HWENCODER = 100, /**< 使用硬编码(无参数) */
    EVENT_AUTOADJUST_BITRATE, /**< 自适应码率（int*) */

    EVENT_DATA_RECEIVE = 999 /**< 内部事件 */
};

/// 调度返回信息结构
#define c_maxBackAddr (3)
struct ServerAddrs
{
    enum EProto proto; ///< 协议类型
    const char *appKey; ///< app key
    const char *sn; ///< SN
    const char *encodeType; ///< 转码标识 h265或其他值
    const char *mainAddr; ///< 推流或看流地址
    const char *backAddr[c_maxBackAddr + 1]; ///< 备用地址
    const char *sn_alias;
    const char *publicMainAddr;

    int isRTC; ///< 是否rtc 1表示是 0表示不是
    int isMerge; ///< 是否合流 -1为无效值
    const char *isp; ///< 连麦服务商
    const char *appID; ///< 连麦的appID
    const char *token; ///< 连麦的token
    const char *aesKey; ///< 连麦的aesKey
};

/// 本地录制事件
enum WriteLocalEvent
{
    WRITE_SAMPLE_FAILED = 1, /**< 本地录制失败 */
    INVALID_FILE = 2, /**< 无效的存储位置 */
    ILLEGAL_TS = 3 /**< 非法的时间戳 */
};

struct BinaryInfo
{
    const unsigned char *data; ///< 二进制数据
    size_t len; ///< 二进制数据长度
};
 
/// 帧类型
enum EFrameType
{
	FRAME_TYPE_UNKNOWN = -1, /**< 非法类型 */
    FRAME_TYPE_AUDIO, /**< OPUS */
    FRAME_TYPE_VIDEO_IDR, /**< IDR帧 */
    FRAME_TYPE_VIDEO_P, /**< P帧 */
    FRAME_TYPE_VIDEO_B, /**< B帧 */
    FRAME_TYPE_CONTROL, /**< 内部使用的帧类型 */
	FRAME_TYPE_AAC, /**< AAC */
    FRAME_TYPE_VIDEO_EXTRADATA,  /**<视频附加数据 （对于H264，这里是AVCDecoderConfigurationRecord, 对应ffmpeg里处理的extradata） */
    FRAME_TYPE_AUDIO_EXTRADATA   /**<音频附加数据  (对于AAC，这里是AudioSpecificConfig) */
};

/// 错误码
enum EErrCode
{
    TERROR_SUCCESS = 0, /**< 成功 */
    TERROR_INVALID_HANDLE    = -1, /**< 非法的实例句柄 */
    TERROR_INVALID_PARAM     = -2, /**< 非法参数 */
    TERROR_NOT_SUPPORT       = -3, /**< 不支持该操作 */
    TERROR_NOT_INITIALIZED   = -4, /**< 未初始化 */
    TERROR_BAD_CALL_SEQUENCE = -5, /**< 错误的调用顺序 */
    TERROR_SERVER = -6, ///< 与服务端通信错误
    TERROR_UNKNOWN           = -999, /**< 未知错误 */
};

/**
 * 事件回调函数原型
 * @param c 实例句柄
 * @param e 事件类型
 * @param param 事件参数
 * @param context 透传context
 */
typedef void (*event_callback_t)(CORE_HANDLE c, enum EEvent e, const void *param, void *context);

/**
 * 数据回调函数原型
 * @param c 实例句柄
 * @param type 帧类型
 * @param buffer 数据
 * @param length 数据长度
 * @param context 上下文
 */
typedef void (*frame_callback_t)(CORE_HANDLE c, enum EFrameType type, const char *buffer, int length, void *context);

/**
 * 编码后数据回调函数原型
 * @param c 实例句柄
 * @param type 帧类型
 * @param buffer 数据
 * @param length 数据长度
 * @param ts 时间戳
 * @param context 上下文
 */
typedef void (*encoded_callback_t)(CORE_HANDLE c, enum EFrameType type, const unsigned char *buffer, unsigned int length, 
                                   unsigned long long ts, void *context);

/**
 * 日志模块输出函数原型
 * @param loggerID logger id
 * @param level 日志级别
 * @param data 输出内容
 */
typedef void (*print_cb)(int loggerID, enum ELogLevel level, const char *data);

struct addrinfo_dns
{
    int ai_flags;
    int ai_family;
    int ai_socktype;
    int ai_protocol;
    size_t ai_addrlen;
    struct sockaddr_storage ai_addr;
    struct addrinfo *ai_next;
};

/// 配置项
struct BaseSettings
{
    const char *sid; ///< 实例唯一ID

    event_callback_t event_cb; ///< 事件回调函数
    void *event_context; ///< 事件回调函数上下文
    frame_callback_t frame_cb; ///< 数据回调函数
    void *frame_context; ///< 数据回调函数上下文

    int retry_max; ///< 连接断开后重连尝试次数(私有)或尝试的时间(公有)
    int retry_maxTime; ///< 最长重试连接时间，默认180s
};

typedef struct
{
    unsigned int m_videoFrames; ///< 本次上报周期内视频帧数量
    unsigned int m_audioFrames; ///< 本次上报周期内音频帧数量
    unsigned long long m_bytes; ///< 本次上报周期内字节数
    unsigned int m_queueLen; ///< 队列长度
    unsigned long long m_queueBytes; ///< 队列内数据字节数
    unsigned int m_dropFrames; ///< 丢帧数
    unsigned int m_greater100ms; ///< 收到的数据时间戳间隔超过100ms的帧数
    unsigned int m_greater200ms; ///< 收到的数据时间戳间隔超过200ms的帧数
    unsigned int m_greater300ms; ///< 收到的数据时间戳间隔超过300ms的帧数
} StreamInfo;

typedef struct
{
    StreamInfo m_variantInfo;

    int m_connectionStatus; ///< 连接状态 0表示连接正常 1表示其他
    int m_proto; ///< 协议 0表示TCP 1表示UDP 2表示RTMP
    int m_eof; ///< 是否结束 0表示未结束 1表示结束
    int m_eofReason; ///< 结束原因 由业务设定
    int m_hardEncoderFlag; ///< 硬编标记 0表示软编 1表示硬编
    unsigned int m_retryCount; ///< 重连次数
    unsigned int m_switchCount; ///< 切换次数 暂时不使用
    unsigned int m_width; ///< 编码宽
    unsigned int m_height; ///< 编码高
    int m_trans264; ///< 转码264开关 0表示关闭 1表示开启 默认值为1
} StreamStatus;

// 一些可选参数
typedef struct
{
    char brand[20];
    char sysver[20];
} OptionalParams;

/**
 * 返回传输层版本号
 * @return 传输层版本号
 */
static __inline const char *transport_version(void)
{
    return "2.5.0.19072201";
}

#ifdef __cplusplus
}
#endif
#endif

