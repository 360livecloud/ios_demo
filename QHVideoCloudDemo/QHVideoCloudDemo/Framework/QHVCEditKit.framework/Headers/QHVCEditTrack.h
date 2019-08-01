//
//  QHVCEditTrack.h
//  QHVCEditKit
//
//  Created by liyue-g on 2018/4/20.
//  Copyright © 2018年 liyue-g. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import "QHVCEditDefinitions.h"

@class QHVCEditTimeline;
@class QHVCEditTrackClip;
@class QHVCEditEffect;

@interface QHVCEditTrack : QHVCEditObject


#pragma mark - 基础方法

/**
 初始化，创建轨道

 @param trackType 轨道类型
 @return 轨道实例对象
 */
- (instancetype)initWithTimeline:(QHVCEditTimeline *)timeline type:(QHVCEditTrackType)trackType;


/**
 获取轨道类型 (video、audio)

 @return 轨道类型
 */
- (QHVCEditTrackType)trackType;


/**
 轨道素材排序类型（顺序轨道、画中画轨道）

 @return 轨道排序类型
 */
- (QHVCEditTrackArrangement)trackArrangement;


/**
 获取轨道Id

 @return 轨道Id
 */
- (NSInteger)trackId;


/**
 轨道时长（单位：毫秒）
 轨道时长计算方式：以轨道内所有文件结束时间点最大值为结束时间点
 
 @return 轨道时长
 */
- (NSInteger)duration;


/**
 获取父对象
 当轨道被添加至timeline之后，返回timeline对象

 @return 父对象
 */
- (QHVCEditObject *)superObj;

/**
 添加自定义数据
 
 @param userData 自定义数据
 @return 返回值
 */
- (QHVCEditError)setUserData:(void *)userData;


/**
 获取自定义数据
 
 @return 自定义数据
 */
- (void *)userData;


#pragma mark - 输出设置


/**
 设置渲染层级，默认按trackId从小到大顺序渲染
 
 @param zOrder 渲染层级
 @return 返回值
 */
- (QHVCEditError)setZOrder:(NSInteger)zOrder;


/**
 获取渲染层级
 
 @return 渲染层级
 */
- (NSInteger)zOrder;


/**
 设置轨道整体渲染倍速，影响轨道内所有素材、特效渲染速度
 默认原速1.0，大于1.0为快速播放，0~1.0为慢速播放
 
 @param speed 倍速（倍速>0）
 @return 返回值
 */
- (QHVCEditError)setSpeed:(CGFloat)speed;


/**
 轨道整体渲染倍速
 
 @return 倍速
 */
- (CGFloat)speed;


/**
 设置轨道整体播放音量，影响轨道内所有素材、特效音量
 默认原素材音量100，0~100为减小音量, 100~200为增大音量
 
 @param volume 音量值（0~200）
 @return 返回值
 */
- (QHVCEditError)setVolume:(NSInteger)volume;


/**
 轨道整体音量
 
 @return 音量
 */
- (NSInteger)volume;


/**
 设置轨道内clip的渲染信息
 track和clip都设置渲染信息时，优先读取clip的渲染信息，默认以QHVCEditFillModeAspectFit方式填充黑色背景
 
 @param renderInfo 渲染信息
 @return 返回值
 */
- (QHVCEditError)setRenderInfo:(QHVCEditRenderInfo *)renderInfo;


/**
 获取轨道内clip的渲染信息
 
 @return 背景样式
 */
- (QHVCEditRenderInfo *)renderInfo;


#pragma mark - 文件素材相关

/**
 更新素材属性

 @param clip 素材对象
 @return 返回值
 */
- (QHVCEditError)updateClipParams:(QHVCEditTrackClip *)clip;

/**
 按文件素材Id删除轨道上的素材，删除素材不影响后续索引对应素材的插入时间点
 
 @param clipId 文件素材Id
 @return 返回值
 */
- (QHVCEditError)deleteClipById:(NSInteger)clipId;


/**
 按id获取文件素材

 @param clipId 文件素材Id
 @return 文件素材
 */
- (QHVCEditTrackClip *)getClipById:(NSInteger)clipId;

/**
 获取轨道上所有文件素材

 @return 文件素材数组
 */
- (NSArray<QHVCEditTrackClip *>*)getClips;


#pragma mark - 轨道特效


/**
 添加轨道特效
 
 @param effect 特效
 @return 返回值
 */
- (QHVCEditError)addEffect:(QHVCEditEffect *)effect;


/**
 更新特效参数
 
 @param effect 特效
 @return 返回值
 */
- (QHVCEditError)updateEffect:(QHVCEditEffect *)effect;


/**
 删除轨道特效
 
 @param effectId 特效Id
 @return 返回值
 */
- (QHVCEditError)deleteEffectById:(NSInteger)effectId;


/**
 获取特效
 
 @param effectId 特效Id
 @return 特效
 */
- (QHVCEditEffect *)getEffectById:(NSInteger)effectId;


/**
 获取轨道上添加的所有特效
 
 @return 特效数组
 */
- (NSArray<QHVCEditEffect *>*)getEffects;

@end

#pragma mark - 有序轨道

@interface QHVCEditSequenceTrack : QHVCEditTrack


/**
 添加素材至轨道末尾
 例如, 轨道上素材列表为ABC，调用此接口添加素材D，调用成功后，轨道上的素材列表为ABCD
 
 @param clip 素材
 @return 返回值
 */
- (QHVCEditError)appendClip:(QHVCEditTrackClip *)clip;


/**
 在指定索引位置插入素材
 index为0时，代表添加至轨道开始位置；index >= 轨道素材个数，代表添加至轨道末尾位置
 例如，轨道素材列表为ABC，调用此接口插入素材D至索引0，调用成功后，轨道上的素材列表为DABC；若设置索引1，则为ADBC
 
 @param clip 素材
 @param index 插入后片段索引
 @return 返回值
 */
- (QHVCEditError)insertClip:(QHVCEditTrackClip *)clip atIndex:(NSInteger)index;

/**
 移动素材至指定索引位置
 @param fromIndex 当前索引
 @param toIndex 要移动到的索引
 @return 返回值
*/
- (QHVCEditError)moveClip:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;


/**
 按素材索引删除轨道上的素材，删除素材不影响后续索引对应素材的插入时间点
 
 @param index 素材在轨道内的索引
 @return 返回值
 */
- (QHVCEditError)deleteClipAtIndex:(NSInteger)index;


/**
 按素材索引获取文件素材
 
 @param index 素材索引
 @return 文件素材
 */
- (QHVCEditTrackClip *)getClipAtIndex:(NSInteger)index;


/**
 添加转场

 @param clipIndex 转场添加位置，例如AB两个素材间添加转场，clipIndex为B的下标
 @param duration 转场持续时长（单位：毫秒）
 @param transitionName 视频转场名称，转场名称详见文档
 @param easingFunctionType 缓动函数类型
 @return 返回值
 */
- (QHVCEditError)addVideoTransitionToIndex:(NSInteger)clipIndex
                                  duration:(NSInteger)duration
                       videoTransitionName:(NSString *)transitionName
                        easingFunctionType:(QHVCEditEasingFunctionType)easingFunctionType;


/**
 更新转场参数

 @param clipIndex 转场添加位置，例如AB两个素材间添加转场，clipIndex为B的下标
 @param duration 转场持续时长（单位：毫秒）
 @param transitionName 视频转场名称，转场名称详见文档
 @param easingFunctionType 缓动函数类型
 @return 返回值
 */
- (QHVCEditError)updateVideoTransitionAtIndex:(NSInteger)clipIndex
                                     duration:(NSInteger)duration
                          videoTransitionName:(NSString *)transitionName
                           easingFunctionType:(QHVCEditEasingFunctionType)easingFunctionType;

/**
 删除转场
 
 @param clipIndex 转场添加位置，例如AB两个素材间添加转场，clipIndex为B的索引
 @return 返回值
 */
- (QHVCEditError)deleteVideoTransition:(NSInteger)clipIndex;

@end

#pragma mark - 画中画轨道

@interface QHVCEditOverlayTrack : QHVCEditTrack


/**
 在轨道上某个时间点添加文件素材
 添加时间点为相对timeline的时间，同一轨道上素材持续时间段不可叠加，若添加时间点上已有素材则插入失败
 如需要添加叠加效果请设置转场效果或新增轨道
 
 @param clip 文件素材
 @param time 插入时间点（单位：毫秒）
 @return 返回值
 */
- (QHVCEditError)addClip:(QHVCEditTrackClip *)clip atTime:(NSInteger)time;


/**
 修改文件素材插入时间点
 同一轨道上素材持续时间段不可叠加，若插入时间点上已有素材则插入失败
 
 @param time 插入时间点（单位：毫秒）
 @param clipId 素材Id
 @return 返回值
 */
- (QHVCEditError)changeClipInsertTime:(NSInteger)time clipId:(NSInteger)clipId;

@end
