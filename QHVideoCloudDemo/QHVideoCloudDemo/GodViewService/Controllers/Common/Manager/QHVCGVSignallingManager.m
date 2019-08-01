//
//  QHVCGVSignallingManager.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/11/1.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCGVSignallingManager.h"
#import "QHVCGodViewLocalManager.h"
//#import "JSONHelp.h"
#import "QHVCGVInteractiveManager.h"
#import "QHVCLogger.h"
#import <QHVCCommonKit/QHVCCommonKit.h>

/// SDK内部模块通信使用的cmd标志，别的业务请使用其他标志
static NSString *QHVCGVSignallingCmd  =  @"1001";


static NSString *QHVCGVSignallingModelNameRTCSDK = @"rtcsdk";
static NSString *QHVCGVSignallingModelNameNetSDK = @"netsdk";

@implementation QHVCGVSignallingManager

+ (QHVCGVSignallingManager *)sharedInstance {
    static QHVCGVSignallingManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [QHVCGVSignallingManager new];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        [QHVCGVLonglinkManager sharedInstance].delegate = self;
    }
    return self;
}

#pragma mark - 长连相关操作
/**
 * 返回长连连接状态 YES:连接中  NO:未连接
 */
- (BOOL)isConnecting {
    return [[QHVCGVLonglinkManager sharedInstance] isConnecting];
}

/**
 * 建立长连
 * @param host 长连服务器地址
 * @param userId 建立长连的用户唯一标识
 */
- (void)connectToHost:(nonnull NSString *)host userId:(nonnull NSString *)userId {
    [[QHVCGVLonglinkManager sharedInstance] connectToHost:host userId:userId];
}
- (void)connectToHost:(nonnull NSString *)host userId:(nonnull NSString *)userId handler:(nonnull void (^)(BOOL isConnected))handler {
    [[QHVCGVLonglinkManager sharedInstance] connectToHost:host userId:userId handler:handler];
}

/**
 * 断开长连
 */
- (void)disconnect {
    [[QHVCGVLonglinkManager sharedInstance] disconnect];
}

#pragma mark - 发消息
/**
 * 利用长连通道发送消息
 * @param message 消息体
 * @param destId 消息接收方
 */
- (void)sendMessage:(NSString *)message to:(NSString *)destId {
    [[QHVCGVLonglinkManager sharedInstance] sendCmd:QHVCGVSignallingCmd message:message to:destId];
}

/**
 * 订阅topic
 * @param topicId 订阅的主题id（房间号)
 * @return 订阅结果 YES:成功 NO:失败
 */
- (BOOL)subscribe:(NSString *)topicId {
    return [[QHVCGVLonglinkManager sharedInstance] subscribe:topicId];
}

/**
 * 取消订阅topic
 * @param topicId 要取消订阅的主题id（房间号)
 * @return 取消订阅结果 YES:成功 NO:失败
 */
- (BOOL)unsubscribe:(NSString *)topicId {
    return [[QHVCGVLonglinkManager sharedInstance] unsubscribe:topicId];
}


#pragma mark - 收消息

- (void)didLonglinkReceiveMessage:(nonnull NSString *)message {
    NSData *msgData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *msgDict = [QHVCToolUtils resolveJsonDataToDictionary:msgData];
    // 解析消息
    NSString *cmd = [QHVCToolUtils getStringFromDictionary:msgDict key:@"cmd" defaultValue:nil];
    NSString *dataString = [QHVCToolUtils getStringFromDictionary:msgDict key:@"data" defaultValue:nil];
    
    NSData *dataTmp = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dataDict = [QHVCToolUtils resolveJsonDataToDictionary:dataTmp];
    
    NSString *messageBody = [QHVCToolUtils dictionaryConversionToString:dataDict];
    // sdk消息
    if([cmd isEqualToString:QHVCGVSignallingCmd]) {
        NSString *modelName = [QHVCToolUtils getStringFromDictionary:dataDict key:@"model" defaultValue:nil];
        if ([modelName isEqualToString:QHVCGVSignallingModelNameRTCSDK]) {
            [[QHVCGVInteractiveManager sharedInstance] receiveSignalingMessages:messageBody];
        }
        else if ([modelName isEqualToString:QHVCGVSignallingModelNameNetSDK]) {
            [[QHVCGodViewLocalManager sharedInstance] receiveGodSeesSignallingData:messageBody];
        }
    }
    // 未知消息
    else {
        [QHVCLogger printLogger:QHVC_LOG_LEVEL_INFO content:[NSString stringWithFormat:@"未知业务消息:%@",message]];
    }
}


@end
