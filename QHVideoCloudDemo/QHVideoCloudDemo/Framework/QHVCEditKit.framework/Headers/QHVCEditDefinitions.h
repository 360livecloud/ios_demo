//
//  QHVCEditDefinitions.h
//  QHVCEditKit
//
//  Created by liyue-g on 2018/4/20.
//  Copyright © 2018年 liyue-g. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

#pragma mark - QHVCEffectRect

struct
QHVCEffectRect {
    CGPoint center;  //中心点
    CGSize  size;    //宽高
};
typedef struct QHVCEffectRect QHVCEffectRect;

#ifdef __cplusplus
extern "C" {
#endif
    QHVCEffectRect QHVCEffectRectMake(CGFloat x, CGFloat y, CGFloat width, CGFloat height);
    
#ifdef __cplusplus
}
#endif

#define QHVCEffectRectZero QHVCEffectRectMake(0,0,0,0)

typedef NS_ENUM(NSUInteger, QHVCEditError)
{
    QHVCEditErrorNoError,                         //无错误
    QHVCEditErrorParamError,                      //参数错误
    QHVCEditErrorAlreayExist,                     //已存在
    QHVCEditErrorNotExist,                        //不存在
    QHVCEditErrorInitError,                       //初始化失败
    QHVCEditErrorStatusError,                     //状态错误
    QHVCEditErrorHandleIsNull,                    //句柄为空
};

typedef NS_ENUM(NSUInteger, QHVCEditAuthError)
{
    QHVCEditAuthErrorNoError,          //无错误
    QHVCEditAuthErrorNetworkError,     //网络错误
    QHVCEditAuthErrorPackageError,     //包名错误
    QHVCEditAuthErrorExpired,          //已过期
    QHVCEditAuthErrorParamError,       //配置错误
    QHVCEditAuthErrorRequstTooMany,    //请求太频繁
};

typedef NS_ENUM(NSUInteger, QHVCEditLogLevel)
{
    QHVCEditLogLevelNone,   //关闭日志
    QHVCEditLogLevelError,  //仅包含错误
    QHVCEditLogLevelWarn,   //错误+警告
    QHVCEditLogLevelInfo,   //错误+警告+状态信息
    QHVCEditLogLevelDebug,  //错误+警告+状态信息+调试信息
};


typedef NS_ENUM(NSUInteger, QHVCEditObjectType)
{
    QHVCEditObjectTypeTimeline,    //timeline对象
    QHVCEditObjectTypeTrack,       //track对象
    QHVCEditObjectTypeClip,        //clip对象
};

typedef NS_ENUM(NSUInteger, QHVCEditFillMode)
{
    QHVCEditFillModeAspectFit,    //视频内容完全填充，可能会显示背景
    QHVCEditFillModeAspectFill,   //视频内容铺满画布，视频内容可能会被裁剪
    QHVCEditFillModeScaleToFill,  //视频内容铺满画布，视频内容可能会被拉伸
};

typedef NS_ENUM(NSUInteger, QHVCEditBgMode)
{
    QHVCEditBgModeColor,  //纯色背景
    QHVCEditBgModeBlur,   //毛玻璃背景
    QHVCEditBgModeImage,  //图片背景
};

typedef NS_ENUM(NSUInteger, QHVCEditTrackType)
{
    QHVCEditTrackTypeVideo,    //视频轨道
    QHVCEditTrackTypeAudio,    //音频轨道
};

typedef NS_ENUM(NSUInteger, QHVCEditTrackArrangement)
{
    QHVCEditTrackArrangementOverlay,
    QHVCEditTrackArrangementSequence,
};

typedef NS_ENUM(NSUInteger, QHVCEditTrackClipType)
{
    QHVCEditTrackClipTypeVideo,    //视频文件
    QHVCEditTrackClipTypeAudio,    //音频文件
    QHVCEditTrackClipTypeImage,    //静态图片
};

typedef NS_ENUM(NSUInteger, QHVCEditEffectType)
{
    QHVCEditEffectTypeVideo,   //视频特效
    QHVCEditEffectTypeAudio,   //音频特效
    QHVCEditEffectTypeMix,     //图层混合特效
};

typedef NS_ENUM(NSUInteger, QHVCEditEasingFunctionType)
{
    QHVCEditEasingFunctionTypeLinear,
    QHVCEditEasingFunctionTypeCubicEaseIn,
    QHVCEditEasingFunctionTypeCubicEaseOut,
    QHVCEditEasingFunctionTypeCubicEaseInOut,
    QHVCEditEasingFunctionTypeQuintEaseInOut,
    QHVCEditEasingFunctionTypeQuartEaseInOut,
    QHVCEditEasingFunctionTypeQuadEaseInOut,
    QHVCEditEasingFunctionTypeQuadEaseOut,
};

typedef NS_ENUM(NSUInteger, QHVCEditAudioTransferType)
{
    QHVCEditAudioTransferTypeNone,                //正常
    QHVCEditAudioTransferTypeFadeIn,              //淡入
    QHVCEditAudioTransferTypeFadeOut,             //淡出
};

typedef NS_ENUM(NSInteger, QHVCEditAudioTransferCurveType)
{
    QHVCEditAudioTransferCurveTypeTri,                    //线性
    QHVCEditAudioTransferCurveTypeQsin,                   //正弦波
    QHVCEditAudioTransferCurveTypeEsin,                   //指数正弦
    QHVCEditAudioTransferCurveTypeHsin,                   //正弦波的一半
    QHVCEditAudioTransferCurveTypeLog,                    //对数
    QHVCEditAudioTransferCurveTypeIpar,                   //倒抛物线
    QHVCEditAudioTransferCurveTypeQua,                    //二次方
    QHVCEditAudioTransferCurveTypeCub,                    //立方
    QHVCEditAudioTransferCurveTypeSqu,                    //平方根
    QHVCEditAudioTransferCurveTypeCbr,                    //立方根
    QHVCEditAudioTransferCurveTypePar,                    //抛物线
    QHVCEditAudioTransferCurveTypeExp,                    //指数
    QHVCEditAudioTransferCurveTypeIqsin,                  //正弦波反季
    QHVCEditAudioTransferCurveTypeIhsin,                  //倒一半的正弦波
    QHVCEditAudioTransferCurveTypeDese,                   //双指数差值
    QHVCEditAudioTransferCurveTypeDesi,                   //双指数S弯曲
};

#pragma mark - 慢视频信息

@interface QHVCEditSlowMotionVideoInfo : NSObject
@property (nonatomic, assign) NSInteger startTime;    //物理文件开始时间点（单位：毫秒）
@property (nonatomic, assign) NSInteger endTime;      //物理文件结束时间点（单位：毫秒）
@property (nonatomic, assign) CGFloat speed;            //物理文件原始速率

@end

#pragma mark - 渲染信息

@interface QHVCEditRenderInfo : NSObject

/**
 填充样式, 默认 QHVCEditFillModeAspectFit（视频内容完全填充，可能会有黑边）
 */
@property (nonatomic, assign) QHVCEditFillMode fillMode;

/**
 背景画布样式，默认黑色背景
 */
@property (nonatomic, assign) QHVCEditBgMode bgMode;

/**
 背景颜色，16进制ARGB值，背景样式为QHVCEditBgModeColor时有效
 */
@property (nonatomic, strong) NSString* bgColor;

/**
 背景图，背景样式为QHVCEditBgModeImage时有效
 */
@property (nonatomic, strong) UIImage* bgImage;

/**
 相对输出画布的视图渲染区域，x、y为渲染区域中心点在画布中的坐标，默认同画布尺寸
 */
@property (nonatomic, assign) QHVCEffectRect viewRect;

/**
 相对view的视频渲染区域，x、y为渲染区域中心点在view中的坐标，默认同view的尺寸
 */
@property (nonatomic, assign) QHVCEffectRect renderRect;

/**
 视图旋转弧度值，默认不旋转
 */
@property (nonatomic, assign) CGFloat viewRadian;

/**
 视频旋转弧度值，默认不旋转
 */
@property (nonatomic, assign) CGFloat renderRadian;

@end

#pragma mark - QHVCEditObject

@interface QHVCEditObject : NSObject
@property (nonatomic, readonly, assign) QHVCEditObjectType objType;

@end

