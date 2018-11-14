//
//  QHVCLocalServerDownloadManager.h
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/11/3.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ReloadBlock)(NSUInteger index);
typedef void(^ReloadTable)(NSUInteger index);
typedef void(^MsgBlock)(NSString *msg);

@interface QHVCLocalServerDownloadManager : NSObject

@property (nonatomic, readonly) NSMutableArray *tasksArray;

+ (instancetype)sharedInstance;

- (void)startDownload:(NSString *)rid url:(NSString *)url path:(NSString *)path title:(NSString *)title;
- (BOOL)cancelDownload:(NSInteger)index deleteFile:(BOOL)deleteFile;
- (BOOL)pauseDownload:(NSInteger)index;
- (BOOL)resumeDownload:(NSInteger)index;

- (void)reloadData:(ReloadBlock)block;//刷新单条回调
- (void)reloadTable:(ReloadTable)block;//刷新表单回调
- (void)msgCallBack:(MsgBlock)block;//状态回调

@end
