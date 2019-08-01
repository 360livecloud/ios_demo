//
//  QHVCGVDefine.h
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/9/18.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#ifndef QHVCGVDefine_h
#define QHVCGVDefine_h

#define WEAK_SELF_GODVIEW       __weak __typeof(&*self) weakSelf = self;
#define STRONG_SELF_GODVIEW     __strong __typeof(&*self) self = weakSelf;

// ---------------------------------
#define QHVCGV_KEY_ROOM_ID                              @"roomId"   // 房间id
#define QHVCGV_KEY_ROOM_NAME                            @"roomName" // 房间名
#define QHVCGV_KEY_ROOM_TOKEN                           @"token"    // 房间Token

#define QHVCGV_KEY_VERSION                              @"appVersion"//版本号
#define QHVCGV_KEY_APP_ID                               @"appId"
#define QHVCGV_KEY_APP_KEY                              @"appKey"
#define QHVCGV_KEY_TOKEN                                @"token"
#define QHVCGV_KEY_AES_KEY                              @"aesKey"
#define QHVCGV_KEY_MODEL_NAME                           @"modelName"
#define QHVCGV_KEY_URL                                  @"url"//URL
#define QHVCGV_KEY_BODY_DATA                            @"body"
#define QHVCGV_KEY_GET                                  @"GET"
#define QHVCGV_KEY_POST                                 @"POST"
#define QHVCGV_KEY_SIGN                                 @"sign"//地址签名
#define QHVCGV_KEY_USING                                @"usign"//用户签名
#define QHVCGV_KEY_TIMESTAMP                            @"r"//时间戳
#define QHVCGV_KEY_USER_ID                              @"uid"//用户ID
#define QHVCGV_KEY_TALK_ID                              @"talk_id"//用于信令、rtc通话的id
#define QHVCGV_KEY_BIND_ROLE_ID                         @"bindRoleId"//绑定用户ID
#define QHVCGV_KEY_OS_TYPE                              @"ostype"//操作系统
#define QHVCGV_KEY_SESSION_ID                           @"sid"//会话ID
#define QHVCGV_KEY_RTC_VENDOR                           @"vendor"//连麦厂商
#define QHVCGV_KEY_ROOM_ID                              @"roomId"//房间ID
#define QHVCGV_KEY_ROOM_NAME                            @"roomName"//房间名
#define QHVCGV_KEY_IDENTITY                             @"identity"//身份
#define QHVCGV_KEY_OPTION                               @"option"//可选操作
#define QHVCGV_KEY_BIND                                 @"bind"//绑定
#define QHVCGV_KEY_BUSINESS_ID                          @"businessId"//业务ID
#define QHVCGV_KEY_CHANNEL_ID                           @"channelId"//渠道ID
#define QHVCGV_KEY_DEVICE_ID                            @"deviceId"//设备ID
#define QHVCGV_KEY_ERROR_NUMBER                         @"errno"//错误码
#define QHVCGV_KEY_ERROR_MESSAGE                        @"errmsg"//错误消息
#define QHVCGV_KEY_DATA                                 @"data"//数据
#define QHVCGV_KEY_IMEI                                 @"imei"   // 手机标识(同设备id)
#define QHVCGV_KEY_USERNAME                             @"user_name"   // 用户名
#define QHVCGV_KEY_MOBILES                              @"mobiles"   // 用户名
#define QHVCGV_KEY_ADDRESS                              @"address"   // 地址
#define QHVCGV_KEY_EMAIL                                @"email"   // 用户邮箱
#define QHVCGV_KEY_INDEX                                @"index"   // 索引

// ----------------------------------------------------------------------------

/**
 * 帝视请求拉流时 身份认证相关错误码
 */
typedef NS_ENUM(NSInteger, QHVCNetGodSeesTokenVerifyErrorCode) {
    QHVC_NET_GODSEES_TOKEN_ERROR_NO_ERROR = 0,               // token验证成功
    QHVC_NET_GODSEES_TOKEN_ERROR_TokenVerifyFail,            // token验证失败
    QHVC_NET_GODSEES_TOKEN_ERROR_RelayConnectionOverLimit,   // 通过转发连接数超过限制
    QHVC_NET_GODSEES_TOKEN_ERROR_RecordConnectionOverLimit,  // 观看卡录的连接超过限制
    QHVC_NET_GODSEES_TOKEN_ERROR_TotalConnectionOverLimit    // 总观看数超过最大数量
};

// 文案
/// 播放回调
static NSString * const kQHVC_NET_GODSEES_ERROR_SID_INVALID_TEXT                        = @"输入的sid无效";
static NSString * const kQHVC_NET_GODSEES_ERROR_SN_INVALID_TEXT                         = @"输入的sn无效";
static NSString * const kQHVC_NET_GODSEES_ERROR_TOKEN_INVALID_TEXT                      = @"token验证失败";
static NSString * const kQHVC_NET_GODSEES_ERROR_SESSION_NET_BROKEN_TEXT                 = @"session连接断开";
static NSString * const kQHVC_NET_GODSEES_ERROR_DECRYPT_KEY_INVALID_TEXT                = @"视频帧解密秘钥无效";
/// token认证
static NSString * const kQHVC_NET_GODSEES_TOKEN_ERROR_TokenVerifyFail_TEXT              = @"token验证失败";
static NSString * const kQHVC_NET_GODSEES_TOKEN_ERROR_RelayConnectionOverLimit_TEXT     = @"通过转发观看的连接数量超限";
static NSString * const kQHVC_NET_GODSEES_TOKEN_ERROR_RecordConnectionOverLimit_TEXT    = @"观看卡录的连接数量超限";
static NSString * const kQHVC_NET_GODSEES_TOKEN_ERROR_TotalConnectionOverLimit_TEXT     = @"总观看连接数量超限";
static NSString * const kQHVC_NET_GODSEES_REOCRD_PLAY_COMPLETED_TEXT                    = @"卡录已播放完毕";


#endif /* QHVCGVDefine_h */
