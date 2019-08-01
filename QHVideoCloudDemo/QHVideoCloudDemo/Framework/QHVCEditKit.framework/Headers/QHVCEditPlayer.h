//
//  QHVCEditPlayer.h
//  QHVCEditKit
//
//  Created by liyue-g on 2018/4/20.
//  Copyright © 2018年 liyue-g. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QHVCEditDefinitions.h"

#pragma mark - 代理方法

@protocol QHVCEditPlayerDelegate <NSObject>
@optional

/**
 播放器错误回调

 @param error 错误类型
 */
- (void)onPlayerError:(QHVCEditError)error detail:(NSString *)detail;


/**
 播放完成回调
 */
- (void)onPlayerPlayComplete;


/**
 播放器第一帧已渲染回调
 */
- (void)onPlayerFirstFrameDidRendered;

@end

#pragma mark - 播放器方法

@class QHVCEditTimeline;

@interface QHVCEditPlayer : NSObject


/**
 初始化

 @param timeline 时间线对象
 @return 预览播放器实例对象
 */
- (instancetype)initWithTimeline:(QHVCEditTimeline *)timeline;


/**
 设置代理

 @param delegate 代理对象
 @return 返回值
 */
- (QHVCEditError)setDelegate:(id<QHVCEditPlayerDelegate>)delegate;


/**
 释放

 @return 返回值
 */
- (QHVCEditError)free;


/**
 是否正在播放

 @return 是否正在播放
 */
- (BOOL)isPlaying;


/**
 设置预览画布

 @param preview 预览画布
 @return 返回值
 */
- (QHVCEditError)setPreview:(UIView *)preview;


/**
 设置预览画布填充样式

 @param fillMode 填充样式，默认QHVCEditFillMode_AspectFit（视频内容完全填充，可能会有黑边）
 @return 返回值
 */
- (QHVCEditError)setPreviewFillMode:(QHVCEditFillMode)fillMode;


/**
 设置预览画布背景填充色
 默认黑色

 @param color 背景填充色（16进制ARGB值）
 @return 返回值
 */
- (QHVCEditError)setPreviewBgColor:(NSString *)color;


/**
 重置播放器
 若播放器初始化之后有素材文件操作均需重置播放器
 需重置播放器的场景包括：
 * 添加、删除轨道
 * 添加、删除文件
 * 变速
 * 变声
 * 添加、删除转场，修改转场时长

 @param seekTimestamp 重置播放器并跳转至相对timeline的某个时间点（单位：毫秒），默认跳转0点
 @return 返回值
 */
- (QHVCEditError)resetPlayer:(NSInteger)seekTimestamp;

/**
 刷新播放器
 播放器初始化之后有效果变动需刷新播放器，例如添加、删除、修改贴纸特效
 
 @param forceRefresh 是否强制刷新，建议基础属性变动时、频繁更新效果结束时置为true，频繁更新过程中置为false
 @param completion 刷新完成回调
 @return 返回值
 */
- (QHVCEditError)refreshPlayer:(BOOL)forceRefresh completion:(void(^)(void))completion;

/**
 播放

 @return 返回值
 */
- (QHVCEditError)playerPlay;


/**
 停止

 @return 返回值
 */
- (QHVCEditError)playerStop;


/**
 跳转至某个时间点

 @param timestamp 跳转至相对timeline的某个时间点（单位：毫秒）
 @param forceRequest 是否强制请求
 @param block 跳转完成回调
 @return 返回值
 */
- (QHVCEditError)playerSeekToTime:(NSInteger)timestamp
                     forceRequest:(BOOL)forceRequest
                         complete:(void(^)(NSInteger currentTimeMs))block;

/**
 设置播放器静音状态
 
 @param isMute 是否静音
 @return 返回值
 */
- (QHVCEditError)setMute:(BOOL)isMute;

/**
 获取播放器当前时间戳

 @return 播放器当前时间戳
 */
- (NSInteger)getCurrentTimestamp;


/**
 获取播放器当前播放时长

 @return 播放时长
 */
- (NSInteger)getPlayerDuration;


/**
 获取当前视频帧（带所有效果）

 @return 视频帧
 */
- (UIImage *)getCurrentFrame;


/**
 批量获取当前时间点指定视频帧（带所有效果）
 
 @param trackIds 轨道id数组，默认timeline的trackId=-1
 @return @{指令id,视频帧}
 */
- (NSDictionary<NSNumber*, UIImage*>*)getCurrentFrameOfTrackIds:(NSArray<NSNumber *>*)trackIds;


/**
 获取当前时间点指定视频帧（排除某些效果)
 
 @param trackId 轨道id，默认timeline的trackId=-1
 @param excludeEffectIds 排除的特效数组
 @return 视频帧
 */
- (UIImage *)getCurrentFrameOfTrackId:(NSInteger)trackId excludeEffectCommandIds:(NSArray<NSNumber *> *)excludeEffectIds;


@end
