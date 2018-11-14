# iOS互动直播SDK开发文档

## 介绍

直播云以SDK形式提供互动直播服务，可以帮助开发者快速实现全互动直播。SDK包含framework、demo及开发文档。

## 功能说明

互动直播SDK支持主流CDN分发和旁路直播，提供的基础功能有：加入房间、离开房间、数据采集、转推数据流、大小流切换、禁止/开启声音、禁止/开启视频、码率相关参数的配置等
## 系统范围

| 系统特性 | 支持范围     |
| -------- | ------------ |
| 系统版本 | iOS8+        |
| 系统架构 | armv7、armv7s、arm64 |


## SDK集成
### demo地址

下载链接：[https://github.com/360livecloud/ios_demo.git](https://github.com/360livecloud/ios_demo.git)

### 配置说明

1. 互动直播功能需要加入的framework：

	QHVCInteractiveKit.framework该库为静态库（Build Phases->Link Binary With Libraries-> +）

	QHVCCommonKit.framework该库为动态库（Build Phases->Embed Frameworks-> +）
	AgoraRtcEngineKit.framework该库为静态库（Build Phases->Link Binary With Libraries-> +）



2. 实际开发中#import `<QHVCInteractiveKit/QHVCInteractiveKit.h>`头文件调用相关接口。


## 接口说明

### 初始化SDK
   

```

/**
 设置公共业务信息
 该方法需要在所有实例方法之前调用，用于设置业务所需要的一些必要信息，便于业务区分、统计使用。
 
 @param channelId 渠道Id，用于区分公司或部门下拥有多款应用
 @param appKey 平台为每个应用分配的唯一ID
 @param userSign 用户签名
 @return 0 成功, 非0 表示失败。
 */
- (int) setPublicServiceInfo:(nonnull NSString *)channelId
                      appKey:(nonnull NSString *)appKey
                    userSign:(nonnull NSString *)userSign;


/**
 加载互动直播引擎数据，进行准备工作。
 调用该方法前，必须先调用setPublicServiceInfo进行业务信息准备，在该方法必须调用后才能调用其它实例方法。该方法是异步执行，待回调执行之后才能执行其它实例方法。若加载成功，SDK将会触发didLoadEngineData回调，然后，业务可以进行一系列参数的设置，之后调用joinChannel以及后续操作。若加载失败，SDK将会触发didOccurError回调，请根据相关错误码进行逻辑处理。

 @param delegate 托管对象
 @param roomId 房间ID
 @param userId 用户ID，必须是数字
  @param sessionId 会话ID，用于标识业务会话请求，每一次完整的流程之后，该值需要重新设置
 @param optionInfoDict 可选字典，若需旁路直播功能等可通过该字典设置，如果业务准备使用视频云的直播服务，可以通过applyforBypassLiveAddress接口申请推流服务；如果用业务自己的直播推流服务，流ID一定要保证唯一。
 例如:
 @{@"pull_addr":@"",//拉流地址
   @"push_addr":@"",//推流地址
  };
 @return 0 成功, 非0 表示失败。
 */
- (int) loadEngineDataWithDelegate:(nonnull id<QHVCInteractiveDelegate>)delegate
                            roomId:(nonnull NSString *)roomId
                            userId:(nonnull NSString *)userId
                         sessionId:(nullable NSString *)sessionId
                    optionInfoDict:(nullable NSDictionary *)optionInfoDict;
```
### 开启视频

```
/**
 开启视频模式
 该方法用于开启视频模式。可以在加入频道前或者通话中调用，在加入频道前调用，则自动开启视频模式，在通话中调用则由音频模式切换为视频模式。使用disableVideo方法可关闭视频模式。
 
 @return 0 成功, <0 表示失败.
 */
- (int)enableVideo;
```

### 设置视频显示模式

```
/**
 设置本地视频显示属性
 该方法设置本地视频显示信息。应用程序通过调用此接口绑定本地视频流的显示视窗(view)，并设置视频显示模式。
 在应用程序开发中， 通常在初始化后调用该方法进行本地视频设置，然后再加入频道。退出频道后，绑定仍然有效，如果需要解除绑定，可以指定空(NULL)View调用setupLocalVideo。
 
 @param local 设置视频属性
 @return 0 成功, return <0 表示失败
 */
- (int)setupLocalVideo:(nullable QHVCITLVideoCanvas *)local;


/**
 设置远端视频显示视图
 该方法绑定远程用户和显示视图，即设定uid指定的用户用哪个视图显示。调用该接口时需要指定远程视频的uid，一般可以在进频道前提前设置好，如果应用程序不能事先知道对方的uid，可以在应用程序收到didJoinedOfUid事件时设置。
 如果启用了视频录制功能，视频录制服务会做为一个哑客户端加入频道，因此其他客户端也会收到它的didJoinedOfUid事件，APP不应给它绑定视图（因为它不会发送视频流），如果APP不能识别哑客户端，可以在firstRemoteVideoDecodedOfUid事件触发时再绑定视图。解除某个用户的绑定视图可以把view设置为空。退出频道后，SDK会把远程用户的绑定关系清除掉。
 
 @param remote 设置视频属性
 @return 0 成功, return <0 表示失败
 */
- (int)setupRemoteVideo:(nonnull QHVCITLVideoCanvas *)remote;
```

### 设置视频分辨率

```
/**
 设置本地视频属性
 该方法设置视频编码属性。
 每个Profile对应一套视频参数，如分辨率、帧率、码率等。当设备的摄像头不支持指定的分辨率时，SDK会自动选择一个合适的摄像头分辨率，但是编码分辨率仍然用setVideoProfile 指定的。
 该方法仅设置编码器编出的码流属性，可能跟最终显示的属性不一致，例如编码码流分辨率为640x480，码流的旋转属性为90度，则显示出来的分辨率为竖屏模式。
 应在调用joinChannel/startPreview前设置视频属性。
 
 @param profile 视频属性
 @param swapWidthAndHeight 是否交换宽和高，true：交换宽和高，false：不交换宽和高(默认)
 @return 0 成功, return <0 表示失败
 */
- (int)setVideoProfile:(QHVCITLVideoProfile)profile
    swapWidthAndHeight:(BOOL)swapWidthAndHeight;
```

### 设置用户角色
```
/**
 设置用户角色
 在加入频道前，用户需要通过本方法设置观众(默认)或主播模式。在加入频道后，用户可以通过本方法切换用户模式。
 
 @param role 直播场景里的用户角色
 @param permissionKey 填写为NULL
 @return 0 成功, return <0 表示失败
 */
- (int)setClientRole:(QHVCITLClientRole)role withKey: (nullable NSString *)permissionKey;
```
### 加入频道
```
/**
 加入频道
 该方法让用户加入通话频道，在同一个频道内的用户可以互相通话，多个用户加入同一个频道，可以群聊。在真正加入频道后，SDK会触发didJoinChannel回调。如果已在通话中，用户必须调用leaveChannel退出当前通话，才能进入下一个频道。该方法是异步的，所以可以在主用户界面线程被调用。
 
 @return 0 成功, <0 表示失败.
 */
- (int)joinChannel;

```

### 离开频道
```
/**
 离开频道
 即挂断或退出通话。joinChannel后，必须调用leaveChannel以结束通话，否则不能进行下一次通话。不管当前是否在通话中，都可以调用leaveChannel，没有副作用。leaveChannel会把会话相关的所有资源释放掉。leaveChannel是异步操作，调用返回时并没有真正退出频道。在真正退出频道后，SDK会触发didLeaveChannelWithStats回调。
 
 @return 0 成功, <0 表示失败.
 */
- (int)leaveChannel;

```

### 日志相关
开发阶段辅助开发调试，根据实际情况使用

```
/**
 开启日志
 
 @param level 日志等级
 */
+ (void) openLogWithLevel:(QHVCITLLogLevel)level;


/**
 设置日志输出callback
 
 @param callback 回调block
 */
+ (void) setLogOutputCallBack:(void(^_Nullable)(int loggerID, QHVCITLLogLevel level, const char * _Nullable data))callback;
```

###回调
```
@protocol QHVCInteractiveDelegate <NSObject>
@optional
/**
 发生警告回调
 该回调方法表示SDK运行时出现了（网络或媒体相关的）警告。通常情况下，SDK上报的警告信息应用程序可以忽略，SDK会自动恢复。
 
 @param engine 引擎对象
 @param warningCode 警告代码
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine didOccurWarning:(QHVCITLWarningCode)warningCode;


/**
 本地推流端发生错误回调
 该回调方法表示SDK运行时出现了（网络或媒体相关的）错误。通常情况下，SDK上报的错误意味着SDK无法自动恢复，需要应用程序干预或提示用户。比如启动通话失败时，SDK会上报QHVCITL_Error_StartCall(1002)错误。应用程序可以提示用户启动通话失败，并调用leaveChannel退出频道。
 
 @param engine 引擎对象
 @param errorCode 错误代码
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine didOccurError:(QHVCITLErrorCode)errorCode;


/**
 加载互动直播引擎数据成功回调
 该回调方法表示SDK加载引擎数据成功。该回调成功后，业务可以进行一系列参数的设置，之后调用joinChannel以及后续操作。
 
 @param engine 引擎对象
 @param dataDict 参数字典，将会返回业务所需的必要信息
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine didLoadEngineData:(nullable NSDictionary *)dataDict;

/**
 音量提示回调
 提示谁在说话及其音量，默认禁用。可通过enableAudioVolumeIndication方法设置。
 
 @param engine 引擎对象
 @param speakers 说话者（数组）。每个speaker()：uid: 说话者的用户ID,volume：说话者的音量（0~255）
 @param totalVolume 混音后的）总音量（0~255）
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine reportAudioVolumeIndicationOfSpeakers:(nullable NSArray *)speakers totalVolume:(NSInteger)totalVolume;


/**
 本地首帧视频显示回调
 提示第一帧本地视频画面已经显示在屏幕上。
 
 @param engine 引擎对象
 @param size 视频流尺寸（宽度和高度）
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine firstLocalVideoFrameWithSize:(CGSize)size;


/**
 远端首帧视频接收解码回调
 提示已收到第一帧远程视频流并解码。
 
 @param engine 引擎对象
 @param uid 用户ID，指定是哪个用户的视频流
 @param size 视频流尺寸（宽度和高度）
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine firstRemoteVideoDecodedOfUid:(nonnull NSString *)uid size:(CGSize)size;


/**
 本地或远端用户更改视频大小的事件

 @param engine 引擎对象
 @param uid 用户ID
 @param size 视频新Size
 @param rotation 视频新的旋转角度
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine videoSizeChangedOfUid:(nonnull NSString *)uid size:(CGSize)size rotation:(NSInteger)rotation;


/**
 远端首帧视频显示回调
 提示第一帧远端视频画面已经显示在屏幕上。
 如果是主播推混流，这里需要在回调里面强制更新一下混流布局配置:
 setVideoCompositingLayout:(QHVCITLVideoCompositingLayout*)layout;
 
 @param engine 引擎对象
 @param uid 用户ID，指定是哪个用户的视频流
 @param size 视频流尺寸（宽度和高度）
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine firstRemoteVideoFrameOfUid:(nonnull NSString *)uid size:(CGSize)size;



/**
 用户加入回调
 提示有用户加入了频道。如果该客户端加入频道时已经有人在频道中，SDK也会向应用程序上报这些已在频道中的用户。
 
 @param engine 引擎对象
 @param uid 用户ID，如果joinChannel中指定了uid，则此处返回该ID；否则使用连麦服务器自动分配的ID。
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine didJoinedOfUid:(nonnull NSString *)uid;


/**
 某个用户离线回调
 提示有用户离开了频道（或掉线）。
 
 @param engine 引擎对象
 @param uid 用户ID
 @param reason 离线原因
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine didOfflineOfUid:(nonnull NSString *)uid reason:(QHVCITLUserOfflineReason)reason;


/**
 用户音频静音回调
 提示有用户用户将通话静音/取消静音。
 
 @param engine 引擎对象
 @param muted Yes:静音, No:取消静音
 @param uid 用户ID
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine didAudioMuted:(BOOL)muted byUid:(nonnull NSString *)uid;


/**
 用户停止/重新发送视频回调
 提示有其他用户暂停发送/恢复发送其视频流。
 
 @param engine 引擎对象
 @param muted Yes：该用户已暂停发送其视频流 No：该用户已恢复发送其视频流
 @param uid 用户ID
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine didVideoMuted:(BOOL)muted byUid:(nonnull NSString *)uid;


/**
 音频路由改变

 @param engine 引擎对象
 @param routing 新的输出设备
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine didAudioRouteChanged:(QHVCITLAudioOutputRouting)routing;


/**
 用户启用/关闭视频回调
 提示有其他用户启用/关闭了视频功能。关闭视频功能是指该用户只能进行语音通话，不能显示、发送自己的视频，也不能接收、显示别人的视频。
 
 @param engine 引擎对象
 @param enabled Yes：该用户已启用了视频功能 No：该用户已关闭了视频功能
 @param uid 用户ID
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine didVideoEnabled:(BOOL)enabled byUid:(nonnull NSString *)uid;


/**
 本地视频统计回调
 报告更新本地视频统计信息，该回调方法每两秒触发一次。
 
 @param engine 引擎对象
 @param stats sentBytes（上次统计后）发送的字节数 sentFrames（上次统计后）发送的帧数
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine localVideoStats:(nonnull QHVCITLLocalVideoStats *)stats;


/**
 远端视频统计回调
 报告更新远端视频统计信息，该回调方法每两秒触发一次。
 
 @param engine 引擎对象
 @param stats 统计信息
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine remoteVideoStats:(nonnull QHVCITLRemoteVideoStats *)stats;


/**
 摄像头启用回调
 提示已成功打开摄像头，可以开始捕获视频。
 
 @param engine 引擎对象
 */
- (void)interactiveEngineCameraDidReady:(nonnull QHVCInteractiveKit *)engine;


/**
 视频功能停止回调
 提示视频功能已停止。应用程序如需在停止视频后对view做其他处理（比如显示其他画面），可以在这个回调中进行。
 
 @param engine 引擎对象
 */
- (void)interactiveEngineVideoDidStop:(nonnull QHVCInteractiveKit *)engine;


/**
 本地网络连接中断回调
 在SDK和服务器失去了网络连接时，触发该回调。失去连接后，除非APP主动调用leaveChannel，SDK会一直自动重连。
 
 @param engine 引擎对象
 */
- (void)interactiveEngineConnectionDidInterrupted:(nonnull QHVCInteractiveKit *)engine;


/**
 本地网络连接丢失回调
 在SDK和服务器失去了网络连接后，会触发interactiveEngineConnectionDidInterrupted回调，并自动重连。在一定时间内（默认10秒）如果没有重连成功，触发interactiveEngineConnectionDidLost回调。除非APP主动调用leaveChannel，SDK仍然会自动重连。
 
 @param engine 引擎对象
 */
- (void)interactiveEngineConnectionDidLost:(nonnull QHVCInteractiveKit *)engine;


/**
 加入频道成功回调
 该回调方法表示该客户端成功加入了指定的频道。
 
 @param engine 引擎对象
 @param channel 频道名
 @param uid 用户ID
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine didJoinChannel:(nonnull NSString *)channel withUid:(nonnull NSString *)uid;


/**
 重新加入频道回调
 有时候由于网络原因，客户端可能会和服务器失去连接，SDK会进行自动重连，自动重连成功后触发此回调方法，提示有用户重新加入了频道，且频道ID和用户ID均已分配。
 
 @param engine 引擎对象
 @param channel 频道名
 @param uid 用户ID
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine didRejoinChannel:(nonnull NSString *)channel withUid:(nonnull NSString *)uid;


/**
 统计数据回调
 该回调定期上报Interactive Engine的运行时的状态，每两秒触发一次。
 
 @param engine 引擎对象
 @param stats 统计值
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine reportStats:(nonnull QHVCITLStatistics *)stats;


/**
 用户主动离开频道回调
 
 @param engine 引擎对象
 @param stats 本次通话数据统计，包括时长、发送和接收数据量等
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine didLeaveChannelWithStats:(nullable QHVCITLStatistics *)stats;


/**
 语音质量回调
 在通话中，该回调方法每两秒触发一次，报告当前通话的（嘴到耳）音频质量。
 
 @param engine 引擎对象
 @param uid 用户ID
 @param quality 声音质量评分
 @param delay 延迟（毫秒）
 @param lost 丢包率（百分比）
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine audioQualityOfUid:(nonnull NSString *)uid quality:(QHVCITLQuality)quality delay:(NSUInteger)delay lost:(NSUInteger)lost;


/**
 频道内网络质量报告回调
 该回调定期触发，向APP报告频道内通话中用户当前的上行、下行网络质量。
 
 @param engine 引擎对象
 @param uid 用户ID。表示该回调报告的是持有该ID的用户的网络质量。当uid为0时，返回的是本地用户的网络质量。当前版本仅报告本地用户的网络质量。
 @param txQuality 该用户的上行网络质量。
 @param rxQuality 该用户的下行网络质量。
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine networkQuality:(nonnull NSString *)uid txQuality:(QHVCITLQuality)txQuality rxQuality:(QHVCITLQuality)rxQuality;


/**
 抓取视频截图回调
 该回调方法由takeStreamSnapshot触发，返回的是对应uid当前流的图像
 
 @param engine 引擎对象
 @param img 截图对象
 @param uid 用户ID
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine takeStreamSnapshot:(nonnull CGImageRef)img uid:(nonnull NSString *)uid;

@end


/**
 视频输出回调
 */
@protocol QHVCInteractiveVideoFrameDelegate <NSObject>
@optional

/**
 创建一个CVPixelBufferRef对象的内存地址给SDK，接收到的图像将会存放到这个对象上，然后调用renderPixelBuffer方法进行通知
 
 @param engine 引擎对象
 @param width 视频宽
 @param height 视频高
 @param stride stride值
 */
- (nonnull CVPixelBufferRef)interactiveEngine:(nonnull QHVCInteractiveKit *)engine createInputBufferWithWidth:(int)width height:(int)height stride:(int)stride;

/**
 远端视频数据拷贝完毕后进行回调，通知业务进行渲染
 
 @param engine 引擎对象
 @param uid 用户ID
 @param pixelBuffer 视频对象，数据为一个CVPixelBufferRef对象
 */
- (void)interactiveEngine:(nonnull QHVCInteractiveKit *)engine renderPixelBuffer:(nonnull NSString *)uid pixelBuffer:(nonnull CVPixelBufferRef)pixelBuffer;

@end

/**
 音频输出回调
 */
@protocol QHVCInteractiveAudioFrameDelegate <NSObject>
@optional

/**
 该方法获取本地采集的音频数据，可以在此时机处理前置声音效果。
 
 @param audioFrame 声音数据
 */
- (void)onRecordLocalAudioFrame:(nonnull QHVCITLAudioFrame *)audioFrame;

/**
 该方法获取上行、下行所有数据混音后的数据。
 
 @param audioFrame 声音数据
 */
- (void)onMixedAudioFrame:(nonnull QHVCITLAudioFrame *)audioFrame;

@end
```

### 查看更多API介绍 可参考API文档