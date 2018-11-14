//
//  QHVCEditPhotoItem.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/12/22.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <QHVCEditKit/QHVCEditCommand.h>

@class QHVCEditThumbnailItem;
@interface QHVCEditPhotoItem : NSObject<NSMutableCopying>

@property (nonatomic, strong) UIImage *thumbImage;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) NSDictionary *info;
@property (nonatomic, assign) CGSize thumbImageCacheSize;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString* photoFileIdentifier;   //相册中的文件标识符，用于直接从相册读取数据的场景
@property (nonatomic, strong) NSArray<QHVCEditSlowMotionVideoInfo *>* slowMotionVideoInfos;

@property (nonatomic, strong) NSMutableArray<QHVCEditThumbnailItem *> *thumbs;
@property (nonatomic, assign) NSTimeInterval startMs;
@property (nonatomic, assign) NSTimeInterval endMs;
@property (nonatomic, assign) NSTimeInterval lastStartMs;
@property (nonatomic, assign) NSTimeInterval lastEndMs;
@property (nonatomic, assign) NSInteger sortIndex;
@property (nonatomic, assign) NSTimeInterval durationMs;

@end
