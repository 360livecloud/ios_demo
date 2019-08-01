//
//  QHVCEditTrackClipItem.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/6/26.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QHVCPhotoItem.h"
#import <QHVCEditKit/QHVCEditKit.h>

@interface QHVCEditTrackClipItem : NSObject

- (instancetype)initWithPhotoItem:(QHVCPhotoItem *)item;

//文件信息
@property (nonatomic, assign) QHVCEditTrackClipType clipType; //素材类型
@property (nonatomic, strong) NSString* filePath;        //素材物理路径
@property (nonatomic, strong) NSString* fileIdentifier;  //素材相册唯一标识
@property (nonatomic, assign) NSTimeInterval  startMs;   //clip开始时间
@property (nonatomic, assign) NSTimeInterval  endMs;     //clip结束时间
@property (nonatomic, assign) NSInteger durationMs;      //素材原始时长(单位：毫秒)
@property (nonatomic, strong) NSArray<QHVCEditSlowMotionVideoInfo *>* slowMotionInfo; //慢视频信息
@property (nonatomic, assign) NSInteger volume; //音量

//画中画轨道
@property (nonatomic, assign) NSInteger insertMs;        //相对于timeline的时间

//缩略图
@property (nonatomic, strong) NSMutableArray<QHVCEditThumbnailItem *> *thumbs;  //缩略图数组
@property (nonatomic, strong) UIImage*  thumbnail; //封面图

//clip属性
@property (nonatomic, assign) NSInteger clipIndex;
@property (nonatomic, strong) QHVCEditTrackClip* clip;

//转场
@property (nonatomic, assign) BOOL hasTransition;
@property (nonatomic, strong) NSString* transitionName;

@end
