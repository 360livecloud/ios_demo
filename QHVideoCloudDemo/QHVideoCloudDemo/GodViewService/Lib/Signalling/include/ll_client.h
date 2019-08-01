#ifndef _HDY_LL_SUBCLIENT_H_HH_
#define _HDY_LL_SUBCLIENT_H_HH_

#include <cstddef>

#include "ll_callback.h"

namespace dsdk {

/* write log level */
#define LL_LOG_DEBUG     0x00000001
#define LL_LOG_INFO      0x00000002
#define LL_LOG_WARN      0x00000004
#define LL_LOG_FATAL     0x00000008

typedef void (*ll_log_func) (int level, const char* log);

enum mqtt_message_qos {
    /* Fire and forget - the message may not be delivered. */
    mqtt_msg_qos_maybe_once     = 0,
    /* At least once - the message will be delivered, but may be delivered more than once in some circumstances. */
    mqtt_msg_qos_least_once,
    /* Once and one only - the message will be delivered exactly once. */
    mqtt_msg_qos_only_once
};

class ll_client
{
 public:
    /*
     * @param cid: client identifier
     * @param callback :
     * */
    ll_client(const char* cid, ll_callback* callback, ll_log_func log_func = NULL);
    virtual ~ll_client();
    /*
     * @param server: format tcp://ip:port
     * */
    bool connect(const char* server);
    bool connect(const char* server, const char* username, const char* password);
    bool is_connected();
    /*
     * @param topic : can subscribe multi topic.
     * */
    bool subscribe(const char* topic, mqtt_message_qos qos=mqtt_msg_qos_maybe_once);
    bool unsubscribe(const char* topic);

    /*
     * @param message : message buffer
     * @param len     : message buffer lenght
     * @param topic
     * @param qos     : 0: Fire and forget - the message may not be delivered.
     *                  1: At least once - the message will be delivered, but may be delivered more than once in some circumstances.
     *                  2: Once and one only - the message will be delivered exactly once.
     * @return value  : >0 message seq number; =0 failed.
     * */
    int  publish(const void* message, int len, const char* topic, mqtt_message_qos qos=mqtt_msg_qos_maybe_once);

 private:
    void* _priv;
};

};

#endif // _HDY_LL_SUBCLIENT_H_HH_

