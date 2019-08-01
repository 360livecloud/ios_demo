//
//  QHVCITSProtocolMonitor.h
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/3/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QHVCITSHTTPSessionManager.h"
#import <QHVCCommonKit/QHVCCommonKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 网络队请求C方法实现 -
void runSynchronouslyOnProtocolProcessingQueue_ITS(void (^ _Nonnull block)(void));
void runAsynchronouslyOnProtocolProcessingQueue_ITS(void (^ _Nonnull block)(void));

typedef void (^QHVCITSProtocolMonitorDataComplete)(NSURLSessionDataTask* _Nullable taskData, BOOL success);//协议监听数据处理完成
typedef void (^QHVCITSProtocolMonitorDataCompleteWithMessage)(NSURLSessionDataTask* _Nullable taskData, BOOL success, NSString* _Nullable msg);//协议监听数据处理完成并返回消息
typedef void (^QHVCITSProtocolMonitorDataCompleteWithDictionary)(NSURLSessionDataTask* _Nullable taskData, BOOL success, NSDictionary* _Nullable dict);//协议监听数据处理完成并返回字典
typedef void (^QHVCITSProtocolMonitorDataCompleteWithArray)(NSURLSessionDataTask* _Nullable taskData, BOOL success, NSArray* _Nullable array);//协议监听数据处理完成并返回数组
typedef void (^QHVCITSProtocolMonitorDataCompleteWithErrorCode)(NSURLSessionDataTask* _Nullable taskData, BOOL success, NSString* _Nullable msg, NSInteger errorCode);//协议监听数据处理完成并返回消息,若失败返回错误码

@interface QHVCITSProtocolMonitor : NSObject

//执行代码块
+ (void)executeBlock:(QHVCITSProtocolMonitorDataComplete _Nullable )dataComplete
            taskData:(NSURLSessionDataTask * _Nullable)taskData
              result:(BOOL)result;

//执行代码块，返回消息
+ (void)executeBlock:(QHVCITSProtocolMonitorDataCompleteWithMessage _Nullable )dataComplete
            taskData:(NSURLSessionDataTask * _Nullable)taskData
              result:(BOOL)result
             message:(NSString * _Nullable)message;

//执行代码块，返回字典数据
+ (void)executeBlock:(QHVCITSProtocolMonitorDataCompleteWithDictionary _Nullable )dataComplete
            taskData:(NSURLSessionDataTask *_Nullable)taskData
              result:(BOOL)result
                dict:(NSDictionary *_Nullable)dict;

//执行代码块，返回数组数据
+ (void)executeBlock:(QHVCITSProtocolMonitorDataCompleteWithArray _Nullable )dataComplete
            taskData:(NSURLSessionDataTask *_Nullable)taskData
              result:(BOOL)result
               array:(NSArray *_Nullable)array;

//执行代码块，返回消息，错误码
+ (void)executeBlock:(QHVCITSProtocolMonitorDataCompleteWithErrorCode _Nullable )dataComplete
            taskData:(NSURLSessionDataTask *_Nullable)taskData
              result:(BOOL)result
             message:(NSString *_Nullable)message
           errorCode:(NSInteger)errorCode;

//用户登录
+ (void) getUserLogin:(QHVCITSHTTPSessionManager *_Nonnull)httpManager
                 dict:(NSMutableDictionary *_Nullable)dict
             complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary _Nullable )complete;

//获取房间列表
+ (void) getRoomList:(QHVCITSHTTPSessionManager *_Nonnull)httpManager
                dict:(NSMutableDictionary *_Nullable)dict
            complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary _Nullable )complete;

//获取房间信息
+ (void) getRoomInfo:(QHVCITSHTTPSessionManager *_Nonnull)httpManager
                dict:(NSMutableDictionary *_Nullable)dict
            complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary _Nullable )complete;

//创建房间
+ (void) createRoom:(QHVCITSHTTPSessionManager *_Nonnull)httpManager
               dict:(NSMutableDictionary *_Nullable)dict
           complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary _Nullable )complete;

//加入房间接口
+ (void) joinRoom:(QHVCITSHTTPSessionManager *_Nonnull)httpManager
             dict:(NSMutableDictionary *_Nullable)dict
         complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary _Nullable)complete;

//获取房间用户列表
+ (void) getRoomUserList:(QHVCITSHTTPSessionManager *_Nonnull)httpManager
                    dict:(NSMutableDictionary *_Nullable)dict
                complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary _Nullable)complete;

//改变 嘉宾/观众 身份标识
+ (void) changeUserIdentity:(QHVCITSHTTPSessionManager *_Nonnull)httpManager
                       dict:(NSMutableDictionary *_Nullable)dict
                   complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary _Nullable)complete;

//退出房间
+ (void) userLeaveRoom:(QHVCITSHTTPSessionManager *_Nonnull)httpManager
                 dict:(NSMutableDictionary *_Nullable)dict
             complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary _Nullable )complete;

//主播解散房间
+ (void) dismissRoom:(QHVCITSHTTPSessionManager *_Nonnull)httpManager
                dict:(NSMutableDictionary *_Nullable)dict
            complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary _Nullable )complete;

//心跳接口
+ (void) updateUserHeartbeat:(QHVCITSHTTPSessionManager * _Nonnull)httpManager
                        dict:(NSMutableDictionary *_Nullable)dict
                    complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary _Nullable )complete;

//加入互动房间
+ (void)joinLinkRoom:(QHVCITSHTTPSessionManager * _Nonnull)httpManager
                dict:(NSMutableDictionary *_Nullable)dict
            complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary _Nullable )complete;

//退出互动房间
+ (void)leaveLinkRoom:(QHVCITSHTTPSessionManager * _Nonnull)httpManager
                 dict:(NSMutableDictionary *_Nullable)dict
             complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary _Nullable )complete;

//给单个用户推送消息
+ (void)sendUserMessage:(QHVCITSHTTPSessionManager *)httpManager
                   dict:(NSMutableDictionary *)dict
               complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary)complete;

//给房间用户推送消息
+ (void)sendRoomMessage:(QHVCITSHTTPSessionManager *)httpManager
                   dict:(NSMutableDictionary *)dict
               complete:(QHVCITSProtocolMonitorDataCompleteWithDictionary)complete;
@end

NS_ASSUME_NONNULL_END
