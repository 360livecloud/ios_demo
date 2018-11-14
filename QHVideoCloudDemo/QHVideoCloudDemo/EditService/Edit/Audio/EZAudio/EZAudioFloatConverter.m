
#import "EZAudioFloatConverter.h"
#import "EZAudioUtilities.h"


static UInt32 EZAudioFloatConverterDefaultOutputBufferSize = 128 * 32;
UInt32 const EZAudioFloatConverterDefaultPacketSize = 2048;


typedef struct
{
    AudioConverterRef             converterRef;
    AudioBufferList              *floatAudioBufferList;
    AudioStreamBasicDescription   inputFormat;
    AudioStreamBasicDescription   outputFormat;
    AudioStreamPacketDescription *packetDescriptions;
    UInt32 packetsPerBuffer;
} EZAudioFloatConverterInfo;


OSStatus EZAudioFloatConverterCallback(AudioConverterRef             inAudioConverter,
                                       UInt32                       *ioNumberDataPackets,
                                       AudioBufferList              *ioData,
                                       AudioStreamPacketDescription **outDataPacketDescription,
                                       void                         *inUserData)
{
    AudioBufferList *sourceBuffer = (AudioBufferList *)inUserData;
    
    memcpy(ioData,
           sourceBuffer,
           sizeof(AudioBufferList) + (sourceBuffer->mNumberBuffers - 1) * sizeof(AudioBuffer));
    sourceBuffer = NULL;
    
    return noErr;
}


@interface EZAudioFloatConverter ()
@property (nonatomic, assign) EZAudioFloatConverterInfo *info;
@end


@implementation EZAudioFloatConverter


+ (instancetype)converterWithInputFormat:(AudioStreamBasicDescription)inputFormat
{
    return [[self alloc] initWithInputFormat:inputFormat];
}


- (void)dealloc
{
    AudioConverterDispose(self.info->converterRef);
    [EZAudioUtilities freeBufferList:self.info->floatAudioBufferList];
    free(self.info->packetDescriptions);
    free(self.info);
}

- (instancetype)initWithInputFormat:(AudioStreamBasicDescription)inputFormat
{
    self = [super init];
    if (self)
    {
        self.info = (EZAudioFloatConverterInfo *)malloc(sizeof(EZAudioFloatConverterInfo));
        memset(self.info, 0, sizeof(EZAudioFloatConverterInfo));
        self.info->inputFormat = inputFormat;
        [self setup];
    }
    return self;
}

- (void)setup
{
    // create output format
    self.info->outputFormat = [EZAudioUtilities floatFormatWithNumberOfChannels:self.info->inputFormat.mChannelsPerFrame
                                                                     sampleRate:self.info->inputFormat.mSampleRate];
    
    // create a new instance of the audio converter
    [EZAudioUtilities checkResult:AudioConverterNew(&self.info->inputFormat,
                                                    &self.info->outputFormat,
                                                    &self.info->converterRef)
                        operation:"Failed to create new audio converter"];
    
    // get max packets per buffer so you can allocate a proper AudioBufferList
    UInt32 packetsPerBuffer = 0;
    UInt32 outputBufferSize = EZAudioFloatConverterDefaultOutputBufferSize;
    UInt32 sizePerPacket = self.info->inputFormat.mBytesPerPacket;
    BOOL isVBR = sizePerPacket == 0;
    
    // VBR
    if (isVBR)
    {
        // determine the max output buffer size
        UInt32 maxOutputPacketSize;
        UInt32 propSize = sizeof(maxOutputPacketSize);
        OSStatus result = AudioConverterGetProperty(self.info->converterRef,
                                                    kAudioConverterPropertyMaximumOutputPacketSize,
                                                    &propSize,
                                                    &maxOutputPacketSize);
        if (result != noErr)
        {
            maxOutputPacketSize = EZAudioFloatConverterDefaultPacketSize;
        }
        
        // set the output buffer size to at least the max output size
        if (maxOutputPacketSize > outputBufferSize)
        {
            outputBufferSize = maxOutputPacketSize;
        }
        packetsPerBuffer = outputBufferSize / maxOutputPacketSize;
        
        // allocate memory for the packet descriptions
        self.info->packetDescriptions = (AudioStreamPacketDescription *)malloc(sizeof(AudioStreamPacketDescription) * packetsPerBuffer);
    }
    else
    {
        packetsPerBuffer = outputBufferSize / sizePerPacket;
    }
    self.info->packetsPerBuffer = packetsPerBuffer;
    
    // allocate the AudioBufferList to hold the float values
    BOOL isInterleaved = [EZAudioUtilities isInterleaved:self.info->outputFormat];
    self.info->floatAudioBufferList = [EZAudioUtilities audioBufferListWithNumberOfFrames:packetsPerBuffer
                                                                         numberOfChannels:self.info->outputFormat.mChannelsPerFrame
                                                                              interleaved:isInterleaved];
}

- (void)convertDataFromAudioBufferList:(AudioBufferList *)audioBufferList
                    withNumberOfFrames:(UInt32)frames
                        toFloatBuffers:(float **)buffers
{
    [self convertDataFromAudioBufferList:audioBufferList
                      withNumberOfFrames:frames
                          toFloatBuffers:buffers
                      packetDescriptions:self.info->packetDescriptions];
}

- (void)convertDataFromAudioBufferList:(AudioBufferList *)audioBufferList
                    withNumberOfFrames:(UInt32)frames
                        toFloatBuffers:(float **)buffers
                    packetDescriptions:(AudioStreamPacketDescription *)packetDescriptions
{
    if (frames != 0)
    {

        for (int i = 0; i < audioBufferList->mNumberBuffers; i++)
        {
            audioBufferList->mBuffers[i].mDataByteSize = frames * self.info->inputFormat.mBytesPerFrame;
        }
        
        [EZAudioUtilities checkResult:AudioConverterFillComplexBuffer(self.info->converterRef,
                                                                      EZAudioFloatConverterCallback,
                                                                      audioBufferList,
                                                                      &frames,
                                                                      self.info->floatAudioBufferList,
                                                                      packetDescriptions ? packetDescriptions : self.info->packetDescriptions)
                            operation:"Failed to fill complex buffer in float converter"];
        
      
        for (int i = 0; i < self.info->floatAudioBufferList->mNumberBuffers; i++)
        {
            memcpy(buffers[i],
                   self.info->floatAudioBufferList->mBuffers[i].mData,
                   self.info->floatAudioBufferList->mBuffers[i].mDataByteSize);
        }
    }
}

@end
