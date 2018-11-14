//
//  QHVCUploader.h
//  QHVCUploadKit
//
//  Created by deng on 2017/9/18.
//  Copyright © 2017年 qihoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QHVCCommonUploadConfigObject;

typedef NS_ENUM(NSInteger, QHVCCommonUploadTaskType) {
    QHVCCommonUploadTaskTypeUnknow = 0,
    QHVCCommonUploadTaskTypeForm,//表单
    QHVCCommonUploadTaskTypeParallel//分片
};

typedef NS_ENUM(NSInteger, QHVCCommonUploadStatus) {
    QHVCCommonUploadStatusUploadSucceed = 3,
    QHVCCommonUploadStatusUploadFail,
    QHVCCommonUploadStatusUploadError,
    QHVCCommonUploadStatusUploadCancel
};

typedef NS_ENUM(NSInteger, QHVCCommonUploadError) {
    QHVCCommonUploadErrorNull = 0,//
    QHVCCommonUploadErrorResponse = 20,//上传返回值解析异常
    QHVCCommonUploadErrorInvalidToken = -111,//Token为空
    QHVCCommonUploadErrorInvalidData = -112,//上传的内存数据是空
    QHVCCommonUploadErrorInvalidFile = -113,//上传的文件0字节
    QHVCCommonUploadErrorFileIsDir = -108,//指定FILE是文件夹
    QHVCCommonUploadErrorFileNoExist = -105,//文件不存在
};

typedef NS_ENUM(NSInteger, QHVCCommonUploadLogLevel) {
    QHVCCommonUploadLogLevelTrace = 0,
    QHVCCommonUploadLogLevelDebug = 1,
    QHVCCommonUploadLogLevelInfo  = 2,
    QHVCCommonUploadLogLevelWarn  = 3,
    QHVCCommonUploadLogLevelError = 4,
    QHVCCommonUploadLogLevelAlarm = 5,
    QHVCCommonUploadLogLevelFatal = 6,
};

NS_ASSUME_NONNULL_BEGIN

@protocol QHVCCommonUploaderDelegate <NSObject>

/**
 *  @功能 回调上传状态 成功、失败
 *  @参数 uploader 调用者创建的uploader
 *  @参数 status 上传状态
 */
- (void)didUpload:(id)uploader status:(QHVCCommonUploadStatus)status error:(nullable NSError *)error;

@optional
/**
 *  @功能 上传进度
 *  @参数 uploader 调用者创建的uploader
 *  @参数 progress 上传进度（0.0-1.0）
 */
- (void)didUpload:(id)uploader progress:(float)progress;

@end

@protocol QHVCCommonRecorderDelegate <NSObject>

/**
 *  @功能 保存持久化上传信息
 *  @参数 key 持久化记录key
 *  @参数 data 上传信息
 */
- (void)setRecorder:(NSString *)key data:(NSData *)data;

/**
 *  @功能 获取上传信息
 *  @参数 key 持久化记录key
 *  @返回值 存储的上传信息
 */
- (NSData *)fetchRecorder:(NSString *)key;

/**
 *  @功能 删除上传信息（上传成功、信息过期）
 *  @参数 key 持久化记录key
 */
- (void)deleteRecorder:(NSString *)key;

@end

@interface QHVCCommonUploader : NSObject

/**
 *  @功能 设置上传配置信息
 *  @返回值
 */
- (void)setUploadConfigObject:(QHVCCommonUploadConfigObject *)config;

/**
 *  @功能 获取上传类型，目前有表单和分片两种形式，具体使用哪种形式由服务器返回的配置信息决定
 *  如果是分片上传，需要调用parallelQueueNum获得队列数，用于计算token
 *  如果是表单上传，无需调用parallelQueueNum，计算token不需要此参数
 *  @参数 size 待上传任务数据大小，单位：字节
 *  @返回值
 */
- (QHVCCommonUploadTaskType)uploadTaskType:(uint64_t)size;

/**
 *  @功能 获取分片上传队列数，用于业务计算token
 *  @返回值 分片上传队列数
 */
- (NSInteger)parallelQueueNum;

/**
 *  @功能 分片上传续传
 *  @参数 key 通过key管理上传信息
 */
- (BOOL)setUploadRecorderKey:(NSString *)key;

/**
 *  @功能 两种上传方式，数据在本地uploadFile:，数据在内存中uploadData:
 *  @参数 filePath 待上传文件本地路径
 *  @参数 data    待上传内存数据
 *  @参数 fileName    本地文件/内存数据上传到服务器后的文件名
 *  @参数 token 表单/分片任务计算规则略有差别 在服务器计算
 */
- (void)uploadFile:(NSString *)filePath fileName:(NSString *)fileName token:(NSString *)token;
- (void)uploadData:(NSData *)data fileName:(NSString *)fileName token:(NSString *)token;

/**
 *  @功能 取消当前上传任务
 */
- (void)cancel;

/**
 *  @功能 设置回调代理
 *  @参数
 */
- (void)setUploaderDelegate:(nullable id<QHVCCommonUploaderDelegate>)uploaderDelegate;
- (nullable id<QHVCCommonUploaderDelegate>)uploaderDelegate;

- (void)setRecorderDelegate:(nullable id<QHVCCommonRecorderDelegate>)recorderDelegate;
- (nullable id<QHVCCommonRecorderDelegate>)recorderDelegate;

- (nullable NSString *)fetchSessionId;

#pragma mark Common

/**
 * 开启日志（debug阶段辅助开发调试，根据实际情况使用）
 * @参数 level 日志等级
 */
+ (void)openLogWithLevel:(QHVCCommonUploadLogLevel)level;

/**
 * 设置日志输出callback
 * @参数 callback 回调block
 */
+ (void)setLogOutputCallBack:(void(^)(int loggerID, QHVCCommonUploadLogLevel level, const char *data))callback;

/**
 *  @功能 获取上传sdk版本号
 *  @返回值 sdk版本号（e.g. 2.0.0.0）
 */
+ (NSString *)sdkVersion;

@end

NS_ASSUME_NONNULL_END
