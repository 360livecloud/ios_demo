//
//  QHVCEditMonochromeView.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2019/7/3.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCEditMonochromeView.h"
#import "QHVCEditTimelineView.h"
#import "QHVCEditHueSlider.h"
#import "QHVCEditMonochromeTimelineView.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditPlayerBaseVC.h"

@interface QHVCEditMonochromeView ()

@property (weak, nonatomic) IBOutlet UIView *timelineContainer;
@property (weak, nonatomic) IBOutlet UIView *sliderContainer;

@property (nonatomic, retain) QHVCEditMonochromeTimelineView* timelineView;
@property (nonatomic, retain) QHVCEditHueSlider* sliderView;


@end

@implementation QHVCEditMonochromeView

- (void)dealloc
{
    [self.timelineView removeFromSuperview];
    [self.sliderView removeFromSuperview];
}

- (void)prepareSubviews
{
    [super prepareSubviews];
    [self setCancelButtonState:NO];
    SAFE_BLOCK(self.seekPlayerBlock, YES, 0);
    SAFE_BLOCK(self.pausePlayerBlock);
    SAFE_BLOCK(self.hidePlayButtonBolck, YES);

    //timeline view
    self.timelineView = [[QHVCEditMonochromeTimelineView alloc] init];
    [self.timelineView setFrame:CGRectMake(0, 0,
                                           self.timelineContainer.frame.size.width,
                                           self.timelineContainer.frame.size.height)];
    [self.timelineContainer addSubview:self.timelineView];
    [self.timelineView setPlayerBaseVC:self.playerBaseVC];
    [self.timelineView setHue:0.5];
    
    //hue slider view
    self.sliderView = [[QHVCEditHueSlider alloc] initWithFrame:CGRectMake(0, 0,
                                                                          self.sliderContainer.frame.size.width,
                                                                          self.sliderContainer.frame.size.height)];
    [self.sliderContainer addSubview:self.sliderView];
    
    WEAK_SELF
    [self.sliderView setValueChangedAction:^(CGFloat progress)
    {
        STRONG_SELF
        [self.timelineView setHue:progress];
    }];
}

- (void)confirmAction
{
    [super confirmAction];
    [self.timelineView pause];
    SAFE_BLOCK(self.pausePlayerBlock);
    SAFE_BLOCK(self.seekPlayerBlock, YES, 0);
    SAFE_BLOCK(self.hidePlayButtonBolck, NO);
}

- (void)cancelAction
{
    [super cancelAction];
    [self.timelineView pause];
    [self.timelineView clearAllEffects];
    SAFE_BLOCK(self.pausePlayerBlock);
    SAFE_BLOCK(self.seekPlayerBlock, YES, 0);
    SAFE_BLOCK(self.hidePlayButtonBolck, NO);
}

@end
