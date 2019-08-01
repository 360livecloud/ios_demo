//
//  QHVCEditMonochromeTimelineView.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2019/7/3.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCEditMonochromeTimelineView.h"
#import "QHVCEditMediaEditor.h"
#import "QHVCEditMediaEditorConfig.h"
#import "QHVCEditPlayerBaseVC.h"
#import "QHVCEditTimelineView.h"
#import "QHVCEditPrefs.h"

@interface QHVCEditMonochromeTimelineView ()
@property (nonatomic, retain) QHVCEditTimelineView* timelineView;
@property (nonatomic, retain) QHVCEditMonochromeEffect* curEffect;
@property (nonatomic, retain) QHVCEditPlayerBaseVC* playerBaseVC;
@property (nonatomic, retain) UIView* curMaskView;
@property (nonatomic, assign) CGFloat curHue;
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, retain) NSMutableArray* effects;

@end

@implementation QHVCEditMonochromeTimelineView

- (void)dealloc
{
    [self.timelineView removeFromSuperview];
}

- (void)drawRect:(CGRect)rect
{
    self.effects = [NSMutableArray array];
    self.timelineView =[[NSBundle mainBundle] loadNibNamed:@"QHVCEditTimelineView" owner:self options:nil][0];
    [self.timelineView setFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    [self.timelineView setPlayerBaseVC:self.playerBaseVC];
    [self addSubview:self.timelineView];
    
    WEAK_SELF
    [self.timelineView setPlayAction:^{
        STRONG_SELF
        [self play];
    }];
    
    [self.timelineView setPauseAction:^{
        STRONG_SELF
        [self pause];
    }];
    
    [self.timelineView setPlayingAction:^(NSInteger timestamp)
    {
        STRONG_SELF
        [self updateMask:timestamp];
    }];
}

- (void)setHue:(CGFloat)hue
{
    self.curHue = hue;
}

- (void)setPlayerBaseVC:(QHVCEditPlayerBaseVC *)playerBaseVC
{
    _playerBaseVC = playerBaseVC;
}

- (void)clearAllEffects
{
    [self.effects enumerateObjectsUsingBlock:^(QHVCEditMonochromeEffect* effect, NSUInteger idx, BOOL *stop)
     {
         [[QHVCEditMediaEditor sharedInstance] deleteMainVideoTrackEffect:effect];
    }];
    [self.effects removeAllObjects];
    [self.playerBaseVC refreshPlayer:YES];
}

- (void)play
{
    [self addCommand];
}

- (void)pause
{
    [self updateCommandEndTime];
}

#pragma mark - Effect && Mask Methods

- (void)addCommand
{
    UIColor* color = [UIColor colorWithHue:self.curHue saturation:1.0 brightness:1.0 alpha:1.0];
    UIColor* maskColor = [UIColor colorWithHue:self.curHue saturation:1.0 brightness:1.0 alpha:0.5];
    
    CGSize size = self.timelineView.collectionView.contentSize;
    NSInteger curTime = [self.timelineView timelineTimestamp];
    NSInteger duration = self.playerBaseVC.playerDuration;
    CGFloat x = (float)curTime * size.width/duration;
    self.startTime = curTime;
    self.curMaskView = [[UIView alloc] initWithFrame:CGRectMake(x, 0, 0, size.height)];
    [self.curMaskView setBackgroundColor:maskColor];
    [self.timelineView.collectionView addSubview:self.curMaskView];
    
    QHVCEditTimeline* timeline = [[QHVCEditMediaEditor sharedInstance] timeline];
    QHVCEditTrack* mainTrack = [[QHVCEditMediaEditor sharedInstance] mainTrack];

    self.curEffect = [[QHVCEditMonochromeEffect alloc] initEffectWithTimeline:timeline];
    self.curEffect.startTime = self.playerBaseVC.curPlayerTime;
    self.curEffect.endTime = [mainTrack duration];
    self.curEffect.color = color;
    self.curEffect.renderZOrder = [[QHVCEditMediaEditorConfig sharedInstance] monochromeIndex];
    [[QHVCEditMediaEditorConfig sharedInstance] setMonochromeIndex:self.curEffect.renderZOrder+1];

    [[QHVCEditMediaEditor sharedInstance] addEffectToMainVideoTrack:self.curEffect];
    [self.effects addObject:self.curEffect];
    [self.playerBaseVC refreshPlayer:YES];
}

- (void)updateCommandEndTime
{
    [self.curEffect setEndTime:(self.playerBaseVC.curPlayerTime)];
    [[QHVCEditMediaEditor sharedInstance] updateMainVideoTrackEffect:self.curEffect];
    [self.playerBaseVC refreshPlayer:YES];
}

- (void)updateMask:(NSInteger)timestamp
{
    CGSize size = self.timelineView.collectionView.contentSize;
    NSInteger time = timestamp - self.startTime;
    NSInteger duration = self.playerBaseVC.playerDuration;
    CGFloat w = (float)time * size.width/duration;
    [self.curMaskView setFrame:CGRectMake(self.curMaskView.frame.origin.x,
                                          self.curMaskView.frame.origin.y,
                                          w,
                                          self.curMaskView.frame.size.height)];
}

@end
