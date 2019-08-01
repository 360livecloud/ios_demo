# iOS拍摄SDK开发文档

## 介绍

直播云以SDK形式提供视频拍摄功能 ，帮助开发者快速实现视频拍摄能力。SDK包括开发文档、demo、SDK。开发者可参考文档或demo，将相关framework加入工程中，完成相关配置，调用相关的API即可接入拍摄功能。

## 功能说明

拍摄包括采集（音频、视频）、渲染（Metal/OpenGL）、分段录制、合成等主要功能。

| 功能列表| 
| -------- |
| 视频采集 | 
| 音频采集 | 
| 自定义分辨率、码率、帧率 | 
| 照片拍摄 | 
| 分段录制 | 
| 倍速| 
| 回删 | 
| 分段合成 | 
| 滤镜 | 
| 背景音乐 .etc | 

## 系统范围

| 系统特性 | 支持范围     |
| -------- | ------------ |
| 系统版本 | iOS8+        |
| 系统架构 | armv7、armv7s、arm64 |



## SDK集成
### demo地址

下载链接：[https://github.com/360livecloud/ios_demo.git](https://github.com/360livecloud/ios_demo.git)

### 配置说明

1. 拍摄功能提供两个framework：

	QHVCRecordKit.framework该库为动态库（Build Phases->Embed Frameworks-> +）

	QHVCCommonKit.framework该库为动态库（Build Phases->Embed Frameworks-> +）




2. 实际开发中#import `<QHVCRecordKit/QHVCRecord.h>`头文件调用相关接口。


## 接口说明

### 初始化

创建拍摄对象（注意：初始化sdk前，需要获取相机、麦克风访问权限，否则会有异常）


```

[QHVCRecord openLogWithLevel:QHVCRecordLogLevelTrace];//log for test
    
    _videoSession = [[QHVCRecord alloc] init];
    [_videoSession setStatisticsInfo:@{@"channelId":@"demo_1",
                                       @"userId":@"110",
                                       }];//统计相关
    [_videoSession setVideoConfig:[QHVCRecordVideoConfig defaultVideoConfig]];//设置视频编码输出参数
    [_videoSession setAudioConfig:[QHVCRecordAudioConfig defaultAudioConfig]];//设置音频编码输出参数

    [_videoSession setRecordDelegate:self];
//    [_videoSession switchCamera:_isFrontCamera];
    [_videoSession startCameraPreview:preview];//开始本地预览
```

### 分段录制


```

if (_isRecording) {
    _recordBtn.enabled = NO;
    [_videoSession stopRecord];
}
else
{
    // Disable the idle timer while recording
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // Make sure we have time to finish saving the movie if the app is backgrounded during recording
    if ( [[UIDevice currentDevice] isMultitaskingSupported] ) {
        _backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
    }
    
    if (!_isFirstRecord) {
        BOOL status = [[NSFileManager defaultManager] removeItemAtPath:_cacheFolder error:nil];//每次录制前或者结束后清空cacheFolder
        if (!status) {
            NSLog(@"remove fail !!!");
        }
        [_videoSession setRecordPath:_outputFile videoSegmentsFolder:_cacheFolder];
        _isFirstRecord = YES;
    }
    [_videoSession setRecordSpeed:self.recordSpeed];//设置倍速
    
    _recordBtn.enabled = NO;// avoid re-enabled
    [_videoSession startRecord];//开始录制
}
        
```
###合成
```
合成进度、状态等信息获取，参见QHVCRecordDelegate.h

[_videoSession joinAllSegments];

```

```

## 错误码说明

|状态码|含义|
|:--:|:--|
|-999|时间戳错误|
|-899|参数错误|
|-797|创建线程失败|
|-796|打开文件失败|
|-794|打开编码器失败|