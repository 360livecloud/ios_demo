
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "EZAudioFloatData.h"

//------------------------------------------------------------------------------

@class EZAudio;
@class EZAudioFile;

typedef void (^EZAudioWaveformDataCompletionBlock)(float **waveformData, int length);

@protocol EZAudioFileDelegate <NSObject>

@optional

- (void)     audioFile:(EZAudioFile *)audioFile
             readAudio:(float **)buffer
        withBufferSize:(UInt32)bufferSize
  withNumberOfChannels:(UInt32)numberOfChannels;


- (void)audioFileUpdatedPosition:(EZAudioFile *)audioFile;

- (void)audioFile:(EZAudioFile *)audioFile
  updatedPosition:(SInt64)framePosition  __attribute__((deprecated));

@end


@interface EZAudioFile : NSObject <NSCopying>
@property (nonatomic, weak) id<EZAudioFileDelegate> delegate;

- (instancetype)initWithURL:(NSURL *)url;

- (instancetype)initWithURL:(NSURL *)url
                   delegate:(id<EZAudioFileDelegate>)delegate;


- (instancetype)initWithURL:(NSURL *)url
                   delegate:(id<EZAudioFileDelegate>)delegate
               clientFormat:(AudioStreamBasicDescription)clientFormat;

+ (instancetype)audioFileWithURL:(NSURL *)url;

+ (instancetype)audioFileWithURL:(NSURL *)url
                        delegate:(id<EZAudioFileDelegate>)delegate;

+ (instancetype)audioFileWithURL:(NSURL *)url
                        delegate:(id<EZAudioFileDelegate>)delegate
                    clientFormat:(AudioStreamBasicDescription)clientFormat;

+ (AudioStreamBasicDescription)defaultClientFormat;

+ (Float64)defaultClientFormatSampleRate;

+ (NSArray *)supportedAudioFileTypes;

- (void)readFrames:(UInt32)frames
   audioBufferList:(AudioBufferList *)audioBufferList
        bufferSize:(UInt32 *)bufferSize
               eof:(BOOL *)eof;

- (void)seekToFrame:(SInt64)frame;

@property (readwrite) AudioStreamBasicDescription clientFormat;

@property (nonatomic, readwrite) NSTimeInterval currentTime;


@property (readonly) NSTimeInterval duration;

@property (readonly) AudioStreamBasicDescription fileFormat;


@property (readonly) NSString *formattedCurrentTime;

@property (readonly) NSString *formattedDuration;

@property (readonly) SInt64 frameIndex;

@property (readonly) NSDictionary *metadata;
@property (readonly) NSTimeInterval totalDuration __attribute__((deprecated));
@property (readonly) SInt64 totalClientFrames;
@property (readonly) SInt64 totalFrames;
@property (nonatomic, copy, readonly) NSURL *url;

- (EZAudioFloatData *)getWaveformData;
- (EZAudioFloatData *)getWaveformDataWithNumberOfPoints:(UInt32)numberOfPoints;
- (void)getWaveformDataWithCompletionBlock:(EZAudioWaveformDataCompletionBlock)completion;
- (void)getWaveformDataWithNumberOfPoints:(UInt32)numberOfPoints
                               completion:(EZAudioWaveformDataCompletionBlock)completion;

@end
