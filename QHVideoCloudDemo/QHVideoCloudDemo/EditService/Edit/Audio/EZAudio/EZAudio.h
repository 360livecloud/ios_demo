//
//  EZAudio.h
//  EZAudio
//
//  Created by Syed Haris Ali on 11/21/13.
//  Copyright (c) 2015 Syed Haris Ali. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Foundation/Foundation.h>

//! Project version number for teat.
FOUNDATION_EXPORT double EZAudioVersionNumber;

//! Project version string for teat.
FOUNDATION_EXPORT const unsigned char EZAudioVersionString[];

//------------------------------------------------------------------------------
#pragma mark - Core Components
//------------------------------------------------------------------------------

#import "EZAudioFile.h"

//#import "EZOutput.h"


//------------------------------------------------------------------------------
#pragma mark - Interface Components
//------------------------------------------------------------------------------

#import "EZPlot.h"
#import "EZAudioDisplayLink.h"
#import "EZAudioPlot.h"


//------------------------------------------------------------------------------
#pragma mark - Utility Components
//------------------------------------------------------------------------------

#import "EZAudioFloatConverter.h"
#import "EZAudioFloatData.h"
#import "EZAudioUtilities.h"

@interface EZAudio : NSObject

+ (void)setShouldExitOnCheckResultFail:(BOOL)shouldExitOnCheckResultFail __attribute__((deprecated));

+ (BOOL)shouldExitOnCheckResultFail __attribute__((deprecated));

+ (AudioBufferList *)audioBufferListWithNumberOfFrames:(UInt32)frames
                                      numberOfChannels:(UInt32)channels
                                           interleaved:(BOOL)interleaved __attribute__((deprecated));

+ (float **)floatBuffersWithNumberOfFrames:(UInt32)frames
                          numberOfChannels:(UInt32)channels __attribute__((deprecated));

+ (void)freeBufferList:(AudioBufferList *)bufferList __attribute__((deprecated));


+ (void)freeFloatBuffers:(float **)buffers numberOfChannels:(UInt32)channels __attribute__((deprecated));

+ (AudioStreamBasicDescription)AIFFFormatWithNumberOfChannels:(UInt32)channels
                                                   sampleRate:(float)sampleRate __attribute__((deprecated));


+ (AudioStreamBasicDescription)iLBCFormatWithSampleRate:(float)sampleRate __attribute__((deprecated));


+ (AudioStreamBasicDescription)floatFormatWithNumberOfChannels:(UInt32)channels
                                                    sampleRate:(float)sampleRate __attribute__((deprecated));


+ (AudioStreamBasicDescription)M4AFormatWithNumberOfChannels:(UInt32)channels
                                                  sampleRate:(float)sampleRate __attribute__((deprecated));


+ (AudioStreamBasicDescription)monoFloatFormatWithSampleRate:(float)sampleRate __attribute__((deprecated));


+ (AudioStreamBasicDescription)monoCanonicalFormatWithSampleRate:(float)sampleRate __attribute__((deprecated));


+ (AudioStreamBasicDescription)stereoCanonicalNonInterleavedFormatWithSampleRate:(float)sampleRate __attribute__((deprecated));


+ (AudioStreamBasicDescription)stereoFloatInterleavedFormatWithSampleRate:(float)sampleRate __attribute__((deprecated));


+ (AudioStreamBasicDescription)stereoFloatNonInterleavedFormatWithSampleRate:(float)sampleRate __attribute__((deprecated));


+ (BOOL)isFloatFormat:(AudioStreamBasicDescription)asbd __attribute__((deprecated));


+ (BOOL)isInterleaved:(AudioStreamBasicDescription)asbd __attribute__((deprecated));


+ (BOOL)isLinearPCM:(AudioStreamBasicDescription)asbd __attribute__((deprecated));


+ (void)printASBD:(AudioStreamBasicDescription)asbd __attribute__((deprecated));


+ (NSString *)displayTimeStringFromSeconds:(NSTimeInterval)seconds __attribute__((deprecated));


+ (NSString *)stringForAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd __attribute__((deprecated));


+ (void)setCanonicalAudioStreamBasicDescription:(AudioStreamBasicDescription*)asbd
                               numberOfChannels:(UInt32)nChannels
                                    interleaved:(BOOL)interleaved __attribute__((deprecated));


+ (void)appendBufferAndShift:(float*)buffer
              withBufferSize:(int)bufferLength
             toScrollHistory:(float*)scrollHistory
       withScrollHistorySize:(int)scrollHistoryLength __attribute__((deprecated));

+(void)    appendValue:(float)value
       toScrollHistory:(float*)scrollHistory
 withScrollHistorySize:(int)scrollHistoryLength __attribute__((deprecated));


+ (float)MAP:(float)value
     leftMin:(float)leftMin
     leftMax:(float)leftMax
    rightMin:(float)rightMin
    rightMax:(float)rightMax __attribute__((deprecated));


+ (float)RMS:(float*)buffer length:(int)bufferSize __attribute__((deprecated));


+ (float)SGN:(float)value __attribute__((deprecated));


+ (void)checkResult:(OSStatus)result operation:(const char *)operation __attribute__((deprecated));


+ (NSString *)stringFromUInt32Code:(UInt32)code __attribute__((deprecated));


+ (void)updateScrollHistory:(float **)scrollHistory
                 withLength:(int)scrollHistoryLength
                    atIndex:(int *)index
                 withBuffer:(float *)buffer
             withBufferSize:(int)bufferSize
       isResolutionChanging:(BOOL *)isChanging __attribute__((deprecated));


+ (void)appendDataToCircularBuffer:(TPCircularBuffer*)circularBuffer
               fromAudioBufferList:(AudioBufferList*)audioBufferList __attribute__((deprecated));


+ (void)circularBuffer:(TPCircularBuffer*)circularBuffer
              withSize:(int)size __attribute__((deprecated));

+ (void)freeCircularBuffer:(TPCircularBuffer*)circularBuffer __attribute__((deprecated));

@end
