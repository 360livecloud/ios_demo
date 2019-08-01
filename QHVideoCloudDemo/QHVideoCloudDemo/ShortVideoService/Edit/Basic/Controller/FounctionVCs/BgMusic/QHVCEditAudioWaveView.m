//
//  QHVCEditAudioWaveView.m
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/3/13.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCEditAudioWaveView.h"
#import "EZAudioFloatData.h"

@interface QHVCEditAudioWaveView ()
{
    BOOL _alreadyLayoutSubviews;
}

@end

@implementation QHVCEditAudioWaveView

- (void)layoutSubviews
{
    if (!_alreadyLayoutSubviews)
    {
        _alreadyLayoutSubviews = YES;
        self.backgroundColor = [UIColor blackColor];
        self.color = [UIColor whiteColor];
        
        self.plotType = EZPlotTypeBuffer;
        self.shouldFill = YES;
        self.shouldMirror = YES;
        self.shouldOptimizeForRealtimePlot = NO;
        self.waveformLayer.shadowOffset = CGSizeMake(0.0, 1.0);
        self.waveformLayer.shadowRadius = 0.0;
        self.waveformLayer.shadowColor = [UIColor colorWithRed: 0.069 green: 0.543 blue: 0.575 alpha: 1].CGColor;
        self.waveformLayer.shadowOpacity = 1.0;
    }
}

- (void)updateWaveWithData:(void *)data size:(int)size
{
    EZAudioFloatData* waveData = [self dataWithNumberOfPoints:1024 data:data length:size];
    [self updateBuffer:waveData.buffers[0] withBufferSize:waveData.bufferSize];
}

- (EZAudioFloatData *)dataWithNumberOfPoints:(UInt32)numberOfPoints data:(unsigned char *)audioData length:(NSInteger)length
{
    float maxValue = 32768.0;
    UInt32 channels = 2;
    int16_t *audioData16 = (int16_t *)audioData;
    
    float **data = (float **)malloc(sizeof(float*) * channels);
    for (int i = 0; i < channels; i++)
    {
        data[i] = (float *)malloc(sizeof(float) * numberOfPoints);
    }
    
    // calculate the required number of frames per buffer
    SInt64 totalFrames = length / 2;//两个unsigned char 为一个声音数据
    SInt64 framesPerBuffer = ((SInt64) totalFrames / numberOfPoints);//包含全部交叉存储声道数据
    SInt64 framesPerChannel = framesPerBuffer / channels;
    
    // read through file and calculate rms at each point
    for (SInt64 i = 0; i < numberOfPoints; i++)
    {
        int16_t *buffer = &audioData16[framesPerBuffer * i];
        for (int channel = 0; channel < channels; channel++)
        {
            float channelData[framesPerChannel];
            for (int frame = 0; frame < framesPerChannel; frame++)
            {
                channelData[frame] = buffer[frame * channels + channel] / maxValue;
            }
            float rms = [self RMS:channelData length:(int)framesPerChannel];
            data[channel][i] = rms;
        }
    }
    
    EZAudioFloatData* waveformData = [EZAudioFloatData dataWithNumberOfChannels:channels
                                                                        buffers:(float **)data
                                                                     bufferSize:numberOfPoints];
    
    // cleanup
    for (int i = 0; i < channels; i++)
    {
        free(data[i]);
    }
    free(data);
    
    return waveformData;
}

- (float)RMS:(float *)buffer length:(int)bufferSize
{
    float sum = 0.0;
    for(int i = 0; i < bufferSize; i++)
    {
        sum += buffer[i] * buffer[i];
    }
    
    float val = sqrtf( sum / bufferSize);
    
    return val;
}

@end
