
#ifndef __CLIENT_NET_STATISTICS_ENTRYS_H_
#define __CLIENT_NET_STATISTICS_ENTRYS_H_

#ifdef __cplusplus
extern "C" {
#endif

/**
 * 连麦feedback结果回调函数原型
 * @param result feedback结果 0表示成功 否则为错误码
 * @param ctx 上下文
 */
typedef void (*rtc_notify_cb)(int result, void *ctx);

typedef enum
{
    ST_FORM_UPLOAD = 1, ///< 表单上传
    ST_SLICE_REQUEST, ///< 分片Request
    ST_BLOCK_UPLOAD, ///< block上传
    ST_MEMORY_UPLOAD, ///< 内存上传
    ST_COMMIT, ///< commit
    ST_FINISH, ///< finish
    ST_CANCEL, ///< 取消上传
    ST_SPEED_TEST ///< 
} StageType;

typedef struct
{
    const char *uri; ///< 目标URI
    const char *dip; ///< 目标机器IP
    unsigned int conTime; ///< 连接时间
    unsigned int respTime; ///< 响应时间
    unsigned int avgSpeed; ///< 平均速度
    unsigned long long totalBytes; ///< 字节数
    int errCode; ///< 错误码
    int blockID; ///< block编号
    unsigned int retryCnt; ///< 重试次数
} UploadDataInfo;

typedef struct
{
    bool m_dnsCacheEnable;
    unsigned int m_dnsCacheSeconds;
    unsigned int m_time_adjust_threshold;
    unsigned short m_enable;
} CloudControlTrans;

#ifdef __cplusplus
}
#endif

#endif

