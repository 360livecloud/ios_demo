//
//  QHVCEditPhotoManage.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/12/22.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "QHVCPhotoItem.h"

typedef void(^QHVCPhotoSaveToAlbumComplete)(BOOL success, NSError* error);

@interface QHVCPhotoManager : NSObject

+ (instancetype)manager;

//申请权限
- (void)requestAuthorization:(void(^)(BOOL granted))completion;

//返回相册所有对象
- (void)fetchAllItems:(void(^)(NSArray<QHVCPhotoItem *>* items, NSArray<PHAsset *>* caches))dataBlock;

//返回相册所有视频
- (void)fetchAllVideos:(void(^)(NSArray<QHVCPhotoItem *>* items, NSArray<PHAsset *>* caches))dataBlock;

//返回相册所有图片
- (void)fetchAllPhotos:(void(^)(NSArray<QHVCPhotoItem *>* items, NSArray<PHAsset *>* caches))dataBlock;

//缓存图片
- (void)cacheImageForAssets:(NSArray<PHAsset *> *)assets targetSize:(CGSize)thumbSize;
- (void)stopImageCacheForAssets:(NSArray<PHAsset *> *)photos targetSize:(CGSize)thumbSize;

//获取asset缩略图
- (void)fetchImageForAsset:(QHVCPhotoItem *)item options:(PHImageRequestOptions *)options completion:(void (^)(void))completion;

//从icloud下载素材
- (void)fetchCloudAsset:(QHVCPhotoItem *)item completion:(void (^)(void))completion;

//从相册存入沙盒
- (void)writeAssetsToSandbox:(NSArray<QHVCPhotoItem *> *)items complete:(void(^)(void))complete;

//添加相册唯一标识
- (void)addAssetIdentifier:(NSArray<QHVCPhotoItem *> *)items;

//视频保存至相册
- (void)saveVideoToAlbum:(NSString *)sourcePath complete:(QHVCPhotoSaveToAlbumComplete)complete;

@end
