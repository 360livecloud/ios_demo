
#ifndef __CLIENT_NET_CORE_ENTRYS_H_
#define __CLIENT_NET_CORE_ENTRYS_H_

#ifdef __cplusplus
extern "C" {
#endif

typedef enum
{
    NC_TYPE_TOWIFI, /**< 移动网络变为WIFI */
    NC_TYPE_OTHERS /**< 其他网络变化类型 */
} NetworkChangeType;

#ifdef __cplusplus
}
#endif

#endif

