//
//  QHVCMP4V2File.h
//  QHLCBase
//
//  Created by yangkui on 2017/11/6.
//  Copyright © 2017年 qihoo 360. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QHVCMP4V2File : NSObject

/**
 优化MP4文件的布局，把调整后的文件索引写入到一个新的文件中。
 
 @param fileName 将要优化的文件
 @param newFileName 优化后的文件,默认传nil,传nil代表就直接在源文件上进行修改
 @return YES 处理成功，FALSE：处理失败
 */
+ (BOOL) MP4OptimizeLayout:(NSString *)fileName newFileName:(NSString *)newFileName;

@end
