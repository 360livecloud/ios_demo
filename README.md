# ios_demo
360直播云iOS DEMO
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

QHVCPLayerKit.framework

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
### SDK集成注意事项：
```
QHVCPlayerKit.framework与QHVCCommonKit.framework均是动态库，一定要在TARGETS->General->Embed Binaries下引入
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


# iOS LocalServer SDK开发文档


### ioslocal server SDK简单介绍:
直播云以SDK形式提供本地缓存服务，可以帮助开发者快速实现预缓存的功能。SDK包含framework、demo及开发文档。


### 功能说明：

系统属性

| 系统特性 | 支持内容     |
| -------- | ------------ |
| 系统版本 | iOS8+        |
| 系统架构 | armv7、arm64 |

LocalServer属性

| 功能类别 | 支持范围     |
| -------- | ------------ |
| 缓存 | 开始、停止缓存服务 |
| 预加载 | 开始、取消预加载任务 |
| 分配磁盘空间 | 设置缓存文件总大小 |
| 其他功能 | 清除全部缓存、非WIFI网络开启关闭预加载 |

### 系统框图：


### SDK集成方法介绍：

#### 下载工程，demo对接

下载链接：https://github.com/360livecloud/iOS_demo.git
>* QHVCLocalServerKit.framework

#### 函数及配置说明
通过360直播云平台创建应用，然后获取到SDK使用的appId，下载iOS播放SDK

添加依赖库

```
TARGETS->General->Linked Frameworks and Libraries
+ QHVCLocalServerKit.framework
```

引入头文件

```
//只需引用一次
#import <QHVCLocalServerKit/QHVCLocalServerKit.h>
```

#### 代码对接
##### 1、开启缓存
```
[[QHVCLocalServerKit sharedInstance] startServer:path deviceId:"设备Id" appId:@"申请的appId" cacheSize:cacheSizeInMB];//path必须是已经存在的目录
```
##### 2、停止缓存
```
[[QHVCLocalServerKit sharedInstance] stopServer];
```
##### 3、开始预缓存
```
[[QHVCLocalServerKit sharedInstance] preloadCacheFile:@"rid" url:@"playUrl" preCacheSize:800];
```
##### 4、取消预缓存
```
[[QHVCLocalServerKit sharedInstance] cancelPreCache:@"rid"];
```
##### 5、获取走LocalServer播放的链接
```
NSString *urlString;
if ([[QHVCLocalServerKit sharedInstance] isStartLocalServer])
{
[[QHVCLocalServerKit sharedInstance]enableCache:YES];//每次播放之前确认enableCache为yes
urlString = [[QHVCLocalServerKit sharedInstance] getPlayUrl:rid url:url];
}
else
{
urlString = url;
}
```
##### 6、 LocalServer设置

```
缓存占用空间

默认50M，超过设置的大小后将删除最早加入的缓存文件（如果单个视频文件大小超过设置的缓存占用空间大小，则播放结束后将自动删除该视频文件的缓存）。为避免过度占用用户手机内存卡空间，请合理设置缓存占用空间大小。

/**
设置和调整缓存占用空间大小。 这个接口可以中途调用，可以调用多次

@param cacheSizeInMB 缓存空间的大小， 单位:MB
@return yes:成功 no:失败
*/
- (BOOL)setCacheSize:(int)cacheSizeInMB;
业务方可随时调用-(void)clearCache接口清除当前占用的空间（该接口不会影响当前正在播放的任务）。

/**
清除缓存（当前正在播放任务的缓存不会清除）
*/
- (void)clearCache;

非WIFI网络预缓存

默认关闭，防止偷跑用户3G/4G网络流量，请谨慎开启。该接口不影响正在播放的视频，仅影响预缓存任务。

/**
设置移动网络预缓存开关，防止在移动网络下额外花费流量。

@param onoff YES:开  FALSE:关， 默认：开
*/
- (void)enablePrecacheForMobileNetwork:(BOOL)onoff;

禁止所有网络请求

禁止后，所有网络请求都将被禁止，主要用于非WIFI网暂停络播放时禁止预缓存的场景（LocalServer会预加载当前播放点后约4M的文件）。具体使用方法请参考DEMO中的示例。

/**
恢复/禁止LocalServer所有访问网络主动拉取数据的行为

@param enableCache YES:允许，NO：禁止，默认：允许
*/
- (void)enableCache:(BOOL)enableCache;
```
### SDK集成注意事项：
1、如无特殊说明，所有接口均在主线程调用

2、加防盗链或可变的URL无法作为视频的唯一标识，必须正确设置rid参数

### SDK日志文件：
本地路径Library/Cache/com.qihoo.videocloud/log/QHVCLocalServer


# iOS上传SDK开发文档

## 介绍

直播云以SDK形式提供上传服务，可以帮助开发者快速上传文件并进行管理。SDK包含framework、demo及开发文档。

## 功能说明

上传SDK提供两种上传形式：本地文件、内存数据，根据实际业务情况使用，上传过程中可取消，设置代理接收进度、上传状态等信息
## 系统范围

| 系统特性 | 支持范围     |
| -------- | ------------ |
| 系统版本 | iOS8+        |
| 系统架构 | armv7、armv7s、arm64 |

## 业务流程

![image](http://p1.qhimg.com/d/inn/dd65852f/t01365f0273df5e605c.png)

详细信息请参考：[云存储-用户手册-编程模型](https://live.360.cn/index/doc?type=s3&id=189)。

## SDK集成
### 下载SDK

下载链接：[https://github.com/360livecloud/ios_demo.git](https://github.com/360livecloud/ios_demo.git)

### 配置说明

1. 上传功能提供两个framework：

QHVCUploadKit.framework该库为静态库（Build Phases->Link Binary With Libraries-> +）

QHVCCommonKit.framework该库为动态库（Build Phases->Embed Frameworks-> +）




2. 实际开发中#import `<QHVCUploadKit/QHVCUploader.h>`头文件调用相关接口。


## 接口说明

### 上传相关

创建上传对象

` _uploader =  [[QHVCUploader alloc]init];`

` [_uploader setUploaderDelegate:self];`



```

/**
*  @功能 获取上传类型，目前有表单和分片两种形式，具体使用哪种形式由服务器返回的配置信息决定
*  如果是分片上传，需要调用parallelQueueNum获得队列数，用于计算token
*  如果是表单上传，无需调用parallelQueueNum，计算token不需要此参数
*  @参数 size 待上传任务数据大小，单位：字节
*  @返回值 详见QHVCUploadTaskType
*/
- (QHVCUploadTaskType)uploadTaskType:(uint64_t)size;

/**
*  @功能 获取分片上传队列数，用于业务计算token
*  @返回值 分片上传队列数
*/
- (NSInteger)parallelQueueNum;

/**
*  @功能 两种上传方式，数据在本地uploadFile:，数据在内存中uploadData:
*  @参数 filePath 待上传文件本地路径
*  @参数 data    待上传内存数据
*  @参数 fileName    本地文件/内存数据上传到服务器后的文件名
*  @参数 token 表单/分片任务计算规则略有差别
*/
- (void)uploadFile:(NSString *)filePath fileName:(NSString *)fileName token:(NSString *)token;
- (void)uploadData:(NSData *)data fileName:(NSString *)fileName token:(NSString *)token;

/**
*  @功能 取消当前上传任务
*/
- (void)cancel;

直播云上传域名由云控参数确定，业务方可以调用以下接口修改上传域名。
/**
*  @功能 第三方设置上传域名，上传前设置
*  @参数 domain 有效的域名
*/
+ (void)setUploadDomain:(NSString *)domain;
```

### 日志相关
开发阶段辅助开发调试，根据实际情况使用

```
/**
* 打开上传日志
* @参数 level 日志等级
*/
+ (void)openLogWithLevel:(QHVCUploadLogLevel)level;

/**
* 设置日志输出callback
* @参数 callback 回调block
*/
+ (void)setLogOutputCallBack:(void(^)(int loggerID, QHVCUploadLogLevel level, const char *data))callback
```
###统计相关
```
//统计相关，请正确设置，利于排查线上问题，在上传前设置
/**
*  @功能 用户id
*  @参数 userId  第三方用户id
*/
+ (void)setUserId:(NSString *)userId;

/**
*  @功能 设置第三方渠道号
*  @参数 channelId   渠道号
*/

+ (void)setChannelId:(NSString *)channelId;
/**
*  @功能 设置第三方业务版本号
*  @参数 appVersion   版本号
*/
+ (void)setAppVersion:(NSString *)appVersion;

/**
*  @功能 设置设备id
*  @参数 deviceId   设备id
*/
+ (void)setDeviceId:(NSString *)deviceId;
```
###回调
```
/**
*  @功能 回调上传状态 成功、失败
*  @参数 uploader
*  @参数 status 上传状态
*/
- (void)didUpload:(QHVCUploader *)uploader status:(QHVCUploadStatus)status error:(nullable NSError *)error;

@optional
/**
*  @功能 上传进度
*  @参数 uploader
*  @参数 progress 上传进度（0.0-1.0）
*/
- (void)didUpload:(QHVCUploader *)uploader progress:(float)progress;
```

## 错误码说明

|状态码|含义|
|:--:|:--|
|-105|文件不存在|
|-108|不支持文件夹|
|-111|Token为空|
|-112|上传的内存数据为空|
|-113|上传的文件是0字节|


