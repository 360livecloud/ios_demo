//
//  QHVCGVSignallingManager.h
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/11/1.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QHVCGVLonglinkManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface QHVCGVSignallingManager : NSObject<QHVCGVLonglinkManagerDelegate>

+ (QHVCGVSignallingManager *)sharedInstance;

/**
 * 建立长连
 * @param host 长连服务器地址
 * @param userId 建立长连的用户唯一标识
 */
- (void)connectToHost:(nonnull NSString *)host userId:(nonnull NSString *)userId;
- (void)connectToHost:(nonnull NSString *)host userId:(nonnull NSString *)userId handler:(nonnull void (^)(BOOL isConnected))handler;
/**
 * 返回长连连接状态 YES:连接中  NO:未连接
 */
- (BOOL)isConnecting;

/**
 * 断开长连
 */
- (void)disconnect;

/**
 * 利用长连通道发送消息
 * @param message 消息体
 * @param destId 消息接收方
 */
- (void)sendMessage:(NSString *)message to:(NSString *)destId;

/**
 * 订阅topic
 * @param topicId 订阅的主题id（房间号)
 * @return 订阅结果 YES:成功 NO:失败
 */
- (BOOL)subscribe:(NSString *)topicId;

/**
 * 取消订阅topic
 * @param topicId 要取消订阅的主题id（房间号)
 * @return 取消订阅结果 YES:成功 NO:失败
 */
- (BOOL)unsubscribe:(NSString *)topicId;

@end

NS_ASSUME_NONNULL_END
