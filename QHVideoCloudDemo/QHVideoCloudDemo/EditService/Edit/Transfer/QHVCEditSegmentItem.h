//
//  QHVCEditSegmentItem.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/2/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QHVCEditSegmentCell.h"
#import <QHVCEditKit/QHVCEditCommand.h>

@interface QHVCEditSegmentItem : NSObject

@property (nonatomic, strong) NSString* filePath;         //物理文件路径
@property (nonatomic, assign) NSInteger fileDuration;     //物理文件时长
@property (nonatomic, assign) NSInteger segmentStartTime; //片段开始时间点，相对物理文件
@property (nonatomic, assign) NSInteger segmentEndTime;   //片段结束时间点，相对物理文件
@property (nonatomic, strong) UIImage*  thumbnail; //缩略图
@property (nonatomic, assign) NSInteger transferIndex;
@property (nonatomic, strong) NSString* transferName;
@property (nonatomic, assign) NSInteger segmentIndex;
@property (nonatomic, strong) NSArray<QHVCEditSlowMotionVideoInfo *>* slowMotionVideoInfos;

@end
