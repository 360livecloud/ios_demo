
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class EZAudioDisplayLink;


@protocol EZAudioDisplayLinkDelegate <NSObject>

@required

- (void)displayLinkNeedsDisplay:(EZAudioDisplayLink *)displayLink;

@end


@interface EZAudioDisplayLink : NSObject


+ (instancetype)displayLinkWithDelegate:(id<EZAudioDisplayLinkDelegate>)delegate;


@property (nonatomic, weak) id<EZAudioDisplayLinkDelegate> delegate;


- (void)start;

- (void)stop;

@end
