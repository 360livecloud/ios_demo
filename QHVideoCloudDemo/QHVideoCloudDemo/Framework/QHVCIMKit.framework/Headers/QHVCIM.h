//
//  QHVCIM.h
//  QHVCIMKit
//
//  Created by deng on 2018/3/1.
//  Copyright © 2018年 qihoo.QHVCIMKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QHVCIMStatusDefine.h"
#import "QHVCIMChatroomInfo.h"
#import "QHVCIMMessageContent.h"
#import "QHVCIMMessage.h"
#import "QHVCIMTextContent.h"
#import "QHVCIMCommandContent.h"
#import "QHVCIMDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface QHVCIM : NSObject

+ (QHVCIM *)sharedInstance;

- (BOOL)setChannelId:(NSString *)channelId;

- (BOOL)setIMContexts:(NSDictionary *)context;

/**
 *  @功能 设置当前登录用户的用户信息
 *  @参数 info @{@"userId":userId, @"name":userName, @"protraitUrl":userProtrait}
 */
- (BOOL)setUserInfos:(NSDictionary *)info;

/**
 *  @功能 与服务器建立连接
 *  @返回值 successBlock            连接建立成功的回调 [userId:当前连接成功所用的用户ID]
 *  @返回值 errorBlock              连接建立失败的回调 [status:连接失败的错误码]
 *  在App整个生命周期，您只需要调用一次此方法与服务器建立连接。
 *  之后无论是网络出现异常或者App有前后台的切换等，SDK都会负责自动重连。
 *  除非您已经手动将连接断开，否则您不需要自己再手动重连。
 */
- (void)connect:(void (^)(NSString *userId))successBlock
          error:(void (^)(QHVCIMConnectErrorCode status))errorBlock;

/**
 *  @功能 断开与服务器的连接
 *  @参数 isReceivePush   App在断开连接之后，是否还接收远程推送
 *  因为SDK在前后台切换或者网络出现异常都会自动重连，会保证连接的可靠性。
 *  所以除非您的App逻辑需要登出，否则一般不需要调用此方法进行手动断开。
 */
- (void)disconnect:(BOOL)isReceivePush;

#pragma mark 消息发送
- (QHVCIMMessage *)sendMessage:(QHVCIMConversationType)conversationType
                      targetId:(NSString *)targetId
                       content:(QHVCIMMessageContent *)content
                       success:(void (^)(long messageId))successBlock
                         error:(void (^)(QHVCIMErrorCode errorCode,
                                         long messageId))errorBlock;

#pragma mark - 聊天室操作

/**
 *  @功能 加入聊天室（如果聊天室不存在则会创建）
 *  @参数 roomId 聊天室ID
 *  @参数 messageCount 进入聊天室时获取历史消息的数量，-1<=messageCount<=50
 *  @参数 successBlock            加入聊天室成功的回调
 *  @参数 errorBlock              加入聊天室失败的回调 [status:加入聊天室失败的错误码]
 *  @discussion
 *  可以通过传入的messageCount设置加入聊天室成功之后，需要获取的历史消息数量。
 *  -1表示不获取任何历史消息，0表示不特殊设置而使用SDK默认的设置（默认为获取10条），0<messageCount<=50为具体获取的消息数量,最大值为50。
 *
 */
- (void)joinChatroom:(NSString *)roomId
        messageCount:(int)messageCount
             success:(void (^)(void))successBlock
               error:(void (^)(QHVCIMErrorCode status))errorBlock;

/**
 *  @功能 退出聊天室
 *  @参数 roomId 聊天室ID
 *  @参数 successBlock            退出聊天室成功的回调
 *  @参数 errorBlock              退出聊天室失败的回调 [status:加入聊天室失败的错误码]
 *
 */
- (void)quitChatroom:(NSString *)roomId
             success:(void (^)(void))successBlock
               error:(void (^)(QHVCIMErrorCode status))errorBlock;

/**
 *  @功能 设置回调代理
 *  @参数
 */
- (void)setMessageDelegate:(id<QHVCIMMessageDelegate>)messageDelegate;
- (nullable id<QHVCIMMessageDelegate>)messageDelegate;

@end
NS_ASSUME_NONNULL_END
