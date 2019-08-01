//
//  QHVCGVRecordFileManager.h
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/10/31.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^QHVCGVWatchRecordFileSaveHandler)(BOOL isSuccess,NSError *_Nullable error);

@interface QHVCGVWatchRecordFileManager : NSObject

+ (instancetype)sharedManager;

/*
 * 录制文件存放的临时目录
 */
+ (NSString *)recordFileDirectory;

///**
// * 清除所有视频文件
// * 每个文件成功保存到相册后，会从缓存中删除，但异常情况时 会残留下来，比如保存相册的过程中，杀死app。
// */
//+ (void)cleanRecordFiles;
//
///**
// * 保存视频到相册
// */
//- (void)saveVideoToAlbum:(NSString *)videoPath completion:(QHVCGVWatchRecordFileSaveHandler)completion;
//
/**
 * 保存图片到相册
 */
- (void)saveImageToAlbum:(UIImage *)image completion:(QHVCGVWatchRecordFileSaveHandler)completion;



@end

NS_ASSUME_NONNULL_END
