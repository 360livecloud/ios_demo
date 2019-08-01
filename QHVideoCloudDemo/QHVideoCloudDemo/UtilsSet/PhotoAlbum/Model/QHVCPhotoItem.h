//
//  QHVCEditPhotoItem.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/12/22.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "QHVCSlowMotionVideoInfo.h"

typedef NS_ENUM(NSUInteger, QHVCAssetType)
{
    QHVCAssetType_Video,
    QHVCAssetType_Audio,
    QHVCAssetType_Image,
};

@class QHVCEditThumbnailItem;
@interface QHVCPhotoItem : NSObject<NSMutableCopying>

- (instancetype)initWithAsset:(PHAsset *)asset;

@property (nonatomic, assign) BOOL isSelected;              //是否为选中状态
@property (nonatomic, assign) QHVCAssetType assetType;      //asset类型
@property (nonatomic, strong) PHAsset* asset;               //相册读取的asset
@property (nonatomic, assign) BOOL assetPlayable;           //asset是否可播
@property (nonatomic, assign) NSInteger assetWidth;         //asset宽度
@property (nonatomic, assign) NSInteger assetHeight;        //asset高度
@property (nonatomic, strong) UIImage* thumbImage;          //asset缩略图
@property (nonatomic, assign) CGSize thumbImageCacheSize;   //asset缩略图尺寸
@property (nonatomic, assign) BOOL isLocalFile;             //是否是本地文件，反之云端文件
@property (nonatomic, strong) NSString* fileIdentifier;     //相册唯一标识
@property (nonatomic, strong) NSString* filePath;           //存储至沙盒的路径
@property (nonatomic, assign) NSInteger assetDurationMs;    //物理文件时长(单位：毫秒)
@property (nonatomic, assign) NSInteger photoIndex;          //用于排序的索引
@property (nonatomic, strong) NSArray<QHVCSlowMotionVideoInfo *>* slowMotionInfo; //慢视频信息

@end
