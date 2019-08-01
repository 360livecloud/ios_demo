//
//  QHVCGVRecordFileManager.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/10/31.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCGVWatchRecordFileManager.h"
#import "QHVCGVConfig.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "QHVCLogger.h"

@interface QHVCGVWatchRecordFileManager()
@property (nonatomic,copy) QHVCGVWatchRecordFileSaveHandler saveImageCompletion;
@property (nonatomic,copy) QHVCGVWatchRecordFileSaveHandler saveVideoCompletion;
@end

@implementation QHVCGVWatchRecordFileManager

+ (instancetype)sharedManager {
    static QHVCGVWatchRecordFileManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [QHVCGVWatchRecordFileManager new];
    });
    return instance;
}

+ (NSString *)recordFileDirectory {
    NSString *directory = [NSTemporaryDirectory() stringByAppendingPathComponent:QHVCGV_GODVIEW_RECORD_FILE_DIRECTORY];
    if (![[NSFileManager defaultManager] fileExistsAtPath:directory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return directory;
}


+ (void)cleanRecordFiles {
    
}

- (void)removeFilePath:(NSString *)filePath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}



- (void)saveVideoToAlbum:(NSString *)videoPath completion:(QHVCGVWatchRecordFileSaveHandler)completion {
    if(videoPath == nil || ![[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
        completion(NO,nil);
        return;
    }
    self.saveVideoCompletion = completion;
    if ([QHVCGVWatchRecordFileManager photoPermission]) {
        [self saveVideo:videoPath];
        return;
    }
    
    [QHVCGVWatchRecordFileManager requestPhotoPermissionWithResult:^(BOOL granted) {
        if (granted == NO) {
            [QHVCGVWatchRecordFileManager showPermissionAlert];
            if (completion) {
                completion(NO, nil);
            }
        }
        else {
            [self saveVideo:videoPath];
        }
    }];
}

- (void)saveImageToAlbum:(UIImage *)image completion:(QHVCGVWatchRecordFileSaveHandler)completion {
    self.saveImageCompletion = completion;
    if ([QHVCGVWatchRecordFileManager photoPermission]) {
        [self saveImage:image];
        return;
    }
    [QHVCGVWatchRecordFileManager requestPhotoPermissionWithResult:^(BOOL granted) {
        if (granted == NO) {
            [QHVCGVWatchRecordFileManager showPermissionAlert];
            if (completion) {
                completion(NO, nil);
            }
        }
        else {
            [self saveImage:image];
        }
    }];
}

/**
 * 保存图片
 */
- (void)saveImage:(UIImage *)image {
    if (image) {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
    }
    else if (self.saveVideoCompletion) {
        self.saveVideoCompletion(NO, nil);
    }
}
/**
 * 图片保存完成后调用的方法
 */
- (void) savedPhotoImage:(UIImage*)image didFinishSavingWithError: (NSError *)error contextInfo: (void *)contextInfo {
    if (error) {
        [QHVCLogger printLogger:QHVC_LOG_LEVEL_ERROR content:[NSString stringWithFormat:@"保存图片出错%@", error.localizedDescription]];
        if (self.saveImageCompletion) {
            self.saveImageCompletion(NO, error);
        }
    }
    else {
        [QHVCLogger printLogger:QHVC_LOG_LEVEL_INFO content:@"保存图片成功"];
        if (self.saveImageCompletion) {
            self.saveImageCompletion(YES, nil);
        }
    }
}

/**
 * 保存视频
 */
- (void)saveVideo:(NSString *)videoPath {
    if (videoPath) {
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoPath)) {
            UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
        if (self.saveVideoCompletion) {
            self.saveVideoCompletion(NO, nil);
        }
    }
    else if (self.saveVideoCompletion) {
        self.saveVideoCompletion(NO, nil);
    }
}

/**
 * 保存视频完成之后的回调
 */
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        [QHVCLogger printLogger:QHVC_LOG_LEVEL_ERROR content:[NSString stringWithFormat:@"保存视频失败%@", error.localizedDescription]];
        if (self.saveVideoCompletion) {
            self.saveImageCompletion(NO, error);
        }
    }
    else {
        [QHVCLogger printLogger:QHVC_LOG_LEVEL_INFO content:@"保存视频成功"];
        if (self.saveVideoCompletion) {
            self.saveVideoCompletion(YES, nil);
        }
        [self removeFilePath:videoPath];
    }
}

#pragma mark - 相册权限
+ (BOOL)photoPermission
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
    {
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if ( author == ALAuthorizationStatusAuthorized ) {
            return YES;
        }
        return NO;
    }
    
    PHAuthorizationStatus authorStatus = [PHPhotoLibrary authorizationStatus];
    if ( authorStatus == PHAuthorizationStatusAuthorized ) {
        return YES;
    }
    return NO;
}


+ (void)requestPhotoPermissionWithResult:(void(^)( BOOL granted))completion
{
    //获取相册访问权限
    PHAuthorizationStatus photoStatus = [PHPhotoLibrary authorizationStatus];
    switch (photoStatus) {
        case PHAuthorizationStatusAuthorized:
            completion(YES);
            break;
        case PHAuthorizationStatusDenied:
        case PHAuthorizationStatusRestricted:
            completion(NO);
            break;
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    switch (status) {
                        case PHAuthorizationStatusAuthorized: //已获取权限
                            completion(YES);
                            break;
                        case PHAuthorizationStatusDenied: //用户已经明确否认了这一照片数据的应用程序访问
                        case PHAuthorizationStatusRestricted://此应用程序没有被授权访问的照片数据。可能是家长控制权限
                            completion(NO);
                            break;
                            
                        default:
                            completion(NO);
                            break;
                    }
                });
            }];
        }
            break;
        default:
            completion(NO);
            break;
    }
}


#pragma mark - 相册授权
- (BOOL)isPhotoAuthorized {
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        return YES;
    }
    return NO;
}


+ (void)showPermissionAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"权限访问" message:@"保存到系统相册需要先开启相册权限，请前往\"设置\"开启相册权限" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"前往" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

@end
