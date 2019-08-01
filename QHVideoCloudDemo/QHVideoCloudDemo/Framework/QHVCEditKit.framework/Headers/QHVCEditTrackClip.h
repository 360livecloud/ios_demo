//
//  QHVCEditTrackClip.h
//  QHVCEditKit
//
//  Created by liyue-g on 2018/4/20.
//  Copyright © 2018年 liyue-g. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "QHVCEditDefinitions.h"

@class QHVCEditEffect;
@class QHVCEditTimeline;
@class QHVCEffectVideoTransferParam;

@interface QHVCEditTrackClip : QHVCEditObject


#pragma mark - 基础方法

/**
 初始化，创建素材

 @return 素材实例对象
 */
- (instancetype)initClipWithTimeline:(QHVCEditTimeline *)timeline;


/**
 获取素材Id

 @return 素材Id
 */
- (NSInteger)clipId;


/**
 获取父对象
 当素材被添加至轨道之后，返回轨道对象
 
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


#pragma mark - 素材属性

/************************************************************/
/** 更改属性后，需要调用 [track updateClip] 来更新 */
/************************************************************/

/**
 设置素材沙盒访问路径、素材类型
 相册标识和沙盒路径同时设置时，优先读取相册标识
 
 @param filePath 素材沙盒访问路径
 @param type 素材类型
 @return 返回值
 */
- (QHVCEditError)setFilePath:(NSString *)filePath type:(QHVCEditTrackClipType)type;

/**
 获取素材访问路径

 @return 素材访问路径
 */
- (NSString *)filePath;


/**
 设置素材相册唯一标识
 相册标识和沙盒路径同时设置时，优先读取相册标识

 @param fileIdentifier 相册唯一标识
 @param type 素材类型
 @return 返回值
 */
- (QHVCEditError)setFileIdentifier:(NSString *)fileIdentifier type:(QHVCEditTrackClipType)type;


/**
 获取素材相册唯一标识

 @return 相册唯一标识
 */
- (NSString *)fileIdentifier;


/**
 获取素材类型

 @return 素材类型
 */
- (QHVCEditTrackClipType)clipType;


/**
 设置素材裁剪入点，即相对于物理文件的开始时间点（单位：毫秒）
 图片文件持续时长 = 裁剪结束点 - 裁剪起始点

 @param time 开始时间点
 @return 返回值
 */
- (QHVCEditError)setFileStartTime:(NSInteger)time;


/**
 获取素材裁剪入点

 @return 裁剪入点
 */
- (NSInteger)fileStartTime;


/**
 设置素材裁剪出点，即素材相对于物理文件的结束时间点（单位：毫秒）
 图片文件持续时长 = 裁剪结束点 - 裁剪起始点

 @param time 结束时间点
 @return 返回值
 */
- (QHVCEditError)setFileEndTime:(NSInteger)time;


/**
 获取素材裁剪出点

 @return 裁剪出点
 */
- (NSInteger)fileEndTime;


/**
 插入在轨道上的时间点（单位：毫秒）
 插入时间点为相对timeline的时间

 @return 插入时间点
 */
- (NSInteger)insertTime;

/**
 设置素材渲染倍速，影响素材、素材特效渲染速度
 默认原速1.0，大于1.0为快速播放，0~1.0为慢速播放
 
 @param speed 倍速（倍速>0）
 @return 返回值
 */
- (QHVCEditError)setSpeed:(CGFloat)speed;


/**
 素材渲染倍速
 
 @return 倍速
 */
- (CGFloat)speed;


/**
 设置素材播放音量
 默认原素材音量100，0~100为减小音量，100~200为增大音量
 
 @param volume 音量值（0~200）
 @return 返回值
 */
- (QHVCEditError)setVolume:(NSInteger)volume;


/**
 获取素材音量
 
 @return 音量
 */
- (NSInteger)volume;


/**
 设置素材变调，默认为0（变调范围：-12~12）

 @param pitch 变调值
 @return 返回值
 */
- (QHVCEditError)setPitch:(NSInteger)pitch;


/**
 获取素材变调值

 @return 变调值
 */
- (NSInteger)pitch;


/**
 设置水平镜像

 @param flipX 水平镜像
 @return 返回值
 */
- (QHVCEditError)setFlipX:(BOOL)flipX;


/**
 是否水平镜像, 默认不镜像

 @return 是否水平镜像
 */
- (BOOL)flipX;


/**
 设置是否垂直镜像，默认不镜像

 @param flipY 垂直镜像
 @return 返回值
 */
- (QHVCEditError)setFlipY:(BOOL)flipY;


/**
 是否垂直镜像

 @return 垂直镜像
 */
- (BOOL)flipY;


/**
 设置裁剪区域
 默认为源素材大小，原点对齐

 @param cropRect 裁剪区域尺寸
 @return 返回值
 */
- (QHVCEditError)setCropRect:(CGRect)cropRect;


/**
 获取裁剪区域尺寸

 @return 裁剪区域尺寸
 */
- (CGRect)cropRect;

/**
 设置渲染信息，默认以QHVCEditFillModeAspectFit方式填充黑色背景
 
 @param renderInfo 渲染信息
 @return 返回值
 */
- (QHVCEditError)setRenderInfo:(QHVCEditRenderInfo *)renderInfo;


/**
 获取渲染信息
 
 @return 背景样式
 */
- (QHVCEditRenderInfo *)renderInfo;


/**
 设置慢视频信息，普通视频无需设置

 @param slowMotionVideoInfos 慢视频信息
 @return 返回值
 */
- (QHVCEditError)setSlowMotionVideoInfo:(NSArray<QHVCEditSlowMotionVideoInfo *>*)slowMotionVideoInfos;


/**
 慢视频信息

 @return 慢视频信息
 */
- (NSArray<QHVCEditSlowMotionVideoInfo *>*)slowMotionVideoInfo;

/**
 素材时长（单位：毫秒）
 
 @return 素材时长
 */
- (NSInteger)duration;


#pragma mark - 素材特效


/**
 添加素材特效
 
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
 删除素材特效
 
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
 获取素材上添加的所有特效
 
 @return 特效数组
 */
- (NSArray<QHVCEditEffect *>*)getEffects;

@end
