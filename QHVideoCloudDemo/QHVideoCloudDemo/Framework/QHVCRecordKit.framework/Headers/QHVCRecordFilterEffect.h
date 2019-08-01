
#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

@protocol QHVCRecordFilterEffect <NSObject>

@optional

//两种回调方式 根据具体情况 实现一种即可
- (CVPixelBufferRef)processBuffer:(CVPixelBufferRef)pixelBuffer;

- (CIImage *)processImage:(CIImage *)image;

@end
