//
//  AudioWaveForm.h
//  AudioWave
//
//  Created by huangshiping on 2018/5/8.
//  Copyright © 2018年 huangshiping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EZAudioPlot.h"
#import "EZAudioFloatData.h"

#define BACKGROUNDCOLOR  [UIColor blackColor]
#define FOREGROUNDCOLOR  [UIColor whiteColor]


@interface AudioWaveForm : NSObject

+(AudioWaveForm *)sharedManager;
//-(EZAudioPlot*)generateWave:(NSURL*)audioPath frame:(CGRect)frame;
-(EZAudioPlot*)generateWave:(EZAudioFloatData *)waveformData frame:(CGRect)frame;

@end
