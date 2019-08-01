//
//  QHVCEditTrackClipItem.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/6/26.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditTrackClipItem.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditMediaEditorConfig.h"
#import <QHVCEditKit/QHVCEditKit.h>

@implementation QHVCEditTrackClipItem

- (instancetype)initWithPhotoItem:(QHVCPhotoItem *)item
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    [self initialParams:item];
    return self;
}

- (void)initialParams:(QHVCPhotoItem *)item
{
    self.clipType = (QHVCEditTrackClipType)item.assetType;
    
    NSInteger duration = 0;
    if (item.fileIdentifier)
    {
        self.fileIdentifier = item.fileIdentifier;
        QHVCEditFileInfo* fileInfo = [QHVCEditTools getFileInfoWithIdentifier:self.fileIdentifier];
        duration = fileInfo.durationMs;
    }
    else
    {
        self.filePath = item.filePath;
        QHVCEditFileInfo* fileInfo = [QHVCEditTools getFileInfo:self.filePath];
        duration = fileInfo.durationMs;
    }
    
    self.durationMs = duration;
    self.thumbs = [[NSMutableArray alloc] initWithCapacity:0];
    
    if (self.clipType == QHVCEditTrackClipTypeImage)
    {
        self.durationMs = kImageFileDurationMS;
    }
    
    if (item.slowMotionInfo)
    {
        __block NSMutableArray<QHVCEditSlowMotionVideoInfo *>* slowMotionArray = [[NSMutableArray alloc] initWithCapacity:0];
        [item.slowMotionInfo enumerateObjectsUsingBlock:^(QHVCSlowMotionVideoInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
        {
            QHVCEditSlowMotionVideoInfo* info = [[QHVCEditSlowMotionVideoInfo alloc] init];
            info.startTime = obj.startTime;
            info.endTime = obj.endTime;
            info.speed = obj.speed;
            [slowMotionArray addObject:info];
        }];
        self.slowMotionInfo = slowMotionArray;
    }
}

@end
