# iOS短视频剪辑SDK开发文档

### 介绍：
360直播云以SDK形式提供短视频剪辑服务，可以帮助开发者快速集成短视频剪辑能力。SDK包含framework、demo及开发文档。

### 功能说明：
短视频剪辑SDK支持文件导入、编辑、添加特效、合成导出等功能。
具体功能列表如下：

1.文件导入：

|功能列表							|
|-------------------------|
|支持导入图片、gif、视频     |
|支持导入文件片段				|

2.缩略图

|功能列表							|
|-------------------------|
|支持以任意粒度获取文件缩略图  |
|支持取消获取缩略图操作			|
	
3.文件编辑：

|功能列表							|
|-------------------------|
|排序								|
|剪切								|
|删除								|
|设置渲染模式（黑边填充、裁剪填充、变形填充）|
|设置背景样式（rgba色值、毛玻璃效果）|
|添加背景音乐						|
|添加音乐素材						|
|添加画中画素材					|
|调节文件音量						|
|音视频分离						|
|文件变速							|
|文件变调                  |

4.添加特效

|功能列表							|
|-------------------------|
|添加静态字幕						|
|添加静态贴纸						|
|添加滤镜							|
|添加水印、二维码				|
|画面旋转							|
|画面水平、垂直镜像				|
|调整画质（亮度、对比度、曝光度、gamma补偿、色温、色调、饱和度、色相、振动、暗角、色散、褪色、高光减弱、阴影补偿）|
|添加转场							|
|色键抠图							|
|美颜（嫩肤、美白）          |
|特效                      |
|音频淡入淡出               |
|视频、贴纸、字幕、水印淡入淡出 |
|画中画混合模式             |
|马赛克                    |
|去水印							|
	
5.实时预览

|功能列表							|
|-------------------------|
|播放								|
|暂停								|
|跳转到某个时间点				|
|刷新播放器						|
|重置播放器						|
|获取当前播放时间				|
|获取当前视频帧					|
|获取主视频当前视频帧按某种滤镜处理后对应的缩略图 |
	
6.合成

|功能列表							|
|-------------------------|
|开始合成							|
|支持取消正在进行的合成操作		|

7.音频波形图生成器

|功能列表							|
|-------------------------|
|开始生成                  |
|停止使用                  |
	
### 系统范围：
| 系统特性 | 支持范围       |
| ------- | :----------: |
| 系统版本 | iOS 9+        |
| 系统架构 | armv7、armv64 |

### 系统框图：

### SDK集成方法介绍：

#### 下载工程，demo对接

demo下载链接：https://github.com/360livecloud/iOS_demo.git
sdk下载链接：https://live.360.cn/index/sdkdownload

#### 函数及配置说明
#### 添加依赖库
TARGETS -> General -> Embed Binaries

QHVCEditKit.framework

#### 引入头文件
```
#import <QHVCEditKit/QHVCEditKit.h>          //头文件列表

或
#import <QHVCEditKit/QHVCEditPlayer.h>	     //实时预览
#import <QHVCEditKit/QHVCEditCommand.h>      //指令操作
#import <QHVCEditKit/Thumbnail.h>			 //缩略图
#import <QHVCEditKit/Maker.h>				 //合成操作
```

#### 初始化指令工厂
所有操作都基于指令完成，使用时需先初始化指令工厂，再根据不同的动作创建不同的指令。

```
//初始化指令工厂
commandFactory = [[QHVCEditCommandFactory alloc] initCommandFactory];

//配置输出样式
outputParams = [[QHVCEditOutput alloc] init];
[outputParams setOutputSize:CGSizeMake(360, 640)];
[outputParams setOutputRenderMode:QHVCEditOutputRenderMode_AspectFit];
[commandFactory setOutput:outputParams];

```
#### 指令操作
指令分为两大类：不可编辑指令和可编辑指令。不可编辑指令只有initCommand（初始化）、addCommand（添加指令）方法，可编辑指令有initCommand、addCommand、editCommand、deleteCommand方法，分别对应指令的初始化、增、改、删操作。

- 不可编辑指令：

```Objective-C
//添加视频文件
QHVCEditCommandAddVideoFile* command = [[QHVCEditCommandAddVideoFile alloc] initCommand:self.commandFactory];
[command setFilePath:item.filePath];
[command setFileIndex:index];
[command addCommand];
```

```Objective-C
//添加图片文件
QHVCEditCommandAddImageFile* command = [[QHVCEditCommandAddImageFile alloc] initCommand:self.commandFactory];
[command setDurationMs:3*1000];
[command setFilePath:item.filePath];
[command setFileIndex:index];
[command addCommand];
```

```Objective-C
//添加文件片段
QHVCEditCommandAddVideoFileSegment* command = [[QHVCEditCommandAddVideoFileSegment alloc] initCommand:self.commandFactory];
[command setFilePath:item.filePath];
if (!item.isVideo)
{
    [command setDurationMs:3*1000];
}
else
{
    [command setStartTimestampMs:2000];
    [command setEndTimestampMs:3000];
}
[command addCommand];
```

```Objective-C
//文件剪切
 QHVCEditCommandCutFile* command = [[QHVCEditCommandCutFile alloc] initCommand:self.commandFactory];
[command setFileIndex:self.clipFileIndex];
[command setCutTimestampMs:self.clipTimestampMs];
[command addCommand];
```

```Objective-C
//文件删除
QHVCEditCommandDeleteFile* command = [[QHVCEditCommandDeleteFile alloc] initCommand:self.commandFactory];
[command setFileIndex:index];
[command addCommand];
```

```Objective-C
//文件移动
QHVCEditCommandMoveFile* command = [[QHVCEditCommandMoveFile alloc] initCommand:self.commandFactory];
[command setFileIndex:index];
[command setMoveStep:step];
[command addCommand];
```

```Objective-C
//配置文件合成参数
self.fileSavePath = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"edit.mp4"];
QHVCEditCommandMakeFile* command = [[QHVCEditCommandMakeFile alloc] initCommand:self.commandFactory];
[command setFilePath:self.fileSavePath];
[command addCommand];
```
- 可编辑指令：

```Objective-C
//背景音乐指令
//NSString* filePath = [[NSBundle mainBundle] pathForResource:@"sunshine" ofType:@"mp3"];
self.bgMusicCommand = [[QHVCEditCommandBackgroundMusic alloc] initCommand:self.commandFactory];
[self.bgMusicCommand setFilePath:filePath];
[self.bgMusicCommand setInsertTimeStampMs:self.curStartTimestamp];
[self.bgMusicCommand setEndTimeStampMs:self.totalDurationMs];
[self.bgMusicCommand setVolum:50];
[self.bgMusicCommand setLoop:YES];

//添加
[self.bgMusicCommand addCommand];

//修改
//[self.bgMusicCommand editCommand];

//删除
//[self.bgMusicCommand deleteCommand];
```

```Objective-C
//音乐素材
QHVCEditCommandAudio *a = [[QHVCEditCommandAudio alloc]initCommand:self.commandFactory];
NSString* filePath = [[NSBundle mainBundle] pathForResource:item.audiofile ofType:@"mp3"];
a.filePath = filePath;
a.startTime = item.startTimeMs;
a.endTime = item.audioDuration;
a.insertStartTime = item.insertStartTimeMs;
a.insertEndTime = item.insertEndTimeMs;
a.volume = item.volume;
a.loop = (a.endTime - a.startTime) > (a.insertEndTime - a.insertStartTime)?NO:YES;

//添加
[a addCommand];

//修改
//[a editCommand];

//删除
//[a deleteCommand];
```

```Objective-C
//叠加文件
QHVCEditCommandOverlaySegment* cmd = [[QHVCEditCommandOverlaySegment alloc] initCommand:self.commandFactory];
cmd.filePath = file.filePath;
cmd.durationMs = file.endMs - file.startMs;
cmd.startTimestampMs = file.asset.mediaType == PHAssetMediaTypeImage ? 0 : file.startMs;
cmd.endTimestampMs = file.asset.mediaType == PHAssetMediaTypeImage ? 0 : file.endMs;
cmd.insertTimestampMs = 0;

//添加
[cmd addCommand];

//修改
//[cmd editCommand];

//删除
//[cmd deleteCommand];
```

```Objective-C
//调节文件音量
 QHVCEditCommandAlterVolume *cmd = [[QHVCEditCommandAlterVolume alloc]initCommand:self.commandFactory];
 cmd.fileIndex = i;
 cmd.volume = item.volume;

 //添加
 [cmd addCommand];

 //修改
 //[a editCommand];

 //删除
 //[a deleteCommand];
```

```Objective-C
//矩阵指令(旋转、水平翻转)
command = [[QHVCEditCommandMatrixFilter alloc] initCommand:self.commandFactory];
[command setDestinationRotateAngle:0.25];
[command setFlipX:YES];
[command setStartTimestampMs:self.curStartTimestamp];
[command setEndTimestampMs:self.curEndTimestamp];

//添加
[command addCommand];

//修改
//[command editCommand];

//删除
//[command deleteCommand];

```

```Objective-C
//文件变速
QHVCEditCommandAlterSpeed *command = [[QHVCEditCommandAlterSpeed alloc] initCommand:self.commandFactory];
[command setFileIndex:i];
[command setSpeed:speed];

//添加
[command addCommand];

//修改
//[command editCommand];

//删除
//[command deleteCommand];
```

```Objective-C
//字幕指令
command = [[QHVCEditCommandSubtitle alloc] initCommand:self.commandFactory];
CGFloat x = CGRectGetMinX(self.curFrameRectInView);
CGFloat scale = self.curFrameImage.size.height/CGRectGetHeight(self.curFrameRectInView);
command.image = image;
command.destinationX = (CGRectGetMinX(subtitle.frame) - x)*scale;
command.destinationY = CGRectGetMinY(subtitle.frame)*scale;
command.destinationWidth = CGRectGetWidth(subtitle.frame)*scale;
command.destinationHeight = CGRectGetHeight(subtitle.frame)*scale;
command.destinationRotateAngle = 0;
command.startTimestampMs = self.curStartTimestampMs;
command.endTimestampMs = self.curEndTimestampMs;

//添加
[command addCommand];

//修改
//[command editCommand];

//删除
//[command deleteCommand];                  
```

贴图指令、水印指令使用方式同字幕指令。

```Objective-C
 //新增滤镜
command = [[QHVCEditCommandAuxFilter alloc] initCommand:self.commandFactory];
command.auxFilterType = self.curAuxFilterType;
command.startTimestampMs = self.curStartTimestampMs;
command.endTimestampMs = self.curEndTimestampMs;

//添加
[command addCommand];

//修改
//[command editCommand];

//删除
//[command deleteCommand];
```

```Objective-C
//画质指令
QHVCEditCommandQualityFilter *q = [[QHVCEditCommandQualityFilter alloc] initCommand:self.commandFactory];
q.brightnessValue = 0.5; //调节亮度
q.startTimestampMs = start;
q.endTimestampMs = q.startTimestampMs +cmd.endTimestampMs;

//添加
[q addCommand];

//修改
//[q editCommand];

//删除
//[q deleteCommand];
```

```Objective-C
//转场指令
QHVCEditCommandTransition *transferCommand = [[QHVCEditCommandTransition alloc]initCommand:self.commandFactory];
transferCommand.overlayCommandId = overlaySegment.commandId;
transferCommand.transitionName = @"transition_1";
transferCommand.startTimestampMs = MIN(originalSegment.segmentStartTime - kTransferDuration, 0) ;
transferCommand.endTimestampMs = originalSegment.segmentStartTime;

//添加
[transferCommand addCommand];

//修改
//[transferCommand editCommand];

//删除
//[transferCommand deleteCommand];
```

```Objective-C
//色键抠图
QHVCEditCommandChromakey* cmd = [[QHVCEditCommandChromakey alloc] initCommand:self.commandFactory];
cmd.overlayCommandId = overlayCommandId;
cmd.color = @"FFFFFFFF";
cmd.threshold = 20;
cmd.startTimestampMs = startTimestampMs;
cmd.endTimestampMs = endTimestampMs;

//添加
[cmd addCommand];

//修改
//[cmd editCommand];

//删除
//[cmd deleteCommand];
```

```Objective-C
//添加特效
QHVCEditCommandEffectFilter* cmd = [[QHVCEditCommandEffectFilter alloc] initCommand:self.commandFactory];
cmd.effecName = @"effect_6";
cmd.color = @"FFFFFFFF";
cmd.threshold = 20;
cmd.startTimestampMs = startTimestampMs;
cmd.endTimestampMs = endTimestampMs;

//添加
[cmd addCommand];

//修改
//[cmd editCommand];

//删除
//[cmd deleteCommand];
```

```Objective-C
//添加美颜效果
QHVCEditCommandBeauty* cmd = [[QHVCEditCommandBeauty alloc] initCommand:self.commandFactory];
cmd.softLevel = 1.0;
cmd.whiteLevel = 1.0;
cmd.startTimestampMs = startTimestampMs;
cmd.endTimestampMs = endTimestampMs;

//添加
[cmd addCommand];

//修改
//[cmd editCommand];

//删除
//[cmd deleteCommand];
```

```Objective-C
//添加马赛克效果
QHVCEditCommandMosaic* cmd = [[QHVCEditCommandMosaic alloc] initCommand:self.commandFactory];
cmd.degree = 0.5;
cmd.region = CGRectMake(0, 0, 100, 100);
cmd.startTimestampMs = startTimestampMs;
cmd.endTimestampMs = endTimestampMs;

//添加
[cmd addCommand];

//修改
//[cmd editCommand];

//删除
//[cmd deleteCommand];
```

```Objective-C
//添加去水印效果
QHVCEditCommandDelogo* f = [[QHVCEditCommandDelogo alloc] initCommand:self.commandFactory];
f.startTimestampMs = start;
f.endTimestampMs = f.startTimestampMs + 2000;
f.region = CGRectMake(0, 0, 100, 100);
[f addCommand];
```

#### 实时预览

- 初始化

```Objective-C
self.player = [[QHVCEditPlayer alloc] initPlayerWithCommandFactory:self.commandFactory];
[self.player setPreviewBackgroudColor:@"FF4B4B4B"];
[self.player setPlayerDelegate:self];
```

- 设置预览画面

```Objective-C
[self.player setPlayerPreview:self.playerPreview];
```
- 播放

```Objective-C
[self.player playerPlay];
```

- 暂停

```Objective-C
[self.player playerStop];
```

- 释放

```Objective-C
[self.player free];
```

- 跳转到某个时间点

```Objective-C
[self.player playerSeekToTime:time complete:^(NSTimeInterval currentTime){}];
```

- 刷新播放器

```Objective-C
[self.player refresh];
```

- 重置播放器

```Objective-C
[self.player reset];
```

- 获取当前播放时间戳

```Objective-C
NSTimeInterval timestamp = [self.player getCurrentTimestamp];
```

- 获取当前视频帧

```Objective-C
UIImage* image = [self.player getCurrentFrame];
```

- 协议部分

```Objective-C
/**
 播放器错误回调

 @param error 错误类型
 @param info 详细错误信息
 */
- (void)onPlayerError:(QHVCEditPlayerError)error detailInfo:(QHVCEditPlayerErrorInfo)info;
```

```Objective-C
/**
 播放完成回调
 */
- (void)onPlayerPlayComplete;
```

#### 缩略图

- 初始化

```Objective-C
self.thumbnailFactory = [[QHVCEditThumbnail alloc] initThumbnailFactory];
```

- 获取缩略图

```Objective-C
 [self.thumbnailFactory getVideoThumbnailFromFile:fileItem.filePath
                                               width:200
                                              height:200
                                           startTime:startTime
                                             endTime:endTime
                                               count:count
                                            callback:^(NSArray<QHVCEditThumbnailItem *> *thumbnails, QHVCEditThumbnailCallbackState state){}];
```

- 取消获取缩略图操作

```Objective-C
[self.thumbnailFactory cancelGettingVideoThumbnail];
```

- 释放缩略图对象

```Objective-C
[self.thumbnailFactory free];
```

#### 合成操作

- 初始化

```Objective-C
self.makerFactory = [[QHVCEditMaker alloc] initWithCommandFactory:self.commandFactory];
[self.makerFactory setMakerDelegate:self];

self.fileSavePath = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"edit.mp4"];
QHVCEditCommandMakeFile* command = [[QHVCEditCommandMakeFile alloc] initCommand:self.commandFactory];
[command setFilePath:self.fileSavePath];
[command addCommand];
```

- 开始合成

```Objective-C
[self.makerFactory makerStart];
```

- 取消合成

```Objective-C
[self.makerFactory makerStop];
```

- 释放

```Objective-C
[self.makerFactory free];
```

- 协议部分

```Objective-C
/**
 合成回调

 @param status 当前合成状态
 @param progress 当前合成进度（0-100）
 */
- (void)onMakerProcessing:(QHVCEditMakerStatus)status progress:(int)progress;
```

#### 获取音频波形图

- 初始化

```Objective-C
_audioProducer = [[QHVCEditAudioProducer alloc] initWithCommandFactory:[[QHVCEditCommandManager manager] commandFactory]];
_audioProducer.fileIndex = 0;
_audioProducer.startTime = 0;
_audioProducer.endTime = cmd.endTime;
_audioProducer.delegate = self;
```

- 开始生成

```Objective-C
[_audioProducer startProducer];
```

- 停止使用

```Objective-C
[_audioProducer stopProducer];
```


# API部分
## 指令
### 指令工厂初始化

```Objective-C
@interface QHVCEditCommandFactory : NSObject

- (instancetype)initCommandFactory; //初始化指令工厂
- (QHVCEditCommandError)freeCommandFactory; //释放指令工厂

//获取文件片段列表信息block (片段信息数组，片段总时长)
typedef void(^QHVCEditSegmentInfoBlock)(NSArray<QHVCEditSegmentInfo *>* segments, NSInteger totalDurationMs);
- (QHVCEditCommandError)getSegmentInfo:(QHVCEditSegmentInfoBlock)complete; //获取文件片段列表信息

@property (nonatomic, retain) QHVCEditOutputParams* defaultOutputParams; //默认输出样式
@property (nonatomic, readonly, assign) NSInteger factoryHandle;

@end
```

### 指令初始化

```Objective-C
@interface QHVCEditCommand : NSObject

- (instancetype)initCommand:(QHVCEditCommandFactory *)commandFactory; //创建指令
- (QHVCEditCommandError)addCommand; //添加指令

@property (nonatomic, readonly, assign) NSInteger commandId;  //指令ID

@end

@interface QHVCEditEditableCommand : QHVCEditCommand

- (QHVCEditCommandError)editCommand;   //修改已发送指令
- (QHVCEditCommandError)deleteCommand; //删除已发送指令

@end
```

### 指令操作

```Objective-C
#pragma mark - 添加视频文件

@interface QHVCEditCommandAddVideoFile : QHVCEditCommand
@property (nonatomic, strong) NSString* filePath;  //视频存储路径
@property (nonatomic, assign) NSInteger fileIndex; //插入序号

@end

#pragma mark - 添加文件片段

@interface QHVCEditCommandAddFileSegment : QHVCEditCommand
@property (nonatomic, strong) NSString* filePath;              //视频存储路径
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
@property (nonatomic, assign) NSTimeInterval startTime;           //音频文件开始时间，相对素材(单位：毫秒)
@property (nonatomic, assign) NSTimeInterval endTime;             //音频文件结束时间，相对素材（单位：毫秒）
@property (nonatomic, assign) NSTimeInterval insertStartTime;     //音频文件混音相对于所有文件所在的时间轴的开始时间（单位：毫秒）
@property (nonatomic, assign) NSTimeInterval insertEndTime;       //音频文件混音相对于所有文件所在的时间轴的结束时间 (单位：毫秒)
@property (nonatomic, assign) int volume;                         //音频音量(0~200)
@property (nonatomic, assign) BOOL loop;                          //是否循环播放
@property (nonatomic, assign) int pitch;                          //音调（-12~12）
@property (nonatomic, assign) int speed;                          //变速（1/8~8）

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
@property (nonatomic, assign) NSTimeInterval startTimestampMs;                  //起始时间点，相对于文件的时间（单位：毫秒）
@property (nonatomic, assign) NSTimeInterval endTimestampMs;                    //结束时间点，相对于文件的时间（单位：毫秒）
@property (nonatomic, assign) NSInteger gainMin;                                //淡入淡出声音最小值，默认0
@property (nonatomic, assign) NSInteger gainMax;                                //淡入淡出声音最大值， 默认100
@property (nonatomic, assign) QHVCEditCommandAudioFilterType audioFilterType;   //淡入、淡出类型
@property (nonatomic, assign) QHVCEditCommandAudioFadeType fadeType;            //变化曲线类型

@end


#pragma mark -  文件变速

@interface QHVCEditCommandAlterSpeed : QHVCEditCommand
@property (nonatomic, assign) NSInteger fileIndex;           //文件序列号
@property (nonatomic, assign) float speed;                   //速度0.25~4

@end

#pragma mark - 变调
@interface QHVCEditCommandAlterPitch : QHVCEditEditableCommand
@property (nonatomic, assign) NSInteger fileIndex;            //文件序列号
@property (nonatomic, assign) int pitch;                      //音调（-12~12）
@end


#pragma mark - 叠加片段

@interface QHVCEditCommandOverlaySegment : QHVCEditEditableCommand
@property (nonatomic, strong) NSString* filePath;                 //物理文件路径
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

@interface QHVCEditCommandEffectFilter : QHVCEditEditableCommand

//指定特效添加层级。添加给某个叠加片段，需指定叠加文件的commandId; 只添加给主片段列表，=0; 默认为-1，生效于主片段和所有叠加片段
@property (nonatomic, assign) NSInteger overlayCommandId;
@property (nonatomic, retain) NSString* effectName;                 //特效名称（目前支持15种，命名为 effect_1 ... effect_15）
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

@interface QHVCEditCommandChromakey : QHVCEditEditableCommand

//指定特效添加层级。添加给某个叠加片段，需指定叠加文件的commandId; 只添加给主片段列表，=0; 默认为-1，生效于主片段和所有叠加片段
@property (nonatomic, assign) NSInteger overlayCommandId;
@property (nonatomic, retain) NSString* color;                              //抠去的颜色, 16进制ARGB值
@property (nonatomic, assign) int threshold;                                //微调，基于抠去的颜色的波动范围，微调越大抠色范围越大, 0-100
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
```

## 实时预览

```Objective-C
/**
 初始化播放器

 @return 播放器对象
 */
- (instancetype)initPlayerWithCommandFactory:(QHVCEditCommandFactory *)commandFactory;


/**
 设置播放器代理对象

 @param delegate 代理对象
 @return 是否设置成功
 */
- (QHVCEditPlayerError)setPlayerDelegate:(id<QHVCEditPlayerDelegate>)delegate;


/**
 关闭播放器

 @return 是否关闭成功
 */
- (QHVCEditPlayerError)free;


/**
 播放器是否处于播放状态

 @return 是否处于播放状态
 */
- (BOOL)isPlayerPlaying;


/**
 设置预览画布

 @param preview 预览画布
 @return 是否设置成功
 */
- (QHVCEditPlayerError)setPlayerPreview:(UIView *)preview;


/**
 设置预览画布填充模式
 默认使用 QHVCEditPlayerPreviewFillMode_AspectFit

 @param mode 填充模式
 @return 是否设置成功
 */
- (QHVCEditPlayerError)setPreviewFillMode:(QHVCEditPlayerPreviewFillMode)mode;


/**
 设置预览画布填充背景色
 默认黑色

 @param color 填充背景色 (16进制值, ARGB)
 @return 是否设置成功
 */
- (QHVCEditPlayerError)setPreviewBackgroudColor:(NSString *)color;


/**
 重置播放器
 若播放器初始化之后有文件操作均需重置播放器（移序、删除、添加文件、添加背景音）

 @param seekTimestampMs 重置并将播放器跳转至某时间点
 @return 是否设置成功
 */
- (QHVCEditPlayerError)resetPlayer:(NSTimeInterval)seekTimestampMs;


/**
 刷新播放器
 若播放器初始化之后有效果添加需刷新播放器（字幕、贴纸、水印、滤镜、画质等）
 
 @return 是否设置成功
 */
- (QHVCEditPlayerError)refreshPlayer;

/**
 播放

 @return 是否调用成功
 */
- (QHVCEditPlayerError)playerPlay;


/**
 停止

 @return 是否调用成功
 */
- (QHVCEditPlayerError)playerStop;


/**
 跳转回调

 @param currentTime 当前跳转时间点（单位：毫秒）
 */
typedef void(^QHVCEditPlayerSeekCallback)(NSTimeInterval currentTime);

/**
 跳转至某个时间点

 @param time 跳转时间点（相对所有文件时间轴，单位：毫秒）
 @param forceRequest 是否强制请求
 @param block 跳转完成回调
 @return 是否调用成功
 */
- (QHVCEditPlayerError)playerSeekToTime:(NSTimeInterval)time forceRequest:(BOOL)forceRequest complete:(QHVCEditPlayerSeekCallback)block;


/**
 跳转至某个片段第一帧

 @param index 片段序号
 @param block 跳转完成回调
 @return 是否调用成功
 */
- (QHVCEditPlayerError)playerSeekToSegment:(NSInteger)index complete:(QHVCEditPlayerSeekCallback)block;


/**
 获取当前时间戳

 @return 当前时间戳
 */
- (NSTimeInterval)getCurrentTimestamp;


/**
 获取当前视频帧（带所有效果）
 
 @return 视频帧
 */
- (UIImage *)getCurrentFrame;

/**
 批量获取主视频当前视频帧按某些效果处理后对应的缩略图，回调接口

 @param thumbnails 缩略图对象数组
 @param clutImagePaths 查色图路径数组
 */
typedef void(^QHVCEditCLUTFilterThumbnailsCallback)(NSArray<UIImage *>* thumbnails, NSArray<NSString *>* clutImagePaths);

/**
 批量获取主视频当前视频帧按某些效果处理后对应的缩略图

 @param clutImageInfo 查色图信息数组，image和path同时存在优先读取path，image和path均为空（@“”）时返回不带任何特效的缩略图
 例如：
 @[
 @{
 @"path":path,
 @"image":image,
 @"progress":@1.0,
 }];
 @param size 生成缩略图尺寸
 @param block 数据回调
 @return 返回值
 */
- (QHVCEditPlayerError)generateCLUTFilterThumbnails:(NSArray<NSDictionary *>*)clutImageInfo
                                             toSize:(CGSize)size
                                           callback:(QHVCEditCLUTFilterThumbnailsCallback)block;


//播放器回调
@protocol QHVCEditPlayerDelegate <NSObject>
@optional

/**
 播放器错误回调

 @param error 错误类型
 @param info 详细错误信息
 */
- (void)onPlayerError:(QHVCEditPlayerError)error detailInfo:(QHVCEditPlayerErrorInfo)info;

/**
 播放完成回调
 */
- (void)onPlayerPlayComplete;

/**
 播放器第一帧已渲染
 */
- (void)onPlayerFirstFrameDidRendered;

@end

```

## 缩略图

```Objective-C
/**
 初始化缩略图生成器

 @return 缩略图生成器对象
 */
- (instancetype)initThumbnailFactory;


/**
 释放缩略图生成器
 
 @return 是否调用成功
 */
- (QHVCEditThumbnailError)free;


/**
 获取缩略图回调
 异步操作，可能会陆续回调缩略图

 @param thumbnails 缩略图数组
 @param state 当前状态
 */
typedef void(^QHVCEditThumbnailCallback)(NSArray<QHVCEditThumbnailItem*>* thumbnails, QHVCEditThumbnailCallbackState state);


/**
 获取缩略图

 @param filePath 文件物理路径
 @param width 缩略图宽度
 @param height 缩略图库高度
 @param startTimestampMs 起始时间点，相对当前文件（单位：毫秒）
 @param endTimestampMs 结束时间点，相对当前文件（单位：毫秒）
 @param count 期望获取视频帧数，会根据视频fps做调整，可能实际拿到视频帧数小于期望值
 @param block 获取缩略图回调
 @return 是否调用成功
 */
- (QHVCEditThumbnailError)getVideoThumbnailFromFile:(NSString *)filePath
                                     width:(int)width
                                    height:(int)height
                                 startTime:(NSTimeInterval)startTimestampMs
                                   endTime:(NSTimeInterval)endTimestampMs
                                     count:(int)count
                                  callback:(QHVCEditThumbnailCallback)block;


/**
 取消获取缩略图

 @return 是否调用成功
 */
- (QHVCEditThumbnailError)cancelGettingVideoThumbnail;
```

## 合成

```Objective-C
/**
 初始化合成器

 @param commandFactory 指令工厂
 @return 合成器实例对象
 */
- (instancetype)initWithCommandFactory:(QHVCEditCommandFactory *)commandFactory;


/**
 设置合成器代理对象

 @param delegate 代理对象
 @return 是否调用成功
 */
- (QHVCEditMakerError)setMakerDelegate:(id<QHVCEditMakerDelegate>)delegate;


/**
 关闭合成器

 @return 是否调用成功
 */
- (QHVCEditMakerError)free;


/**
 开始合成

 @return 是否调用成功
 */
- (QHVCEditMakerError)makerStart;


/**
 停止合成，用于打断操作

 @return 是否调用成功
 */
- (QHVCEditMakerError)makerStop;

```

## 音频波形图生成器

``` Objective-C
@property (nonatomic, weak) id<QHVCEditAudioProducerDelegate> delegate;
@property (nonatomic, assign) int fileIndex;
@property (nonatomic, assign) int overlayCommandId;
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) NSInteger endTime;

/**
 初始化合成器
 
 @param commandFactory 指令工厂
 @return 合成器实例对象
 */
- (instancetype)initWithCommandFactory:(QHVCEditCommandFactory *)commandFactory;

/**
 开始读取pcm
 */
- (QHVCEditAudioProducerError)startProducer;

/**
 停止
 */
- (QHVCEditAudioProducerError)stopProducer;

//回调接口
@protocol QHVCEditAudioProducerDelegate <NSObject>

- (void)onPCMData:(unsigned char *)pcm size:(int)size;

@optional
- (void)onProducerStatus:(QHVCEditAudioProducerStatus)status;

@end
```

## 日志

``` Objective-C
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
```

### SDK集成注意事项

```
QHVCEditKit.framework是动态库，一定要在TARGETS->General->Embed Binaries下引入
```

```
所有操作均依赖指令集，初始化播放器、初始化合成对象前，请确保已初始化指令工厂且正确配置输出参数。
```

### 错误码说明

QHVCEditOutputError（输出参数）

| 状态码 | 字段                            | 注释    |
|:-----:|--------------------------------|---------|
|   1   | QHVCEditOutputError_NoError    | 无错误   |
|   2   | QHVCEditOutputError_ParamError | 参数错误 |

QHVCEditCommandError（指令操作）

| 状态码 | 字段                               | 注释       |
|:-----:|-----------------------------------|------------|
|   1   | QHVCEditCommandError_NoError      | 无错误      |
|   2   | QHVCEditCommandError_ParamError   | 参数错误    |
|   3   | QHVCEditCommandError_FactoryError | 指令工厂错误 |
|   4   | QHVCEditCommandError_SendError    | 指令发送错误 |

QHVCEditPlayerError（播放器基本错误类型）

| 状态码 | 字段                             | 注释       |
|:-----:|---------------------------------|------------|
|   1   | QHVCEditPlayerError_NoError     | 无错误      |
|   2   | QHVCEditPlayerError_ParamError  | 参数错误    |
|   3   | QHVCEditPlayerError_InitError   | 初始化失败   |
|   4   | QHVCEditPlayerError_StatusError | 播放状态错误 |

QHVCEditPlayerErrorInfo（播放器详细错误类型）

| 状态码 | 字段                                         | 注释           |
|:-----:|---------------------------------------------|----------------|
|   1   | QHVCEditPlayerErrorInfo_NoError             | 无错误          |
|   2   | QHVCEditPlayerErrorInfo_CommandFactoryError | edit handle错误 |
|   3   | QHVCEditPlayerErrorInfo_PlayerHandleError   | 播放器handle错误 |

QHVCEditThumbnailError（缩略图基本错误类型）

| 状态码 | 字段                                 | 注释         |
|:-----:|-------------------------------------|--------------|
|   1   | QHVCEditThumbnailError_NoError      | 无错误        |
|   2   | QHVCEditThumbnailError_InitError    | 初始化失败     |
|   3   | QHVCEditThumbnailError_processError | 获取缩略图错误 |
|   4   |  QHVCEditThumbnailError_ParamError  | 参数错误      |

QHVCEditMakerError （合成基本错误类型）

| 状态码 | 字段                             | 注释       |
|:-----:|---------------------------------|------------|
|   1   | QHVCEditMakerError_NoError      | 无错误      |
|   2   | QHVCEditMakerError_FactoryError | 指令工厂错误 |
|   3   | QHVCEditMakerError_InitError    | 初始化失败   |

QHVCEditAudioProducerError（音频波形图生成器错误类型）

| 状态码 | 字段                                    | 注释          |
|:-----:|----------------------------------------|---------------|
|   1   | QHVCEditAudioProducerError_NoError     | 无错误         |
|   2   | QHVCEditAudioProducerError_ParamError  | 参数错误       |
|   3   | QHVCEditAudioProducerError_InitError   | 初始化失败      |
|   4   | QHVCEditAudioProducerError_ReadPCMError| PCM数据读取失败 |

详细错误码

| 状态码 | 注释        |
|:-----:|------------|
| -999  | 内存分配失败 |
| -998  | 文件打开失败 |
| -997  | 文件内容不对 |
| -996  | 背景音乐不存在 |
| -995  | 特效已存在 |
| -994  | 特效不存在 |
| -899  | 输入参数错误 |
| -799  | 合成中，不能操作参数配置 |
| -798  | 参数配置为空就开始合成（主轴没有视频）|
| -797  | 视频流不存在 |
| -796  | 音频流不存在 |
| -795  | 创建流失败   |
| -794  | 没有合适的解码器 |
| -793  | 解码器打开失败 |
| -792  | 编码器打开失败 |
| -791  | 编码失败 |
| -790  | 解码失败 |
| -789  | 创建特效失败 |
| -788  | ffmpeg seek失败 |
| -787  | 写文件失败 |
| -786  | 填充音频失败 |


