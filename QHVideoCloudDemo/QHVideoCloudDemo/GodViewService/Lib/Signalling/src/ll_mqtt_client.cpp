#include "ll_mqtt_client.h"
#include "ll_client.h"

#include <unistd.h>
#include <string.h>

#include "job_thread.h"

namespace dsdk {
class mqtt_connect_job : public job_base
{
 public:
    mqtt_connect_job(ll_mqtt_client_ex* client): _client(client) {}
    virtual ~mqtt_connect_job() {}

    virtual void do_job() {
        if (_client) {
            _client->on_connect();
        }
    }
 private:
    ll_mqtt_client_ex*  _client;
};

class mqtt_subscribe_job : public job_base
{
 public:
    mqtt_subscribe_job(ll_mqtt_client_ex* client): _client(client) {}
    virtual ~mqtt_subscribe_job() {}

    virtual void do_job() {
        if (_client) {
            _client->on_subscribe();
        }
    }
 public:
    ll_mqtt_client_ex*  _client;
};

class mqtt_unsubscribe_job : public job_base
{
 public:
    mqtt_unsubscribe_job(ll_mqtt_client_ex* client, const char* topic)
        : _client(client), _topic(topic) {}
    virtual ~mqtt_unsubscribe_job() {}

    virtual void do_job() {
        if (_client) {
            _client->on_unsubscribe(_topic.c_str());
        }
    }
 private:
    ll_mqtt_client_ex*  _client;
    std::string         _topic;
};

class mqtt_publish_job : public job_base
{
 public:
    mqtt_publish_job(ll_mqtt_client_ex* client): _client(client) {}
    virtual ~mqtt_publish_job() {}

    virtual void do_job() {
        if (_client) {
            _client->on_publish();
        }
    }
 private:
    ll_mqtt_client_ex*  _client;
};

class mqtt_destroy_job : public job_base
{
 public:
    mqtt_destroy_job(ll_mqtt_client_ex* client)
        : _client(client) {}
    virtual ~mqtt_destroy_job() {}

    virtual void do_job() {
        if (_client) {
            _client->on_destroy();
        }
    }
 private:
    ll_mqtt_client_ex*  _client;
};

//---------------------------------------------------------------------------------------------------------
const int ll_mqtt_timeout = 3000;

ll_mqtt_client_ex::ll_mqtt_client_ex(const char* selfid, ll_callback* callback, ll_log_func log_func)
    : _selfid(selfid),
      _callback(callback),
      _log(new ll_log()),
      _mqtt_client(NULL),
      _connected(0),
      _destroyed(0),
      _conn_callback(0),
      _seq(0)
{
    _log->init(log_func);
    _th = new job_thread();
}

ll_mqtt_client_ex::~ll_mqtt_client_ex()
{
    INFO(_log, "ll_mqtt_client_ex::~ll_mqtt_client_ex start\n");
    _th->end();
    _th = NULL;
    while (!_message_queue.empty()) {
        mqtt_message* msg = _message_queue.front();
        _message_queue.pop();
        delete[] msg->message;
        delete   msg;
    }
    auto it = _topics.begin();
    while (it != _topics.end()) {
        mqtt_subscribe* sub = it->second;
        delete sub;
        it++;
    }
}

bool ll_mqtt_client_ex::connect(const char* server, const char* username, const char* password)
{
    INFO(_log, "ll_mqtt_client_ex::connect sid=%s, server=%s %s %s\n", _selfid.c_str(), server, username, password);
    if (_mqtt_client) {
        WARN(_log, "ll_mqtt_client_ex::connect mqtt client is exist.\n");
        return false;
    }

    if (_selfid.empty()) {
        WARN(_log, "ll_mqtt_client_ex::connect selfid can`t be empty.\n");
        return false;
    }
    if (server) _server.assign(server);
    if (_server.empty()) {
        WARN(_log, "ll_mqtt_client_ex::connect server can`t be empty.\n");
        return false;
    }
    if (username) _username.assign(username);
    if (password) _password.assign(password);

    if (MQTTCLIENT_SUCCESS != MQTTClient_create(&_mqtt_client, _server.c_str(), _selfid.c_str(), MQTTCLIENT_PERSISTENCE_NONE, NULL)) {
        WARN(_log, "ll_mqtt_client_ex::connect mqtt client create failed. sid=%s, server=%s\n", _selfid.c_str(), _server.c_str());
        return false;
    }
    MQTTClient_setCallbacks(_mqtt_client, this, on_connect_lost, on_message_arrived, NULL);

    _conn_callback = 1;
    _th->push_job(new mqtt_connect_job(this));
    return true;
}

int  ll_mqtt_client_ex::publish(const char* topic, const void* message, int len, int qos)
{
    if (!_mqtt_client) {
        WARN(_log, "ll_mqtt_client_ex::publish mqtt client is null. please called connect() func\n");
        return 0;
    }

    if (!message || len <= 0) {
        WARN(_log, "ll_mqtt_client_ex::publish message can`t be empty.\n");
        return 0;
    }

    std::string tpc(topic);
    if (tpc.empty()) {
        WARN(_log, "ll_mqtt_client_ex::publish topic can`t be empty.\n");
        return 0;
    }

    INFO(_log, "ll_mqtt_client_ex::publish sid=%s, topic=%s\n", _selfid.c_str(), topic);
    mqtt_message* msg = new mqtt_message();
    {
        msg->topic  = tpc;
        msg->qos    = qos;
        msg->lenght = len;
        msg->retry  = 0;
        msg->message= new char[len];
        memcpy(msg->message, message, len);

        std::unique_lock<std::mutex> lock(_lock);
        msg->seq = ++_seq;
        _message_queue.push(msg);
    }
    _th->push_job(new mqtt_publish_job(this));
    return msg->seq;
}

bool ll_mqtt_client_ex::subscribe(const char* topic, int qos)
{
    if (!_mqtt_client) {
        WARN(_log, "ll_mqtt_client_ex::subscribe mqtt client is null. please called connect() func\n");
        return false;
    }

    std::string tpc(topic);
    if (tpc.empty()) {
        WARN(_log, "ll_mqtt_client_ex::subscribe topic can`t be empty.\n");
        return false;
    }

    INFO(_log, "ll_mqtt_client_ex::subscribe sid=%s, topic=%s, qos=%d\n", _selfid.c_str(), topic, qos);
    mqtt_subscribe* sub = NULL;
    {
        std::unique_lock<std::mutex> lock(_lock);
        auto it = _topics.find(tpc);
        if (it == _topics.end()) {
            sub = new mqtt_subscribe();
            sub->qos    = qos;
            sub->state  = 0;
            sub->retry  = 0;
            _topics.insert(std::pair<std::string, mqtt_subscribe*>(tpc, sub));
        }
    }

    _th->push_job(new mqtt_subscribe_job(this));
    return true;
}

bool ll_mqtt_client_ex::unsubscribe(const char* topic)
{
    if (!_mqtt_client) {
        WARN(_log, "ll_mqtt_client_ex::unsubscribe mqtt client is null. please called connect() func\n");
        return false;
    }

    std::string tpc(topic);
    if (tpc.empty()) {
        WARN(_log, "ll_mqtt_client_ex::unsubscribe topic can`t be empty.\n");
        return false;
    }

    INFO(_log, "ll_mqtt_client_ex::unsubscribe sid=%s, topic=%s\n", _selfid.c_str(), topic);

    mqtt_subscribe* sub = NULL;
    {
        std::unique_lock<std::mutex> lock(_lock);
        auto it = _topics.find(tpc);
        if (it != _topics.end()) {
            sub = it->second;
            _topics.erase(it);
        }
    }
    if (sub && sub->state) {
        _th->push_job(new mqtt_unsubscribe_job(this, topic));
    }
    return true;
}

void ll_mqtt_client_ex::destroy()
{
    _destroyed = 1;
    _callback  = NULL;
    if (_mqtt_client) {
        _th->push_job(new mqtt_destroy_job(this));
        return ;
    }
    delete this;
}

void ll_mqtt_client_ex::on_connect()
{
    if (_mqtt_client && _connected == 0) {

        MQTTClient_connectOptions conn = MQTTClient_connectOptions_initializer;
        conn.keepAliveInterval  = 20;
        conn.cleansession       = 1;
        if (!_username.empty()) {
            conn.username = _username.c_str();
            conn.password = _password.c_str();
        }
        int retry = 0;

        INFO(_log, "ll_mqtt_client_ex::on_connect start, sid=%s\n", _selfid.c_str());
        int r;
        do {
            if (_destroyed)
                break;

            r = MQTTClient_connect(_mqtt_client, &conn);
            if (MQTTCLIENT_SUCCESS != r) {
                retry++;
                WARN(_log, "ll_mqtt_client_ex::on_connect mqtt connect failed. sid=%s, code=%d, try=%d\n", _selfid.c_str(), r, retry);

                if (retry < 10) {
                    usleep(300*1000);
                } else {
                    MQTTClient_destroy(&_mqtt_client);
                    _mqtt_client = NULL;
                    if (_callback) {
                        _callback->on_connect_broke();
                    }
                    break;
                }
            } else {
                _connected = 1;
                INFO(_log, "ll_mqtt_client_ex::on_connect success, sid=%s\n", _selfid.c_str());
                if (_conn_callback && _callback) {
                    _conn_callback = 0;
                    _callback->on_connected();
                }
                break;
            }
        } while (true);

        if (_connected) {
            _th->push_job(new mqtt_subscribe_job(this));
            _th->push_job(new mqtt_publish_job(this));
        }
    }
}

void ll_mqtt_client_ex::on_connect_broke(const char* cause)
{
    WARN(_log, "ll_mqtt_client_ex::on_connect_broke mqtt connect broke. sid=%s, cause=%s\n", _selfid.c_str(), cause);

    {
        std::unique_lock<std::mutex> lock(_lock);
        auto it = _topics.begin();
        for (; it!=_topics.end(); it++) {
            mqtt_subscribe* sub = it->second;
            sub->state = 0;
        }
    }
    _connected = 0;
    _th->push_job(new mqtt_connect_job(this));
}

void ll_mqtt_client_ex::on_subscribe()
{
    if (_mqtt_client && _connected && !_destroyed) {
        int fail = 0;
        {
            std::unique_lock<std::mutex> lock(_lock);
            auto it = _topics.begin();
            for (; it!= _topics.end(); it++) {
                mqtt_subscribe* sub = it->second;
                if (sub->state == 0) {
                    sub->retry++;
                    if (MQTTCLIENT_SUCCESS != MQTTClient_subscribe(_mqtt_client, it->first.c_str(), sub->qos)) {
                        WARN(_log, "ll_mqtt_client_ex::on_subscribe topic=%s failed, try=%d\n", it->first.c_str(), sub->retry);
                        fail++;
                    } else {
                        sub->state = 1;
                    }
                }
            }
        }
    }
}

void ll_mqtt_client_ex::on_unsubscribe(const char* topic)
{
    if (_mqtt_client && _connected && !_destroyed) {
        MQTTClient_unsubscribe(_mqtt_client, topic);
    }
}

void ll_mqtt_client_ex::on_publish()
{
    if (_mqtt_client && _connected && !_destroyed) {
        bool empty = false;

        do {
            mqtt_message* msg = NULL;
            {
                std::unique_lock<std::mutex> lock(_lock);
                if (_message_queue.empty()) {
                    empty = true;
                    break;
                }
                msg = _message_queue.front();
            }
            if (msg) {
                msg->retry++;
                MQTTClient_message message = MQTTClient_message_initializer;
                MQTTClient_deliveryToken token = 0;
                message.payload     = msg->message;
                message.payloadlen  = msg->lenght;
                message.qos         = msg->qos;
                message.retained    = 0;
                INFO(_log, "ll_mqtt_client_ex::on_publish topic=%s, qos=%d, seq=%u, try=%d\n", msg->topic.c_str(), msg->qos, msg->seq, msg->retry);
                if (MQTTCLIENT_SUCCESS != MQTTClient_publishMessage(_mqtt_client, msg->topic.c_str(), &message, &token)) {
                    WARN(_log, "ll_mqtt_client_ex::on_publish failed seq=%u\n", msg->seq);
                    break;
                }
                if (MQTTCLIENT_SUCCESS != MQTTClient_waitForCompletion(_mqtt_client, token, ll_mqtt_timeout)) {
                    WARN(_log, "ll_mqtt_client_ex::on_publish failed seq=%u\n", msg->seq);
                    break;
                }

                {
                    std::unique_lock<std::mutex> lock(_lock);
                    _message_queue.pop();
                }
                delete[] msg->message;
                delete   msg;
            }
        } while (false);

        if (!empty) {
            _th->push_job(new mqtt_publish_job(this));
        }
    }
}

void ll_mqtt_client_ex::on_message(const char* topic, const void* message, int len)
{
    INFO(_log, "ll_mqtt_client_ex::on_message topic=%s, msglen=%d\n", topic, len);
    auto it = _topics.find(topic);
    if (it != _topics.end()) {
        if (_callback) _callback->on_arrived_message(topic, message, len);
    }
}

void ll_mqtt_client_ex::on_destroy()
{
    MQTTClient mqtt_client = _mqtt_client;
    _mqtt_client = NULL;
    if (mqtt_client) {
        if (_connected) {
            auto it = _topics.begin();
            for(;it!= _topics.end(); it++) {
                MQTTClient_unsubscribe(mqtt_client, it->first.c_str());
            }
            MQTTClient_disconnect(mqtt_client, ll_mqtt_timeout);
        }
        MQTTClient_destroy(&mqtt_client);
    }
    delete this;
}

void ll_mqtt_client_ex::on_connect_lost(void* context, char* cause)
{
    if (context) {
        ll_mqtt_client_ex* self = (ll_mqtt_client_ex*)context;
        self->on_connect_broke(cause);
    }
}

int  ll_mqtt_client_ex::on_message_arrived(void* context, char* topicName, int /*topicLen*/, MQTTClient_message* message)
{
    if (context) {
        ll_mqtt_client_ex* self = (ll_mqtt_client_ex*)context;
        self->on_message(topicName, message->payload, message->payloadlen);
    }
    MQTTClient_freeMessage(&message);
    MQTTClient_free(topicName);
    return 1;
}

//---------------------------------------------------------------------------------------------------------
//const int subqos = 0;
//
//ll_mqtt_client::ll_mqtt_client(const char* self_id, ll_callback* callback)
//    : _selfid(self_id),
//      _callback(callback),
//      _connected(false),
//      _reconnect(0),
//      _mqtt_client(NULL),
//      _sub_success(false)
//{
//}
//
//ll_mqtt_client::~ll_mqtt_client()
//{
//    WARN(_log, " ll_mqtt_client::~ll_mqtt_client\n");
//    clean();
//}
//
//bool ll_mqtt_client::connect(const char* server)
//{
//    if (_mqtt_client)
//        return false;
//
//    _server = server;
//    if (_server.empty() || _selfid.empty())
//        return false;
//
//    MQTTAsync_create(&_mqtt_client, _server.c_str(), _selfid.c_str(), MQTTCLIENT_PERSISTENCE_NONE, NULL);
//
//    MQTTAsync_connectOptions conn_opt = MQTTAsync_connectOptions_initializer;
//    conn_opt.keepAliveInterval = 20;
//    conn_opt.cleansession      = 1;
//    conn_opt.onSuccess         = onConnect;
//    conn_opt.onFailure         = onConnectFailure;
//    conn_opt.context           = this;
//
//    int r;
//    if ((r = MQTTAsync_connect(_mqtt_client, &conn_opt)) != MQTTASYNC_SUCCESS) {
//        WARN(_log, " connect mqtt server failed, r=%d\n", r);
//        clean();
//        return false;
//    }
//    MQTTAsync_setCallbacks(_mqtt_client, this, onConnectLost, onMessageArrived, NULL);
//
//    return true;
//}
//
//bool ll_mqtt_client::publish(const char* topic, const void* message, int len, int qos)
//{
//    std::string tmptopic(topic);
//    if (tmptopic.empty())
//        return false;
//
//    if (!message || len <= 0)
//        return false;
//    INFO(_log, "ll_mqtt_client::pub_message topic=%s, qos=%d, msg=%p, msgl=%d\n", tmptopic.c_str(), qos, message, len);
//
//    if (qos > 2 || qos < 0)
//        qos = 0;
//    //MQTTAsync_responseOptions opt = MQTTAsync_responseOptions_initializer;
//    MQTTAsync_message msg = MQTTAsync_message_initializer;
//    msg.payload    = (void*)message;
//    msg.payloadlen = len;
//    msg.qos        = qos;
//    msg.retained   = 0;
//    int r;
//    if ((r = MQTTAsync_sendMessage(_mqtt_client, tmptopic.c_str(), &msg, NULL)) != MQTTASYNC_SUCCESS) {
//        WARN(_log, " mqtt publish message failed, r=%d\n", r);
//        return false;
//    }
//    return true;
//}
//
//bool ll_mqtt_client::subscribe(const char* topic)
//{
//    std::string tmptopic(topic);
//    if (tmptopic.empty())
//        return false;
//
//    _topic = tmptopic;
//    on_sub_topic();
//    return true;
//}
//
//void ll_mqtt_client::destroy()
//{
//    if (_mqtt_client) {
//        if (_connected) {
//            MQTTAsync_disconnectOptions opt = { {'M', 'Q', 'T', 'D'}, 1, 0, NULL, NULL, NULL, MQTTProperties_initializer, MQTTREASONCODE_SUCCESS, NULL, NULL };
//            opt.onSuccess = onDisconnect;
//            opt.onFailure = onDisconnectFailure;
//            opt.context   = this;
//            int r;
//            if ((r = MQTTAsync_disconnect(_mqtt_client, &opt)) == MQTTASYNC_SUCCESS) {
//                return ;
//            }
//            WARN(_log, " mqtt disconnect failed, r=%d\n", r);
//        }
//    }
//    delete this;
//}
//
//void ll_mqtt_client::onConnect(void* context, MQTTAsync_successData* /*response*/)
//{
//    if (context) {
//        ll_mqtt_client* self = (ll_mqtt_client*)context;
//        self->on_connected();
//    }
//}
//
//void ll_mqtt_client::onConnectFailure(void* context, MQTTAsync_failureData* /*response*/)
//{
//    if (context) {
//        ll_mqtt_client* self = (ll_mqtt_client*)context;
//        self->on_connect_failed();
//    }
//}
//
//void ll_mqtt_client::onDisconnect(void* context, MQTTAsync_successData* /*response*/)
//{
//    if (context) {
//        WARN(_log, " onDisconnect\n");
//        ll_mqtt_client* self = (ll_mqtt_client*)context;
//        delete self;
//    }
//}
//
//void ll_mqtt_client::onDisconnectFailure(void* context, MQTTAsync_failureData* /*response*/)
//{
//    if (context) {
//        WARN(_log, " onDisconnect\n");
//        ll_mqtt_client* self = (ll_mqtt_client*)context;
//        delete self;
//    }
//}
//
//void ll_mqtt_client::onSubscribe(void* context, MQTTAsync_successData* /*response*/)
//{
//    if (context) {
//        ll_mqtt_client* self = (ll_mqtt_client*)context;
//        self->on_subscribed();
//    }
//}
//
//void ll_mqtt_client::onConnectLost(void* context, char* /*cause*/)
//{
//    if (context) {
//        ll_mqtt_client* self = (ll_mqtt_client*)context;
//        self->on_connect_broke();
//    }
//}
//
//int  ll_mqtt_client::onMessageArrived(void* context, char* topicName, int topicLen, MQTTAsync_message* message)
//{
//    if (context) {
//        ll_mqtt_client* self = (ll_mqtt_client*)context;
//        std::string topic(topicName, topicLen);
//        self->on_message(topic, message->payload, message->payloadlen);
//    }
//    MQTTAsync_freeMessage(&message);
//    MQTTAsync_free(topicName);
//    return 1;
//}
//
//
//void ll_mqtt_client::on_connected()
//{
//    _connected = true;
//    _reconnect = 0;
//    if (_callback) {
//        _callback->on_connected();
//    }
//    on_sub_topic();
//}
//
//void ll_mqtt_client::on_connect_failed()
//{
//    reconnect();
//}
//
//void ll_mqtt_client::on_connect_broke()
//{
//    reconnect();
//}
//
//void ll_mqtt_client::on_subscribed()
//{
//    _sub_success = true;
//}
//
//void ll_mqtt_client::on_message(const std::string& topic, const void* message, int len)
//{
//    if (_callback && (_topic.compare(topic) == 0)) {
//        _callback->on_arrived_message(topic.c_str(), message, len);
//    }
//}
//
//void ll_mqtt_client::on_sub_topic()
//{
//    if (_connected &&
//        !_sub_success &&
//        !_topic.empty()) {
//
//        MQTTAsync_responseOptions opt = MQTTAsync_responseOptions_initializer;
//        opt.onSuccess = onSubscribe;
//        opt.context   = this;
//        MQTTAsync_subscribe(_mqtt_client, _topic.c_str(), subqos, &opt);
//    }
//}
//
//void ll_mqtt_client::reconnect()
//{
//    WARN(_log, " mqtt reconnect\n");
//
//    _connected = false;
//    _sub_success = false;
//    if (_reconnect > 10) {
//        WARN(_log, " reconnect count=%d, give up\n", _reconnect);
//        if (_callback) {
//            _callback->on_connect_broke();
//            return;
//        }
//    }
//    _reconnect++;
//    MQTTAsync_connectOptions conn_opt = MQTTAsync_connectOptions_initializer;
//    conn_opt.keepAliveInterval = 20;
//    conn_opt.cleansession      = 1;
//    conn_opt.onSuccess         = onConnect;
//    conn_opt.onFailure         = onConnectFailure;
//    MQTTAsync_connect(_mqtt_client, &conn_opt);
//    int r;
//    if ((r = MQTTAsync_connect(_mqtt_client, &conn_opt)) != MQTTASYNC_SUCCESS) {
//        WARN(_log, " reconnect mqtt server failed, r=%d\n", r);
//        if (_callback) {
//            _callback->on_connect_broke();
//        }
//    }
//}
//
//void ll_mqtt_client::clean()
//{
//    if (_mqtt_client) {
//        WARN(_log, " ll_mqtt_client::clean\n");
//        MQTTAsync_destroy(&_mqtt_client);
//        _mqtt_client = NULL;
//    }
//}

}; // namespace

