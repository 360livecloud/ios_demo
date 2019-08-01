//
//  QHVCEditMosaicItemView.m
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2018/12/28.
//  Copyright © 2018 yangkui. All rights reserved.
//

#import "QHVCEditMosaicItemView.h"
#import "QHVCEditMediaEditor.h"
#import "QHVCEditMediaEditorConfig.h"
#import "QHVCEditPrefs.h"

@implementation QHVCEditMosaicItemView

- (void)prepareSubviews
{
    self.rotateEnable = NO;
    CGSize outputSize = [QHVCEditMediaEditorConfig sharedInstance].outputSize;
    CGRect rect = [self rectToOutputRect:outputSize];
    self.effect = [self createMosaicEffect];
    self.effect.startTime = 0;
    self.effect.endTime = [[QHVCEditMediaEditor sharedInstance] getTimelineDuration];
    self.effect.region = [QHVCEditPrefs rectFormatter:rect];
    self.effect.intensity = 1.0;
    [[QHVCEditMediaEditor sharedInstance] addEffectToMainVideoTrack:self.effect];
    SAFE_BLOCK(self.refreshPlayerForBasicParamBlock);
}

- (QHVCEditMosaicEffect *)createMosaicEffect
{
    QHVCEditTimeline* timeline = [[QHVCEditMediaEditor sharedInstance] timeline];
    QHVCEditMosaicEffect* effect = [[QHVCEditMosaicEffect alloc] initEffectWithTimeline:timeline];
    return effect;
}

- (void)updateIntensity:(CGFloat)intensity
{
    self.effect.intensity = intensity;
    [[QHVCEditMediaEditor sharedInstance] updateMainVideoTrackEffect:self.effect];
    SAFE_BLOCK(self.refreshPlayerBlock, NO);
}

- (void)updateRenderRect
{
    CGSize outputSize = [QHVCEditMediaEditorConfig sharedInstance].outputSize;
    CGRect rect = [self rectToOutputRect:outputSize];
    self.effect.region = [QHVCEditPrefs rectFormatter:rect];
    [[QHVCEditMediaEditor sharedInstance] updateTimelineEffect:self.effect];
}

#pragma mark - Event Methods

- (void)moveGestureAction:(BOOL)isEnd
{
    [self updateRenderRect];
    SAFE_BLOCK(self.refreshPlayerBlock, isEnd);
}

- (void)pinchGestureAction:(BOOL)isEnd
{
    [self updateRenderRect];
    SAFE_BLOCK(self.refreshPlayerBlock, isEnd);
}

@end
