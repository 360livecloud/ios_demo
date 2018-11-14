//
//  QHVCEdit.h
//  QHVCEditKit
//
//  Created by liyue-g on 2017/9/11.
//  Copyright © 2017年 liyue-g. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class QHVCEditCommandFactory;

typedef NS_ENUM(NSUInteger, QHVCEditPlayerError)
{
    QHVCEditPlayerError_NoError       = 1, //无错误
    QHVCEditPlayerError_ParamError    = 2, //参数错误
    QHVCEditPlayerError_InitError     = 3, //初始化失败
    QHVCEditPlayerError_StatusError   = 4, //播放状态错误
};

typedef NS_ENUM(NSUInteger, QHVCEditPlayerErrorInfo)
{
    QHVCEditPlayerErrorInfo_NoError             = 1, //无错误
    QHVCEditPlayerErrorInfo_CommandFactoryError = 2, //edit handle错误
    QHVCEditPlayerErrorInfo_PlayerHandleError   = 3, //播放器handle错误
    QHVCEditPlayerErrorInfo_ConnectFailed       = 4, //连接错误
    QHVCEditPlayerErrorInfo_OpenFailed          = 5, //打开失败
};

typedef NS_ENUM(NSUInteger, QHVCEditPlayerPreviewFillMode)
{
    QHVCEditPlayerPreviewFillMode_AspectFit,    //视频内容完全填充，可能会有黑边
    QHVCEditPlayerPreviewFillMode_AspectFill,   //视频内容铺满画布，视频内容可能会被裁剪
    QHVCEditPlayerPreviewFillMode_ScaleToFill,  //视频内容铺满画布，视频内容可能会被拉伸
};

@protocol QHVCEditPlayerDelegate <NSObject>
@optional

/**
 播放器错误回调

 @param error 错误类型
 @param info 详细错误信息
 */
- (void)onPlayerError:(QHVCEditPlayerError)error detailInfo:(QHVCEditPlayerErrorInfo)info;

/**
 播放完成回调
 */
- (void)onPlayerPlayComplete;

/**
 播放器第一帧已渲染
 */
- (void)onPlayerFirstFrameDidRendered;

@end

@interface QHVCEditPlayer : NSObject


/**
 初始化播放器

 @return 播放器对象
 */
- (instancetype)initPlayerWithCommandFactory:(QHVCEditCommandFactory *)commandFactory;


/**
 设置播放器代理对象

 @param delegate 代理对象
 @return 是否设置成功
 */
- (QHVCEditPlayerError)setPlayerDelegate:(id<QHVCEditPlayerDelegate>)delegate;


/**
 关闭播放器

 @return 是否关闭成功
 */
- (QHVCEditPlayerError)free;


/**
 关闭播放器

 @param complete 关闭完成回调
 @return 是否调用成功
 */
- (QHVCEditPlayerError)free:(void(^)(void))complete;


/**
 播放器是否处于播放状态

 @return 是否处于播放状态
 */
- (BOOL)isPlayerPlaying;


/**
 设置预览画布

 @param preview 预览画布
 @return 是否设置成功
 */
- (QHVCEditPlayerError)setPlayerPreview:(UIView *)preview;


/**
 设置预览画布填充模式
 默认使用 QHVCEditPlayerPreviewFillMode_AspectFit

 @param mode 填充模式
 @return 是否设置成功
 */
- (QHVCEditPlayerError)setPreviewFillMode:(QHVCEditPlayerPreviewFillMode)mode;


/**
 设置预览画布填充背景色
 默认黑色

 @param color 填充背景色 (16进制值, ARGB)
 @return 是否设置成功
 */
- (QHVCEditPlayerError)setPreviewBackgroudColor:(NSString *)color;


/**
 重置播放器
 若播放器初始化之后有文件操作均需重置播放器（移序、删除、添加文件、添加背景音）

 @param seekTimestampMs 重置并将播放器跳转至某时间点
 @return 是否设置成功
 */
- (QHVCEditPlayerError)resetPlayer:(NSTimeInterval)seekTimestampMs;

/**
 刷新播放器
 若播放器初始化之后有效果添加需刷新播放器（字幕、贴纸、水印、滤镜、画质等）
 
 @return 是否调用成功
 */
- (QHVCEditPlayerError)refreshPlayerWithCompletion:(void(^)(void))completion;

/**
 刷新播放器
 若播放器初始化之后有效果添加需刷新播放器（字幕、贴纸、水印、滤镜、画质等）
 此接口多用于需要频繁刷新播放器的场景，频繁刷新过程中旋转非强制刷新，频繁刷新结束时强制刷新

 @param forceRefresh 是否强制刷新
 @return 是否调用成功
 */
- (QHVCEditPlayerError)refreshPlayerWithForceRefresh:(BOOL)forceRefresh completion:(void(^)(void))completion;

/**
 播放

 @return 是否调用成功
 */
- (QHVCEditPlayerError)playerPlay;


/**
 停止

 @return 是否调用成功
 */
- (QHVCEditPlayerError)playerStop;


/**
 跳转回调

 @param currentTime 当前跳转时间点（单位：毫秒）
 */
typedef void(^QHVCEditPlayerSeekCallback)(NSTimeInterval currentTime);

/**
 跳转至某个时间点

 @param time 跳转时间点（相对所有文件时间轴，单位：毫秒）
 @param forceRequest 是否强制请求
 @param block 跳转完成回调
 @return 是否调用成功
 */
- (QHVCEditPlayerError)playerSeekToTime:(NSTimeInterval)time forceRequest:(BOOL)forceRequest complete:(QHVCEditPlayerSeekCallback)block;


/**
 跳转至某个片段第一帧

 @param index 片段序号
 @param block 跳转完成回调
 @return 是否调用成功
 */
- (QHVCEditPlayerError)playerSeekToSegment:(NSInteger)index complete:(QHVCEditPlayerSeekCallback)block;


/**
 获取当前时间戳

 @return 当前时间戳
 */
- (NSTimeInterval)getCurrentTimestamp;


/**
 获取当前视频帧（带所有效果）
 
 @return 视频帧
 */
- (UIImage *)getCurrentFrame;


/**
 获取当前时间点某个文件的视频帧，带添加到该文件的所有效果

 @param overlayCommandId 文件指令id
 @return 视频帧
 */
- (UIImage *)getCurrentFrameOfOverlayCommandId:(NSInteger)overlayCommandId;


/**
 获取当前时间点某个文件的视频帧，带添加到文件的所有效果，支持排除某些效果

 @param overlayCommandId 文件指令id
 @param excludeCommandIds 排除的指令数组
 @return 视频帧
 */
- (UIImage *)getCurrentFrameOfOverlayCommandId:(NSInteger)overlayCommandId excludeEffectCommandIds:(NSArray<NSNumber *> *)excludeCommandIds;

/**
 批量获取主视频当前视频帧按某些效果处理后对应的缩略图，回调接口

 @param thumbnails 缩略图对象数组
 @param clutImagePaths 查色图路径数组
 */
typedef void(^QHVCEditCLUTFilterThumbnailsCallback)(NSArray<UIImage *>* thumbnails, NSArray<NSString *>* clutImagePaths);

/**
 批量获取主视频当前视频帧按某些效果处理后对应的缩略图

 @param clutImageInfo 查色图信息数组，image和path同时存在优先读取path，image和path均为空（@“”）时返回不带任何特效的缩略图
 例如：
 @[
 @{
 @"path":path,
 @"image":image,
 @"progress":@1.0,
 }];
 @param size 生成缩略图尺寸
 @param block 数据回调
 @return 返回值
 */
- (QHVCEditPlayerError)generateCLUTFilterThumbnails:(NSArray<NSDictionary *>*)clutImageInfo
                                             toSize:(CGSize)size
                                           callback:(QHVCEditCLUTFilterThumbnailsCallback)block;

@end





