//
//  QHVCEditPhotoItem.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/12/22.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCPhotoItem.h"
#import <AVFoundation/AVFoundation.h>

@implementation QHVCPhotoItem

- (instancetype)initWithAsset:(PHAsset *)asset
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    self.asset = asset;
    [self initialParams];
    return self;
}

- (void)initialParams
{
    //asset类型
    if (self.asset.mediaType == PHAssetMediaTypeVideo)
    {
        self.assetType = QHVCAssetType_Video;
    }
    else if (self.asset.mediaType == PHAssetMediaTypeAudio)
    {
        self.assetType = QHVCAssetType_Audio;
    }
    else if (self.asset.mediaType == PHAssetMediaTypeImage)
    {
        self.assetType = QHVCAssetType_Image;
    }
    
    //默认为本地文件
    self.isLocalFile = YES;
    self.assetPlayable = YES;
    
    //asset时长
    self.assetDurationMs = self.asset.duration * NSEC_PER_USEC;
    self.assetWidth = self.asset.pixelWidth;
    self.assetHeight = self.asset.pixelHeight;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    return nil;
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone
{
    return nil;
}

@end
