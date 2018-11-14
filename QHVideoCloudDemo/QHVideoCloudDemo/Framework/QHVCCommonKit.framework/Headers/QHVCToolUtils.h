//
//  QHVCToolUtils.h
//  QHVCToolKit
//
//  Created by yangkui on 2017/8/31.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QHVCToolUtils : NSObject

+ (BOOL)createDirectoryAtPath:(NSString *)path;

+ (BOOL)createFileAtPath:(NSString *)path;

+ (BOOL)deleteFile:(NSString *)path;

+ (BOOL)copyFile:(NSString *)path topath:(NSString *)topath;

+ (BOOL)cutFile:(NSString *)path topath:(NSString *)topath;

+ (NSArray *)getAllFileByName:(NSString *)path;

+ (NSArray *)getAllFloderByName:(NSString *)path;

+ (float)sizeOfDirectory:(NSString *)dir;

+ (NSData *)dataUseZLibDecompressWithData:(NSData *)data;

+ (NSData *)dataUseZLibCompressWithData:(NSData *)data;

@end
