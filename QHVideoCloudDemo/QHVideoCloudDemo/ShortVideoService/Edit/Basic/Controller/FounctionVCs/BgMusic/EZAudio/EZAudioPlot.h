

#import <QuartzCore/QuartzCore.h>
#import "EZPlot.h"
#import "EZAudioDisplayLink.h"

@class EZAudio;

FOUNDATION_EXPORT UInt32 const kEZAudioPlotMaxHistoryBufferLength __attribute__((deprecated));


FOUNDATION_EXPORT UInt32 const kEZAudioPlotDefaultHistoryBufferLength __attribute__((deprecated));


FOUNDATION_EXPORT UInt32 const EZAudioPlotDefaultHistoryBufferLength;


FOUNDATION_EXPORT UInt32 const EZAudioPlotDefaultMaxHistoryBufferLength;



@interface EZAudioPlotWaveformLayer : CAShapeLayer
@end

@interface EZAudioPlot : EZPlot

@property (nonatomic, assign) BOOL shouldOptimizeForRealtimePlot;


@property (nonatomic, assign) BOOL shouldCenterYAxis;


@property (nonatomic, strong) EZAudioPlotWaveformLayer *waveformLayer;

-(int)setRollingHistoryLength:(int)historyLength;

-(int)rollingHistoryLength;


- (CGPathRef)createPathWithPoints:(CGPoint *)points
                       pointCount:(UInt32)pointCount
                           inRect:(EZRect)rect;

- (int)defaultRollingHistoryLength;

- (void)setupPlot;

- (int)initialPointCount;

- (int)maximumRollingHistoryLength;

- (void)redraw;


-(void)setSampleData:(float *)data length:(int)length;

@end

@interface EZAudioPlot () <EZAudioDisplayLinkDelegate>
@property (nonatomic, strong) EZAudioDisplayLink *displayLink;
@property (nonatomic, assign) EZPlotHistoryInfo  *historyInfo;
@property (nonatomic, assign) CGPoint            *points;
@property (nonatomic, assign) UInt32              pointCount;
@end
