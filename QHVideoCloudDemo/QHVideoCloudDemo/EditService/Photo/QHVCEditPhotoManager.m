//
//  QHVCEditPhotoManage.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/12/22.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCEditPhotoManager.h"
#import "QHVCEditPrefs.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <QHVCEditKit/QHVCEditKit.h>

@interface  QHVCEditPhotoManager()<UIAlertViewDelegate>
{
    PHCachingImageManager *_cacheImageManager;
}
@end

static QHVCEditPhotoManager *singleInstance = nil;

@implementation QHVCEditPhotoManager

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

- (void)startImageCache:(NSArray *)photos targetSize:(CGSize)thumbSize
{
    [_cacheImageManager startCachingImagesForAssets:photos targetSize:thumbSize contentMode:PHImageContentModeAspectFill options:nil];
}

- (void)stopImageCache:(NSArray *)photos targetSize:(CGSize)thumbSize
{
    [_cacheImageManager stopCachingImagesForAssets:photos targetSize:thumbSize contentMode:PHImageContentModeAspectFill options:nil];
}

- (void)fetchPhotos:(void(^)(NSArray<QHVCEditPhotoItem *> *photos,NSArray<PHAsset *> *caches))completion
{
    PHFetchResult* albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [albums enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         PHAssetCollection* collection = obj;
         if ([collection.localizedTitle isEqualToString:@"相机胶卷"] ||
             [collection.localizedTitle isEqualToString:@"Camera Roll"] ||
             [collection.localizedTitle isEqualToString:@"All Photos"]||
             [collection.localizedTitle isEqualToString:@"所有照片"])
         {
             NSMutableArray *photos = [NSMutableArray array];
             NSMutableArray *caches = [NSMutableArray array];
             
             PHFetchOptions* option = [[PHFetchOptions alloc] init];
             option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
             PHFetchResult<PHAsset *>* assets = [PHAsset fetchAssetsInAssetCollection:collection options:option];
             [assets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
              {
                  PHAsset* asset = obj;
                  QHVCEditPhotoItem *item = [[QHVCEditPhotoItem alloc]init];
                  item.asset = asset;
                  item.startMs = 0;
                  item.endMs = (item.asset.mediaType == PHAssetMediaTypeImage) ? kImageFileDurationMS:item.asset.duration*1000.0;
                  item.lastStartMs = item.startMs;
                  item.lastEndMs = item.endMs;
                  item.durationMs = item.endMs;
                  [photos addObject:item];
                  [caches addObject:asset];
              }];
             if (completion) {
                 completion(photos,caches);
             }
         }
     }];
}

- (void)fetchImageForAsset:(QHVCEditPhotoItem *)item options:(nullable PHImageRequestOptions *)options completion:(void (^)(void))completion
{
    [_cacheImageManager requestImageForAsset:item.asset
                                        targetSize:item.thumbImageCacheSize
                                       contentMode:PHImageContentModeAspectFill
                                           options:nil
                                     resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info)
     {
         item.thumbImage = result;
         item.info = info;
         if (completion) {
             completion();
         }
     }];
}

- (void)writeAssetsToSandbox:(NSArray<QHVCEditPhotoItem *> *)items complete:(void(^)())complete
{
   NSString *cacheDir = [self assetCacheDir];
    if (!cacheDir) {
        return;
    }
    
    dispatch_group_t group = dispatch_group_create();
    NSInteger i = 0;
    for (QHVCEditPhotoItem *item in items) {
        
        dispatch_group_enter(group);
        
        item.sortIndex = i;
        i++;
        if (item.filePath)
        {
            dispatch_group_leave(group);
            continue;
        }
        
        NSString *version = [UIDevice currentDevice].systemVersion;
        if (version.doubleValue >= 9.0)
        {
            PHAssetResource * resource = [[PHAssetResource assetResourcesForAsset:item.asset] firstObject];
            NSString *idenfifier = resource.assetLocalIdentifier;
            item.photoFileIdentifier = idenfifier;
            
            //test getfileinfo
            [QHVCEditGetFileInfo getPhotoFileInfo:idenfifier];

            if (item.asset.mediaType == PHAssetMediaTypeVideo)
            {
                dispatch_group_enter(group);
                [self getFileOriginSpeed:item.asset complete:^(NSArray<QHVCEditSlowMotionVideoInfo *> *infos, CGFloat fileDuration)
                 {
                     item.slowMotionVideoInfos = infos;
                     item.endMs = fileDuration;
                     dispatch_group_leave(group);
                 }];;
            }
            dispatch_group_leave(group);
        }
        else
        {
            if (item.asset.mediaType == PHAssetMediaTypeImage)
            {
                [[PHImageManager defaultManager] requestImageDataForAsset:item.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info)
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
                [[PHImageManager defaultManager] requestAVAssetForVideo:item.asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info)
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

- (void)getFileOriginSpeed:(PHAsset *)asset complete:(void(^)(NSArray<QHVCEditSlowMotionVideoInfo *>* infos, CGFloat fileDuration))complete
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

- (int64_t)slowMotionDuration:(NSArray<QHVCEditSlowMotionVideoInfo *>*) slowMotionInfos {
    int64_t duration = 0;
    for (QHVCEditSlowMotionVideoInfo *info in slowMotionInfos) {
        duration += (info.endTimeMs - info.startTimeMs) / info.speed;
    }
    return duration;
}


- (NSArray<QHVCEditSlowMotionVideoInfo *>*)slowMotionInfoFromSegements:(NSArray <AVCompositionTrackSegment *> *)segments
{
    NSMutableArray *infos = [[NSMutableArray alloc] init];
    int multiplier = 6;     // 用于判断是否进入了慢速区间，按理说慢速区间的时长是正常时长的 8 倍。但直接乘 8 比较不准这里用个小于 8 的数来判断。
    
    __block NSInteger curveStartTime = 0;
    __block NSInteger curveSourceDuration = 0;
    __block NSInteger curveTargetDuration = 0;;
    
    void (^clearPreviousCurve)(void) = ^ {
        if (curveSourceDuration > 0) {
            QHVCEditSlowMotionVideoInfo *info = [[QHVCEditSlowMotionVideoInfo alloc] init];
            info.startTimeMs = curveStartTime;
            info.endTimeMs = curveStartTime + curveSourceDuration;
            info.speed = (double)curveSourceDuration / (double)curveTargetDuration;
            [infos addObject:info];
            
            curveStartTime = info.endTimeMs;
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
            
            QHVCEditSlowMotionVideoInfo *info = [[QHVCEditSlowMotionVideoInfo alloc] init];
            info.startTimeMs = curveStartTime;
            info.endTimeMs = info.startTimeMs + sourceDuration;
            info.speed = 1;
            [infos addObject:info];
            curveStartTime = info.endTimeMs;
            
            continue;
        }
        if (sourceDuration < targetDuration && sourceDuration * multiplier > targetDuration) {
            curveSourceDuration += sourceDuration;
            curveTargetDuration += targetDuration;
        } else if (targetDuration > sourceDuration * multiplier) {
            clearPreviousCurve();
            
            // 慢速区间
            QHVCEditSlowMotionVideoInfo *info = [[QHVCEditSlowMotionVideoInfo alloc] init];
            info.startTimeMs = curveStartTime;
            info.endTimeMs = info.startTimeMs + sourceDuration;
            info.speed = (double)sourceDuration / (double)targetDuration;
            [infos addObject:info];
            curveStartTime = info.endTimeMs;
        }
    }
    return infos;
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

- (NSString *)videoTempDir
{
    NSString *videoFilePath = [NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(),@"video"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:videoFilePath isDirectory:nil])
    {
        BOOL isSucess = [[NSFileManager defaultManager] createDirectoryAtPath:videoFilePath withIntermediateDirectories:YES attributes:nil error:nil];
        if (!isSucess) {
            return nil;
        }
    }
    return videoFilePath;
}

- (void)saveVideoToAlbum:(NSString *)sourcePath
{
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(sourcePath)) {

        UISaveVideoAtPathToSavedPhotosAlbum(sourcePath, self,
                                            @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo {
    NSLog(@"saveVideoToAlbum done");
}

#pragma mark - 相册授权
- (BOOL)isPhotoAuthorized {
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        return YES;
    }
    return NO;
}

- (void)requestAuthorization:(void(^)(BOOL granted))completion {
    if (![self isPhotoAuthorized]) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status != PHAuthorizationStatusAuthorized) {
                    [self showAlert];
                    completion(NO);
                }
                else {
                    completion(YES);
                }
            });
        }];
    }
    else {
        completion(YES);
    }
}

- (void)showAlert {
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"需要访问你的相册" message:@"请授权相册访问权限" delegate:self cancelButtonTitle:@"设置" otherButtonTitles:@"取消", nil];
    [alert show];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

@end
