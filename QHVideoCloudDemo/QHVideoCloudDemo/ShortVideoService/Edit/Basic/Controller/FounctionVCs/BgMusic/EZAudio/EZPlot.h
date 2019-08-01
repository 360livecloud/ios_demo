
#import <Foundation/Foundation.h>
#import "EZAudioUtilities.h"


typedef NS_ENUM(NSInteger, EZPlotType)
{
   
    EZPlotTypeBuffer,
    
    EZPlotTypeRolling
};


#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
@interface EZPlot : UIView
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
@interface EZPlot : NSView
#endif

#if TARGET_OS_IPHONE
@property (nonatomic, strong) IBInspectable UIColor *backgroundColor;
#elif TARGET_OS_MAC
@property (nonatomic, strong) IBInspectable NSColor *backgroundColor;
#endif

#if TARGET_OS_IPHONE
@property (nonatomic, strong) IBInspectable UIColor *color;
#elif TARGET_OS_MAC
@property (nonatomic, strong) IBInspectable NSColor *color;
#endif


@property (nonatomic, assign) IBInspectable float gain;


@property (nonatomic, assign) IBInspectable EZPlotType plotType;

@property (nonatomic, assign) IBInspectable BOOL shouldFill;

@property (nonatomic, assign) IBInspectable BOOL shouldMirror;


-(void)clear;

-(void)updateBuffer:(float *)buffer withBufferSize:(UInt32)bufferSize;

@end
