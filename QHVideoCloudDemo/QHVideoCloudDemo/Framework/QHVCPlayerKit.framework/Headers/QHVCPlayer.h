//
//  QHVCPlayer.h
//  QHVCPlayerKit
//
//  Created by yinchaoyu on 2017/5/24.
//  Copyright © 2017年 qihoo 360. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 播放器播放视频的类型
 */
typedef NS_ENUM(NSInteger, QHVCPlayType)
{
    QHVCPlayTypeLive     = 0,//直播
    QHVCPlayTypeVod      = 1,//点播
};

//直播用
typedef NS_ENUM(NSInteger, QHVCStreamType)
{
    QHVCStreamTypeOnlyAudio = 0,//仅音频
    QHVCStreamTypeOnlyVideo = 1,//仅视频
    QHVCStreamTypeDefault = 2,//默认方式（音、视频）
};

/**
 播放器渲染模式
 */
typedef NS_ENUM(NSInteger, QHVCPlayerRenderMode)
{
    QHVCPlayerRenderModeIn   = 0,//默认，窗口内缩放，不填充屏幕
    QHVCPlayerRenderModeOut  = 1,//填充整个屏幕，可能丢失显示内容，但不会变形
    QHVCPlayerRenderModeFull = 2,//全屏显示，可能会变形
};

/**
 播放器声音权限
 */
typedef NS_ENUM(NSInteger, QHVCAudioSessionCategory)
{
    QHVCAudioSessionCategoryPlayback   = 0,     //默认
    QHVCAudioSessionCategoryAmbient  = 1,       //混音
    QHVCAudioSessionCategorySoloAmbient = 2,    //声音独占
    QHVCAudioSessionCategoryPlayAndRecord = 3,  //播放录制
};

/**
 定义播放器错误信息
 */
typedef NS_ENUM(NSInteger, QHVCPlayerError)
{
    QHVCPlayerErrorPlayerInitFailed  = 1,//播放器初始化失败
    QHVCPlayerErrorConnectFailed     = 2,//播放器连接失败，比如网络连接
    QHVCPlayerErrorFormatNotSupport  = 3,//文件格式不支持
    QHVCPlayerErrorFileNotOpen       = 4,//文件打开失败
};

/**
 播放器详细错误信息
 */
typedef NS_ENUM(NSInteger, QHVCPlayerErrorDetailedInfo)
{
    //播放器内部错误
    QHVCPlayerErrorDetailedInfoUnknow                    = 0,//未知消息
    QHVCPlayerErrorDetailedInfoIOException               = 1,//I/O异常
    QHVCPlayerErrorDetailedInfoConnectRefused            = 2,//拒绝连接
    QHVCPlayerErrorDetailedInfoInvalidData               = 3,//无效的数据
    QHVCPlayerErrorDetailedInfoExit                      = 4,//退出，可能注册了无效的过滤器
    QHVCPlayerErrorDetailedInfoNotBitstream              = 5,//找不到Bitstream
    QHVCPlayerErrorDetailedInfoNotDecoder                = 6,//找不到解码器
    QHVCPlayerErrorDetailedInfoNotDemuxer                = 7,//找不到demuxer
    QHVCPlayerErrorDetailedInfoNotFilter                 = 8,//找不到Filter
    QHVCPlayerErrorDetailedInfoNotProtocol               = 9,//找不到Protocol
    QHVCPlayerErrorDetailedInfoNotStream                 = 10,//找不到Stream
    QHVCPlayerErrorDetailedInfoServer                    = 11,//server 错误
    QHVCPlayerErrorDetailedInfoEOF                       = 12,//EOF
    //SDK层错误
    QHVCPlayerErrorDetailedInfoHandleError               = 13,//播放器初始化handle为空
    QHVCPlayerErrorDetailedInfoNotReadyToPlay            = 14,//prepare failed
};

/**
 播放器状态
 */
typedef NS_ENUM(NSInteger, QHVCPlayerStatus)
{
    QHVCPlayerStatusUnknown              = 0,//未知类型
    QHVCPlayerStatusPlaying              = 1,//播放
    QHVCPlayerStatusPaused               = 2,//暂停
    QHVCPlayerStatusStoped               = 3,//会话关闭
};

/**
  日志级别
 */
typedef NS_ENUM(NSInteger, QHVCPlayerLogLevel)
{
    QHVCPlayerLogLevelTrace = 0,//trace
    QHVCPlayerLogLevelDebug = 1,//debug
    QHVCPlayerLogLevelInfo  = 2,//info
    QHVCPlayerLogLevelWarn  = 3,//warn
    QHVCPlayerLogLevelError = 4,//error
    QHVCPlayerLogLevelAlarm = 5,//alarm
    QHVCPlayerLogLevelFatal = 6,//fatal
};

@class QHVCPlayer;

/**
 播放器状态delegate
 */
@protocol QHVCPlayerDelegate <NSObject>

@required
/**
 播放器首次加载缓冲准备完毕，在此回调中调用play开始播放
 */
- (void)onPlayerPrepared:(QHVCPlayer *_Nonnull)player;

/**
 播放器首屏渲染，可以显示第一帧画面
 */
- (void)onPlayerFirstFrameRender:(NSDictionary *_Nullable)mediaInfo player:(QHVCPlayer *_Nonnull)player;

/**
 播放结束回调
 */
- (void)onPlayerFinish:(QHVCPlayer *_Nonnull)player;

@optional
/**
 * 视频大小变化通知
 *
 * @param width  视频宽度
 * @param height 视频高度
 */
- (void)onPlayerSizeChanged:(int)width height:(int)height player:(QHVCPlayer *_Nonnull)player;

/**
 开始缓冲(buffer为空，触发loading)
 */
- (void)onPlayerBufferingBegin:(QHVCPlayer *_Nonnull)player;

/**
 * 缓冲进度(buffer loading进度)
 *
 * @param progress 缓冲进度，progress==0表示开始缓冲， progress==100表示缓冲结束
 */
- (void)onPlayerBufferingUpdate:(int)progress player:(QHVCPlayer *_Nonnull)player;

/**
 缓冲完成(buffer loading完成，可以继续播放)
 */
- (void)onPlayerBufferingComplete:(QHVCPlayer *_Nonnull)player;

/**
 播放进度回调

 @param progress 播放进度
 */
- (void)onPlayerPlayingProgress:(CGFloat)progress player:(QHVCPlayer *_Nonnull)player;

/**
 测试用

 @param mediaInfo 视频详细参数
 */
- (void)onplayerPlayingUpdatingMediaInfo:(NSDictionary *_Nullable)mediaInfo player:(QHVCPlayer *_Nonnull)player;

/**
 * 拖动操作缓冲完成
 */
- (void)onPlayerSeekComplete:(QHVCPlayer *_Nonnull)player;

/**
 * 播放器错误回调
 *
 * @param error       错误类型
 * @param extraInfo   额外的信息
 */
- (void)onPlayerError:(QHVCPlayerError) error extra:(QHVCPlayerErrorDetailedInfo)extraInfo player:(QHVCPlayer *_Nonnull)player;

/**
 * 播放状态回调
 *
 * @param info  参见状态信息枚举
 * @param extraInfo 扩展信息
 */
- (void)onPlayerInfo:(QHVCPlayerStatus)info extra:(NSString * _Nullable)extraInfo player:(QHVCPlayer *_Nonnull)player;

/**
 码率切换成功

 @param index 播放index
 */
- (void)onPlayerSwitchResolutionSuccess:(int)index player:(QHVCPlayer *_Nonnull)player;

/**
 码率切换失败

 @param errorMsg errorMsg description
 */
- (void)onPlayerSwitchResolutionFailed:(NSString *_Nullable)errorMsg player:(QHVCPlayer *_Nonnull)player;

/**
 主播切入后台
 */
- (void)onPlayerAnchorInBackground:(QHVCPlayer *_Nonnull)player;

/**
 系统音量回调

 @param volume 系统音量
 */
- (void)onPlayerSystemVolume:(float)volume;

/**
 音频音高回调
 @param volume 大小
 */
- (void)audioPitch:(int)volume player:(QHVCPlayer *_Nonnull)player;

/**
 接收自定义透传数据
 @param data 自定义数据
 */
- (void)onUserData:(NSData *_Nullable)data;

@end

@interface QHVCPlayer : NSObject

/**
 播放器状态delegate
 */
@property (nonatomic, weak) _Null_unspecified id<QHVCPlayerDelegate> playerDelegate;

/**
 播放器状态
 */
@property (nonatomic, assign) QHVCPlayerStatus playerStatus;

/**
 初始化播放器
 
 @param URL 需要播放到URL
 @param channelId 渠道ID，使用者从平台申请，eg:live_huajiao_v2
 @param userId 用户ID，用户标识，唯一标识（需要详细说明）
 @param playType 播放类型，直播、点播、本地
 @return 成功：播放器对象, 失败：nil
 */
- (QHVCPlayer * _Nullable)initWithURL:(NSString * _Nonnull)URL
                            channelId:(NSString * _Nullable)channelId//内部默认值
                               userId:(NSString * _Nullable)userId//内部默认值
                             playType:(QHVCPlayType)playType;

/**
 通知栏辅助进程初始化播放器
 
 @param URL 需要播放到URL
 @param channelId 渠道ID，使用者从平台申请，eg:live_huajiao_v2
 @param userId 用户ID，用户标识，唯一标识（需要详细说明）
 @param playType 播放类型，直播、点播、本地
 @return 成功：播放器对象, 失败：nil
 */
- (QHVCPlayer * _Nullable)initWithAssistProcessURL:(NSString * _Nonnull)URL
                                         channelId:(NSString * _Nullable)channelId//内部默认值
                                            userId:(NSString * _Nullable)userId//内部默认值
                                          playType:(QHVCPlayType)playType;

/**
 初始化播放器(若需要设置解码类型、流类型用如下初始化接口，更多设置请用Advance内部初始化接口)
 
 @param URL 需要播放到URL
 @param channelId 渠道ID，使用者从平台申请，eg:live_huajiao_v2
 @param userId 用户ID，用户标识，唯一标识（需要详细说明）
 @param playType 播放类型，直播、点播、本地
 @param options @{@"streamType":@"intValue",@"hardDecode":@"boolValue",@"position":@"longValue",@"mute":@"boolValue",@"forceP2p":@"boolValue",@"playMode":@"intValue"，@"audioSessionCategory"：@"intValue",@"setPreferredIOBufferDuration"：@"boolValue"}
 @return 成功：播放器对象, 失败：nil
 */
- (QHVCPlayer * _Nullable)initWithURL:(NSString * _Nonnull)URL
                            channelId:(NSString * _Nullable)channelId//内部默认值
                               userId:(NSString * _Nullable)userId//内部默认值
                             playType:(QHVCPlayType)playType
                              options:(NSDictionary *_Nullable)options;


/**
 初始化播放器(需要切换码率时用如下初始化接口)

 @param urlArray 多分辨播放源
 @param playIndex 初始播放索引
 @param channelId 渠道ID，使用者从平台申请，eg:live_huajiao_v2
 @param userId 用户ID，用户标识，唯一标识（需要详细说明）
 @param playType 播放类型，直播、点播、本地
 @param options @{@"streamType":@"intValue",@"hardDecode":@"boolValue",@"position":@"longValue",@"mute":@"boolValue",@"forceP2p":@"boolValue",@"playMode":@"intValue",@"audioSessionCategory"：@"intValue",@"setPreferredIOBufferDuration"：@"boolValue"}
 @return 成功：播放器对象, 失败：nil
 */
- (QHVCPlayer * _Nullable)initWithUrlArray:(NSArray<NSString *> *_Nullable)urlArray
                                 playIndex:(int)playIndex
                                 channelId:(NSString * _Nullable)channelId//内部默认值
                                    userId:(NSString * _Nullable)userId//内部默认值
                                  playType:(QHVCPlayType)playType
                                   options:(NSDictionary *_Nullable)options;

/**
 设置播放器填充模式

 @param mode 默认，窗口内缩放，不填充屏幕
 */
- (void)setRenderMode:(QHVCPlayerRenderMode)mode;

/**
 切换码率

 @param index 索引
 @return success or not
 */
- (BOOL)switchResolutionWithIndex:(int)index;

/**
 自动切换码率

 @param isAutomatically yes or no
 */
- (void)setAutomaticallySwitchResolution:(BOOL)isAutomatically;

/**
 创建播放器渲染playerView
 @return playerView
 */
- (UIView *_Nonnull)createPlayerViewWithFrame:(CGRect)frame;

/**
 创建播放器渲染playerView 透明
 @return playerView
 */
- (UIView *_Nonnull)createPlayerTransparentViewWithFrame:(CGRect)frame;

/**
 创建播放器渲染playerView(add在传入的view上)
 @param view playerView
 */
- (void)createPlayerView:(UIView *_Nonnull)view;

/**
 创建播放器渲染playerView(add在传入的view上)
 @param view playerView
 */
- (void)createPlayerConstraintView:(UIView *_Nonnull)view;

/**
 创建播放器渲染playerView(add在传入的view上)透明
 @param view playerView
 */
- (void)createPlayerTransparentView:(UIView *_Nonnull)view;

/**
 创建播放器渲染playerView(add在传入的view上)透明
 @param view playerView
 */
- (void)createPlayerConstraintTransparentView:(UIView *_Nonnull)view;

/**
 释放player时候是否移除playerView

 @param remove 默认移除
 */
- (void)removePlayerViewWhenPlayerRelease:(BOOL)remove;

/**
 重置画布（GLView大小变化之后调用，如果不调用画面可能变虚：注意不能频繁调用，如果有动画，建议在动画结束时候调用。否则可能出现绿屏）
 */
- (void)resetCanvas;

/**
 渲染位置偏移
 
 @param offset 偏移量
 @param heigth 画布高度
 */
- (void)playerViewTranslate:(int)offset canvasHeight:(int)heigth;

/**
 播放器准备播放，准备完毕后回调onPrepared
 */
- (void)prepare;

/**
 播放器准备完成后调用该接口开始播放，调用时机说明：播放器准备完成后会回调QHVCPlayerDelegate中的onPrepared方法，在该方法中调用play开始播放
 */
- (void)play;

/**
 点播视频暂停播放, 直播场景调用无效，暂停后继续播放使用play
 */
- (void)pause;

/**
 播放器停止播放
 */
- (void)stop;

/**
 播放过程中改变进度操作,直播场景无效
 *  @param positionByS 点播视频位置，单位秒(second)
 *  @return 成功：YES，失败：NO
 */
- (BOOL)seekTo:(NSTimeInterval)positionByS;

/**
 精确seek
 @param positionByS 单位秒
 @return 成功：YES，失败：NO
 */
- (BOOL)preciseSeekTo:(NSTimeInterval)positionByS;

/**
 点播视频当前播放时间

 @return 点播视频场景下获取当前播放时间，单位秒
 */
- (NSTimeInterval)getCurrentPosition;

/**
 点播视频总时长

 @return 点播视频总时长，直播时调用无效，单位秒
 */
- (NSTimeInterval)getDuration;

/**
 获取播放器回看缓冲下载进度
 
 @return <0失败， >0成功
 */
- (double)getDownloadProgress;

/**
 获取相对时间
 
 @return return 时间
 */
- (unsigned long long)getCurrentStreamTime;

/**
 获取p2p信息

 @return 详情
 */
- (nullable NSDictionary *)getP2pInfo;

/**
 回调系统音量

 @param callback 是否回调
 */
- (void)setSystemVolumeCallback:(BOOL)callback;

/**
 隐藏系统音量视图

 @param hidden 是否隐藏
 */
- (void)setSystemVolumeViewHidden:(BOOL)hidden;

/**
 设置音量

 @param volume 音量范围 0.0~1.0 （1.0最大）
 @return YES:成功， NO:失败
 */
- (BOOL)setVolume:(float)volume;

/**
 获取播放器当前音量

 @return 音量范围 0.0~1.0 （1.0最大）
 */
- (float)getVolume;

/**
 设置音高回调间隔
 
 @param amount 间隔大小
 */
- (void)setAudioPitchCallbackInterval:(uint)amount;

/**
 设置静音

 @param mute 是否静音
 */
- (void)setMute:(BOOL)mute;

/**
 销毁音频模块
 */
- (void)destroyAudioModule;

/**
 重启音频模块
 */
- (void)reStartAudioModule;

/**
 是否静音

 @return yes or no
 */
- (BOOL)isMute;

/**
 视频边缘模糊化

 @param edgeBlur yes:打开 or no:关闭
 */
- (void)setEdgeBlur:(BOOL)edgeBlur;


/**
 截图
 @param callback 回调
 @return yes 成功 no 失败
 */
- (BOOL)snapshotImage:(void (^_Nonnull)(UIImage * _Nullable image))callback;

/**
 设置p2p上传开关是否打开(已弃用，使用云控配置该功能)
 
 @param enableUpload yes:允许上传 or no:禁止上传 默认值为no
 */
+ (void)setP2pUploadStatus:(BOOL)enableUpload;

/**
 设置日志级别

 @param level 日志级别
 */
+ (void)setLogLevel:(QHVCPlayerLogLevel)level;

/**
 设置日志输出block

 @param logOutput 接收日志block
 */
+ (void)setLogOutputBlock:(void (^_Nonnull)(int loggerID, QHVCPlayerLogLevel level, const char * _Nonnull data))logOutput;

/**
 版本号

 @return 版本号
 */
+ (NSString *_Nonnull)getVersion;

@end
