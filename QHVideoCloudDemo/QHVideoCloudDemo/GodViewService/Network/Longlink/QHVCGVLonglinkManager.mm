//
//  QHVCGVLonglinkManager.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/10/11.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCGVLonglinkManager.h"
#include "ll_mqtt_client.h"
#import "QHVCGVLonglinkCallback.h"
#import "JSONHelp.h"
#include "ll_client.h"
#import "QHVCTool.h"
#import <QHVCCommonKit/QHVCCommonKit.h>
#import "QHVCLogger.h"


typedef void (^QHVCGVLonglinkConnectCallback)(BOOL isConnected);

#define QHVCGVLonglink_Cmd          @"cmd"
#define QHVCGVLonglink_Data         @"data"
#define QHVCGVLonglink_rid          @"rid"

@interface QHVCGVLonglinkManager ()
@property (nonatomic,strong) NSString *host;
@property (nonatomic,strong) NSString *userId;
@property (nonatomic,copy) QHVCGVLonglinkConnectCallback connectCallback;
@property(nonatomic,assign) BOOL isFirstConnect;
@end

@implementation QHVCGVLonglinkManager

+ (QHVCGVLonglinkManager *)sharedInstance {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self class] new];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

static dsdk::ll_client* qhvc_gv_longlink = nullptr;
qhvcgv_longlink::QHVCGVLonglinkCallback *qhvc_gv_longlink_callback = nullptr;

void qhvc_net_god_sees_signalling_log_callback(int level, const char* log)
{
    NSString* logString = [[NSString alloc] initWithUTF8String:log];
    if ([QHVCToolUtils isNullString:logString]) {
        return;
    }
    QHVCLogLevel tmpLevel = QHVC_LOG_LEVEL_NONE;
    if (level == LL_LOG_DEBUG) {
        tmpLevel = QHVC_LOG_LEVEL_DEBUG;
    } else if (level == LL_LOG_INFO) {
        tmpLevel = QHVC_LOG_LEVEL_INFO;
    } else if (level == LL_LOG_WARN) {
        tmpLevel = QHVC_LOG_LEVEL_WARN;
    } else if (level == LL_LOG_FATAL) {
        tmpLevel = QHVC_LOG_LEVEL_FATAL;
    }
    [QHVCLogger printLogger:tmpLevel content:[NSString stringWithFormat:@"signalling log :%@",logString]];
}

#pragma mark - Public
/**
 * 返回长连连接状态 YES:连接中  NO:未连接
 */
- (BOOL)isConnecting {
    if (qhvc_gv_longlink_callback == NULL || qhvc_gv_longlink == NULL) {
        return NO;
    }
    return qhvc_gv_longlink_callback->is_connected();
}

/**
 * 断开长连
 */
- (void)disconnect {
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_INFO content:@"长连 - 断开已有连接"];
    if (qhvc_gv_longlink != NULL) {
        delete qhvc_gv_longlink;
        qhvc_gv_longlink = NULL;
    }
    if (qhvc_gv_longlink_callback != NULL) {
        delete qhvc_gv_longlink_callback;
        qhvc_gv_longlink_callback = NULL;
    }
    return;
}

/**
 * 建立长连
 * @param host 长连服务器地址
 * @param userId 建立长连的用户唯一标识
 */
- (void)connectToHost:(nonnull NSString *)host userId:(nonnull NSString *)userId {
    if (userId == nil) {
        [QHVCLogger printLogger:QHVC_LOG_LEVEL_ERROR content:@"长连 - 建立连接失败 userId为空"];
        return;
    }
    if (host == nil) {
        [QHVCLogger printLogger:QHVC_LOG_LEVEL_ERROR content:@"长连 - 建立连接失败 host为空"];
        return;
    }
    self.host = host;
    self.userId = userId;
    
    if (qhvc_gv_longlink != NULL) {
        delete qhvc_gv_longlink;
    }
    if (qhvc_gv_longlink_callback != NULL) {
        delete qhvc_gv_longlink_callback;
    }
    
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_INFO content:@"长连 - 开始连接"];
    qhvc_gv_longlink_callback = new qhvcgv_longlink::QHVCGVLonglinkCallback();
    qhvc_gv_longlink = new dsdk::ll_client(self.userId.UTF8String, qhvc_gv_longlink_callback, qhvc_net_god_sees_signalling_log_callback);
    qhvc_gv_longlink->connect(host.UTF8String);
    
}

- (void)connectToHost:(nonnull NSString *)host userId:(nonnull NSString *)userId handler:(void(^)(BOOL isConnected))handler {
    self.isFirstConnect = YES;
    self.connectCallback = handler;
    [self connectToHost:host userId:userId];
}

/**
 * 订阅topic
 * @param topicId 订阅的主题id（房间号)
 * @return 订阅结果 YES:成功 NO:失败
 */
- (BOOL)subscribe:(NSString *)topicId {
    if ([QHVCToolUtils isNullString:topicId]) {
        [QHVCLogger printLogger:QHVC_LOG_LEVEL_ERROR content:@"长连 - 订阅失败，reason:传入topicId为空"];
        return NO;
    }
    if (![self isConnecting]) {
        [QHVCLogger printLogger:QHVC_LOG_LEVEL_ERROR content:@"长连 - 订阅失败，reason:未建立连接"];
        return NO;
    }
    return qhvc_gv_longlink->subscribe(topicId.UTF8String);
}

/**
 * 取消订阅topic
 * @param topicId 要取消订阅的主题id（房间号)
 * @return 取消订阅结果 YES:成功 NO:失败
 */
- (BOOL)unsubscribe:(NSString *)topicId {
    if ([QHVCToolUtils isNullString:topicId]) {
        [QHVCLogger printLogger:QHVC_LOG_LEVEL_ERROR content:@"长连 - 取消订阅失败，reason:传入topicId为空"];
        return NO;
    }
    if (![self isConnecting]) {
        [QHVCLogger printLogger:QHVC_LOG_LEVEL_ERROR content:@"长连 - 取消订阅失败，reason:未建立连接"];
        return NO;
    }
    return qhvc_gv_longlink->subscribe(topicId.UTF8String);
}



/**
 * 利用长连通道发送消息
 * @param cmd 长连信令指令 如sdk采用的@"1001"
 * @param message 消息体
 * @param destId 消息接收方
 */
- (void)sendCmd:(NSString *)cmd message:(NSString *)message to:(NSString *)destId {
    if (qhvc_gv_longlink_callback == NULL || !qhvc_gv_longlink_callback->is_connected()) {
        [QHVCLogger printLogger:QHVC_LOG_LEVEL_ERROR content:@"长连 - 未建立连接，无法发送消息"];
        return;
    }
    
    if (message == nil) {
        [QHVCLogger printLogger:QHVC_LOG_LEVEL_ERROR content:@"长连 - 发送的消息为空"];
        return;
    }
    
    if (destId == nil) {
        [QHVCLogger printLogger:QHVC_LOG_LEVEL_ERROR content:@"长连 - 目标设备id为空"];
        return;
    }

    // 封装长连协议
    NSDictionary *dictMsg = @{QHVCGVLonglink_Cmd:cmd,
                              QHVCGVLonglink_Data:message,
                              QHVCGVLonglink_rid:self.userId
                              };
    const char *msg = [[JSONHelp nsdictionary2NSString:dictMsg] cStringUsingEncoding:NSUTF8StringEncoding];
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_DEBUG content:[NSString stringWithFormat:@"长连 - 发送消息:%@",dictMsg]];
    qhvc_gv_longlink->publish(msg, (int)strlen(msg), [destId cStringUsingEncoding:NSUTF8StringEncoding]);
}

#pragma mark - 长连回调
/**
 * 长连接收消息的入口
 */
- (void)onLonglinkReceiveMessage:(NSString *)message {
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_DEBUG content:[NSString stringWithFormat:@"长连 - 收到了消息:%@ ",message]];
    if ([self.delegate respondsToSelector:@selector(didLonglinkReceiveMessage:)]) {
        [self.delegate didLonglinkReceiveMessage:message];
    }
}

/**
 * 连接成功
 */
- (void)onConnected {
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_DEBUG content:[NSString stringWithFormat:@"长连 - 连接成功！ 订阅%@",self.userId]];
    qhvc_gv_longlink->subscribe(self.userId.UTF8String);
    
    if (self.isFirstConnect && self.connectCallback) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.connectCallback(YES);
        });
    }
    self.isFirstConnect = NO;
}

/**
 * 连接断开
 */
- (void)onConnectBroke {
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_DEBUG content:@"长连 - 连接断开！开始重连"];
    qhvc_gv_longlink->connect(self.host.UTF8String);
    
    if (self.isFirstConnect && self.connectCallback) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.connectCallback(NO);
        });
    }
    self.isFirstConnect = NO;
}

@end
