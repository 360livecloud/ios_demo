//
//  QHVCITSDefine.h
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/3/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

//本类定义各模块需要的字段

#ifndef QHVCITSDefine_h
#define QHVCITSDefine_h

#define WEAK_SELF_LINKMIC       __weak __typeof(&*self) weakSelf = self;
#define STRONG_SELF_LINKMIC     __strong __typeof(&*self) self = weakSelf;

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread])\
{\
block();\
}\
else\
{\
dispatch_async(dispatch_get_main_queue(), block);\
}


#define QHVCITS_KEY_VERSION                             @"appVersion"//版本号
#define QHVCITS_KEY_APP_ID                              @"appId"
#define QHVCITS_KEY_APP_KEY                             @"appKey"
#define QHVCITS_KEY_TOKEN                               @"token"
#define QHVCITS_KEY_AES_KEY                             @"aesKey"
#define QHVCITS_KEY_MODEL_NAME                          @"modelName"
#define QHVCITS_KEY_URL                                 @"url"//URL
#define QHVCITS_KEY_BODY_DATA                           @"body"
#define QHVCITS_KEY_GET                                 @"GET"
#define QHVCITS_KEY_POST                                @"POST"
#define QHVCITS_KEY_SIGN                                @"sign"//地址签名
#define QHVCITS_KEY_USING                               @"usign"//用户签名
#define QHVCITS_KEY_TIMESTAMP                           @"ts"//时间戳
#define QHVCITS_KEY_USER_ID                             @"userId"//用户ID
#define QHVCITS_KEY_BIND_ROLE_ID                        @"bindRoleId"//绑定用户ID
#define QHVCITS_KEY_OS_TYPE                             @"ostype"//操作系统
#define QHVCITS_KEY_CHANNEL_ID                          @"channelId"//渠道ID
#define QHVCITS_KEY_SESSION_ID                          @"sid"//会话ID
#define QHVCITS_KEY_RTC_VENDOR                          @"vendor"//连麦厂商
#define QHVCITS_KEY_ROOM_ID                             @"roomId"//房间ID
#define QHVCITS_KEY_ROOM_NAME                           @"roomName"//房间名
#define QHVCITS_KEY_IDENTITY                            @"identity"//身份
#define QHVCITS_KEY_STREAM_NAME                         @"sn"//流名
#define QHVCITS_KEY_PUSH_ADDRESS                        @"push_addr"//推流地址
#define QHVCITS_KEY_OPTION                              @"option"//可选操作
#define QHVCITS_KEY_BIND                                @"bind"//绑定
#define QHVCITS_KEY_ROOM_PUSH                           @"room_push"//房间合流转推地址
#define QHVCITS_KEY_ROOM_OPTION                         @"room_opt"//房间可选操作
#define QHVCITS_KEY_BUSINESS_ID                         @"businessId"//业务ID
#define QHVCITS_KEY_CHANNEL_ID                          @"channelId"//渠道ID
#define QHVCITS_KEY_DEVICE_ID                           @"deviceId"//设备ID
#define QHVCITS_KEY_ERROR_NUMBER                        @"errno"//错误码
#define QHVCITS_KEY_ERROR_MESSAGE                       @"errmsg"//错误消息
#define QHVCITS_KEY_DATA                                @"data"//数据
#define QHVCITS_KEY_CREATE_TIME                         @"createTime"//创建时间
#define QHVCITS_KEY_OPTION_INFO                         @"optionInfo"//可选操作
#define QHVCITS_KEY_ROOM_TYPE                           @"roomType"//房间类型
#define QHVCITS_KEY_TALK_TYPE                           @"talkType"//通话类型
#define QHVCITS_KEY_MAX_NUMBER                          @"maxNum"//最大人数
#define QHVCITS_KEY_NUM                                 @"num"//数量
#define QHVCITS_KEY_ROOM_LIFE_TYPE                      @"roomLifeType"//房间生命周期
#define QHVCITS_KEY_VIDEO_PROFILE                       @"videoProfile"//视频属性
#define QHVCITS_KEY_EXCHANGE_W_H                        @"exchangeWH"//切换宽高
#define QHVCITS_KEY_CMD                                 @"cmd"//指令
#define QHVCITS_KEY_TARGET_ID                           @"targetId"//目标ID
#define QHVCITS_KEY_CONTENT                             @"content"//内容
#define QHVCITS_KEY_CLIENT_ID                           @"clientId"//客户端
#define QHVCITS_KEY_IMAGE                               @"image"//图像
#define QHVCITS_KEY_TITLE                               @"title"//标题
#define QHVCITS_KEY_VALUE                               @"value"//值

typedef NS_ENUM(NSInteger, QHVCITFunctionType) {
    QHVCITFunctionTypeOwnerAndGuest = 0,         // 主播&嘉宾
    QHVCITFunctionTypeOwnerVSOwner,              // 主播vs主播
    QHVCITFunctionTypeHongpa,                    // 开趴大厅
};

#endif /* QHVCITSDefine_h */
