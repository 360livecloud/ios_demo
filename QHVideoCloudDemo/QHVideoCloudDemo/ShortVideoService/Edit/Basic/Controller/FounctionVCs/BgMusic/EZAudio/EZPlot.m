
#import "EZPlot.h"

@implementation EZPlot

#pragma mark - Clearing
-(void)clear
{
  // Override in subclass
}

#pragma mark - Get Samples
-(void)updateBuffer:(float *)buffer
     withBufferSize:(UInt32)bufferSize
{
  // Override in subclass
}

@end
