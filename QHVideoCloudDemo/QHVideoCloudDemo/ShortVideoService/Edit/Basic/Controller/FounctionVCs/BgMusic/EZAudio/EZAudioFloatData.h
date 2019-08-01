
#import <Foundation/Foundation.h>

@interface EZAudioFloatData : NSObject

+ (instancetype)dataWithNumberOfChannels:(int)numberOfChannels
                                 buffers:(float **)buffers
                              bufferSize:(UInt32)bufferSize;

@property (nonatomic, assign, readonly) int numberOfChannels;
@property (nonatomic, assign, readonly) float **buffers;
@property (nonatomic, assign, readonly) UInt32 bufferSize;

- (float *)bufferForChannel:(int)channel;
@end
