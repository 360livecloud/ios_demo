//
//  QHVCEditEffect.h
//  QHVCEditKit
//
//  Created by liyue-g on 2018/4/20.
//  Copyright © 2018年 liyue-g. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QHVCEditDefinitions.h"
#import "QHVCEffectBase.h"

@class QHVCEditTimeline;

#pragma mark - 特效基类

@interface QHVCEditEffect : QHVCEffectBase

/**
 初始化

 @param timeline timeline对象
 @return 特效实例对象
 */
- (instancetype)initEffectWithTimeline:(QHVCEditTimeline *)timeline;

/**
 获取父对象
 
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

@property (nonatomic, readonly,  assign) NSInteger effectId;            //特效Id，每个特效唯一
@property (nonatomic, readonly,  assign) QHVCEditEffectType effectType; //特效类型
@property (nonatomic, readwrite, assign) NSInteger startTime;           //特效相对被添加对象的开始时间（单位：毫秒）
@property (nonatomic, readwrite, assign) NSInteger endTime;             //特效相对被添加对象的结束时间（单位：毫秒）
@property (nonatomic, readwrite, assign) NSInteger renderZOrder;        //特效渲染层级，从小到大依次渲染，层级相同时按添加顺序渲染

@end

#pragma mark - 视频过渡效果（和画中画、贴图组合使用）

typedef NS_ENUM(NSUInteger, QHVCEffectVideoTransferType)
{
    QHVCEffectVideoTransferTypeAlpha,     //透明度（0-1），默认1.0
    QHVCEffectVideoTransferTypeScale,     //缩放，默认1.0
    QHVCEffectVideoTransferTypeOffsetX,   //x方向相对位移，默认0
    QHVCEffectVideoTransferTypeOffsetY,   //y方向相对位移，默认0
    QHVCEffectVideoTransferTypeRadian,    //旋转弧度值，默认0
};

typedef NS_ENUM(NSUInteger, QHVCEffectVideoTransferCurveType)
{
    QHVCEffectVideoTransferCurveTypeLinear,   //线性
    QHVCEffectVideoTransferCurveTypeCurve,    //曲线
};

@interface QHVCEffectVideoTransferParam : NSObject
@property (nonatomic, assign) QHVCEffectVideoTransferType transferType;    //参数类型
@property (nonatomic, assign) QHVCEffectVideoTransferCurveType curveType;  //曲线类型
@property (nonatomic, assign) CGFloat startValue;                          //初始值
@property (nonatomic, assign) CGFloat endValue;                            //结束值
@property (nonatomic, assign) NSInteger startTime;                         //初始时间，为相对时间(单位：毫秒)
@property (nonatomic, assign) NSInteger endTime;                           //结束时间，为相对时间(单位：毫秒)
@end

#pragma mark - 滤镜

@interface QHVCEditFilterEffect : QHVCEditEffect
@property (nonatomic, strong) NSString* filePath;                //查色图本地路径
@property (nonatomic, assign) CGFloat intensity;                 //滤镜程度（0.0~1.0），默认为1.0
@property (nonatomic, assign) NSInteger dimension;               //查色图色阶宽度，默认为64
@end

#pragma mark - 单色调色

@interface QHVCEditMonochromeEffect : QHVCEditEffect
@property (nonatomic, retain) UIColor* color;                    //叠加色值
@property (nonatomic, assign) CGFloat intensity;                 //叠加浓度(0.0 ~ 1.0)，默认为1.0
@end

#pragma mark - 贴图

@interface QHVCEditStickerEffect : QHVCEditEffect
@property (nonatomic, strong) UIImage* sticker;                  //贴图
@property (nonatomic, strong) NSString* stickerPath;             //贴图物理路径
@property (nonatomic, assign) QHVCEffectRect renderRect;         //相对输出画布的渲染区域，x、y为贴纸中心点在画布内的坐标
@property (nonatomic, assign) CGFloat renderRadian;              //初始旋转弧度值，例如，90° = π/2

/**
 过渡效果
 */
@property (nonatomic, retain) NSArray<QHVCEffectVideoTransferParam *>* videoTransfer;

/**
 AE轨迹文件路径，AE轨迹文件和过渡效果同时存在时，优先读取AE轨迹文件
 为了保证AE轨迹效果，尽量保证轨迹文件配置的画幅和输出画布尺寸一致
 */
@property (nonatomic, retain) NSString* aeFilePath;

@end

#pragma mark - 动态贴纸

@interface QHVCEditDynamicStickerEffect : QHVCEditEffect

/**
 贴纸图片信息，需指定帧率、图片路径、循环下标，例如：
 @{
 @"fps":@(25)                      //贴纸绘制帧率
 @"path":@[path0, path1, path2];   //图片路径数组
 @"loopStartIndex":@(0)            //循环开始下标
 @"loopEndIndex":@(25)             //循环结束下标
 }
 */
@property (nonatomic, retain) NSDictionary* imageInfo;
@property (nonatomic, assign) QHVCEffectRect renderRect; //绘制点坐标及尺寸，相对目标画布
@property (nonatomic, assign) CGFloat renderRadian;      //绘制旋转弧度值，例如：90° = π/2

@end

#pragma mark - 图层混合效果

/**
 仅用于轨道效果，图层按alpha混合，同一时间点只能存在一种混合效果
 */
@interface QHVCEditMixEffect : QHVCEditEffect
@property (nonatomic, assign) CGFloat intensity;  //混合程度（0-1），默认为1，混合程度为0时不可见

@end


#pragma mark - 视频过渡效果

/**
 多用于素材效果
 */
@interface QHVCEditVideoTransferEffect : QHVCEditEffect

//视频过渡效果
@property (nonatomic, retain) NSArray<QHVCEffectVideoTransferParam *>* videoTransfer;

//AE轨迹文件路径，AE轨迹文件和过渡效果同时存在时，优先读取AE轨迹文件
//为了保证AE轨迹效果，尽量保证轨迹文件配置的画幅和输出画布尺寸一致
@property (nonatomic, retain) NSString* aeFilePath;

@end

#pragma mark - 音频过渡效果

@interface QHVCEditAudioTransferEffect : QHVCEditEffect
@property (nonatomic, assign) NSInteger gainMin;                                //过渡声音激励最小值，默认0
@property (nonatomic, assign) NSInteger gainMax;                                //过渡声音激励最大值， 默认100
@property (nonatomic, assign) QHVCEditAudioTransferType transferType;           //过渡类型
@property (nonatomic, assign) QHVCEditAudioTransferCurveType transferCurveType; //音量变化曲线类型

@end

#pragma mark - 马赛克

@interface QHVCEditMosaicEffect : QHVCEditEffect
@property (nonatomic, assign) QHVCEffectRect region;  //马赛克区域，相对输出画布
@property (nonatomic, assign) CGFloat intensity;      //马赛克强度（0-1，0为没有马赛克效果）

@end
