#ifndef _HDY_LL_CALLBACK_H_HH_
#define _HDY_LL_CALLBACK_H_HH_

namespace dsdk {

class ll_callback
{
 public:
    ll_callback() {}
    virtual ~ll_callback() {}

    virtual void on_connected() {}
    virtual void on_connect_broke() {}

    virtual void on_arrived_message(const char* /*topoc*/, const void* /*message*/, int /*len*/) = 0;
};

};

#endif // _HDY_LL_CALLBACK_H_HH_

