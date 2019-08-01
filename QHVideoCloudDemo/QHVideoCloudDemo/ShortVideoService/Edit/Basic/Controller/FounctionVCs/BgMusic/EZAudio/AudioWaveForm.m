//
//  AudioWaveForm.m
//  AudioWave
//
//  Created by huangshiping on 2018/5/8.
//  Copyright © 2018年 huangshiping. All rights reserved.
//

#import "AudioWaveForm.h"
#import "EZAudioFile.h"

@interface AudioWaveForm()

@property(nonatomic,strong)EZAudioPlot* audioPlot;
@property(nonatomic,strong)EZAudioFile* audioFile;

@end

@implementation AudioWaveForm

+(AudioWaveForm *)sharedManager
{
    static AudioWaveForm *_instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

//-(EZAudioPlot*)generateWave:(NSURL*)audioPath frame:(CGRect)frame
//{
//    self.audioPlot = [[EZAudioPlot alloc] initWithFrame:frame];
//    self.audioFile = [EZAudioFile audioFileWithURL:audioPath];
//
//    self.audioPlot.backgroundColor = BACKGROUNDCOLOR;
//    self.audioPlot.color = FOREGROUNDCOLOR;
//
//    self.audioPlot.plotType = EZPlotTypeBuffer;
//    self.audioPlot.shouldFill = YES;
//    self.audioPlot.shouldMirror = YES;
//    self.audioPlot.shouldOptimizeForRealtimePlot = NO;
//    self.audioPlot.waveformLayer.shadowOffset = CGSizeMake(0.0, 1.0);
//    self.audioPlot.waveformLayer.shadowRadius = 0.0;
//    self.audioPlot.waveformLayer.shadowColor = [UIColor colorWithRed: 0.069 green: 0.543 blue: 0.575 alpha: 1].CGColor;
//    self.audioPlot.waveformLayer.shadowOpacity = 1.0;
//
//
//    __weak typeof (self) weakSelf = self;
//    [self.audioFile getWaveformDataWithCompletionBlock:^(float **waveformData,
//                                                         int length)
//     {
//         [weakSelf.audioPlot updateBuffer:waveformData[0]
//                           withBufferSize:length];
//     }];
//
//    return self.audioPlot;
//
//}


-(EZAudioPlot*)generateWave:(EZAudioFloatData *)waveformData frame:(CGRect)frame
{
    self.audioPlot = [[EZAudioPlot alloc] initWithFrame:frame];
    
    self.audioPlot.backgroundColor = BACKGROUNDCOLOR;
    self.audioPlot.color = FOREGROUNDCOLOR;
    
    self.audioPlot.plotType = EZPlotTypeBuffer;
    self.audioPlot.shouldFill = YES;
    self.audioPlot.shouldMirror = YES;
    self.audioPlot.shouldOptimizeForRealtimePlot = NO;
    self.audioPlot.waveformLayer.shadowOffset = CGSizeMake(0.0, 1.0);
    self.audioPlot.waveformLayer.shadowRadius = 0.0;
    self.audioPlot.waveformLayer.shadowColor = [UIColor colorWithRed: 0.069 green: 0.543 blue: 0.575 alpha: 1].CGColor;
    self.audioPlot.waveformLayer.shadowOpacity = 1.0;
    
    
//    __weak typeof (self) weakSelf = self;
//    [self.audioFile getWaveformDataWithCompletionBlock:^(float **waveformData,
//                                                         int length)
//     {
         [self.audioPlot updateBuffer:waveformData.buffers[0]
                           withBufferSize:waveformData.bufferSize];
//     }];
    
    return self.audioPlot;
    
}

@end
