//
//  QHVCLocalServerLocalFileManager.h
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/11/3.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QHVCLocalServerLocalFileManager : NSObject

+ (instancetype)sharedInstance;

- (void)saveFile:(NSDictionary *)dic;
- (NSMutableArray *)loadAllFiles;
- (void)deleteFile:(NSUInteger)index;

- (BOOL)fileExitAtFilePath:(NSString *)path;
- (BOOL)downloadCompleted:(NSString *)rid;

@end
