#include "ll_client.h"
#include "ll_callback.h"
#include "ll_mqtt_client.h"

namespace dsdk {

ll_client::ll_client(const char* cid, ll_callback* callback, ll_log_func log_func)
    : _priv(new ll_mqtt_client_ex(cid, callback, log_func))
{
}

ll_client::~ll_client()
{
    if (_priv) {
        ll_mqtt_client_ex* client = (ll_mqtt_client_ex*)_priv;
        _priv = NULL;
        client->destroy();
    }
}

bool ll_client::connect(const char* server)
{
    if (_priv) {
        ll_mqtt_client_ex* client = (ll_mqtt_client_ex*)_priv;
        return client->connect(server);
    }
    return  false;
}

bool ll_client::connect(const char* server, const char* username, const char* password)
{
    if (_priv) {
        ll_mqtt_client_ex* client = (ll_mqtt_client_ex*)_priv;
        return client->connect(server, username, password);
    }
    return  false;
}

bool ll_client::is_connected()
{
    if (_priv) {
        ll_mqtt_client_ex* client = (ll_mqtt_client_ex*)_priv;
        return client->is_connected();
    }
    return false;
}

bool ll_client::subscribe(const char* topic, mqtt_message_qos qos)
{
    if (_priv) {
        ll_mqtt_client_ex* client = (ll_mqtt_client_ex*)_priv;
        return client->subscribe(topic, (int)qos);
    }
    return  false;
}

bool ll_client::unsubscribe(const char* topic)
{
    if (_priv) {
        ll_mqtt_client_ex* client = (ll_mqtt_client_ex*)_priv;
        return client->unsubscribe(topic);
    }
    return false;
}

int ll_client::publish(const void* message, int len, const char* topic, mqtt_message_qos qos)
{
    if (_priv) {
        ll_mqtt_client_ex* client = (ll_mqtt_client_ex*)_priv;
        return client->publish(topic, message, len, (int)qos);
    }
    return  0;
}

}; //namespace

