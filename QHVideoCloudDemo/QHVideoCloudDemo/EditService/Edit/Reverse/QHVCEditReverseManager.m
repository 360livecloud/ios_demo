//
//  QHVCEditReverseManager.m
//  QHVideoCloudToolSet
//
//  Created by yinchaoyu on 2018/7/31.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditReverseManager.h"
//#import <QHVCEditKit/QHVCEditKit.h>
#import "QHVCLogger.h"
#import "QHVCFileManager.h"
#import "MBProgressHUD.h"
#import "QHVCEditPrefs.h"

@interface QHVCEditReverseManager() <QHVCEditReverseMakerDelegate>
{
    NSString *_reverseFilePath;
    NSInteger _fileIndex;
}

@property (nonatomic, strong) QHVCEditReverseMaker *maker;

@end

@implementation QHVCEditReverseManager

+ (instancetype)sharedInstance
{
    static QHVCEditReverseManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[QHVCEditReverseManager alloc] init];
    });
    return manager;
}

- (void)handle:(QHVCEditCommandAddFileSegment *)segment
{
    if (!self.maker) {
        self.maker = [[QHVCEditReverseMaker alloc] init];
    }

    NSString *tmpPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"reversetmp"];
    [QHVCFileManager createDirectoriesForPath:tmpPath];
    NSString *photoItemPath = [[[self class] getPhotoPath:segment.photoFileIdentifier] absoluteString];
    NSString *reverseFileName = [NSString stringWithFormat:@"%@%@", @"reverse_", [photoItemPath lastPathComponent]];
    NSString *reversePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:reverseFileName];
    [QHVCFileManager createDirectoriesForPath:tmpPath];
    
    _fileIndex = segment.fileIndex;
    _reverseFilePath = reversePath;
    
    self.maker.fileName = segment.filePath;
    self.maker.photoFileIdentifier = segment.photoFileIdentifier;
    self.maker.reverseFileName = _reverseFilePath;
    self.maker.tempFilePath =  tmpPath;
    self.maker.startMs = segment.startTimestampMs;
    self.maker.endMs = segment.endTimestampMs;
    self.maker.slowMotionVideoInfos = segment.slowMotionVideoInfos;
    self.maker.delegate = self;
    
    [self.maker makerStart];
    
    SAFE_BLOCK_IN_MAIN_QUEUE(self.handleStart);
}


#pragma mark - QHVCEditReverseMakerDelegate
- (void)onReverseMakerStatus:(QHVCEditReverseStatus)status
{
    switch (status) {
        case QHVCEditReverseStatus_Complete:
            [self.maker makerStop];
            [self free];
            SAFE_BLOCK_IN_MAIN_QUEUE(self.handleComplete, _fileIndex, _reverseFilePath);
            break;
            
        case QHVCEditReverseStatus_Processing:
            
            break;
            
        case QHVCEditReverseStatus_Cancel:
            break;
            
        case QHVCEditReverseStatus_Error:
            break;
            
        default:
            break;
    }
}

- (void)onReverseMakerProgress:(float)progress
{
    LogInfo(@"onReverseMakerProgress[%f]", progress);
    SAFE_BLOCK_IN_MAIN_QUEUE(self.handling, progress);
}

- (void)free
{
    [self.maker free];
    self.maker = nil;
}

- (void)freeManager{
    [self.maker makerStop];
    [self free];
}

#pragma mark -工具函数
//获取当前时间戳
+ (NSString *)currentTimeStr{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval time=[date timeIntervalSince1970]*1000;// *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}

+ (NSURL *)getPhotoPath:(NSString *)photoIdentifier
{
    PHFetchResult<PHAsset *> * results = [PHAsset fetchAssetsWithLocalIdentifiers:[NSArray arrayWithObject:photoIdentifier] options:nil];
    if (results == nil || [results count] == 0) {
        return nil;
    }
    PHAsset *phAsset = [results firstObject];
    NSArray *assetResources = [PHAssetResource assetResourcesForAsset:phAsset];
    PHAssetResource *resource = [assetResources firstObject];
    NSURL *filePath = [resource valueForKey:@"fileURL"];
    
    return filePath;
}

@end
