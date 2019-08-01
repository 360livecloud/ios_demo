//
//  QHVCGodViewHttpBusiness.h
//  QHVideoCloudToolSetDebug
//
//  Created by jiangbingbing on 2018/10/23.
//  Copyright © 2018年 yangkui. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "QHVCGVHTTPSessionManager.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 网络队请求C方法实现 -
void runSynchronouslyOnProtocolProcessingQueue_GodView(void (^ _Nonnull block)(void));
void runAsynchronouslyOnProtocolProcessingQueue_GodView(void (^ _Nonnull block)(void));

typedef void (^QHVCGVProtocolMonitorDataComplete)(NSURLSessionDataTask* _Nullable taskData, BOOL success);//协议监听数据处理完成
typedef void (^QHVCGVProtocolMonitorDataCompleteWithMessage)(NSURLSessionDataTask* _Nullable taskData, BOOL success, NSString* _Nullable msg);//协议监听数据处理完成并返回消息
typedef void (^QHVCGVProtocolMonitorDataCompleteWithDictionary)(NSURLSessionDataTask* _Nullable taskData, BOOL success, NSDictionary* _Nullable responseDict);//协议监听数据处理完成并返回字典
typedef void (^QHVCGVProtocolMonitorDataCompleteWithArray)(NSURLSessionDataTask* _Nullable taskData, BOOL success, NSArray* _Nullable array);//协议监听数据处理完成并返回数组
typedef void (^QHVCGVProtocolMonitorDataCompleteWithErrorCode)(NSURLSessionDataTask* _Nullable taskData, BOOL success, NSString* _Nullable msg, NSInteger errorCode);//协议监听数据处理完成并返回消息,若失败返回错误码

@interface QHVCGodViewHttpBusiness : NSObject

//执行代码块
+ (void)executeBlock:(QHVCGVProtocolMonitorDataComplete _Nullable )dataComplete
            taskData:(NSURLSessionDataTask * _Nullable)taskData
              result:(BOOL)result;

//执行代码块，返回消息
+ (void)executeBlock:(QHVCGVProtocolMonitorDataCompleteWithMessage _Nullable )dataComplete
            taskData:(NSURLSessionDataTask * _Nullable)taskData
              result:(BOOL)result
             message:(NSString * _Nullable)message;

//执行代码块，返回字典数据
+ (void)executeBlock:(QHVCGVProtocolMonitorDataCompleteWithDictionary _Nullable )dataComplete
            taskData:(NSURLSessionDataTask *_Nullable)taskData
              result:(BOOL)result
                dict:(NSDictionary *_Nullable)dict;

//执行代码块，返回数组数据
+ (void)executeBlock:(QHVCGVProtocolMonitorDataCompleteWithArray _Nullable )dataComplete
            taskData:(NSURLSessionDataTask *_Nullable)taskData
              result:(BOOL)result
               array:(NSArray *_Nullable)array;

//执行代码块，返回消息，错误码
+ (void)executeBlock:(QHVCGVProtocolMonitorDataCompleteWithErrorCode _Nullable )dataComplete
            taskData:(NSURLSessionDataTask *_Nullable)taskData
              result:(BOOL)result
             message:(NSString *_Nullable)message
           errorCode:(NSInteger)errorCode;

/**
 * 用户注册
 */
+ (void)registerWithParams:(NSMutableDictionary *)params complete:(QHVCGVProtocolMonitorDataCompleteWithDictionary _Nullable )complete;
/**
 * 用户登录
 */
+ (void)loginWithParams:(NSMutableDictionary *)params complete:(QHVCGVProtocolMonitorDataCompleteWithDictionary _Nullable )complete;

/**
 * 设备列表
 */
+ (void)getBindListComplete:(QHVCGVProtocolMonitorDataCompleteWithDictionary _Nullable )complete;

/**
 * 绑定设备
 */
+ (void)bindDeviceWithParams:(NSMutableDictionary *)params complete:(QHVCGVProtocolMonitorDataCompleteWithDictionary _Nullable )complete;

/**
 * 解绑设备
 */
+ (void)unbindDeviceWithParams:(NSMutableDictionary *)params complete:(QHVCGVProtocolMonitorDataCompleteWithDictionary _Nullable )complete;

/**
 * 获取流密码
 */
+ (void)getStreamPwdWithParams:(NSMutableDictionary *)params complete:(QHVCGVProtocolMonitorDataCompleteWithDictionary _Nullable )complete;

/**
 * 修改设备信息
 */
+ (void)modifyInfoWithParams:(NSMutableDictionary *)params complete:(QHVCGVProtocolMonitorDataCompleteWithDictionary _Nullable )complete;

/**
 * 获取用户已绑定的设备云存信息
 */
+ (void)getCloudRecordList:(NSMutableDictionary *)params complete:(QHVCGVProtocolMonitorDataCompleteWithDictionary _Nullable )complete;

/**
 * 删除云录
 */
+ (void)deleteCloudRecord:(NSMutableDictionary *)params complete:(QHVCGVProtocolMonitorDataCompleteWithDictionary _Nullable )complete;

@end
NS_ASSUME_NONNULL_END
