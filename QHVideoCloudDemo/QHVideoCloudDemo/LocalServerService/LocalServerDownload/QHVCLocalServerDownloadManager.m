//
//  QHVCLocalServerDownloadManager.m
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/11/3.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCLocalServerDownloadManager.h"
#import <QHVCLocalServerKit/QHVCLocalServerKit.h>
#import "QHVCLocalServerLocalFileManager.h"

@interface QHVCLocalServerDownloadManager ()<QHVCLocalServerCachePersistenceDelegate>
{
    ReloadBlock reloadBlock;
    ReloadTable reloadTable;
    MsgBlock msgBlock;
}

@property (nonatomic, strong) NSMutableArray *tasksArray;
@property (nonatomic, strong) NSMutableArray *indexArray;
@property (nonatomic, strong) NSRecursiveLock *lock;

@end

@implementation QHVCLocalServerDownloadManager

+ (instancetype)sharedInstance
{
    static QHVCLocalServerDownloadManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[QHVCLocalServerDownloadManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    if (self == [super init])
    {
        [QHVCLocalServerKit sharedInstance].cachePersistenceDelegate = self;
        self.tasksArray = [NSMutableArray new];
        self.indexArray = [NSMutableArray new];
        self.lock = [NSRecursiveLock new];
    }
    
    return self;
}

- (void)startDownload:(NSString *)rid url:(NSString *)url path:(NSString *)path title:(NSString *)title
{
    if (![self isContainObject:_indexArray object:rid])
    {
        if ([[QHVCLocalServerLocalFileManager sharedInstance] fileExitAtFilePath:path] && [[QHVCLocalServerLocalFileManager sharedInstance] downloadCompleted:rid])
        {
            if (msgBlock)
            {
                msgBlock(@"文件已存在");
            }
            return;
        }
        
        [_indexArray addObject:rid];
        
        NSMutableDictionary *temp = [NSMutableDictionary new];
        [temp setObject:title forKey:@"title"];
        [temp setObject:@"0" forKey:@"progress"];
        [temp setObject:@"" forKey:@"completeScale"];
        [temp setObject:rid forKey:@"rid"];
        
        [_tasksArray addObject:temp];
        
        [[QHVCLocalServerKit sharedInstance] cachePersistence:rid url:url path:path];
        
        if (msgBlock)
        {
            msgBlock(@"加入下载队列");
        }
    }
    else
    {
        if (msgBlock)
        {
            msgBlock(@"已经在下载队列中");
        }
    }
}

- (BOOL)cancelDownload:(NSInteger)index deleteFile:(BOOL)deleteFile
{
    [self.lock lock];
    
    BOOL flag = [[QHVCLocalServerKit sharedInstance] cancelCachePersistence:_indexArray[index] deleteFile:deleteFile];
    
    [_tasksArray removeObjectAtIndex:index];
    [_indexArray removeObjectAtIndex:index];
    if (_tasksArray.count == 0)
    {
        NSLog(@"下载全部取消");
    }
    
    if (reloadTable)
    {
        reloadTable(1);
    }
    [self.lock unlock];
    
    return flag;
}

- (BOOL)pauseDownload:(NSInteger)index
{
    return [[QHVCLocalServerKit sharedInstance] pauseCachePersistence:_indexArray[index]];
}

- (BOOL)resumeDownload:(NSInteger)index
{
    return [[QHVCLocalServerKit sharedInstance] resumeCachePersistence:_indexArray[index]];
}

- (void)reloadData:(ReloadBlock)block
{
    reloadBlock = block;
}

- (void)reloadTable:(ReloadTable)block
{
    reloadTable = block;
}

- (void)msgCallBack:(MsgBlock)block
{
    msgBlock = block;
}

- (NSUInteger)realIndex:(NSString *)rid
{
    int i = 0;
    while (i < _indexArray.count)
    {
        if ([rid isEqualToString:_indexArray[i]])
        {
            break;
        }
        i++;
    }
    return i;
}

- (BOOL)isContainObject:(NSArray *)data object:(NSString *)string
{
    for (NSString *obj in data)
    {
        if (obj == string)
        {
            return YES;
        }
    }
    return NO;
}
#pragma mark QHVCLocalServerDownloadDelegate
- (void)onStart:(NSString *)rid
{
    NSLog(@"下载开始:%@", rid);
}

- (void)onProgress:(NSString *)rid position:(long long)position total:(long long)total speed:(double)speed
{
    if (total <= 0)
    {
        NSLog(@"error reason:total = %lld", total);
    }
    NSUInteger index = [self realIndex:rid];
    NSMutableDictionary *item = _tasksArray[index];
    double pos = position * 1.0/1024/1024;
    double tot = total * 1.0/1024/1024;
    double progress = position * 1.0/total;
    [item setObject:[NSString stringWithFormat:@"%.3f", progress] forKey:@"progress"];
    [item setObject:[NSString stringWithFormat:@"%.1fM/%.1fM", pos, tot] forKey:@"completeScale"];
    if (reloadBlock)
    {
        reloadBlock(index);
    }
    NSLog(@"%s", __func__);
}

- (void)onSuccess:(NSString *)rid
{
    [self.lock lock];
    NSUInteger successIndex = [self realIndex:rid];
    if (successIndex >= _tasksArray.count) return;
    
    [[QHVCLocalServerLocalFileManager sharedInstance] saveFile:_tasksArray[[self realIndex:rid]]];
    
    [_tasksArray removeObjectAtIndex:successIndex];
    if (_tasksArray.count == 0)
    {
        NSLog(@"下载全部完成");
    }
    
    [_indexArray removeObjectAtIndex:successIndex];
    if (reloadTable)
    {
        reloadTable(1);
    }
    [self.lock unlock];
    NSLog(@"下载完成rid:%@", rid);
}

- (void)onFailed:(NSString *)rid errCode:(int)errCode errMsg:(NSString *)errMsg
{
    NSLog(@"下载失败:%@", rid);
}

@end
