//
//  QHVCLocalServerLocalFileManager.m
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/11/3.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCLocalServerLocalFileManager.h"

static NSString *fileListKey = @"fileList";

@implementation QHVCLocalServerLocalFileManager

+ (instancetype)sharedInstance
{
    static QHVCLocalServerLocalFileManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[QHVCLocalServerLocalFileManager alloc] init];
    });
    return sharedInstance;
}

- (void)saveFile:(NSDictionary *)dic
{
    NSMutableArray *array = [[self loadAllFiles] mutableCopy];
    if (!array)
    {
        array = [NSMutableArray new];
    }
    [array addObject:dic];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:array forKey:fileListKey];
    [defaults setObject:[dic valueForKey:@"rid"] forKey:[dic valueForKey:@"rid"]];
    
    [defaults synchronize];
}

- (NSMutableArray *)loadAllFiles
{
    NSMutableArray *array;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    array = [defaults objectForKey:fileListKey];
    return array;
}

- (void)deleteFile:(NSUInteger)index
{
    NSMutableArray *array = [[self loadAllFiles] mutableCopy];
    
    NSString *defaultPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"downloadVideo"];
    NSString *path = [defaultPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [array[index] valueForKey:@"title"]]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path])
    {
        [fileManager removeItemAtPath:path error:nil];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults removeObjectForKey:[array[index] valueForKey:@"rid"]];
    [array removeObjectAtIndex:index];
    
    [defaults setObject:array forKey:fileListKey];
    
    [defaults synchronize];
}

- (BOOL)fileExitAtFilePath:(NSString *)path
{
    if (!path)
        return NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:path];
}

- (BOOL)downloadCompleted:(NSString *)rid
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL flag = NO;
    if ([defaults objectForKey:rid])
    {
        flag = YES;
    }
    return flag;
}

@end
