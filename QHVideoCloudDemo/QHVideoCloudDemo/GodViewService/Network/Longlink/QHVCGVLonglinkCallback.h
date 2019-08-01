//
//  QHVCGVLonglinkCallback.h
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/10/11.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#ifndef QHVCGVLonglinkCallback_h
#define QHVCGVLonglinkCallback_h

#include "ll_callback.h"
#include <stdio.h>

namespace qhvcgv_longlink {
    class QHVCGVLonglinkCallback : public dsdk::ll_callback
    {
    public:
        virtual void on_connected();
        
        virtual void on_connect_broke();
        
        virtual void on_arrived_message(const char*topic /*topoc*/, const void*message /*message*/, int len/*len*/);
        
        bool is_connected();
        
    private:
        bool m_connected { false };
    };
}

#endif
