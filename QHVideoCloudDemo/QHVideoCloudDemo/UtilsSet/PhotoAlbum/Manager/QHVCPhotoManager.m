//
//  QHVCEditPhotoManage.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/12/22.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCPhotoManager.h"
#import "QHVCEditPrefs.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "QHVCSlowMotionVideoInfo.h"

@interface  QHVCPhotoManager() <UIAlertViewDelegate>
{
    PHCachingImageManager *_cacheImageManager;
    QHVCPhotoSaveToAlbumComplete _saveToAlbumComplete;
}
@end

static QHVCPhotoManager *singleInstance = nil;

@implementation QHVCPhotoManager

+ (instancetype)manager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleInstance = [[self alloc] init];
    });
    return singleInstance;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        _cacheImageManager = [[PHCachingImageManager alloc] init];
    }
    return self;
}

#pragma mark - 相册授权

- (void)requestAuthorization:(void(^)(BOOL granted))completion
{
    if (![self isPhotoAuthorized])
    {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (status != PHAuthorizationStatusAuthorized)
                 {
                     [self showAlert];
                     completion(NO);
                 }
                 else
                 {
                     completion(YES);
                 }
             });
         }];
    }
    else
    {
        completion(YES);
    }
}

- (BOOL)isPhotoAuthorized
{
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized)
    {
        return YES;
    }
    return NO;
}

- (void)showAlert {
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"需要访问你的相册" message:@"请授权相册访问权限" delegate:self cancelButtonTitle:@"设置" otherButtonTitles:@"取消", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

#pragma mark - 返回相册所有对象

- (void)fetchAllItems:(NSInteger)itemType complete:(void (^)(NSArray<QHVCPhotoItem *>* items, NSArray<PHAsset *>* caches))dataBlock
{
    //0:所有；1:视频；2:图片；
    PHFetchResult* albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [albums enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         PHAssetCollection* collection = obj;
         if ([collection.localizedTitle isEqualToString:@"相机胶卷"] ||
             [collection.localizedTitle isEqualToString:@"Camera Roll"] ||
             [collection.localizedTitle isEqualToString:@"All Photos"]||
             [collection.localizedTitle isEqualToString:@"所有照片"])
         {
             PHFetchOptions* option = [[PHFetchOptions alloc] init];
             PHFetchResult<PHAsset *>* assets = [PHAsset fetchAssetsInAssetCollection:collection options:option];
             NSMutableArray* itemArray = [[NSMutableArray alloc] initWithCapacity:0];
             NSMutableArray* cacheArray = [[NSMutableArray alloc] initWithCapacity:0];
             
             [assets enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
              {
                  BOOL add = NO;
                  PHAsset *asset = obj;
                  
                  switch (itemType)
                  {
                      case 0:
                      {
                          add = YES;
                          break;
                      }
                      case 1:
                      {
                          if (asset.mediaType != PHAssetMediaTypeImage)
                          {
                              add = YES;
                          }
                          break;
                      }
                      case 2:
                      {
                          if (asset.mediaType == PHAssetMediaTypeImage)
                          {
                              add = YES;
                          }
                          break;
                      }
                      default:
                          break;
                  }
                 
                  if (add)
                  {
                     QHVCPhotoItem *item = [[QHVCPhotoItem alloc] initWithAsset:asset];
                     [itemArray addObject:item];
                     [cacheArray addObject:asset];
                  }
                  
              }];
             
             SAFE_BLOCK(dataBlock, itemArray, cacheArray);
             *stop = YES;
         }
     }];
}

- (void)fetchAllItems:(void (^)(NSArray<QHVCPhotoItem *>* items, NSArray<PHAsset *>* caches))dataBlock
{
    [self fetchAllItems:0 complete:dataBlock];
}

- (void)fetchAllVideos:(void (^)(NSArray<QHVCPhotoItem *> *, NSArray<PHAsset *> *))dataBlock
{
    [self fetchAllItems:1 complete:dataBlock];
}

- (void)fetchAllPhotos:(void (^)(NSArray<QHVCPhotoItem *> *, NSArray<PHAsset *> *))dataBlock
{
    [self fetchAllItems:2 complete:dataBlock];
}

#pragma mark - 缓存图片

- (void)cacheImageForAssets:(NSArray<PHAsset *> *)assets targetSize:(CGSize)thumbSize
{
    [_cacheImageManager startCachingImagesForAssets:assets targetSize:thumbSize contentMode:PHImageContentModeAspectFill options:nil];
}

- (void)stopImageCacheForAssets:(NSArray<PHAsset *> *)photos targetSize:(CGSize)thumbSize
{
    [_cacheImageManager stopCachingImagesForAssets:photos targetSize:thumbSize contentMode:PHImageContentModeAspectFill options:nil];
}

#pragma mark - 获取asset缩略图

- (void)fetchImageForAsset:(QHVCPhotoItem *)item options:(nullable PHImageRequestOptions *)options completion:(void (^)(void))completion
{
    [_cacheImageManager requestImageForAsset:item.asset
                                        targetSize:item.thumbImageCacheSize
                                       contentMode:PHImageContentModeAspectFill
                                           options:options
                                     resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info)
     {
         item.thumbImage = result;

         if (completion) {
             completion();
         }
     }];
}

#pragma mark - 从icloud下载资源

- (void)fetchCloudAsset:(QHVCPhotoItem *)item completion:(void (^)(void))completion
{
    if (item.asset.mediaType == PHAssetMediaTypeImage)
    {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.networkAccessAllowed = YES;
        
        [_cacheImageManager requestImageDataForAsset:item.asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info)
        {
            SAFE_BLOCK(completion);
        }];
    }
    else
    {
        PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionCurrent;
        options.networkAccessAllowed = YES;
        
        [_cacheImageManager requestAVAssetForVideo:item.asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info)
        {
            if (!asset)
            {
                item.assetPlayable = NO;
            }
            SAFE_BLOCK(completion);
        }];
    }
    
}

#pragma mark - 从相册存入沙盒

- (void)writeAssetsToSandbox:(NSArray<QHVCPhotoItem *> *)items complete:(void(^)(void))complete
{
   NSString *cacheDir = [self assetCacheDir];
    if (!cacheDir) {
        return;
    }
    
    dispatch_group_t group = dispatch_group_create();
    NSInteger i = 0;
    for (QHVCPhotoItem *item in items) {
        
        dispatch_group_enter(group);
        item.fileIdentifier = nil;
        item.photoIndex = i;
        i++;
        if (item.filePath || !item.isLocalFile)
        {
            dispatch_group_leave(group);
            continue;
        }
        
        if (@available(iOS 9.0, *))
        {
            PHAssetResource * resource = [[PHAssetResource assetResourcesForAsset:item.asset] firstObject];
            NSString *path = [cacheDir stringByAppendingPathComponent:resource.originalFilename];
            item.filePath = path;
            
            if (item.asset.mediaType == PHAssetMediaTypeVideo)
            {
                dispatch_group_enter(group);
                [self getSlowMotionInfo:item.asset complete:^(NSArray<QHVCSlowMotionVideoInfo *> *infos, CGFloat fileDuration)
                 {
                     item.slowMotionInfo = infos;
                     item.assetDurationMs = fileDuration;
                     dispatch_group_leave(group);
                 }];;
            }
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:path])
            {
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            }
            
            [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource toFile:[NSURL fileURLWithPath:path] options:nil completionHandler:^(NSError * _Nullable error) {
                if (error)
                {
                    NSLog(@"writeDataForAssetResource fail %@",[NSThread currentThread].name);
                }
                dispatch_group_leave(group);
            }];
        }
        else
        {
            if (item.asset.mediaType == PHAssetMediaTypeImage)
            {
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
                options.networkAccessAllowed = YES;
                options.resizeMode = PHImageRequestOptionsResizeModeFast;
                
                [[PHImageManager defaultManager] requestImageDataForAsset:item.asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info)
                {
                    NSURL* fileUrl = [info valueForKey:@"PHImageFileURLKey"];
                    NSString* fileName = [fileUrl lastPathComponent];
                    NSString *path = [cacheDir stringByAppendingPathComponent:fileName];
                    [imageData writeToFile:path atomically:YES];
                    item.filePath = path;
                    dispatch_group_leave(group);
                }];
            }
            else
            {
                PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
                options.version = PHVideoRequestOptionsVersionOriginal;
                options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
                options.networkAccessAllowed = YES;
                
                [[PHImageManager defaultManager] requestAVAssetForVideo:item.asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info)
                {
                    AVURLAsset* urlAsset = (AVURLAsset *)asset;
                    NSURL *url = urlAsset.URL;
                    NSString* fileName = [url lastPathComponent];
                    NSString *path = [cacheDir stringByAppendingPathComponent:fileName];
                    NSData* data = [NSData dataWithContentsOfURL:url];
                    [data writeToFile:path atomically:YES];
                    item.filePath = path;
                    dispatch_group_leave(group);
                }];
            }
        }
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        SAFE_BLOCK(complete);
    });
}

- (void)addAssetIdentifier:(NSArray<QHVCPhotoItem *> *)items
{
    if (@available(iOS 9.0, *))
    {
        [items enumerateObjectsUsingBlock:^(QHVCPhotoItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
         {
             if (obj.isLocalFile)
             {
                 PHAssetResource * resource = [[PHAssetResource assetResourcesForAsset:obj.asset] firstObject];
                 NSString *idenfifier = resource.assetLocalIdentifier;
                 obj.fileIdentifier = idenfifier;
                 obj.filePath = nil;
                 
                 //添加慢视频信息
                 if (obj.asset.mediaType == PHAssetMediaTypeVideo)
                 {
                     dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                     [self getSlowMotionInfo:obj.asset complete:^(NSArray<QHVCSlowMotionVideoInfo *> *infos, CGFloat fileDuration)
                      {
                          obj.slowMotionInfo = infos;
                          obj.assetDurationMs = fileDuration;
                          dispatch_semaphore_signal(semaphore);
                      }];
                     dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                 }
             }
         }];
    }
}

- (void)getSlowMotionInfo:(PHAsset *)asset complete:(void(^)(NSArray<QHVCSlowMotionVideoInfo *>* infos, CGFloat fileDuration))complete
{
    __block NSArray* infos = nil;
    __block CGFloat duration = asset.duration * 1000;
    if (asset.mediaType != PHAssetMediaTypeVideo)
    {
        SAFE_BLOCK(complete, infos, duration);
        return;
    }
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info)
     {
         if ([asset isKindOfClass:[AVComposition class]])
         {
             AVComposition *composition = (AVComposition *)asset;
             NSArray<AVCompositionTrack *>* tracks = [composition tracksWithMediaType:AVMediaTypeVideo];
             for (AVCompositionTrack *track in tracks)
             {
//                 AVCompositionTrackSegment* lastSegment = [track.segments lastObject];
//                 duration = CMTimeGetSeconds(lastSegment.timeMapping.target.start) * NSEC_PER_USEC + CMTimeGetSeconds(lastSegment.timeMapping.target.duration) * NSEC_PER_USEC;
                 infos = [self slowMotionInfoFromSegements:track.segments];
                 duration = [self slowMotionDuration:infos];
             }
         }
         SAFE_BLOCK(complete, infos, duration);
    }];
}

- (NSArray<QHVCSlowMotionVideoInfo *>*)slowMotionInfoFromSegements:(NSArray <AVCompositionTrackSegment *> *)segments
{
    NSMutableArray *infos = [[NSMutableArray alloc] init];
    int multiplier = 6;     // 用于判断是否进入了慢速区间，按理说慢速区间的时长是正常时长的 8 倍。但直接乘 8 比较不准这里用个小于 8 的数来判断。
    
    __block NSInteger curveStartTime = 0;
    __block NSInteger curveSourceDuration = 0;
    __block NSInteger curveTargetDuration = 0;;
    
    void (^clearPreviousCurve)(void) = ^ {
        if (curveSourceDuration > 0) {
            QHVCSlowMotionVideoInfo *info = [[QHVCSlowMotionVideoInfo alloc] init];
            info.startTime = curveStartTime;
            info.endTime = curveStartTime + curveSourceDuration;
            info.speed = (double)curveSourceDuration / (double)curveTargetDuration;
            [infos addObject:info];
            
            curveStartTime = info.endTime;
            curveSourceDuration = 0;
            curveTargetDuration = 0;
        }
    };
    
    for (AVCompositionTrackSegment *segment in segments) {
        int64_t sourceDuration = CMTimeGetSeconds(segment.timeMapping.source.duration) * NSEC_PER_USEC;
        int64_t targetDuration = CMTimeGetSeconds(segment.timeMapping.target.duration) * NSEC_PER_USEC;
        if (!sourceDuration || !targetDuration) {
            // 发现素材中有片段时长为 0 的情况
            continue;
        }
        if (sourceDuration == targetDuration) {
            // 开始和结束正常速度区间
            // 有变速区间还没有处理，处理完变速区间信息后加入到 infos 中
            clearPreviousCurve();
            
            QHVCSlowMotionVideoInfo *info = [[QHVCSlowMotionVideoInfo alloc] init];
            info.startTime = curveStartTime;
            info.endTime = info.startTime + sourceDuration;
            info.speed = 1;
            [infos addObject:info];
            curveStartTime = info.endTime;
            
            continue;
        }
        if (sourceDuration < targetDuration && sourceDuration * multiplier > targetDuration) {
            curveSourceDuration += sourceDuration;
            curveTargetDuration += targetDuration;
        } else if (targetDuration > sourceDuration * multiplier) {
            clearPreviousCurve();
            
            // 慢速区间
            QHVCSlowMotionVideoInfo *info = [[QHVCSlowMotionVideoInfo alloc] init];
            info.startTime = curveStartTime;
            info.endTime = info.startTime + sourceDuration;
            info.speed = (double)sourceDuration / (double)targetDuration;
            [infos addObject:info];
            curveStartTime = info.endTime;
        }
    }
    
    return infos;
}

- (int64_t)slowMotionDuration:(NSArray<QHVCEditSlowMotionVideoInfo *>*) slowMotionInfos {
    int64_t duration = 0;
    for (QHVCEditSlowMotionVideoInfo *info in slowMotionInfos) {
        duration += (info.endTime - info.startTime) / info.speed;
    }
    return duration;
}

- (NSString *)assetCacheDir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    NSString *assetFilePath = [NSString stringWithFormat:@"%@/%@",cachesDir,@"photo"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:assetFilePath isDirectory:nil])
    {
        BOOL isSucess = [[NSFileManager defaultManager] createDirectoryAtPath:assetFilePath withIntermediateDirectories:YES attributes:nil error:nil];
        if (!isSucess) {
            return nil;
        }
    }
    return assetFilePath;
}

#pragma mark - 视频保存至相册

- (void)saveVideoToAlbum:(NSString *)sourcePath complete:(QHVCPhotoSaveToAlbumComplete)complete
{
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(sourcePath))
    {

        UISaveVideoAtPathToSavedPhotosAlbum(sourcePath, self,
                                            @selector(video:didFinishSavingWithError:contextInfo:), nil);
        _saveToAlbumComplete = complete;
    }
    else
    {
        if (complete)
        {
            complete(NO, nil);
        }
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo
{
    if (_saveToAlbumComplete)
    {
        BOOL success = error ? NO:YES;
        _saveToAlbumComplete(success, error);
    }
}

@end
