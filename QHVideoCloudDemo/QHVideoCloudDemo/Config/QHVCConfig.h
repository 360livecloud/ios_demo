//
//  QHVCConfig.h
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2017/6/15.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define mark - 定义模块类型

#define QHVC_MODEL_PUSHSTREAM          @"pushStream"//推流
#define QHVC_MODEL_PLAYING             @"playing"//播放
#define QHVC_MODEL_INTERACTIVE         @"interactive"//互动直播
#define QHVC_MODEL_UPLOADING           @"uploading"//上传
#define QHVC_MODEL_VIDEOEDIT           @"videoEdit"//视频编辑
#define QHVC_MODEL_LOCALSERVER         @"localServer"//本地缓存服务器


#pragma mark - 定义服务器地址



#pragma mark - 定义属性变量

#define QHVC_ATT_ICON                                @"icon"
#define QHVC_ATT_NAME                                @"name"
#define QHVC_ATT_TYPE                                @"type"

#pragma mark - 定义互动直播公共变量

#pragma mark - 定义直播推流公共变量

#pragma mark - 定义播放器公共变量

#pragma mark - 定义本地存储公共变量

#pragma mark - 定义P2P公共变量

#pragma mark - 定义上传公共变量

#pragma mark - 定义视频编辑公共变量

#pragma mark - 定义IM公共变量

@interface QHVCConfig : NSObject

@end
