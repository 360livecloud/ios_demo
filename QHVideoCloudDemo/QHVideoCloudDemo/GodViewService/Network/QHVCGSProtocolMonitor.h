//
//  QHVCGSProtocolMonitor.h
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2019/5/7.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QHVCGSHTTPSessionManager.h"
#import <QHVCCommonKit/QHVCCommonKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 网络队请求C方法实现 -
void runSynchronouslyOnProtocolProcessingQueue_GS(void (^ _Nonnull block)(void));
void runAsynchronouslyOnProtocolProcessingQueue_GS(void (^ _Nonnull block)(void));

typedef void (^QHVCGSProtocolMonitorDataComplete)(NSURLSessionDataTask* _Nullable taskData, BOOL success);//协议监听数据处理完成
typedef void (^QHVCGSProtocolMonitorDataCompleteWithMessage)(NSURLSessionDataTask* _Nullable taskData, BOOL success, NSString* _Nullable msg);//协议监听数据处理完成并返回消息
typedef void (^QHVCGSProtocolMonitorDataCompleteWithDictionary)(NSURLSessionDataTask* _Nullable taskData, BOOL success, NSDictionary* _Nullable dict);//协议监听数据处理完成并返回字典
typedef void (^QHVCGSProtocolMonitorDataCompleteWithArray)(NSURLSessionDataTask* _Nullable taskData, BOOL success, NSArray* _Nullable array);//协议监听数据处理完成并返回数组
typedef void (^QHVCGSProtocolMonitorDataCompleteWithErrorCode)(NSURLSessionDataTask* _Nullable taskData, BOOL success, NSString* _Nullable msg, NSInteger errorCode);//协议监听数据处理完成并返回消息,若失败返回错误码

@interface QHVCGSProtocolMonitor : NSObject

//执行代码块
+ (void)executeBlock:(QHVCGSProtocolMonitorDataComplete _Nullable )dataComplete
            taskData:(NSURLSessionDataTask * _Nullable)taskData
              result:(BOOL)result;

//执行代码块，返回消息
+ (void)executeBlock:(QHVCGSProtocolMonitorDataCompleteWithMessage _Nullable )dataComplete
            taskData:(NSURLSessionDataTask * _Nullable)taskData
              result:(BOOL)result
             message:(NSString * _Nullable)message;

//执行代码块，返回字典数据
+ (void)executeBlock:(QHVCGSProtocolMonitorDataCompleteWithDictionary _Nullable )dataComplete
            taskData:(NSURLSessionDataTask *_Nullable)taskData
              result:(BOOL)result
                dict:(NSDictionary *_Nullable)dict;

//执行代码块，返回数组数据
+ (void)executeBlock:(QHVCGSProtocolMonitorDataCompleteWithArray _Nullable )dataComplete
            taskData:(NSURLSessionDataTask *_Nullable)taskData
              result:(BOOL)result
               array:(NSArray *_Nullable)array;

//执行代码块，返回消息，错误码
+ (void)executeBlock:(QHVCGSProtocolMonitorDataCompleteWithErrorCode _Nullable )dataComplete
            taskData:(NSURLSessionDataTask *_Nullable)taskData
              result:(BOOL)result
             message:(NSString *_Nullable)message
           errorCode:(NSInteger)errorCode;

////用户登录
//+ (void) getUserLogin:(QHVCGSHTTPSessionManager *_Nonnull)httpManager
//                 dict:(NSMutableDictionary *_Nullable)dict
//             complete:(QHVCGSProtocolMonitorDataCompleteWithDictionary _Nullable )complete;
//
////获取房间列表
//+ (void) getRoomList:(QHVCGSHTTPSessionManager *_Nonnull)httpManager
//                dict:(NSMutableDictionary *_Nullable)dict
//            complete:(QHVCGSProtocolMonitorDataCompleteWithDictionary _Nullable )complete;
//
////获取房间信息
//+ (void) getRoomInfo:(QHVCGSHTTPSessionManager *_Nonnull)httpManager
//                dict:(NSMutableDictionary *_Nullable)dict
//            complete:(QHVCGSProtocolMonitorDataCompleteWithDictionary _Nullable )complete;
//
////创建房间
//+ (void) createRoom:(QHVCGSHTTPSessionManager *_Nonnull)httpManager
//               dict:(NSMutableDictionary *_Nullable)dict
//           complete:(QHVCGSProtocolMonitorDataCompleteWithDictionary _Nullable )complete;
//
////加入房间接口
//+ (void) joinRoom:(QHVCGSHTTPSessionManager *_Nonnull)httpManager
//             dict:(NSMutableDictionary *_Nullable)dict
//         complete:(QHVCGSProtocolMonitorDataCompleteWithDictionary _Nullable)complete;
//
////获取房间用户列表
//+ (void) getRoomUserList:(QHVCGSHTTPSessionManager *_Nonnull)httpManager
//                    dict:(NSMutableDictionary *_Nullable)dict
//                complete:(QHVCGSProtocolMonitorDataCompleteWithDictionary _Nullable)complete;
//
////改变 嘉宾/观众 身份标识
//+ (void) changeUserIdentity:(QHVCGSHTTPSessionManager *_Nonnull)httpManager
//                       dict:(NSMutableDictionary *_Nullable)dict
//                   complete:(QHVCGSProtocolMonitorDataCompleteWithDictionary _Nullable)complete;
//
////退出房间
//+ (void) userLeaveRoom:(QHVCGSHTTPSessionManager *_Nonnull)httpManager
//                  dict:(NSMutableDictionary *_Nullable)dict
//              complete:(QHVCGSProtocolMonitorDataCompleteWithDictionary _Nullable )complete;
//
////主播解散房间
//+ (void) dismissRoom:(QHVCGSHTTPSessionManager *_Nonnull)httpManager
//                dict:(NSMutableDictionary *_Nullable)dict
//            complete:(QHVCGSProtocolMonitorDataCompleteWithDictionary _Nullable )complete;
//
////心跳接口
//+ (void) updateUserHeartbeat:(QHVCGSHTTPSessionManager * _Nonnull)httpManager
//                        dict:(NSMutableDictionary *_Nullable)dict
//                    complete:(QHVCGSProtocolMonitorDataCompleteWithDictionary _Nullable )complete;
//
////加入互动房间
//+ (void)joinLinkRoom:(QHVCGSHTTPSessionManager * _Nonnull)httpManager
//                dict:(NSMutableDictionary *_Nullable)dict
//            complete:(QHVCGSProtocolMonitorDataCompleteWithDictionary _Nullable )complete;
//
////退出互动房间
//+ (void)leaveLinkRoom:(QHVCGSHTTPSessionManager * _Nonnull)httpManager
//                 dict:(NSMutableDictionary *_Nullable)dict
//             complete:(QHVCGSProtocolMonitorDataCompleteWithDictionary _Nullable )complete;
//
////给单个用户推送消息
//+ (void)sendUserMessage:(QHVCGSHTTPSessionManager *)httpManager
//                   dict:(NSMutableDictionary *)dict
//               complete:(QHVCGSProtocolMonitorDataCompleteWithDictionary)complete;
//
////给房间用户推送消息
//+ (void)sendRoomMessage:(QHVCGSHTTPSessionManager *)httpManager
//                   dict:(NSMutableDictionary *)dict
//               complete:(QHVCGSProtocolMonitorDataCompleteWithDictionary)complete;

@end

NS_ASSUME_NONNULL_END
