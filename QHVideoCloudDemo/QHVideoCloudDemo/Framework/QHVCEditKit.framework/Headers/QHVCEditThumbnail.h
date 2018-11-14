//
//  QHVCEditThumbnail.h
//  QHVCEditKit
//
//  Created by liyue-g on 2017/9/11.
//  Copyright © 2017年 liyue-g. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, QHVCEditThumbnailError)
{
    QHVCEditThumbnailError_NoError         = 1, //无错误
    QHVCEditThumbnailError_InitError       = 2, //初始化失败
    QHVCEditThumbnailError_processError    = 3, //获取缩略图错误
    QHVCEditThumbnailError_ParamError      = 4, //参数错误
};

typedef NS_ENUM(NSUInteger, QHVCEditThumbnailErrorInfo)
{
    QHVCEditThumbnailErrorInfo_NoError   = 1, //无错误
};

typedef NS_ENUM(NSUInteger, QHVCEditThumbnailCallbackState)
{
    QHVCEditThumbnailCallbackState_Normal,      //正常
    QHVCEditThumbnailCallbackState_Cancel,      //业务取消获取缩略图
    QHVCEditThumbnailCallbackState_Complete,    //获取缩略图完成
    QHVCEditThumbnailCallbackState_Error,       //获取缩略图错误
};

@interface QHVCEditThumbnailItem : NSObject

@property (nonatomic, strong) UIImage*  thumbnail; //缩略图
@property (nonatomic, assign) NSInteger index;     //缩略图序号
@property (nonatomic, strong) NSString* videoPath; //缩略图所属视频路径

@end

@interface QHVCEditThumbnail : NSObject

/**
 初始化缩略图生成器

 @return 缩略图生成器对象
 */
- (instancetype)initThumbnailFactory;


/**
 释放缩略图生成器
 
 @return 是否调用成功
 */
- (QHVCEditThumbnailError)free;


/**
 获取缩略图回调
 异步操作，可能会陆续回调缩略图

 @param thumbnails 缩略图数组
 @param state 当前状态
 */
typedef void(^QHVCEditThumbnailCallback)(NSArray<QHVCEditThumbnailItem*>* thumbnails, QHVCEditThumbnailCallbackState state);


/**
 获取缩略图

 @param filePath 文件物理路径
 @param width 缩略图宽度
 @param height 缩略图库高度
 @param startTimestampMs 起始时间点，相对当前文件（单位：毫秒）
 @param endTimestampMs 结束时间点，相对当前文件（单位：毫秒）
 @param count 期望获取视频帧数，会根据视频fps做调整，可能实际拿到视频帧数小于期望值
 @param block 获取缩略图回调
 @return 是否调用成功
 */
- (QHVCEditThumbnailError)getVideoThumbnailFromFile:(NSString *)filePath
                                              width:(int)width
                                             height:(int)height
                                          startTime:(NSTimeInterval)startTimestampMs
                                            endTime:(NSTimeInterval)endTimestampMs
                                              count:(int)count
                                           callback:(QHVCEditThumbnailCallback)block;

/**
 获取缩略图
 
 @param photoFileIdentifier 相册文件标识符
 @param width 缩略图宽度
 @param height 缩略图库高度
 @param startTimestampMs 起始时间点，相对当前文件（单位：毫秒）
 @param endTimestampMs 结束时间点，相对当前文件（单位：毫秒）
 @param count 期望获取视频帧数，会根据视频fps做调整，可能实际拿到视频帧数小于期望值
 @param block 获取缩略图回调
 @return 是否调用成功
 */
- (QHVCEditThumbnailError)getVideoThumbnailFromPhotoAlbum:(NSString *)photoFileIdentifier
                                                    width:(int)width
                                                   height:(int)height
                                                startTime:(NSTimeInterval)startTimestampMs
                                                  endTime:(NSTimeInterval)endTimestampMs
                                                    count:(int)count
                                                 callback:(QHVCEditThumbnailCallback)block;


/**
 取消获取缩略图

 @return 是否调用成功
 */
- (QHVCEditThumbnailError)cancelGettingVideoThumbnail;

@end
