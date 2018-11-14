//
//  QHVCPlayerTranscode.h
//  QHVCPlayerKit
//
//  Created by yinchaoyu on 2017/6/19.
//  Copyright © 2017年 qihoo 360. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QHVCPlayerTranscode : NSObject
/**
 初始化对象
 
 @param inChannel 声道数（输入）
 @param inSampleRate 采样率（输入）
 @param inSampleBits 音频位数（输入）
 @param outChannel 声道数（输出）
 @param outSampleRate 采样率（输出）
 @param outSampleBits 音频位数（输出）
 @return 对象
 */
- (instancetype)initWith:(int)inChannel
        withInSampleRate:(int)inSampleRate
        withInSampleBits:(int)inSampleBits
          withOutChannel:(int)outChannel
       withOutSampleRate:(int)outSampleRate
       withOutSampleBits:(int)outSampleBits;

/**
 音频转换
 
 @param input 音频数据输入
 @param inSize 大小
 @param output 音频数据输出
 @param outSize 期望输出大小
 @return 实际输出音频的大小
 */
- (int) reSample:(unsigned char *)input withInSize:(int)inSize withOutput:(unsigned char *)output withOutSize:(int)outSize;

/**
 对象释放
 */
- (void)releaseObject;
@end
