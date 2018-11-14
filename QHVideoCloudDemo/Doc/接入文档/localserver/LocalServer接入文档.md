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


### SDK接口使用流程说明：

```Objective-C
/**
设置日志开关

@param logLevel 日志等级
@param detailInfo 日志是否包含详细信息（时间、进程号、线程号）
NSLog和Android的Log函数可以自带这些信息时，可以设置成0
存入文件或其他不带详细信息的日日志打印函数的场合建议把detailInfo设置成1
*/
- (void)setLogLevel:(QHVCLocalServerLogLevel)logLevel detailInfo:(int)detailInfo callback:(void(^)(const char* buf, size_t buf_size))callback;
```

```Objective-C
/**
设置和调整缓存占用空间大小。 这个接口可以中途调用，可以调用多次

@param cacheSizeInMB 缓存空间的大小， 单位:MB
*/
- (void)setCacheSize:(int)cacheSizeInMB;
```

```Objective-C
/**
清除缓存（当前正在播放任务的缓存不会清除）
*/
- (void)clearCache;
```

```Objective-C
/**
添加预缓存任务

@param rid 资源的唯一标识，由于url在加防盗链时是可变的，所以需要一个唯一标识来匹配缓存文件
@param url 资源的链接
@param preCacheSizeInKB 预缓存多少的数据量，单位KB
*/
- (void)preloadCacheFile:(NSString *)rid url:(NSString *)url preCacheSize:(int)preCacheSizeInKB;
```

```Objective-C
/**
获取走LocalServer播放的链接

@param rid 资源的唯一标识，由于url在加防盗链时是可变的，所以需要一个唯一标识来匹配缓存文件
@param url 资源的链接
@return 走LocalServer播放的链接，不成功将会返回空
*/
- (NSString *)getPlayUrl:(NSString *)rid url:(NSString *)url;
```

```Objective-C
/**
取消预缓存任务

@param rid 资源的唯一标识，由于url在加防盗链时是可变的，所以需要一个唯一标识来匹配缓存文件
*/
- (void)cancelPreCache:(NSString *)rid;
```

```Objective-C
/**
设置移动网络预缓存开关，防止在移动网络下额外花费流量。

@param onoff YES:开  FALSE:关， 默认：开
*/
- (void)enablePrecacheForMobileNetwork:(BOOL)onoff;
```

```Objective-C
/**
是否允许移动网络环境下开启预缓存

@return YES 允许， NO 不允许
*/
- (BOOL)isEnablePrecacheForMobileNetwork;
```

```Objective-C
/**
返回指定的缓存已完成的数据量以及总数据量

@param rid 资源的唯一标识，由于url在加防盗链时是可变的，所以需要一个唯一标识来匹配缓存文件
@param url 资源的链接
@param callback 返回结果，cachedSize：已经缓存文件大小，totalSize：总文件大小，单位：字节
*/
- (void)getFileCachedSize:(NSString *)rid url:(NSString *)url callback:(void(^)(unsigned long long cachedSize, unsigned long long totalSize))callback;
```

```Objective-C
/**
返回指定的缓存在给定偏移后连续可用的数据量

@param rid 资源的唯一标识，由于url在加防盗链时是可变的，所以需要一个唯一标识来匹配缓存文件
@param url 资源的链接
@param offset 偏移量
@return 指定偏移后连续可用的数据量
*/
-(unsigned long long)getFileAvailedSize:(NSString *)rid url:(NSString *)url offset:(unsigned long long)offset;
```

```Objective-C
/**
恢复/禁止LocalServer所有访问网络主动拉取数据的行为

@param enableCache YES:允许，NO：禁止，默认：允许
*/
- (void)enableCache:(BOOL)enableCache;
```

```Objective-C
/**
是否允许LocalServer所有预缓存访问网络主动拉取数据的行为

@return YES：允许，NO：禁止
*/
- (BOOL)isEnableCache;
```

```Objective-C
/**
开启LocalServer， 全局只用调用一次， 需要和stopServer配对使用

@param cacheDir 缓存目录，要保证是一个当前存在且有读写权限的文件夹
@param deviceId 设备Id， 统计上报会带上，追查问题用
@param appId 业务Id， 统计上报会带上，追查问题用
@param cacheSizeInMB 初始缓存大小 单位：MB
*/
- (void)startServer:(NSString *)cacheDir deviceId:(NSString *)deviceId appId:(NSString *)appId cacheSize:(int)cacheSizeInMB;
```

```Objective-C
/**
停止LocalServer， 需要和startServer配对使用
*/
- (void)stopServer;

/**
是否开启LocalServer

@return YES 开启 NO 未开启
*/
- (BOOL)isStartLocalServer;
```

### SDK集成注意事项：
1、如无特殊说明，所有接口均在主线程调用

2、加防盗链或可变的URL无法作为视频的唯一标识，必须正确设置rid参数

### SDK日志文件：
本地路径Library/Cache/com.qihoo.videocloud/log/QHVCLocalServer
