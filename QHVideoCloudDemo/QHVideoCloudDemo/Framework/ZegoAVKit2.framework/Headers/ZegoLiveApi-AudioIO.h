//
//  ZegoLiveApi-AudioIO.h
//  zegoavkit
//
//  Copyright © 2017年 Zego. All rights reserved.
//

#ifndef ZegoLiveApi_AuidoIO_h
#define ZegoLiveApi_AuidoIO_h

#import "ZegoLiveApi.h"
#import "ZegoAVDefines.h"

#include "audio_in_output.h"

@interface ZegoLiveApi (AudioIO)

#ifdef TARGET_OS_IPHONE

+ (void)enableExternalAudioDevice:(bool)enable;
- (AVE::IAudioDataInOutput* )getIAudioDataInOutput;

#endif

/// \brief 设置音频前处理函数
/// \param prep 前处理函数指针
/// \note 必须在InitSDK前调用，并且不能置空
+ (void)setAudioPrep:(void(*)(const short* inData, int inSamples, int sampleRate, short *outData))prep;

/// \brief 设置音频前处理函数
/// \param prepSet 音频采样参数
/// \param delegate 音频采样数据回调
/// \note 必须在InitSDK前调用
+ (void)setAudioPrep2:(AVE::ExtPrepSet)prepSet dataCallback:(void(*)(const AVE::AudioFrame& inFrame, AVE::AudioFrame& outFrame))callback;

@end


#endif /* ZegoLiveApi_AuidoIO_h */
