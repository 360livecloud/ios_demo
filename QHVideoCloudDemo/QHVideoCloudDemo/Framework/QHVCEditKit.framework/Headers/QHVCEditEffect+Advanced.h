//
//  QHVCEditEffect+Advanced.h
//  QHVCEditKit
//
//  Created by liyue-g on 2018/10/30.
//  Copyright © 2018年 liyue-g. All rights reserved.
//

#import <QHVCEditKit/QHVCEditKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 自定义图像处理插件

@interface QHVCEditCustomVideoEffect : QHVCEditEffect

/**
 继承这个类来自定义效果，特效处理队列会按照添加顺序依次调用这个方法
 
 @param image 输入图片
 @param timestamp 当前时间戳，相对于timeline（单位：毫秒）
 @return 输出图片
 */
- (CIImage *)processImage:(CIImage *)image timestamp:(NSInteger)timestamp;

@end

#pragma mark - 画质

@interface QHVCEditQualityEffect : QHVCEditEffect
@property (nonatomic, assign) NSInteger brightnessValue;       //亮度 (参数范围-100~100)
@property (nonatomic, assign) NSInteger contrastValue;         //对比度 (参数范围-100~100)
@property (nonatomic, assign) NSInteger exposureValue;         //曝光度 (参数范围-100~100)
@property (nonatomic, assign) NSInteger gammaOffsetValue;      //gamma补偿 (参数范围-100~100)
@property (nonatomic, assign) NSInteger temperatureValue;      //色温 (参数范围-100~100)
@property (nonatomic, assign) NSInteger tintValue;             //色调 (参数范围-100~100)
@property (nonatomic, assign) NSInteger saturationValue;       //饱和度 (参数范围-100~100)
@property (nonatomic, assign) NSInteger hueValue;              //色相 (参数范围-180~180)
@property (nonatomic, assign) NSInteger vibranceValue;         //鲜艳度（自然饱和度）(参数范围-100~100)
@property (nonatomic, assign) NSInteger vignetteValue;         //暗角 (参数范围0~100)
@property (nonatomic, assign) NSInteger prismValue;            //色散 (参数范围0~100)
@property (nonatomic, assign) NSInteger fadeValue;             //褪色 (参数范围0~100)
@property (nonatomic, assign) NSInteger highlightValue;        //高光减弱 (参数范围0~100)
@property (nonatomic, assign) NSInteger shadowValue;           //阴影补偿 (参数范围0~100)
@property (nonatomic, assign) NSInteger skinValue;             //肤色（参数范围-100~100）
@property (nonatomic, assign) NSInteger sharpenValue;          //锐度（参数范围0~100）
@property (nonatomic, assign) NSInteger filmGrainValue;        //颗粒噪声（参数范围0~100）
@property (nonatomic, assign) NSInteger blurValue;             //模糊（参数范围0~100）
@property (nonatomic, assign) NSInteger highlightOrangeValue;  //高光色调橙色（参数范围0~100）
@property (nonatomic, assign) NSInteger highlightCreamValue;   //高光色调奶油色（参数范围0~100）
@property (nonatomic, assign) NSInteger highlightYellowValue;  //高光色调黄色（参数范围0~100）
@property (nonatomic, assign) NSInteger highlightGreenValue;   //高光色调绿色（参数范围0~100）
@property (nonatomic, assign) NSInteger highlightBlueValue;    //高光色调蓝色（参数范围0~100）
@property (nonatomic, assign) NSInteger highlightMagentaValue; //高光色调洋红色（参数范围0~100）
@property (nonatomic, assign) NSInteger shadowRedValue;        //阴影色调红色（参数范围0~100）
@property (nonatomic, assign) NSInteger shadowOrangeValue;     //阴影色调橙色（参数范围0~100）
@property (nonatomic, assign) NSInteger shadowYellowValue;     //阴影色调黄色（参数范围0~100）
@property (nonatomic, assign) NSInteger shadowGreenValue;      //阴影色调绿色（参数范围0~100）
@property (nonatomic, assign) NSInteger shadowBlueValue;       //阴影色调蓝色（参数范围0~100）
@property (nonatomic, assign) NSInteger shadowPurpleValue;     //阴影色调紫色（参数范围0~100）

@end

#pragma mark - 变焦

@interface QHVCEditKenburnsEffect : QHVCEditEffect
@property (nonatomic, assign) CGFloat fromScale;  //初始缩放比例系数，大于1为放大，小于1为缩小
@property (nonatomic, assign) CGFloat toScale;    //结束时缩放比例系数
@property (nonatomic, assign) CGFloat fromX;      //初始X方向偏移比例系数，以画布中心为中心，左负右正
@property (nonatomic, assign) CGFloat toX;        //结束时X方向偏移比例系数
@property (nonatomic, assign) CGFloat fromY;      //初始Y方向偏移比例系数，以画布中心为中心，上正下负
@property (nonatomic, assign) CGFloat toY;        //结束时Y方向偏移比例系数

@end

#pragma mark - 去水印

@interface QHVCEditDelogoEffect : QHVCEditEffect
@property (nonatomic, assign) QHVCEffectRect region; //去水印区域，相对输出画布
@end

#pragma mark - 动效

@interface QHVCEditMotionEffect : QHVCEditEffect
@property (nonatomic, retain) NSString* effectName; //特效名称

@end

#pragma mark - 多种图层混合模式

typedef NS_ENUM(NSUInteger, QHVCEffectBlendType)
{
    QHVCEffectBlendTypeAlpha,            //alpha混合
    QHVCEffectBlendTypeOverlay,          //叠加
    QHVCEffectBlendTypeMultiply,         //多倍
    QHVCEffectBlendTypeScreen,           //屏幕
    QHVCEffectBlendTypeSoftLight,        //柔光
    QHVCEffectBlendTypeHardLight,        //强光
    QHVCEffectBlendTypeDarken,           //变暗
    QHVCEffectBlendTypeColorBurn,        //颜色加深
    QHVCEffectBlendTypeLighten,          //变亮
    QHVCEffectBlendTypeLinearDodge,      //更亮
    QHVCEffectBlendTypeLinearBurn,       //更暗
};

/**
 仅用于轨道特效
 */
@interface QHVCEditBlendEffect : QHVCEditMixEffect
@property (nonatomic, assign) QHVCEffectBlendType blendType;  //混合模式，默认为正常模式，不做任何效果

@end

#pragma mark - 动态字幕

@interface QHVCEditDynamicSubtitleEffect : QHVCEditEffect
@property (nonatomic, retain) NSString* configFilePath;                     //ass配置文件物理路径
@property (nonatomic, retain) NSString* fontFilePath;                       //自定义字体物理路径，没有自定义字体可不传
@end

NS_ASSUME_NONNULL_END
