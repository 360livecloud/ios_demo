//
//  QHVCEditPhotoManage.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/12/22.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "QHVCEditPhotoItem.h"

@interface QHVCEditPhotoManager : NSObject

+ (instancetype)manager;

- (void)requestAuthorization:(void(^)(BOOL granted))completion;
- (void)fetchPhotos:(void(^)(NSArray<QHVCEditPhotoItem *> *photos,NSArray<PHAsset *> *caches))completion;

- (void)startImageCache:(NSArray *)photos targetSize:(CGSize)thumbSize;

- (void)fetchImageForAsset:(QHVCEditPhotoItem *)item options:(PHImageRequestOptions *)options completion:(void (^)(void))completion;

- (void)writeAssetsToSandbox:(NSArray<QHVCEditPhotoItem *> *)items complete:(void(^)())complete;
- (void)saveVideoToAlbum:(NSString *)sourcePath;

- (NSString *)videoTempDir;

@end
