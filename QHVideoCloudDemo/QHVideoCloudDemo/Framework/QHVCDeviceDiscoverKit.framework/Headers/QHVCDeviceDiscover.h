//
//  QHVCDeviceDiscover.h
//  QHVCDeviceDiscoverKit
//
//  Created by niezhiqiang on 2019/2/27.
//  Copyright © 2019 qihoo360. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct
{
    char* host_name;
    char* name;
    char* type;
    char* domain;
    char* ip_addr;
    uint16_t port;
    char* txt;  //"key1=1, key2=2 "
}QHVCBrowserRecord;

typedef struct
{
    char* name;
}QHVCPublishRecord;

typedef NS_ENUM(NSInteger, QHVCPublishEvent)
{
    QHVC_DEVICE_PUBLISH_EVENT_OK = 0,  // 发布服务成功
    QHVC_DEVICE_PUBLISH_EVENT_RENAME,  // 有重名服务，需重新命名
    QHVC_DEVICE_PUBLISH_EVENT_ERROR,
};

typedef NS_ENUM(NSInteger, QHVCBrowserEvent)
{
    QHVC_DEVICE_SERVICE_EVENT_FOUND = 0,      //设备发现
    QHVC_DEVICE_SERVICE_EVENT_DISAPPEAR,  //设备消失
    QHVC_DEVICE_SERVICE_EVENT_ERROR,
};

typedef NS_ENUM(NSInteger, QHVCErrorCode)
{
    QHVC_ERROR_NO_ERROR = 0,
    QHVC_ERROR_SERVER_NO_RUNNING,
    QHVC_ERROR_SERVICE_NAME_INVALID,
    QHVC_ERROR_SERVICE_TYPE_INVALID,
    QHVC_ERROR_SERVICE_TXT_INVALID,
    QHVC_ERROR_PORT_INVALID,
    QHVC_ERROR_RECORD_INVALID,
    QHVC_ERROR_TIMEOUT_REACHED,
    QHVC_ERROR_CREAT_BROWSER_SERVICE_ERROR,
    QHVC_ERROR_BROWSER_FAILURE,
    QHVC_ERROR_PUBLISH_ADD_SERVICE_ERROR,
    QHVC_ERROR_REPEAT_PUBLISH_ERROR,
    QHVC_ERROR_RESOLVER_FAILURE,
    QHVC_ERROR_REPEAT_BROSWER_ERROR,
    //...
};

@protocol QHVCDeviceDiscoverDelegate <NSObject>

- (void)publishCallBack:(QHVCErrorCode)err publishEvent:(QHVCPublishEvent)event data:(QHVCPublishRecord *)data;
- (void)browserCallBack:(QHVCErrorCode)err browserEvent:(QHVCBrowserEvent)event data:(QHVCBrowserRecord *)data;

@end

@interface QHVCDeviceDiscover : NSObject

@property (nonatomic, weak) id<QHVCDeviceDiscoverDelegate>delegate;

+ (instancetype)sharedInstance;

/**
 * @param hostName 用户指定的hostname，ios 平台为SCDynamicStoreCopyLocalHostName获取的hostname， linux平台可以为NULL.
 * @param enableIpv6 是否开启IPV6，YES：开启，NO：关闭
 **/
- (int)startServer:(NSString *)hostName enableIpv6:(BOOL)enableIpv6;
- (int)cancelServer;

/**
 * 发布服务接口
 * @param sname 实例化服务名称： 例如： camera-1
 * @param type 服务类型的名称： 例如： _camera._udp、_http._tcp 等
 * @param domain 注册服务的域： 通常置为NULL
 * @param host 注册服务的设备hostname： 通常置为NULL
 * @param port 注册服务的端口号：
 * @param txt   类型为 "key=value" 格式的字符串 例如： "key1=123, key2=abc"
 */
- (void)publishServer:(NSString *)sname type:(NSString *)type domain:(NSString *)domain host:(NSString *)host port:(int)port txt:(NSString *)txt;
- (void)cancelPublishServer:(NSString *)sname type:(NSString *)type domain:(NSString *)domain;

/**
 * 浏览服务的接口
 * @param type 服务类型的名称： 例如： _camera._udp、_http._tcp 等
 * @param domain 注册服务的域： 通常置为NULL
 */
- (void)browserService:(NSString *)type domain:(nullable NSString *)domain;
- (void)cancelBrowserService:(NSString *)type domain:(nullable NSString *)domain;

@end

NS_ASSUME_NONNULL_END
