//
//  QHVCIMStatusDefine.h
//  QHVCIMKit
//
//  Created by deng on 2018/3/6.
//  Copyright © 2018年 qihoo.QHVCIMKit. All rights reserved.
//

#ifndef QHVCIMStatusDefine_h
#define QHVCIMStatusDefine_h

#pragma mark - 错误码相关
#pragma mark QHVCIMErrorCode - 具体业务错误码

typedef NS_ENUM(NSInteger, QHVCIMConnectErrorCode) {
    
    /*!
     连接已被释放
     
     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    QHVC_NET_CHANNEL_INVALID = 30001,
    
    /*!
     连接不可用
     
     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    QHVC_NET_UNAVAILABLE = 30002,
    
    /*!
     导航HTTP发送失败
     
     @discussion 如果是偶尔出现此错误，SDK会做好自动重连，开发者无须处理。如果一直是这个错误，应该是您没有设置好ATS。
     ATS默认只使用HTTPS协议，当HTTP协议被禁止时SDK会一直30004错误。您可以在我们iOS开发文档中搜索到ATS设置。
     */
    QHVC_NAVI_REQUEST_FAIL = 30004,
    
    /*!
     导航HTTP请求失败
     
     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    QHVC_NAVI_RESPONSE_ERROR = 30007,
    
    /*!
     导航HTTP返回数据格式错误
     
     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    QHVC_NODE_NOT_FOUND = 30008,
    
    /*!
     创建Socket连接失败
     
     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    QHVC_SOCKET_NOT_CONNECTED = 30010,
    
    /*!
     Socket断开
     
     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    QHVC_SOCKET_DISCONNECTED = 30011,
    
    /*!
     PING失败
     
     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    QHVC_PING_SEND_FAIL = 30012,
    
    /*!
     PING超时
     
     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    QHVC_PONG_RECV_FAIL = 30013,
    
    /*!
     信令发送失败
     
     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    QHVC_MSG_SEND_FAIL = 30014,
    
    /*!
     连接过于频繁
     
     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    QHVC_CONN_OVERFREQUENCY = 30015,
    
    /*!
     连接ACK超时
     
     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    QHVC_CONN_ACK_TIMEOUT = 31000,
    
    /*!
     信令版本错误
     
     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    QHVC_CONN_PROTO_VERSION_ERROR = 31001,
    
    /*!
     AppKey错误
     
     @discussion 请检查您使用的AppKey是否正确。
     */
    QHVC_CONN_ID_REJECT = 31002,
    
    /*!
     服务器当前不可用（预留）
     
     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    QHVC_CONN_SERVER_UNAVAILABLE = 31003,
    
    /*!
     Token无效
     
     @discussion Token无效一般有以下两种原因。
     一是token错误，请您检查客户端初始化使用的AppKey和您服务器获取token使用的AppKey是否一致；
     二是token过期，是因为您在开发者后台设置了token过期时间，您需要请求您的服务器重新获取token并再次用新的token建立连接。
     */
    QHVC_CONN_TOKEN_INCORRECT = 31004,
    
    /*!
     AppKey与Token不匹配
     
     @discussion
     请检查您使用的AppKey与Token是否正确，是否匹配。一般有以下两种原因。
     一是token错误，请您检查客户端初始化使用的AppKey和您服务器获取token使用的AppKey是否一致；
     二是token过期，是因为您在开发者后台设置了token过期时间，您需要请求您的服务器重新获取token并再次用新的token建立连接。
     */
    QHVC_CONN_NOT_AUTHRORIZED = 31005,
    
    /*!
     连接重定向
     
     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    QHVC_CONN_REDIRECTED = 31006,
    
    /*!
     BundleID不正确
     
     @discussion 请检查您App的BundleID是否正确。
     */
    QHVC_CONN_PACKAGE_NAME_INVALID = 31007,
    
    /*!
     AppKey被封禁或已删除
     
     @discussion 请检查您使用的AppKey是否正确。
     */
    QHVC_CONN_APP_BLOCKED_OR_DELETED = 31008,
    
    /*!
     用户被封禁
     
     @discussion 请检查您使用的Token是否正确，以及对应的UserId是否被封禁。
     */
    QHVC_CONN_USER_BLOCKED = 31009,
    
    /*!
     当前用户在其他设备上登录，此设备被踢下线
     */
    QHVC_DISCONN_KICK = 31010,
    
    /*!
     连接被拒绝
     
     @discussion 建立连接的临时错误码，SDK会做好自动重连，开发者无须处理。
     */
    QHVC_CONN_REFUSED = 32061,
    
    /*!
     SDK没有初始化
     
     @discussion 在使用SDK任何功能之前，必须先Init。
     */
    QHVC_CLIENT_NOT_INIT = 33001,
    
    /*!
     开发者接口调用时传入的参数错误
     
     @discussion 请检查接口调用时传入的参数类型和值。
     */
    QHVC_INVALID_PARAMETER = 33003,
    
    /*!
     Connection已经存在
     
     @discussion
     调用过connect之后，只有在token错误或者被踢下线或者用户logout的情况下才需要再次调用connect。SDK会自动重连，不需要应用多次调用connect来保证连接性。
     */
    QHVC_CONNECTION_EXIST = 34001,
    
    /*!
     开发者接口调用时传入的参数错误
     
     @discussion 请检查接口调用时传入的参数类型和值。
     */
    QHVC_INVALID_ARGUMENT = -1000
};

typedef NS_ENUM(NSInteger, QHVCIMErrorCode) {
    
    QHVC_ERRORCODE_UNKNOWN = -1,
};

#pragma mark - 会话相关

#pragma mark QHVCIMConversationType - 会话类型
/*!
 会话类型
 */
typedef NS_ENUM(NSUInteger, QHVCIMConversationType) {

    QHVCIMConversationTypePrivate = 1,//单聊-暂不支持
    QHVCIMConversationTypeDiscussion = 2,//讨论组-暂不支持
    QHVCIMConversationTypeGroup = 3,//群组-暂不支持
    QHVCIMConversationTypeChartroom = 4,//聊天室
};

#pragma mark RCChatRoomMemberOrder - 聊天室成员排列顺序
/*!
 聊天室成员的排列顺序
 */
typedef NS_ENUM(NSUInteger, QHVCMemberOrder) {

    QHVCMemberOrderedAscending  = 1,//升序，返回最早加入的成员列表
    QHVCMemberOrderedDescending = 2,//降序，返回最晚加入的成员列表
};

#pragma mark QHVCMessageDirection - 消息的方向
/*!
 消息的方向
 */
typedef NS_ENUM(NSUInteger, QHVCMessageDirection) {
    /*!
     发送
     */
    QHVCMessageDirectionSend = 1,
    
    /*!
     接收
     */
    QHVCMessageDirectionReceive = 2
};

#pragma mark RCSentStatus - 消息的发送状态
/*!
 消息的发送状态
 */
typedef NS_ENUM(NSUInteger, QHVCSentStatus) {
    /*!
     发送中
     */
    QHVCSentStatusSending = 10,
    
    /*!
     发送失败
     */
    QHVCSentStatusFailed = 20,
    
    /*!
     已发送成功
     */
    QHVCSentStatusSent = 30,
    
    /*!
     对方已接收
     */
    QHVCSentStatusReceived = 40,
    
    /*!
     对方已阅读
     */
    QHVCSentStatusRead = 50,
    
    /*!
     对方已销毁
     */
    QHVCSentStatusDestroyed = 60,
    
    /*!
     发送已取消
     */
    QHVCSentStatusCanceled = 70
};

#pragma mark RCReceivedStatus - 消息的接收状态
/*!
 消息的接收状态
 */
typedef NS_ENUM(NSUInteger, QHVCReceivedStatus) {
    /*!
     未读
     */
    QHVCReceivedStatusUnread = 0,
    
    /*!
     已读
     */
    QHVCReceivedStatusRead = 1,
    
    /*!
     已听
     
     @discussion 仅用于语音消息
     */
    QHVCReceivedStatusListened = 2,
    
    /*!
     已下载
     */
    QHVCReceivedStatusDownloaded = 4,
    
    /*!
     该消息已经被其他登录的多端收取过。（即该消息已经被其他端收取过后。当前端才登录，并重新拉取了这条消息。客户可以通过这个状态更新UI，比如不再提示）。
     */
    QHVCReceivedStatusRetrieved = 8,
    
    /*!
     该消息是被多端同时收取的。（即其他端正同时登录，一条消息被同时发往多端。客户可以通过这个状态值更新自己的某些UI状态）。
     */
    QHVCReceivedStatusMultipleReceive = 16,
    
};

#endif /* QHVCIMStatusDefine_h */
