
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <TargetConditionals.h>
#import "TPCircularBuffer.h"
#if TARGET_OS_IPHONE
#import <AVFoundation/AVFoundation.h>
#elif TARGET_OS_MAC
#endif

typedef struct
{
    float            *buffer;
    int               bufferSize;
    TPCircularBuffer  circularBuffer;
} EZPlotHistoryInfo;

typedef struct
{
    AudioUnit audioUnit;
    AUNode    node;
} EZAudioNodeInfo;

#if TARGET_OS_IPHONE
typedef CGRect EZRect;
#elif TARGET_OS_MAC
typedef NSRect EZRect;
#endif

@interface EZAudioUtilities : NSObject


+ (void)setShouldExitOnCheckResultFail:(BOOL)shouldExitOnCheckResultFail;

+ (BOOL)shouldExitOnCheckResultFail;

+ (AudioBufferList *)audioBufferListWithNumberOfFrames:(UInt32)frames
                                      numberOfChannels:(UInt32)channels
                                           interleaved:(BOOL)interleaved;


+ (float **)floatBuffersWithNumberOfFrames:(UInt32)frames
                          numberOfChannels:(UInt32)channels;


+ (void)freeBufferList:(AudioBufferList *)bufferList;

+ (void)freeFloatBuffers:(float **)buffers numberOfChannels:(UInt32)channels;

+ (AudioStreamBasicDescription)AIFFFormatWithNumberOfChannels:(UInt32)channels
                                                   sampleRate:(float)sampleRate;


+ (AudioStreamBasicDescription)iLBCFormatWithSampleRate:(float)sampleRate;

+ (AudioStreamBasicDescription)floatFormatWithNumberOfChannels:(UInt32)channels
                                                    sampleRate:(float)sampleRate;


+ (AudioStreamBasicDescription)M4AFormatWithNumberOfChannels:(UInt32)channels
                                                  sampleRate:(float)sampleRate;


+ (AudioStreamBasicDescription)monoFloatFormatWithSampleRate:(float)sampleRate;


+ (AudioStreamBasicDescription)monoCanonicalFormatWithSampleRate:(float)sampleRate;


+ (AudioStreamBasicDescription)stereoCanonicalNonInterleavedFormatWithSampleRate:(float)sampleRate;


+ (AudioStreamBasicDescription)stereoFloatInterleavedFormatWithSampleRate:(float)sampleRate;

+ (AudioStreamBasicDescription)stereoFloatNonInterleavedFormatWithSampleRate:(float)sampleRate;


+ (BOOL)isFloatFormat:(AudioStreamBasicDescription)asbd;


+ (BOOL)isInterleaved:(AudioStreamBasicDescription)asbd;


+ (BOOL)isLinearPCM:(AudioStreamBasicDescription)asbd;


+ (void)printASBD:(AudioStreamBasicDescription)asbd;


+ (NSString *)displayTimeStringFromSeconds:(NSTimeInterval)seconds;


+ (NSString *)stringForAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd;


+ (void)setCanonicalAudioStreamBasicDescription:(AudioStreamBasicDescription*)asbd
                               numberOfChannels:(UInt32)nChannels
                                    interleaved:(BOOL)interleaved;


+ (void)appendBufferAndShift:(float*)buffer
              withBufferSize:(int)bufferLength
             toScrollHistory:(float*)scrollHistory
       withScrollHistorySize:(int)scrollHistoryLength;


+(void)    appendValue:(float)value
       toScrollHistory:(float*)scrollHistory
 withScrollHistorySize:(int)scrollHistoryLength;


+ (float)MAP:(float)value
     leftMin:(float)leftMin
     leftMax:(float)leftMax
    rightMin:(float)rightMin
    rightMax:(float)rightMax;


+ (float)RMS:(float*)buffer length:(int)bufferSize;


+ (float)SGN:(float)value;

+ (NSString *)noteNameStringForFrequency:(float)frequency
                           includeOctave:(BOOL)includeOctave;


+ (void)checkResult:(OSStatus)result operation:(const char *)operation;


+ (NSString *)stringFromUInt32Code:(UInt32)code;

+ (void)getColorComponentsFromCGColor:(CGColorRef)color
                                  red:(CGFloat *)red
                                green:(CGFloat *)green
                                 blue:(CGFloat *)blue
                                alpha:(CGFloat *)alpha;


+ (void)updateScrollHistory:(float **)scrollHistory
                 withLength:(int)scrollHistoryLength
                    atIndex:(int *)index
                 withBuffer:(float *)buffer
             withBufferSize:(int)bufferSize
       isResolutionChanging:(BOOL *)isChanging;


+ (void)appendDataToCircularBuffer:(TPCircularBuffer*)circularBuffer
               fromAudioBufferList:(AudioBufferList*)audioBufferList;


+ (void)circularBuffer:(TPCircularBuffer*)circularBuffer
              withSize:(int)size;


+ (void)freeCircularBuffer:(TPCircularBuffer*)circularBuffer;


+ (void)appendBufferRMS:(float *)buffer
         withBufferSize:(UInt32)bufferSize
          toHistoryInfo:(EZPlotHistoryInfo *)historyInfo;


+ (void)appendBuffer:(float *)buffer
      withBufferSize:(UInt32)bufferSize
       toHistoryInfo:(EZPlotHistoryInfo *)historyInfo;

+ (void)clearHistoryInfo:(EZPlotHistoryInfo *)historyInfo;


+ (void)freeHistoryInfo:(EZPlotHistoryInfo *)historyInfo;


+ (EZPlotHistoryInfo *)historyInfoWithDefaultLength:(int)defaultLength
                                      maximumLength:(int)maximumLength;

@end
