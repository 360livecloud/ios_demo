
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>


FOUNDATION_EXPORT UInt32 const EZAudioFloatConverterDefaultPacketSize;


@interface EZAudioFloatConverter : NSObject


+ (instancetype)converterWithInputFormat:(AudioStreamBasicDescription)inputFormat;

@property (nonatomic, assign, readonly) AudioStreamBasicDescription inputFormat;
@property (nonatomic, assign, readonly) AudioStreamBasicDescription floatFormat;

#pragma mark - Instance Methods

- (instancetype)initWithInputFormat:(AudioStreamBasicDescription)inputFormat;


- (void)convertDataFromAudioBufferList:(AudioBufferList *)audioBufferList
                    withNumberOfFrames:(UInt32)frames
                        toFloatBuffers:(float **)buffers;


- (void)convertDataFromAudioBufferList:(AudioBufferList *)audioBufferList
                    withNumberOfFrames:(UInt32)frames
                        toFloatBuffers:(float **)buffers
                    packetDescriptions:(AudioStreamPacketDescription *)packetDescriptions;


@end
