# ios播放SDK开发文档


### iOS播放SDK简单介绍：

360直播云以SDK形式提供视频直播点播播放器，可以帮助开发者快速实现音视频播放能力。SDK包括开发文档、开发demo、framework库文件。开发者可参考文档或demo，framework文件加入APP的工程中，完成相关配置，调用相关的API即可实现音视频播放功能。


系统属性

| 系统特性 | 支持内容     |
| -------- | ------------ |
| 系统版本 | iOS8+        |
| 流媒体协议 | RTMP、hls、http-flv、私有协议  |
| 硬件特性 | armv7、arm64 |

各协议之间时机存在一些细微的差别，比如

| 直播协议 | 协议优势    | 缺陷  |
| -------- | ------------ | ------------ |
| RTMP | 延时相对较低 | 大并发时消耗性能较大且防火墙不友好 |
| hls | 在移动端支持最好 |  延时比较大，一般在10-20s左右 |
| http-flv | 延时比较低 | 对防火墙友好，但移动端支持不友好 |

| 点播协议 | 协议优势    | 缺陷  |
| -------- | ------------ | ------------ |
| hls | 移动端支持比较好 | 多个小文件分发，系统维度难度相对大 |
| http（FLV）| 一般直播转回放可以用 |  移动端需要用SDK播放 |
| http（mp4）| 在移动端支持相对好 | 对播放器要求比较高，容错性比较差 |

播放属性

| 播放功能 | 支持内容     |
| -------- | ------------ |
| 基础功能 | 播放、暂停、停止、快进、快退、静音等基础播放器功能 |
| 解码方式 | 软解码、硬解码 |
| 解码标准 | H.264、H.265 |
| 码率切换 | 手动、自动切换 |
| 渲染视图 | 全屏、自定义大小 |
| 多实例播放 | 多实例支持 |
| 数据打点 | 自动打点上报 |
| 高级功能 | 预调度、图像镜像、播放器流量统计、延时播放、播放截图等 |
| 其他功能 | 音视频转码 |

### 系统框图：


### SDK集成方法介绍：

####下载工程，demo对接

通过360直播云平台创建应用，然后获取到SDK使用的bid、cid和Token等参数，然后下载iOS播放SDK

下载链接：https://github.com/360livecloud/iOS_demo.git
>* QHVCPlayerKit.framework
>* QHVCCommonKit.framework

####函数及配置说明
#####添加依赖库
TARGETS->General->Embed Binaries

QHVCPlayerKit.framework

QHVCCommonKit.framework


##### 引入头文件
```
#import <QHVCPlayerKit/QHVCPlayerKit.h>
```
##### 如果需要配置解码类型、流类型用如下初始化接口
```
player = [[QHVCPlayer alloc] initWithURL:testUrl channelId:cid userId:nil playType:QHVCPlayTypeVod options:@{@"hardDecode":@(isHardDecode)}];
```
##### 如果需要走调度调用如下初始化接口
```
player = [[QHVCPlayer alloc] initWithSN:sn channelId:cid userId:nil uSign:[self generateSign:APP_SIGN] options:@{@"dispatchUrl":@"url"}];
以上两个初始化接口如需高级参数配置统一放在options里面传字典，参数类型详见QHVCPlayer与QHVCPlayer+Advance头文件
```
##### 播放器seek
```
[player seekTo:];//单位毫秒
```
##### 播放
```
[player play];
```
##### 暂停
```
[player pause];
```
##### 停止
```
[player closeNetStats];//若开启了流量统计stop之后要关闭
[player stop];//调用后，播放器直接销毁，如需再次播放必须重新走初始化流程
```

#### 代码对接
###### 1、初始化播放器
```
player = [[QHVCPlayer alloc] initWithURL:testUrl channelId:cid userId:nil playType:QHVCPlayTypeVod];
```
如下提供两个url测试用

```
//竖屏视频
url = @"http://static.s3.huajiao.com/Object.access/hj-video/NTg1NzY5ODgxNDgxNjM2MzM5OTUxMjcwNjg1MDUzNy5tcDQ=";
//横屏视频
url = @"http://q3.v.k.360kan.com/vod-xinxiliu-tv-q3-bj/15575_6260627c3759e-38a7-4a6c-8d81-a200f1c8ff2d.mp4";
```
##### 2、设置代理
```
player.playerDelegate = self;//必须设置
player.playerAdvanceDelegate = self;//需要使用高级接口时设置
```
##### 3、创建播放器视图
```
playerView = [_player createPlayerView:CGRectMake(0, 0, 100, 100)];
```
##### 4、准备播放
```
[player prepare];//整个player生命周期调用一次，多调用无效
```
##### 5、首次播放
```
//首次播放必须在onPlayerPrepared方法回调回来后调用play才能生效
[player play]; //首次播放
[player openNetStats:5]; //需要流量统计时调用(5是计算周期默认值)
```

### SDK接口使用流程说明：

# 协议部分

```Objective-C
/**
播放器首次加载缓冲准备完毕，在此回调中调用play开始播放
*/
- (void)onPlayerPrepared:(QHVCPlayer *_Nonnull)player;
```

```Objective-C
/**
播放器首屏渲染，可以显示第一帧画面
*/
- (void)onPlayerFirstFrameRender:(NSDictionary *_Nullable)mediaInfo player:(QHVCPlayer *_Nonnull)player;
```

```Objective-C
/**
播放结束回调
*/
- (void)onPlayerFinish:(QHVCPlayer *_Nonnull)player;
```

```Objective-C
/**
* 视频大小变化通知
*
* @param width  视频宽度
* @param height 视频高度
*/
- (void)onPlayerSizeChanged:(int)width height:(int)height player:(QHVCPlayer *_Nonnull)player;
```

```Objective-C
/**
开始缓冲(buffer为空，触发loading)
*/
- (void)onPlayerBufferingBegin:(QHVCPlayer *_Nonnull)player;
```

```Objective-C
/**
* 缓冲进度(buffer loading进度)
*
* @param progress 缓冲进度，progress==0表示开始缓冲， progress==100表示缓冲结束
*/
- (void)onPlayerBufferingUpdate:(int)progress player:(QHVCPlayer *_Nonnull)player;
```

```Objective-C
/**
缓冲完成(buffer loading完成，可以继续播放)
*/
- (void)onPlayerBufferingComplete:(QHVCPlayer *_Nonnull)player;
```

```Objective-C
/**
播放进度回调

@param progress 播放进度
*/
- (void)onPlayerPlayingProgress:(CGFloat)progress player:(QHVCPlayer *_Nonnull)player;
```

```Objective-C
/**
测试用

@param mediaInfo 视频详细参数
*/
- (void)onplayerPlayingUpdatingMediaInfo:(NSDictionary *_Nullable)mediaInfo player:(QHVCPlayer *_Nonnull)player;
```

```Objective-C
/**
* 拖动操作缓冲完成
*/
- (void)onPlayerSeekComplete:(QHVCPlayer *_Nonnull)player;
```

```Objective-C
/**
* 播放器错误回调
*
* @param error       错误类型
* @param extraInfo   额外的信息
*/
- (void)onPlayerError:(QHVCPlayerError) error extra:(QHVCPlayerErrorDetailedInfo)extraInfo player:(QHVCPlayer *_Nonnull)player;
```

```Objective-C
/**
* 播放状态回调
*
* @param info  参见状态信息枚举
* @param extraInfo 扩展信息
*/
- (void)onPlayerInfo:(QHVCPlayerStatus)info extra:(NSString * _Nullable)extraInfo player:(QHVCPlayer *_Nonnull)player;
```

```Objective-C
/**
码率切换成功

@param index 播放index
*/
- (void)onPlayerSwitchResolutionSuccess:(int)index player:(QHVCPlayer *_Nonnull)player;
```

```Objective-C
/**
码率切换失败

@param errorMsg errorMsg description
*/
- (void)onPlayerSwitchResolutionFailed:(NSString *_Nullable)errorMsg player:(QHVCPlayer *_Nonnull)player;
```

```Objective-C
/**
主播切入后台
*/
- (void)onPlayerAnchorInBackground:(QHVCPlayer *_Nonnull)player;
```


# API部分
## 初始化

```Objective-C
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
```

```Objective-C
/**
初始化播放器(若需要设置解码类型、流类型用如下初始化接口，更多设置请用Advance内部初始化接口)

@param URL 需要播放到URL
@param channelId 渠道ID，使用者从平台申请，eg:live_huajiao_v2
@param userId 用户ID，用户标识，唯一标识（需要详细说明）
@param playType 播放类型，直播、点播、本地
@param options @{@"streamType":@"QHVCStreamType",@"bUseHW":@"boolValue"}
@return 成功：播放器对象, 失败：nil
*/
- (QHVCPlayer * _Nullable)initWithURL:(NSString * _Nonnull)URL
channelId:(NSString * _Nullable)channelId//内部默认值
userId:(NSString * _Nullable)userId//内部默认值
playType:(QHVCPlayType)playType
options:(NSDictionary *_Nullable)options;
```

```Objective-C
/**
初始化播放器(需要切换码率时用如下初始化接口)

@param urlArray 多分辨播放源
@param playIndex 初始播放索引
@param channelId 渠道ID，使用者从平台申请，eg:live_huajiao_v2
@param userId 用户ID，用户标识，唯一标识（需要详细说明）
@param playType 播放类型，直播、点播、本地
@param options @{@"streamType":@"QHVCStreamType",@"bUseHW":@"boolValue"}
@return 成功：播放器对象, 失败：nil
*/
- (QHVCPlayer * _Nullable)initWithUrlArray:(NSArray<NSString *> *_Nullable)urlArray
playIndex:(int)playIndex
channelId:(NSString * _Nullable)channelId//内部默认值
userId:(NSString * _Nullable)userId//内部默认值
playType:(QHVCPlayType)playType
options:(NSDictionary *_Nullable)options;
```

## 切码率
```Objective-C

/**
切换码率

@param index 索引
@return success or not
*/
- (BOOL)switchResolutionWithIndex:(int)index;
```

```Objective-C
/**
自动切换码率

@param isAutomatically yes or no
*/
- (void)setAutomaticallySwitchResolution:(BOOL)isAutomatically;
```

## 创建playerView
```Objective-C
/**
创建播放器渲染playerView(add在传入的view上)

@param view playerView
*/
- (void)createPlayerView:(UIView *_Nonnull)view;
```

```Objective-C
/**
释放player时候是否移除playerView

@param remove 默认移除
*/
- (void)removePlayerViewWhenPlayerRelease:(BOOL)remove;
```

## 基础功能
```Objective-C
/**
播放器准备播放，准备完毕后回调onPrepared
*/
- (void)prepare;
```

```Objective-C
/**
播放器准备完成后调用该接口开始播放，调用时机说明：播放器准备完成后会回调QHVCPlayerDelegate中的onPrepared方法，在该方法中调用play开始播放
*/
- (void)play;
```

```Objective-C
/**
点播视频暂停播放, 直播场景调用无效，暂停后继续播放使用play
*/
- (void)pause;
```

```Objective-C
/**
播放器停止播放
*/
- (void)stop;
```

```Objective-C
/**
播放过程中改变进度操作,直播场景无效
*  @param positionByMS 点播视频位置，单位毫秒(millisecond)
*  @return 成功：YES，失败：NO
*/
- (BOOL)seekTo:(NSTimeInterval)positionByMS;
```

```Objective-C
/**
点播视频当前播放时间

@return 点播视频场景下获取当前播放时间，单位毫秒
*/
- (NSTimeInterval)getCurrentPosition;
```

```Objective-C
/**
点播视频总时长

@return 点播视频总时长，直播时调用无效，单位毫秒
*/
- (NSTimeInterval)getDuration;
```

```Objective-C
/**
获取播放器回看缓冲下载进度

@return <0失败， >0成功
*/
- (long)getDownloadProgress;
```

```Objective-C
/**
设置音量

@param volume 音量范围 0.0~1.0 （1.0最大）
@return YES:成功， NO:失败
*/
- (BOOL)setVolume:(float)volume;
```

```Objective-C
/**
获取播放器当前音量

@return 音量范围 0.0~1.0 （1.0最大）
*/
- (float)getVolume;
```

## 日志
```Objective-C
/**
设置日志级别

@param level 日志级别
*/
+ (void)setLogLevel:(QHVCPlayerLogLevel)level;
```

```Objective-C
/**
设置日志输出block

@param logOutput 接收日志block
*/
+ (void)setLogOutputBlock:(void (^_Nonnull)(int loggerID, QHVCPlayerLogLevel level, const char * _Nonnull data))logOutput;
```

### SDK集成注意事项：
```
QHVCPLayerKit.framework与QHVCCommonKit.framework均是动态库，一定要在TARGETS->General->Embed Binaries下引入
```
```
播放器置空之前确保调用[player stop];否则无法停止播放，而且调用stop之后，player将无法继续工作。必须重新初始化
```
```
首次调用[player play];必须在onPlayerPrepared方法回调回来后，否则无效
```

### SDK错误通知：

QHVCPlayerError

| 错误码 | 注释     |
| -------- | ------------ |
| 1 | 播放器初始化失败 |
| 2 | 播放器连接失败，比如网络连接  |
| 3 | 文件格式不支持 |
| 4 | 文件打开失败 |

QHVCPlayerErrorDetailedInfo

| 错误码 | 注释     |
| -------- | ------------ |
| 0 | 未知消息 |
| 1 | I/O异常 |
| 2 | 拒绝连接  |
| 3 | 无效的数据 |
| 4 | 退出，可能注册了无效的过滤器 |
| 5 | 找不到Bitstream |
| 6 | 找不到解码器 |
| 7 | 找不到demuxer |
| 8 | 找不到Filter |
| 9 | 找不到Protocol |
| 10 | 找不到Stream |
| 11 | server 错误 |
| 12 | EOF |
| 13 | 播放器初始化handle为空 |
| 14 | prepare failed |

### SDK日志文件：
本地路径Library/Cache/com.qihoo.videocloud/log/QHVCPlayer



