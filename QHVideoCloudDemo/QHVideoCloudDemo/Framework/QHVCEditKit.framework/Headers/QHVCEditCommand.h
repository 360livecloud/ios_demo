//
//  QHVCEditComand.h
//  QHVCEditKit
//
//  Created by liyue-g on 2017/9/11.
//  Copyright © 2017年 liyue-g. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

#pragma mark - 日志相关
#pragma mark -

typedef NS_ENUM(NSUInteger, QHVCEditLogLevel)
{
    QHVCEditLogLevel_Error,  //仅包含错误
    QHVCEditLogLevel_Warn,   //错误+警告
    QHVCEditLogLevel_Info,   //错误+警告+状态信息
    QHVCEditLogLevel_Debug,  //错误+警告+状态信息+调试信息
};

@interface QHVCEditLog : NSObject

/**
 获取版本号
 */
+ (NSString *)getVersion;

/**
 设置SDK日志控制台输出级别

 @param level SDK日志控制台输出级别
 */
+ (void)setSDKLogLevel:(QHVCEditLogLevel)level;

/**
 设置SDK日志写文件级别

 @param level SDK日志写文件级别
 */
+ (void)setSDKLogLevelForFile:(QHVCEditLogLevel)level;

/**
 设置用户自定义日志控制台输出级别

 @param level 用户自定义控制台输出级别
 */
+ (void)setUserLogLevel:(QHVCEditLogLevel)level;

/**
 设置用户自定义日志写文件级别

 @param level 用户自定义日志写文件级别
 */
+ (void)setUserLogLevelForFile:(QHVCEditLogLevel)level;

/**
 输出用户自定义日志，若开启了写文件，则日志同时写入文件
 
 @param level 日志级别
 @param prefix 用户自定义日志前缀
 @param content 日志内容
 */
+ (void)printUserLog:(QHVCEditLogLevel)level prefix:(NSString*)prefix content:(NSString *)content;

/**
 设置日志存放路径，默认存于Library/Caches/com.qihoo.videocloud/QHVCEdit/Log/”
 
 @param path 日志存放路径
 */
+ (void)setLogFilePath:(NSString *)path;

/**
 日志是否写文件

 @param writeToLocal 是否写文件
 */
+ (void)writeLogToLocal:(BOOL)writeToLocal;

/**
 设置日志文件相关参数

 @param singleSize 单个日志文件最大大小（单位MB），默认1M
 @param count 日志文件循环写入文件，文件个数，默认3个
 */
+ (void)setLogFileParams:(NSInteger)singleSize count:(NSInteger)count;

@end

#pragma mark - 获取文件信息

typedef NS_ENUM(NSUInteger, QHVCEditVideoCodec)
{
    QHVCEditVideoCodec_H264,
    QHVCEditVideoCodec_HEVC,
};

typedef NS_ENUM(NSUInteger, QHVCEditAudioCodec)
{
    QHVCEditAudioCodec_AAC,
};

@interface QHVCEditFileInfo : NSObject
@property (nonatomic, assign) BOOL isPicture;                //是否是图片
@property (nonatomic, assign) NSInteger width;               //宽度
@property (nonatomic, assign) NSInteger height;              //高度
@property (nonatomic, assign) NSInteger durationMs;          //文件总时长(单位：毫秒)
@property (nonatomic, assign) NSInteger videoBitrate;        //视频码率
@property (nonatomic, assign) NSInteger fps;                 //视频帧率
@property (nonatomic, assign) NSInteger audioBitrate;        //音频码率
@property (nonatomic, assign) NSInteger audioChannels;       //音频声道数
@property (nonatomic, assign) NSInteger audioSamplerate;     //音频采样率


@end

@interface QHVCEditGetFileInfo : NSObject

+ (QHVCEditFileInfo *)getFileInfo:(NSString *)filePath; //获取文件信息
+ (QHVCEditFileInfo *)getPhotoFileInfo:(NSString *)photoFileIdentifier; //PHAssetResource identifier

@end

#pragma mark - 输出相关
#pragma mark - 

typedef NS_ENUM(NSUInteger, QHVCEditOutputError)
{
    QHVCEditOutputError_NoError      = 1, //无错误
    QHVCEditOutputError_ParamError   = 2, //参数错误
};

typedef NS_ENUM(NSUInteger, QHVCEditOutputRenderMode)
{
    QHVCEditOutputRenderMode_AspectFit,    //视频内容完全填充，可能会有黑边
    QHVCEditOutputRenderMode_AspectFill,   //视频内容铺满画布，视频内容可能会被裁剪
    QHVCEditOutputRenderMode_ScaleToFill,  //视频内容铺满画布，视频内容可能会被拉伸
};

typedef NS_ENUM(NSUInteger, QHVCEditOutputBackgroundMode)
{
    QHVCEditOutputBackgroundMode_Color,  //纯色背景
    QHVCEditOutputBackgroundMode_Blur,   //毛玻璃背景
};

@interface QHVCEditOutputParams : NSObject

@property (nonatomic, assign) QHVCEditOutputRenderMode renderMode; //视频帧渲染模式，默认黑边填充QHVCEditOutputRenderMode_AspectFit
@property (nonatomic, assign) QHVCEditOutputBackgroundMode backgroundMode; //视频背景画布样式，默认黑色背景
@property (nonatomic, retain) NSString* backgroundInfo; //背景信息 (背景样式为 QHVCEditOutputBackgroudMode_Color时，背景信息为16进制ARGB值)
@property (nonatomic, assign) CGSize size;

@end

#pragma mark - 指令相关
#pragma mark -

typedef NS_ENUM(NSUInteger, QHVCEditCommandError)
{
    QHVCEditCommandError_NoError       = 1, //无错误
    QHVCEditCommandError_ParamError    = 2, //参数错误
    QHVCEditCommandError_FactoryError  = 3, //指令工厂错误
    QHVCEditCommandError_SendError     = 4, //指令发送错误
};

@interface QHVCEditSlowMotionVideoInfo : NSObject
@property (nonatomic, assign) NSInteger startTimeMs;    //物理文件开始时间点（单位：毫秒）
@property (nonatomic, assign) NSInteger endTimeMs;      //物理文件结束时间点（单位：毫秒）
@property (nonatomic, assign) CGFloat speed;            //物理文件原始速率

@end

@interface QHVCEditSegmentInfo : NSObject
@property (nonatomic, assign) NSInteger segmentIndex;     //片段下标, 若为画中画值是-1
@property (nonatomic, strong) NSString* filePath;         //物理文件路径
@property (nonatomic, assign) NSInteger fileDuration;     //物理文件时长
@property (nonatomic, assign) NSInteger segmentStartTime; //片段开始时间点，相对物理文件(单位：毫秒)
@property (nonatomic, assign) NSInteger segmentEndTime;   //片段结束时间点，相对物理文件(单位：毫秒)
@property (nonatomic, assign) NSInteger segmentInsertTime;//片段插入时间点，相对所有文件所在时间轴(单位：毫秒)
@property (nonatomic, assign) NSInteger segmentDuration;  //片段时长，受变速等效果影响（单位：毫秒）

@end

@interface QHVCEditCommandFactory : NSObject

- (instancetype)initCommandFactory; //初始化指令工厂
- (QHVCEditCommandError)freeCommandFactory; //释放指令工厂
- (QHVCEditCommandError)removeAllCommands; //删除所有指令

- (NSArray<QHVCEditSegmentInfo *>*)getSegmentInfo; //获取文件片段列表信息
- (QHVCEditSegmentInfo *)getOverlaySegmentInfo:(NSInteger)overlayCommandId; //获取画中画文件片段信息

@property (nonatomic, retain) QHVCEditOutputParams* defaultOutputParams; //默认输出样式
@property (nonatomic, readonly, assign) NSInteger factoryHandle;

@end

@interface QHVCEditCommand : NSObject

- (instancetype)initCommand:(QHVCEditCommandFactory *)commandFactory; //创建指令
- (QHVCEditCommandError)addCommand; //添加指令

@property (nonatomic, readonly, assign) NSInteger commandId;  //指令ID

@end

@interface QHVCEditEditableCommand : QHVCEditCommand

- (QHVCEditCommandError)editCommand;   //修改已发送指令
- (QHVCEditCommandError)deleteCommand; //删除已发送指令

@end

#pragma mark - 添加视频文件

@interface QHVCEditCommandAddVideoFile : QHVCEditCommand
@property (nonatomic, strong) NSString* filePath;  //视频存储路径
@property (nonatomic, assign) NSInteger fileIndex; //插入序号

@end

#pragma mark - 添加文件片段

@interface QHVCEditCommandAddFileSegment : QHVCEditCommand
@property (nonatomic, strong) NSString* filePath;              //视频存储路径
@property (nonatomic, strong) NSString* photoFileIdentifier;   //相册中的文件标识符，用于直接从相册读取数据的场景,如果photoFileIdentifier和filePath同时存在，优先使用photoFileIdentifier
@property (nonatomic, assign) NSInteger fileIndex;             //插入序号
@property (nonatomic, assign) NSTimeInterval durationMs;       //持续时长(单位：毫秒)，类型为视频文件时，赋值为<=0的任意数值，类型为图片文件时，赋值为实际持续时长
@property (nonatomic, assign) NSTimeInterval startTimestampMs; //起始时间点，相对物理文件时间(单位：毫秒),文件为图片时此值无效
@property (nonatomic, assign) NSTimeInterval endTimestampMs;   //结束时间点，相对物理文件时间(单位：毫秒),文件为图片时此值无效
@property (nonatomic, assign) BOOL mute;                       //是否舍弃音频
@property (nonatomic, assign) int volume;                      //音量0~200
@property (nonatomic, assign) float speed;                     //0.25~4
@property (nonatomic, assign) int pitch;                       //音调，-12~12
@property (nonatomic, retain) NSArray<QHVCEditSlowMotionVideoInfo *>* slowMotionVideoInfos;  //慢视频物理文件倍速信息

@end

#pragma mark - 添加图片文件

@interface QHVCEditCommandAddImageFile : QHVCEditCommand
@property (nonatomic, strong) NSString* filePath;        //图片文件路径
@property (nonatomic, assign) NSTimeInterval durationMs; //图片重复时长(单位：毫秒)
@property (nonatomic, assign) NSInteger fileIndex;       //插入序号

@end

#pragma mark - 分割文件

@interface QHVCEditCommandCutFile : QHVCEditCommand
@property (nonatomic, assign) NSInteger fileIndex;           //文件序列号
@property (nonatomic, assign) NSTimeInterval cutTimestampMs; //剪切时间点，相对所有文件所在时间轴（单位：毫秒）

@end

#pragma mark - 移动文件

@interface QHVCEditCommandMoveFile : QHVCEditCommand
@property (nonatomic, assign) NSInteger fileIndex; //文件序列号
@property (nonatomic, assign) NSInteger moveStep;  //移动位数，负数左移，正数右移

@end

#pragma mark - 删除文件

@interface QHVCEditCommandDeleteFile : QHVCEditCommand
@property (nonatomic, assign) NSInteger fileIndex; //文件序列号

@end

#pragma mark - 文件合成

@interface QHVCEditCommandMakeFile : QHVCEditCommand
@property (nonatomic, strong) NSString* filePath; //文件导出路径
@property (nonatomic, assign) NSInteger bitrate;  //输出码率（单位bit, 例如，码率1M，bitrate = 1000*1000）

@end

#pragma mark - 背景音乐

@interface QHVCEditCommandBackgroundMusic : QHVCEditEditableCommand
@property (nonatomic, strong) NSString* filePath;               //音频文件路径
@property (nonatomic, assign) NSTimeInterval insertTimeStampMs; //插入时间点, 相对所有文件所在时间轴(单位：毫秒)
@property (nonatomic, assign) NSTimeInterval endTimeStampMs;    //插入结束时间点, 相对所有文件所在时间轴（单位：毫秒）
@property (nonatomic, assign) NSInteger volume;                 //音频音量(0~200)
@property (nonatomic, assign) BOOL loop;                        //是否循环播放

@end

#pragma mark - 音频素材

@interface QHVCEditCommandAudio : QHVCEditEditableCommand
@property (nonatomic, strong) NSString* filePath;                 //音频文件全路径
@property (nonatomic, strong) NSString *photoFileIdentifier;      //相册文件标识符PHAssetResource identifer
@property (nonatomic, assign) NSTimeInterval startTime;           //音频文件开始时间，相对素材(单位：毫秒)
@property (nonatomic, assign) NSTimeInterval endTime;             //音频文件结束时间，相对素材（单位：毫秒）
@property (nonatomic, assign) NSTimeInterval insertStartTime;     //音频文件混音相对于所有文件所在的时间轴的开始时间（单位：毫秒）
@property (nonatomic, assign) NSTimeInterval insertEndTime;       //音频文件混音相对于所有文件所在的时间轴的结束时间 (单位：毫秒)
@property (nonatomic, assign) int volume;                         //音频音量(0~200)
@property (nonatomic, assign) BOOL loop;                          //是否循环播放
@property (nonatomic, assign) int pitch;                          //音调（-12~12）
@property (nonatomic, assign) float speed;                        //变速（1/8~8）

@end

#pragma mark -  调节文件音量

@interface QHVCEditCommandAlterVolume : QHVCEditCommand
@property (nonatomic, assign) NSInteger fileIndex;           //文件序列号
@property (nonatomic, assign) int volume;                    //音量0~200

@end


#pragma mark - 声音淡入淡出

typedef NS_ENUM(NSUInteger, QHVCEditCommandAudioFilterType)
{
    QHVCEditAudioFilterNone,
    QHVCEditAudioFilterFadeIn,              //淡入
    QHVCEditAudioFilterFadeOut,             //淡出
};

typedef NS_ENUM(NSInteger, QHVCEditCommandAudioFadeType)
{
    QHVCEditAudioFadeTri,                    //线性
    QHVCEditAudioFadeQsin,                   //正弦波
    QHVCEditAudioFadeEsin,                   //指数正弦
    QHVCEditAudioFadeHsin,                   //正弦波的一半
    QHVCEditAudioFadeLog,                    //对数
    QHVCEditAudioFadeIpar,                   //倒抛物线
    QHVCEditAudioFadeQua,                    //二次方
    QHVCEditAudioFadeCub,                    //立方
    QHVCEditAudioFadeSqu,                    //平方根
    QHVCEditAudioFadeCbr,                    //立方根
    QHVCEditAudioFadePar,                    //抛物线
    QHVCEditAudioFadeExp,                    //指数
    QHVCEditAudioFadeIqsin,                  //正弦波反季
    QHVCEditAudioFadeIhsin,                  //倒一半的正弦波
    QHVCEditAudioFadeDese,                   //双指数差值
    QHVCEditAudioFadeDesi,                   //双指数S弯曲
};

@interface QHVCEditCommandAudioFadeInOut : QHVCEditEditableCommand
@property (nonatomic, assign) NSInteger mainIndex;                              //主轴文件
@property (nonatomic, assign) NSInteger overlayCommandId;                       //视频overlay
@property (nonatomic, assign) NSInteger audioOverlayCommandId;                  //音频overlay
@property (nonatomic, assign) NSTimeInterval startTimestampMs;                  //起始时间点，相对于逻辑文件的时间（单位：毫秒）
@property (nonatomic, assign) NSTimeInterval endTimestampMs;                    //结束时间点，相对于逻辑文件的时间（单位：毫秒）
@property (nonatomic, assign) NSInteger gainMin;                                //淡入淡出声音最小值，默认0
@property (nonatomic, assign) NSInteger gainMax;                                //淡入淡出声音最大值， 默认100
@property (nonatomic, assign) QHVCEditCommandAudioFilterType audioFilterType;   //淡入、淡出类型
@property (nonatomic, assign) QHVCEditCommandAudioFadeType fadeType;            //变化曲线类型

@end


#pragma mark -  文件变速

@interface QHVCEditCommandAlterSpeed : QHVCEditCommand
@property (nonatomic, assign) NSInteger fileIndex;           //文件序列号
@property (nonatomic, assign) float speed;                   //速度1/8~8

@end

#pragma mark - 变调
@interface QHVCEditCommandAlterPitch : QHVCEditEditableCommand
@property (nonatomic, assign) NSInteger fileIndex;            //文件序列号
@property (nonatomic, assign) int pitch;                      //音调（-12~12）
@end


#pragma mark - 叠加片段

@interface QHVCEditCommandOverlaySegment : QHVCEditEditableCommand
@property (nonatomic, strong) NSString* filePath;                 //物理文件路径
@property (nonatomic, strong) NSString* photoFileIdentifier;      //相册中的文件标识符，用于直接从相册读取数据的场景,如果photoFileIdentifier和filePath同时存在，优先使用photoFileIdentifier
@property (nonatomic, assign) NSTimeInterval durationMs;          //素材持续时长，单位毫秒，当持续时长大于素材片段时长时，按循环处理
@property (nonatomic, assign) NSTimeInterval startTimestampMs;    //素材相对于物理文件的起始时间，单位毫秒，对于图片文件开始时间为0
@property (nonatomic, assign) NSTimeInterval endTimestampMs;      //素材相对于物理文件的结束时间，单位毫秒，对于图片文件结束时间为0
@property (nonatomic, assign) NSTimeInterval insertTimestampMs;   //叠加片段插入时间点，相对所有文件所在时间轴（单位：毫秒）
@property (nonatomic, assign) NSInteger volume;                   //音量值（0-200，默认为100）
@property (nonatomic, assign) CGFloat speed;                      //速率（0.25~4）
@property (nonatomic, assign) int pitch;                          //音调（-12~12）
@property (nonatomic, retain) NSArray<QHVCEditSlowMotionVideoInfo *>* slowMotionVideoInfos;  //慢视频物理文件倍速信息

@end

#pragma mark - 动画（和画中画、字幕、贴纸、水印组合使用）

typedef NS_ENUM(NSUInteger, QHVCEditCommandAnimationType)
{
    QHVCEditCommandAnimationType_Alpha,     //透明度（0-1），默认1.0
    QHVCEditCommandAnimationType_Scale,     //缩放，默认1.0
    QHVCEditCommandAnimationType_OffsetX,   //x方向相对位移，默认0
    QHVCEditCommandAnimationType_OffsetY,   //y方向相对位移，默认0
    QHVCEditCommandAnimationType_Radian,    //旋转弧度值，默认0
};

typedef NS_ENUM(NSUInteger, QHVCEditCommandAnimationCurveType)
{
    QHVCEditCommandAnimationCurveType_Linear,    //线性
    QHVCEditCommandAnimationCurveType_Curve,    //曲线
};

@interface QHVCEditCommandAnimation : NSObject
@property (nonatomic, assign) QHVCEditCommandAnimationType animationType;   //动画参数类型
@property (nonatomic, assign) QHVCEditCommandAnimationCurveType curveType;  //曲线类型
@property (nonatomic, assign) CGFloat startValue;    //初始值
@property (nonatomic, assign) CGFloat endValue;      //结束值
@property (nonatomic, assign) NSInteger startTime;   //初始时间，为相对特效的相对时间，单位：毫秒
@property (nonatomic, assign) NSInteger endTime;     //结束时间，为相对特效的相对时间，单位：毫秒
@end

#pragma mark - 矩阵操作

typedef NS_ENUM(NSUInteger, QHVCEditBlendType)
{
    QHVCEditBlendType_Normal,           //正常
    QHVCEditBlendType_Overlay,          //叠加
    QHVCEditBlendType_Multiply,         //多倍
    QHVCEditBlendType_Screen,           //屏幕
    QHVCEditBlendType_SoftLight,        //柔光
    QHVCEditBlendType_HardLight,        //强光
    QHVCEditBlendType_Darken,           //变暗
    QHVCEditBlendType_ColorBurn,        //颜色加深
    QHVCEditBlendType_Lighten,          //变亮
    QHVCEditBlendType_LinearDodge,      //更亮
    QHVCEditBlendType_LinearBurn,       //更暗
    QHVCEditBlendType_BlackBg = 100,    //黑色背景，只显示画中画
};

@interface QHVCEditCommandMatrixFilter : QHVCEditEditableCommand

//指定特效添加层级。添加给某个叠加片段，需指定叠加文件的commandId; 只添加给主片段列表，=0; 默认为-1，生效于主片段和所有叠加片段
@property (nonatomic, assign) NSInteger overlayCommandId;
@property (nonatomic, assign) CGFloat frameRotateAngle;                 //视频帧相对画布旋转弧度值，例如，90° = π/2，默认不旋转
@property (nonatomic, assign) CGFloat previewRotateAngle;               //视频画布旋转弧度值，例如，90° = π/2，默认不旋转
@property (nonatomic, assign) BOOL flipX;                               //是否左右镜像，默认不镜像
@property (nonatomic, assign) BOOL flipY;                               //是否上下镜像，默认不镜像
@property (nonatomic, assign) CGRect renderRect;                        //绘制点矩阵，相对目标画布，默认对齐画布原点、画布大小
@property (nonatomic, assign) CGRect sourceRect;                        //截取素材矩阵，相对源素材，默认对齐源素材原点、源素材大小
@property (nonatomic, assign) NSInteger renderZOrder;                   //渲染层级，层级越低越靠下，层级越高越靠上，默认0
@property (nonatomic, strong) UIView* preview;                          //渲染窗口，可为空
@property (nonatomic, strong) QHVCEditOutputParams* outputParams;       //输出渲染样式，可为空，默认同CommandFactory defaultOutputParams
@property (nonatomic, assign) NSTimeInterval startTimestampMs;          //起始时间点，相对所有文件所在时间轴，开始时间和结束时间不能跨片段（单位：毫秒）
@property (nonatomic, assign) NSTimeInterval endTimestampMs;            //结束时间点，相对所有文件所在时间轴，开始时间和结束不能跨片段（单位：毫秒）


/**
 关键帧动画
 */
@property (nonatomic, retain) NSArray<QHVCEditCommandAnimation *>* animation;

/**
 混合模式
 */
@property (nonatomic, assign) QHVCEditBlendType blendType;

/**
混合程度（0-1），默认为1，当混合程度为0时，不可见
 */
@property (nonatomic, assign) CGFloat blendProgress;

@end

#pragma mark - 贴图操作

@interface QHVCEditCommandImageFilter : QHVCEditEditableCommand

//指定特效添加层级。添加给某个叠加片段，需指定叠加文件的commandId; 只添加给主片段列表，=0; 默认为-1，生效于主片段和所有叠加片段
@property (nonatomic, assign) NSInteger overlayCommandId;
@property (nonatomic, strong) UIImage* image;                   //贴图
@property (nonatomic, strong) NSString* imagePath;              //贴图物理路径，路径和贴图都存在时优先读取路径
@property (nonatomic, assign) CGFloat destinationX;             //绘制点x坐标，相对目标画布
@property (nonatomic, assign) CGFloat destinationY;             //绘制点y坐标，相对目标画布
@property (nonatomic, assign) CGFloat destinationWidth;         //绘制点宽度，相对目标画布
@property (nonatomic, assign) CGFloat destinationHeight;        //绘制点高度，相对目标画布
@property (nonatomic, assign) CGFloat destinationRotateAngle;   //绘制旋转弧度值，例如，90° = π/2
@property (nonatomic, assign) NSTimeInterval startTimestampMs;  //起始时间点，相对所有文件所在时间轴，开始时间和结束时间不能跨片段（单位：毫秒）
@property (nonatomic, assign) NSTimeInterval endTimestampMs;    //结束时间点，相对所有文件所在时间轴，开始时间和结束时间不能跨片段（单位：毫秒）

/**
 关键帧动画
 */
@property (nonatomic, retain) NSArray<QHVCEditCommandAnimation *>* animation;

@end

#pragma mark - 滤镜操作

typedef NS_ENUM(NSUInteger, QHVCEditAuxFilterType)
{
    QHVCEditAuxFilterType_Color,        //叠加颜色
    QHVCEditAuxFilterType_CLUT,         //查色图
};

@interface QHVCEditCommandAuxFilter : QHVCEditEditableCommand

//指定特效添加层级。添加给某个叠加片段，需指定叠加文件的commandId; 只添加给主片段列表，=0; 默认为-1，生效于主片段和所有叠加片段
@property (nonatomic, assign) NSInteger overlayCommandId;
@property (nonatomic, assign) QHVCEditAuxFilterType auxFilterType; //滤镜类型
@property (nonatomic, retain) NSString* auxFilterInfo;             //滤镜信息。滤镜类型为color时，为填充背景色 (16进制值, ARGB)；滤镜类型为CLUT时，为查色图路径
@property (nonatomic, retain) UIImage* clutImage;                  //查色图，auxFilterInfo和clutImage同时存在时，优先读取auxFilterInfo
@property (nonatomic, assign) CGFloat progress;                    //滤镜程度(0-1)，默认为1
@property (nonatomic, assign) NSTimeInterval startTimestampMs;     //起始时间点，相对所有文件所在时间轴，开始时间和结束时间不能跨片段（单位：毫秒）
@property (nonatomic, assign) NSTimeInterval endTimestampMs;       //结束时间点，相对所有文件所在时间轴，开始时间和结束时间不能跨片段（单位：毫秒）

@end

#pragma mark - 特效

/**
 effect_18: kenburns效果，需要额外传参, 例如：
 effectInfo = @{
 @"fromScale": @1.0,        //初始缩放比例系数，大于1为放大，小于1为缩小
 @"toScale"  : @1.1,        //结束时缩放比例系数
 @"fromX"    : @0.0,        //初始X方向偏移比例系数，以画布中心为中心，左正右负
 @"fromY"    : @0.0,        //初始Y方向偏移比例系数，以画布中心为中心，上正下负
 @"toX"      :@(0.5/11.0),  //结束时X方向偏移比例系数
 @"toY"      :@(0.5/11.0),  //结束时Y方向偏移比例系数
 }
 
 +1.00, +1.10, +0.00, +0.00, +0.5/11.0, +0.5/11.0,
 */

@interface QHVCEditCommandEffectFilter : QHVCEditEditableCommand

//指定特效添加层级。添加给某个叠加片段，需指定叠加文件的commandId; 只添加给主片段列表，=0; 默认为-1，生效于主片段和所有叠加片段
@property (nonatomic, assign) NSInteger overlayCommandId;
@property (nonatomic, retain) NSString* effectName;                 //特效名称（目前支持15种，命名为 effect_1 ... effect_19）
@property (nonatomic, retain) NSDictionary* effectInfo;            //某些特效需要额外参数 (effect_7、15需要额外参数，暂不支持)
@property (nonatomic, assign) NSTimeInterval startTimestampMs;     //起始时间点，相对所有文件所在时间轴，开始时间和结束时间不能跨片段（单位：毫秒）
@property (nonatomic, assign) NSTimeInterval endTimestampMs;       //结束时间点，相对所有文件所在时间轴，开始时间和结束时间不能跨片段（单位：毫秒）

@end

#pragma mark - 画质操作

@interface QHVCEditCommandQualityFilter : QHVCEditEditableCommand

//指定特效添加层级。添加给某个叠加片段，需指定叠加文件的commandId; 只添加给主片段列表，=0; 默认为-1，生效于主片段和所有叠加片段
@property (nonatomic, assign) NSInteger overlayCommandId;
@property (nonatomic, assign) NSInteger brightnessValue;       //亮度 (参数范围-100~100)
@property (nonatomic, assign) NSInteger contrastValue;         //对比度 (参数范围-100~100)
@property (nonatomic, assign) NSInteger exposureValue;         //曝光度 (参数范围-100~100)
@property (nonatomic, assign) NSInteger gammaOffsetValue;      //gamma补偿 (参数范围-100~100)
@property (nonatomic, assign) NSInteger temperatureValue;      //色温 (参数范围-100~100)
@property (nonatomic, assign) NSInteger tintValue;             //色调 (参数范围-100~100)
@property (nonatomic, assign) NSInteger saturationValue;       //饱和度 (参数范围-100~100)
@property (nonatomic, assign) NSInteger hueValue;              //色相 (参数范围-180~180)
@property (nonatomic, assign) NSInteger vibranceValue;         //振动（自然饱和度）(参数范围-100~100)
@property (nonatomic, assign) NSInteger vignetteValue;         //暗角 (参数范围0~100)
@property (nonatomic, assign) NSInteger prismValue;            //色散 (参数范围0~100)
@property (nonatomic, assign) NSInteger fadeValue;             //褪色 (参数范围0~100)
@property (nonatomic, assign) NSInteger highlightValue;        //高光减弱 (参数范围0~100)
@property (nonatomic, assign) NSInteger shadowValue;           //阴影补偿 (参数范围0~100)
@property (nonatomic, assign) NSInteger skinValue;             //肤色（参数范围-100~100）
@property (nonatomic, assign) NSInteger sharpenValue;          //锐度（参数范围0~100）
@property (nonatomic, assign) NSInteger filmGrainValue;        //颗粒噪声（参数范围0~100）
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
@property (nonatomic, assign) NSTimeInterval startTimestampMs; //起始时间点，相对所有文件所在时间轴，开始时间和结束时间不能跨片段（单位：毫秒）
@property (nonatomic, assign) NSTimeInterval endTimestampMs;   //结束时间点，相对所有文件所在时间轴，开始时间和结束时间不能跨片段（单位：毫秒）

@end

#pragma mark - 转场操作

@interface QHVCEditCommandTransition : QHVCEditEditableCommand
@property (nonatomic, assign) NSInteger overlayCommandId;        //需指定叠加片段的commandId
@property (nonatomic, strong) NSString* transitionName;          //转场类型 （目前支持67种，命名为 transition_1 ... transition_67）
@property (nonatomic, assign) NSTimeInterval startTimestampMs;   //起始时间点，相对所有文件所在时间轴，开始时间和结束时间不能跨片段（单位：毫秒）
@property (nonatomic, assign) NSTimeInterval endTimestampMs;     //结束时间点，相对所有文件所在时间轴，开始时间和结束时间不能跨片段（单位：毫秒）

@end

#pragma mark - 色键抠图

typedef NS_ENUM(NSUInteger, QHVCEditChromaKeyQuality)
{
    QHVCEditChromaKeyQuality_High,      //高质量，多用于合成，抠图效率慢
    QHVCEditChromaKeyQuality_Middle,    //中等质量
    QHVCEditChromaKeyQuality_Low,       //质量低，抠图效率非常快
};

@interface QHVCEditCommandChromakey : QHVCEditEditableCommand

//指定特效添加层级。添加给某个叠加片段，需指定叠加文件的commandId; 只添加给主片段列表，=0; 默认为-1，生效于主片段和所有叠加片段
@property (nonatomic, assign) NSInteger overlayCommandId;
@property (nonatomic, retain) NSString* color;                              //抠去的颜色, 16进制ARGB值
@property (nonatomic, assign) int threshold;                                //微调，基于抠去的颜色的波动范围，微调越大抠色范围越大, 0-100
@property (nonatomic, assign) QHVCEditChromaKeyQuality quality;             //抠图质量
@property (nonatomic, assign) NSTimeInterval startTimestampMs;              //起始时间点，相对所有文件所在时间轴，开始时间和结束时间不能跨片段（单位：毫秒）
@property (nonatomic, assign) NSTimeInterval endTimestampMs;                //结束时间点，相对所有文件所在时间轴，开始时间和结束时间不能跨片段（单位：毫秒）

@end

#pragma mark - 美颜

@interface QHVCEditCommandBeauty : QHVCEditEditableCommand

//指定特效添加层级。添加给某个叠加片段，需指定叠加文件的commandId; 只添加给主片段列表，=0; 默认为-1，生效于主片段和所有叠加片段
@property (nonatomic, assign) NSInteger overlayCommandId;
@property (nonatomic, assign) CGFloat softLevel;                            //嫩肤程度（0-1）
@property (nonatomic, assign) CGFloat whiteLevel;                           //美白程度（0-1）
@property (nonatomic, assign) NSTimeInterval startTimestampMs;              //起始时间点，相对所有文件所在时间轴，开始时间和结束时间不能跨片段（单位：毫秒）
@property (nonatomic, assign) NSTimeInterval endTimestampMs;                //结束时间点，相对所有文件所在时间轴，开始时间和结束时间不能跨片段（单位：毫秒）

@end

#pragma mark - 马赛克

@interface QHVCEditCommandMosaic : QHVCEditEditableCommand

//指定特效添加层级。添加给某个叠加片段，需指定叠加文件的commandId; 只添加给主片段列表，=0; 默认为-1，生效于主片段和所有叠加片段
@property (nonatomic, assign) NSInteger overlayCommandId;
@property (nonatomic, assign) CGFloat degree;                               //模糊程度（0-1, 0为没有马赛克效果）
@property (nonatomic, assign) CGRect region;                                //马赛克区域，相对输出画布
@property (nonatomic, assign) NSTimeInterval startTimestampMs;              //起始时间点，相对所有文件所在时间轴，开始时间和结束时间不能跨片段（单位：毫秒）
@property (nonatomic, assign) NSTimeInterval endTimestampMs;                //结束时间点，相对所有文件所在时间轴，开始时间和结束时间不能跨片段（单位：毫秒）

@end

#pragma mark - 去水印

@interface QHVCEditCommandDelogo : QHVCEditEditableCommand

//指定特效添加层级。添加给某个叠加片段，需指定叠加文件的commandId; 只添加给主片段列表，=0; 默认为-1，生效于主片段和所有叠加片段
@property (nonatomic, assign) NSInteger overlayCommandId;
@property (nonatomic, assign) CGRect region;                                //去水印区域，相对输出画布
@property (nonatomic, assign) NSTimeInterval startTimestampMs;              //起始时间点，相对所有文件所在时间轴，开始时间和结束时间不能跨片段（单位：毫秒）
@property (nonatomic, assign) NSTimeInterval endTimestampMs;                //结束时间点，相对所有文件所在时间轴，开始时间和结束时间不能跨片段（单位：毫秒）
@end

#pragma mark - 动态字幕

@interface QHVCEditCommandDynamicSubtitle : QHVCEditEditableCommand

//指定特效添加层级。添加给某个叠加片段，需指定叠加文件的commandId; 只添加给主片段列表，=0; 默认为-1，生效于主片段和所有叠加片段
@property (nonatomic, assign) NSInteger overlayCommandId;
@property (nonatomic, retain) NSString* configFilePath;                     //ass配置文件物理路径
@property (nonatomic, retain) NSString* fontFilePath;                       //自定义字体物理路径，没有自定义字体可不传
@property (nonatomic, assign) NSTimeInterval startTimestampMs;              //起始时间点，相对所有文件所在时间轴，开始时间和结束时间不能跨片段（单位：毫秒）
@property (nonatomic, assign) NSTimeInterval endTimestampMs;                //结束时间点，相对所有文件所在时间轴，开始时间和结束时间不能跨片段（单位：毫秒

@end









