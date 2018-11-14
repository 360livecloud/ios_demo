
#import "EZAudioDisplayLink.h"

#if TARGET_OS_IPHONE
#elif TARGET_OS_MAC
static CVReturn EZAudioDisplayLinkCallback(CVDisplayLinkRef displayLinkRef,
                                           const CVTimeStamp *now,
                                           const CVTimeStamp *outputTime,
                                           CVOptionFlags flagsIn,
                                           CVOptionFlags *flagsOut,
                                           void   *displayLinkContext);
#endif


@interface EZAudioDisplayLink ()
#if TARGET_OS_IPHONE
@property (nonatomic, strong) CADisplayLink *displayLink;
#elif TARGET_OS_MAC
@property (nonatomic, assign) CVDisplayLinkRef displayLink;
#endif
@property (nonatomic, assign) BOOL stopped;
@end


@implementation EZAudioDisplayLink


- (void)dealloc
{
#if TARGET_OS_IPHONE
    [self.displayLink invalidate];
#elif TARGET_OS_MAC
    CVDisplayLinkStop(self.displayLink);
    CVDisplayLinkRelease(self.displayLink);
    self.displayLink = nil;
#endif
}

+ (instancetype)displayLinkWithDelegate:(id<EZAudioDisplayLinkDelegate>)delegate
{
    EZAudioDisplayLink *displayLink = [[self alloc] init];
    displayLink.delegate = delegate;
    return displayLink;
}


- (instancetype) init
{
    self = [super init];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.stopped = YES;
#if TARGET_OS_IPHONE
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
#elif TARGET_OS_MAC
    CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
    CVDisplayLinkSetOutputCallback(self.displayLink,
                                   EZAudioDisplayLinkCallback,
                                   (__bridge void *)(self));
    CVDisplayLinkStart(self.displayLink);
#endif
}

- (void)start
{
#if TARGET_OS_IPHONE
    self.displayLink.paused = NO;
#elif TARGET_OS_MAC
    CVDisplayLinkStart(self.displayLink);
#endif
    self.stopped = NO;
}

- (void)stop
{
#if TARGET_OS_IPHONE
    self.displayLink.paused = YES;
#elif TARGET_OS_MAC
    CVDisplayLinkStop(self.displayLink);
#endif
    self.stopped = YES;
}

- (void)update
{
    if (!self.stopped)
    {
        if ([self.delegate respondsToSelector:@selector(displayLinkNeedsDisplay:)])
        {
            [self.delegate displayLinkNeedsDisplay:self];
        }
    }
}


@end

#if TARGET_OS_IPHONE
#elif TARGET_OS_MAC
static CVReturn EZAudioDisplayLinkCallback(CVDisplayLinkRef displayLinkRef,
                                           const CVTimeStamp *now,
                                           const CVTimeStamp *outputTime,
                                           CVOptionFlags flagsIn,
                                           CVOptionFlags *flagsOut,
                                           void   *displayLinkContext)
{
    EZAudioDisplayLink *displayLink = (__bridge EZAudioDisplayLink*)displayLinkContext;
    [displayLink update];
    return kCVReturnSuccess;
}
#endif
