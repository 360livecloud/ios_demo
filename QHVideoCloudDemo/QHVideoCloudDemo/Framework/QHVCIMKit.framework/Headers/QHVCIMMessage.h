//
//  QHVCIMMessage.h
//  QHVCIMKit
//
//  Created by deng on 2018/3/7.
//  Copyright © 2018年 qihoo.QHVCIMKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QHVCIMStatusDefine.h"
#import "QHVCIMMessageContent.h"

/*
 * 消息实体类
 * @discussion 消息实体类，包含消息的所有属性。
 */
@interface QHVCIMMessage : NSObject

/*!
 会话类型
 */
@property(nonatomic, assign) QHVCIMConversationType conversationType;

/*!
 目标会话ID
 */
@property(nonatomic, strong) NSString *targetId;

/*!
 消息的ID
 
 @discussion 本地存储的消息的唯一值（数据库索引唯一值）
 */
@property(nonatomic, assign) long messageId;

/*!
 消息的方向
 */
@property(nonatomic, assign) QHVCMessageDirection messageDirection;

/*!
 消息的发送者ID
 */
@property(nonatomic, strong) NSString *senderUserId;

/*!
 消息的接收状态
 */
@property(nonatomic, assign) QHVCReceivedStatus receivedStatus;

/*!
 消息的发送状态
 */
@property(nonatomic, assign) QHVCSentStatus sentStatus;

/*!
 消息的接收时间（Unix时间戳、毫秒）
 */
@property(nonatomic, assign) long long receivedTime;

/*!
 消息的发送时间（Unix时间戳、毫秒）
 */
@property(nonatomic, assign) long long sentTime;

/*!
 消息的内容
 */
@property(nonatomic, strong) QHVCIMMessageContent *content;

/*!
 消息的附加字段
 */
@property(nonatomic, strong) NSString *extra;

/*!
 全局唯一ID
 
 @discussion 服务器消息唯一ID（在同一个Appkey下全局唯一）
 */
@property(nonatomic, strong) NSString *messageUId;

@end
