
#import "EZAudioFloatData.h"
#import "EZAudioUtilities.h"

@interface EZAudioFloatData ()
@property (nonatomic, assign, readwrite) int    numberOfChannels;
@property (nonatomic, assign, readwrite) float  **buffers;
@property (nonatomic, assign, readwrite) UInt32 bufferSize;
@end


@implementation EZAudioFloatData


- (void)dealloc
{
    [EZAudioUtilities freeFloatBuffers:self.buffers
                      numberOfChannels:self.numberOfChannels];
}

+ (instancetype)dataWithNumberOfChannels:(int)numberOfChannels
                                 buffers:(float **)buffers
                              bufferSize:(UInt32)bufferSize
{
    id data = [[self alloc] init];
    size_t size = sizeof(float) * bufferSize;
    float **buffersCopy = [EZAudioUtilities floatBuffersWithNumberOfFrames:bufferSize
                                                          numberOfChannels:numberOfChannels];
    for (int i = 0; i < numberOfChannels; i++)
    {
        memcpy(buffersCopy[i], buffers[i], size);
    }
    ((EZAudioFloatData *)data).buffers = buffersCopy;
    ((EZAudioFloatData *)data).bufferSize = bufferSize;
    ((EZAudioFloatData *)data).numberOfChannels = numberOfChannels;
    return data;
}

- (float *)bufferForChannel:(int)channel
{
    float *buffer = NULL;
    if (channel < self.numberOfChannels)
    {
        buffer = self.buffers[channel];
    }
    return buffer;
}

@end
