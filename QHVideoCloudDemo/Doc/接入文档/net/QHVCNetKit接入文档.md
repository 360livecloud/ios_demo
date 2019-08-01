## 目录
* 导入SDK
* 初始化
* 观看直播
* 观看卡录
* 直播卡录资源释放
* 局域网文件下载
* 本地缓存


### 一、导入SDK

#### 1.1 SDK文件说明

文件 | 说明 | 注意事项 | 参考文档
---|--- |--- |---
QHVCNetKit.framework | QHVCNetKit的framework库 | 必须导入
QHVCCommonKit.framework | QHVCNetKit依赖的公共库 | 必须导入
QHVCPlayerKit.framework | 播放SDK的framework库 | 使用卡录和直播功能 必须导入 | https://live.360.cn/developer/doc?did=IOSbfSDKjrwd
QHVCInteractiveKit.framework | 互动直播SDK的framework库 | 使用音视频通话必须导入 | https://live.360.cn/developer/doc?did=hdzbksrm
ZegoAVKit2.framework | 音视频通话依赖的framework库 | 使用音视频通话必须导入 |
AgoraRtcEngineKit.framework.framework | 音视频通话依赖的framework库 | 使用音视频通话必须导入 |

#### 1.2 添加系统库依赖 
在TARGETS -> Build Phases -> Link Binary With Libraries中，
除了导入需要的SDK，还需要添加如下系统库的引用:   

* AudioToolBox.framework
* CoreTelephony.framework
* VideoToolbox.framework
* CoreVideo.framework
* Accelerate.framework
* libz.tdb
* libresolv.tbd
* libc++.tdb
* libxml2.tbd
* libsqlite3.tbd


前往TARGETS -> General -> Embed Frameworks 添加导入的SDK:    

* QHVCNetKit.framework
* QHVCPlayerKit.framework
* QHVCCommonKit.framework
* ZegoAVKit2.framework (如果使用音视频通话功能需引入)

### 二、初始化
在您需要使用QHVCNetKit SDK功能的类中，import相关头文件
```
#import <QHVCNetKit/QHVCNetKit.h> // 必须导入
#import <QHVCCommonKit/QHVCCommonKit.h>  // 必须导入
#import <QHVCPlayerKit/QHVCPlayerKit.h>  // 若使用卡录、直播功能
#import <QHVCInteractiveKit/QHVCInteractiveKit.h> // 若使用互动直播的音视频通话
#import <QHVCInteractiveKit/QHVCInteractiveKit+Automation.h> // 若使用互动直播的音视频通话
```
##### 配置服务标识
通过360直播云平台创建应用，然后获取到SDK使用的bid等参数，在App启动时，设置这些参数。 
coreOnAppStart方法必须在app启动的第一时间调用.
```
QHVCCommonCoreEntry.h
/**
* 通知SDK app启动
* 必须在app启动的第一时间调用，且在整个app生命周期只调用一次
* @param businessId 业务ID
* @param appVer 端版本
* @param deviceId 机器id
* @param model 型号
* @param ops 可选参数,例如：@{@"product":@"intValue(QHVCCommonProduct)"}
*/
+ (void)coreOnAppStart:(NSString *)businessId
appVer:(NSString *)appVer
deviceId:(NSString *)deviceId
model:(NSString *)model
optionalParams:(NSDictionary *)ops;

```
##### 启动本地服务
在使用QHVCNetKit的功能前，需要先开启本地服务。启动方法全局调用一次即可。
```
QHVCNet.h

//启动服务：
/**
开启本地服务， 全局只用调用一次， 需要和stopLocalServer配对使用

@param cacheDir 缓存目录，要保证是一个当前存在且有读写权限的文件夹
@param deviceId 设备Id， 统计上报会带上，追查问题用
@param appId 业务Id， 统计上报会带上，追查问题用
@param cacheSizeInMB 初始缓存大小 单位：MB
@param options 需要开启的服务类型 @{kQHVCNetOptionsServicesKey:@(QHVCNetServicePrecache | QHVCNetServiceGodsees)}
*/
- (void)startLocalServer:(NSString *)cacheDir
deviceId:(NSString *)deviceId
appId:(NSString *)appId
cacheSize:(int)cacheSizeInMB
options:(NSDictionary *)options;

/**
停止本地服务， 需要和startLocalServer配对使用
*/
- (void)stopLocalServer;

```
注意事项：在开启本地服务时，QHVCNetKit只会初始化options指定的服务类型，其他未指定的服务将不被初始化，相关回调也不会调用。

### 三、观看直播
观看直播的整体流程如下：
* 第一步：创建session
* 第二步：获取播放地址
* 第三步：传送业务Token给设备验证
* 第四步：初始化播放器
* 第五步：在播放器准备就绪的回调里，添加播放操作。

下面详细介绍下流程中需要调用的API和相关操作。
##### 第一步：创建session
```
QHVCNet+QHVCNetGodSees.h
/**
帝视创建网络会话实例

@param sessionId 实例会话ID
@param serialNumber 设备唯一标识
@param deviceChannelNumber 设备管道号，从索引1开始[1, ...]
@param playType 播放类型
@return 0成功，非0表示失败
*/
- (int)createGodSeesSession:(NSString *)sessionId
serialNumber:(NSString *)serialNumber
deviceChannelNumber:(NSInteger)deviceChannelNumber
playType:(QHVCNetGodSeesPlayType)playType;
```
##### 第二步：获取播放地址
```
/**
获取帝视指定会话播放的链接

@param sessionId 实例会话ID
@return 走帝视播放的链接，不成功将会返回空
*/
- (NSString *)getGodSeesPlayUrl:(NSString *)sessionId;

如：[[QHVCNet sharedInstance] getGodSeesPlayUrl:sessionId];
```
##### 第三步：传送业务Token给固件设备验证
```
/**
传输业务token给设备验证

@param sessionId 实例会话ID
@param token 验证信息，字符串长度不能超过63个字符
@return 0成功，非0表示失败
*/
- (int)sendGodSeesBusinessTokenToDevice:(NSString *)sessionId
token:(NSString *)token;
如：[[QHVCNet sharedInstance] sendGodSeesBusinessTokenToDevice:sessionId
token:token];
```
token验证结果回调：
```
QHVCNet+QHVCNetGodSees.h

/**
业务token验证结果回调

@param sessionId 会话ID
@param status 验证结果，由业务定义
@param info 附带信息
*/
- (void) onGodSees:(NSString *)sessionId didVerifyToken:(NSInteger)status info:(NSString *)info;
```
##### 第四步：初始化播放器
使用“第三步”获取的播放地址初始化播放器
* 初始化QHVCPlayer实例
```
QHVCPlayer.h
/**
初始化播放器(若需要设置解码类型、流类型用如下初始化接口，更多设置请用Advance内部初始化接口)

@param URL 需要播放到URL
@param channelId 传入业务ID，使用者从平台申请
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
```

* 设置播放器相关代理
```
QHVCPlayer.h
/**
播放器状态delegate
*/
@property (nonatomic, weak) _Null_unspecified id<QHVCPlayerDelegate> playerDelegate;
```
```
QHVCPlayer+Advance.h
/**
播放器扩展delegate
*/
@property (nonatomic, weak) _Null_unspecified id<QHVCPlayerAdvanceDelegate> playerAdvanceDelegate;
```
* 播放器初始化示例：
```
- (void)initPlayer
{
QHVCGVConfig * config = [QHVCGVConfig sharedInstance];
_player = [[QHVCPlayer alloc] initWithURL:_playerUrl
channelId:config.businessId
userId:config.userName
playType:QHVCPlayTypeLive
options:@{@"hardDecode":@(FALSE),@"playMode":@(QHVCPlayModeLowLatency)}];
_player.playerDelegate = self;
_player.playerAdvanceDelegate = self;

[_player createPlayerView:_playerView];
[_player setSystemVolumeCallback:YES];
[_player setSystemVolumeViewHidden:NO];
[_player prepare];
}
```
想了解播放器相关设置，可参考播放SDK文档:https://live.360.cn/developer/doc?did=IOSbfSDKjrwd

##### 第五步：在播放器准备就绪的回调里，添加播放操作。
```
/**
播放器首次加载缓冲准备完毕，在此回调中调用play开始播放
*/
- (void)onPlayerPrepared:(QHVCPlayer *_Nonnull)player
{
[_player play];
}
```

### 四、观看卡录
观看卡录的整体流程如下：
* 第一步：创建session
* 第二步：获取播放地址
* 第三步：传送业务Token给设备验证
* 第四步：初始化播放器
* 第五步：在播放器准备就绪的回调里，添加播放操作。
* 第六步：获取卡尺数据
* 第七步：解析卡尺数据，执行seek操作

在观看卡录的流程中，第一步至第五步，同“观看直播”的流程一样。此处不再赘述。下面介绍下观看卡录所需的额外操作。
* 获取卡尺数据   
在执行第三步，将业务Token传送给设备验证后，验证结果会异步回调。在回调方法中，如果验证状态是成功，则调用接口获取卡尺数据。
```
/**
业务token验证结果回调

@param sessionId 会话ID
@param status 验证结果，由业务定义
@param info 附带信息
*/
- (void) onGodSees:(NSString *)sessionId didVerifyToken:(NSInteger)status info:(NSString *)info;
```

```
获取卡尺数据接口：
/**
获取卡录时间轴信息
返回结果监听回调:

@param sessionId 实例会话ID
@return 0成功，非0表示失败
*/
- (int)getGodSeesRecordTimeline:(NSString *)sessionId;
```
* 解析卡尺数据，执行seek操作
在调用获取卡尺数据接口后，相关数据会异步回调。在回调方法中，解析时间戳数据，执行seek操作，便可指定播放的位置。固件设备收到seek指令后，会向播放器吐数据，播放器收到数据，便会执行观看卡录的第五步，并开始播放。
```
卡尺数据回调

QHVCNet+QHVCNetGodSees.h : QHVCNetGodSeesDelegate
/**
请求卡录时间轴结果

@param sessionId 会话ID
@param data 卡录时间数据
*/
- (void) onGodSees:(NSString *)sessionId didRecordTimeLine:(NSArray<QHVCNetGodSeesRecordTimeline *> *)data;
```
```
seek操作

QHVCNet+QHVCNetGodSees.h :
/**
观看从指定时间戳之后的卡录

@param sessionId 实例会话ID
@param timeStampByMS 指定时间点（单位：毫秒）
@return 0成功，非0表示失败
*/
- (int)seekGodSeesRecord:(NSString *)sessionId
timeStamp:(NSUInteger)timeStampByMS;

```

### 五、直播卡录资源释放
在结束播放时，需要停止播放器并销毁QHVCNet创建的session
```
[_player stop];
_player = nil;
[[QHVCNet sharedInstance] destroyGodSeesSession:sessionId];
```

### 六、局域网文件下载
在本地服务开启的情况下，可直接调用以下方法，获取文件的下载地址
```
QHVCNet.h
/**
* @brief 获取设备文件下载的链接
* @param fileKey 指定设备上的文件的标识符
* @param serialNumber 设备唯一标识
* @param token 待设备验证的标识，字符串长度不能超过63个字符
* @param rangeStart 请求文件内容的起始位置，与http的range语义相同
* @param rangeEnd  请求文件内容的结束位置，与http的range语义相同
* @param resultUrlString 获取的下载链接，如果返回成功的，不为nil，否则为nil
* @return 返回NVDERROR_SUCCESS表示成功，返回其它值都是失败
*/

- (int)getDeviceFileDownloadUrlWithFileKey:(NSString *)fileKey
serialNumber:(NSString *)serialNumber
token:(NSString *)token
rangeStart:(NSUInteger)rangeStart
rangeEnd:(NSUInteger)rangeEnd
resultUrlString:(NSString **)resultUrlString

注：rangeStart和rangeEnd都传0 代表下载整个文件
```

### 七、本地缓存
##### 7.1 简单介绍
QHVCNetKit提供本地缓存服务，可以帮助开发者快速实现预缓存功能。
##### 7.2 功能说明：
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

##### 7.3 相关接口对接

###### 7.3.1 开始预缓存
```
QHVCNet+QHVCNetPrecache.h
/**
添加预缓存任务

@param rid 资源的唯一标识，由于url在加防盗链时是可变的，所以需要一个唯一标识来匹配缓存文件
@param url 资源的链接
@param preCacheSizeInKB 预缓存多少的数据量，单位KB
*/
- (void)preloadCacheFile:(NSString *)rid url:(NSString *)url preCacheSize:(int)preCacheSizeInKB;
```
###### 7.3.2 取消预缓存
```
QHVCNet+QHVCNetPrecache.h
/**
取消预缓存任务

@param rid 资源的唯一标识，由于url在加防盗链时是可变的，所以需要一个唯一标识来匹配缓存文件
*/
- (void)cancelPreCache:(NSString *)rid;

```
###### 7.3.3 获取走LocalServer播放的链接
```
QHVCNet.h
/**
获取localserver播放的链接

@param rid 资源的唯一标识，由于url在加防盗链时是可变的，所以需要一个唯一标识来匹配缓存文件
@param url 资源的链接
@return 走预缓存播放的链接，不成功将会返回空
*/
- (NSString *)getLocalServerPlayUrl:(NSString *)rid url:(NSString *)url;
```
###### 7.3.4 LocalServer设置

```

/**
添加预缓存任务

@param rid 资源的唯一标识，由于url在加防盗链时是可变的，所以需要一个唯一标识来匹配缓存文件
@param url 资源的链接
@param preCacheSizeInKB 预缓存多少的数据量，单位KB
*/
- (void)preloadCacheFile:(NSString *)rid url:(NSString *)url preCacheSize:(int)preCacheSizeInKB;

/**
取消预缓存任务

@param rid 资源的唯一标识，由于url在加防盗链时是可变的，所以需要一个唯一标识来匹配缓存文件
*/
- (void)cancelPreCache:(NSString *)rid;

/**
返回指定的缓存已完成的数据量以及总数据量

@param rid 资源的唯一标识，由于url在加防盗链时是可变的，所以需要一个唯一标识来匹配缓存文件
@param url 资源的链接
@param callback 返回结果，cachedSize：已经缓存文件大小，totalSize：总文件大小，单位：字节
*/
- (void)getFileCachedSize:(NSString *)rid url:(NSString *)url callback:(void(^)(unsigned long long cachedSize, unsigned long long totalSize))callback;

/**
返回指定的缓存在给定偏移后连续可用的数据量

@param rid 资源的唯一标识，由于url在加防盗链时是可变的，所以需要一个唯一标识来匹配缓存文件
@param url 资源的链接
@param offset 偏移量
@return 指定偏移后连续可用的数据量
*/
-(unsigned long long)getFileAvailedSize:(NSString *)rid url:(NSString *)url offset:(unsigned long long)offset;

/**
清除缓存（当前正在播放任务的缓存不会清除）
*/
- (void)clearPrecache;

/**
设置移动网络预缓存开关，防止在移动网络下额外花费流量。

@param onoff YES:开  FALSE:关， 默认：开
*/
- (void)enablePrecacheForMobileNetwork:(BOOL)onoff;

/**
是否允许移动网络环境下开启预缓存

@return YES 允许， NO 不允许
*/
- (BOOL)isEnablePrecacheForMobileNetwork;


缓存占用空间

默认50M，超过设置的大小后将删除最早加入的缓存文件（如果单个视频文件大小超过设置的缓存占用空间大小，则播放结束后将自动删除该视频文件的缓存）。为避免过度占用用户手机内存卡空间，请合理设置缓存占用空间大小。

/**
设置和调整缓存占用空间大小。 这个接口可以中途调用，可以调用多次

@param cacheSizeInMB 缓存空间的大小， 单位:MB
@return yes:成功 no:失败
*/
- (BOOL)setCacheSize:(int)cacheSizeInMB;


非WIFI网络预缓存

默认关闭，防止偷跑用户3G/4G网络流量，请谨慎开启。该接口不影响正在播放的视频，仅影响预缓存任务。


禁止所有网络请求

禁止后，所有网络请求都将被禁止，主要用于非WIFI网暂停络播放时禁止预缓存的场景（QHVCNetKit会预加载当前播放点后约4M的文件）。具体使用方法请参考DEMO中的示例。

/**
是否允许QHVCNetKit所有访问网络主动拉取数据的行为

@return YES：允许，NO：禁止
*/
- (BOOL)isEnableNetwork;
```
##### 7.4 本地缓存注意事项
1. 如无特殊说明，所有接口均在主线程调用
2. 加防盗链或可变的URL无法作为视频的唯一标识，必须正确设置rid参数
