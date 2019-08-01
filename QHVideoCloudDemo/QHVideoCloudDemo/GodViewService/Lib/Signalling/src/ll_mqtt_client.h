#ifndef _HDY_DSDK_MQTT_CLIENT_H_HH_
#define _HDY_DSDK_MQTT_CLIENT_H_HH_

#include <string>
#include <map>
#include <queue>
#include <mutex>

#include "ll_log.h"

extern "C" {
#include "MQTTClient.h"
//#include "MQTTAsync.h"
}
namespace dsdk
{

const int mqtt_mode_pub = 0x01;
const int mqtt_mode_sub = 0x02;

struct mqtt_subscribe
{
    int         qos;
    int         state;
    int         retry;
};

struct mqtt_message
{
    int         seq;
    std::string topic;
    int         qos;
    char*       message;
    int         lenght;
    int         retry;
};

class ll_callback;
class job_thread;
class ll_mqtt_client_ex
{
    static void on_connect_lost(void* context, char* cause);
    static int  on_message_arrived(void* context, char* topicName, int topicLen, MQTTClient_message* message);

 public:
    ll_mqtt_client_ex(const char* selfid, ll_callback* callback, ll_log_func log_func);
    virtual ~ll_mqtt_client_ex();

    bool connect(const char* server, const char* username = NULL, const char* password = NULL);
    bool is_connected() { return _connected; }
    int  publish(const char* topic, const void* message, int len, int qos);
    bool subscribe(const char* topic, int qos);
    bool unsubscribe(const char* topic);
    void destroy();

 public:
    void on_connect();
    void on_connect_broke(const char* cause);
    void on_subscribe();
    void on_unsubscribe(const char* topic);

    void on_publish();
    void on_message(const char* topic, const void* message, int len);

    void on_destroy();
 private:
    std::string     _selfid;
    ll_callback*    _callback;
    ll_log*         _log;
    std::string     _server;
    std::string     _username;
    std::string     _password;

    MQTTClient      _mqtt_client;
    volatile int    _connected;
    volatile int    _destroyed;
    int             _conn_callback;

    std::map<std::string, mqtt_subscribe*>  _topics;

    std::mutex                 _lock;
    std::queue<mqtt_message*>  _message_queue;
    unsigned int               _seq;

    job_thread*                _th;
};

//----------------------------------------------------------------------------------------
/*
class ll_mqtt_client
{
 private:
    static void onConnect(void* context, MQTTAsync_successData* response);
    static void onConnectFailure(void* context, MQTTAsync_failureData* response);
    static void onDisconnect(void* context, MQTTAsync_successData* response);
    static void onDisconnectFailure(void* context, MQTTAsync_failureData* response);
    static void onSubscribe(void* context, MQTTAsync_successData* response);

    static void onConnectLost(void* context, char* cause);
    static int  onMessageArrived(void* context, char* topicName, int topicLen, MQTTAsync_message* message);
 public:
    ll_mqtt_client(const char* self_id, ll_callback* callback);
    virtual ~ll_mqtt_client();

    bool connect(const char* server);
    bool publish(const char* topic, const void* message, int len, int qos);
    bool subscribe(const char* topic);
    void destroy();

    void on_connected();
    void on_connect_failed();
    void on_connect_broke();
    void on_disconnected();
    void on_subscribed();
    void on_subscribe_failed();
    void on_message(const std::string& topic, const void* message, int len);
 private:
    void on_sub_topic();
    void reconnect();
    void clean();

 private:
    std::string         _selfid;
    std::string         _server;
    ll_callback*        _callback;

    bool                _connected;
    int                 _reconnect;
    MQTTAsync           _mqtt_client;

    std::string         _topic;
    bool                _sub_success;
}; // */

}; // namespace
#endif //_HDY_DSDK_MQTT_CLIENT_H_HH_

