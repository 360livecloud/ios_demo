//
//  QHVCGVLonglinkCallback.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/10/11.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCGVLonglinkCallback.h"
#import "QHVCGVLonglinkManager.h"

namespace qhvcgv_longlink {
    void QHVCGVLonglinkCallback::on_connected() {
        m_connected = true;
        [[QHVCGVLonglinkManager sharedInstance] onConnected];
    }
    
    void QHVCGVLonglinkCallback::on_connect_broke() {
        m_connected = false;
        [[QHVCGVLonglinkManager sharedInstance] onConnectBroke];
    }
    
    
    void QHVCGVLonglinkCallback::on_arrived_message(const char *topic, const void *message, int len) {
        NSData *data = [[NSData alloc] initWithBytes:message length:len];
        NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [[QHVCGVLonglinkManager sharedInstance] onLonglinkReceiveMessage:msg];
    }
    
    bool QHVCGVLonglinkCallback::is_connected() {
        return m_connected;
    }
}
