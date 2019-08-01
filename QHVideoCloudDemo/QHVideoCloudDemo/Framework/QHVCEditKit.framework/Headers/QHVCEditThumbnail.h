//
//  QHVCEditThumbnail.h
//  QHVCEditKit
//
//  Created by liyue-g on 2018/4/23.
//  Copyright © 2018年 liyue-g. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QHVCEditDefinitions.h"

@interface QHVCEditThumbnailItem : NSObject

@property (nonatomic, strong) UIImage*  thumbnail; //缩略图
@property (nonatomic, assign) NSInteger index;     //缩略图序号

@end

@interface QHVCEditThumbnail : NSObject


/**
 初始化

 @return 缩略图生成器实例对象
 */
- (instancetype)init;


/**
 释放缩略图生成器

 @return 返回值
 */
- (QHVCEditError)free;


/**
 获取缩略图回调

 @param thumbnail 缩略图对象
 @param error 错误码
 */
typedef void(^QHVCEditThumbnailCallback)(QHVCEditThumbnailItem* thumbnail, QHVCEditError error);


/**
 批量获取缩略图

 @param filePath 文件路径
 @param width 生成缩略图宽度
 @param height 生成缩略图高度
 @param startTime 起始时间点，相对当前文件（单位：毫秒）
 @param endTime 结束时间点，相对当前文件（单位：毫秒）
 @param count 期望获取视频帧数
 @param callback 获取缩略图回调
 @return 是否调用成功
 */
- (QHVCEditError)requestThumbnailFromFilePath:(NSString *)filePath
                                        width:(NSInteger)width
                                       height:(NSInteger)height
                                    startTime:(NSInteger)startTime
                                      endTime:(NSInteger)endTime
                                        count:(NSInteger)count
                                 dataCallback:(QHVCEditThumbnailCallback)callback;


/**
 获取单张缩略图

 @param filePath 文件路径
 @param width 生成缩略图宽度
 @param height 生成缩略图高度
 @param timeMs 获取某时间点的缩略图（单位：毫秒）
 @param callback 获取缩略图回调
 @return 是否调用成功
 */
- (QHVCEditError)requestThumbnailFromFilePath:(NSString *)filePath
                                        width:(NSInteger)width
                                       height:(NSInteger)height
                                    timestamp:(NSInteger)timeMs
                                 dataCallback:(QHVCEditThumbnailCallback)callback;


/**
 批量获取缩略图
 
 @param fileIdentifier 相册唯一标识符
 @param width 生成缩略图宽度
 @param height 生成缩略图高度
 @param startTime 起始时间点，相对当前文件（单位：毫秒）
 @param endTime 结束时间点，相对当前文件（单位：毫秒）
 @param count 期望获取视频帧数
 @param callback 获取缩略图回调
 @return 是否调用成功
 */
- (QHVCEditError)requestThumbnailFromFileIdentifier:(NSString *)fileIdentifier
                                              width:(NSInteger)width
                                             height:(NSInteger)height
                                          startTime:(NSInteger)startTime
                                            endTime:(NSInteger)endTime
                                              count:(NSInteger)count
                                       dataCallback:(QHVCEditThumbnailCallback)callback;

/**
 获取单张缩略图
 
 @param fileIdentifier 相册唯一标识符
 @param width 生成缩略图宽度
 @param height 生成缩略图高度
 @param timeMs 获取某时间点的缩略图（单位：毫秒）
 @param callback 获取缩略图回调
 @return 是否调用成功
 */
- (QHVCEditError)requestThumbnailFromFileIdentifier:(NSString *)fileIdentifier
                                              width:(NSInteger)width
                                             height:(NSInteger)height
                                          timestamp:(NSInteger)timeMs
                                       dataCallback:(QHVCEditThumbnailCallback)callback;

/**
 取消获取缩略图

 @return 是否调用成功
 */
- (QHVCEditError)cancelAllThumbnailRequest;

@end
