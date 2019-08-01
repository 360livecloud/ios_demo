//
//  QHVCGVLonglinkManager.h
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/10/11.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QHVCGVLonglinkManagerDelegate <NSObject>
/**
 * QHVCGVLonglinkManager收到长连消息，提供给外部的代理回调
 */
- (void)didLonglinkReceiveMessage:(NSString *)message;
@end

@interface QHVCGVLonglinkManager : NSObject
@property (nonatomic, weak) id<QHVCGVLonglinkManagerDelegate> delegate;

+ (QHVCGVLonglinkManager *)sharedInstance;

/**
 * 建立长连
 * @param host 长连服务器地址
 * @param userId 建立长连的用户唯一标识
 */
- (void)connectToHost:(nonnull NSString *)host userId:(nonnull NSString *)userId;
- (void)connectToHost:(nonnull NSString *)host userId:(nonnull NSString *)userId handler:(void(^)(BOOL isConnected))handler;
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
 * @param cmd 长连信令指令 如sdk采用的@"1001"
 * @param message 消息体
 * @param destId 消息接收方
 */
- (void)sendCmd:(NSString *)cmd message:(NSString *)message to:(NSString *)destId;

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

#pragma mark - 长连监听接口
/**
 * 长连接收消息的入口，供长连回调消息给QHVCGVLonglinkManager，外面接收处理消息，请实现QHVCGVLonglinkManagerDelegate代理
 */
- (void)onLonglinkReceiveMessage:(NSString *)message;

/**
 * 连接成功
 */
- (void)onConnected;

/**
 * 连接断开
 */
- (void)onConnectBroke;

@end

NS_ASSUME_NONNULL_END
