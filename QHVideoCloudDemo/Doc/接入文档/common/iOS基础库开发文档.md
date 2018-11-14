# iOS基础库开发文档

## 介绍

直播云提供的SDK(播放、上传、localServer等)工作前，需要先初始化QHVCCommonKit，具体初始化接口请参考接口说明，使用方法可参考demo。

## 系统范围

| 系统特性 | 支持范围     |
| -------- | ------------ |
| 系统版本 | iOS8+        |
| 系统架构 | armv7、armv7s、arm64 |

## SDK集成

### 配置说明

1. 
	QHVCCommonKit.framework该库为动态库（Build Phases->Embed Frameworks-> +）

2. 实际开发中 `#import <QHVCCommonKit/QHVCCommonCoreEntry.h>`头文件调用相关接口。


## 接口说明

```

/**
 * 通知SDK app启动
 * 必须在app启动的第一时间调用，且在整个app生命周期只调用一次
 * @param businessId 业务ID
 * @param appVer 端版本
 * @param deviceId 机器id
 * @param model 型号
 */
+ (void)coreOnAppStart:(NSString *)businessId
                appVer:(NSString *)appVer
              deviceId:(NSString *)deviceId
                 model:(NSString *)model
        optionalParams:(const OptionalParams *)ops;


```

