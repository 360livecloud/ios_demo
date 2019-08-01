//
//  QHVCEditOverlayFunctionManager.m
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/3/22.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCEditOverlayFunctionManager.h"
#import "QHVCEditOverlayItemView.h"
#import "QHVCEditPlayerBaseVC.h"
#import "QHVCEditOverlaySpeedView.h"
#import "QHVCEditOverlayVolumeView.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditMediaEditor.h"
#import "QHVCEditMediaEditorConfig.h"

@interface QHVCEditOverlayFunctionManager ()
@property (nonatomic, retain) QHVCEditVideoTransferEffect* videoTransferEffect;
@end

@implementation QHVCEditOverlayFunctionManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (void)clickedRotateItem
{
    QHVCEditRenderInfo* renderInfo = self.itemView.clipItem.clip.renderInfo;
    if (!renderInfo)
    {
        renderInfo = [QHVCEditRenderInfo new];
        self.itemView.clipItem.clip.renderInfo = renderInfo;
    }
    CGFloat radian = renderInfo.renderRadian;
    radian += M_PI_2;
    if (radian > M_PI * 2)
    {
        radian += M_PI * 2;
    }
    
    [renderInfo setRenderRadian:radian];
    [self.playerVC refreshPlayer:YES];
}

- (void)clickedFlipYItem
{
    BOOL flipY = self.itemView.clipItem.clip.flipY;
    flipY = !flipY;
    [self.itemView.clipItem.clip setFlipY:flipY];
    [self.playerVC refreshPlayer:YES];
}

- (void)clickedFlipXItem
{
    BOOL flipX = self.itemView.clipItem.clip.flipX;
    flipX = !flipX;
    [self.itemView.clipItem.clip setFlipX:flipX];
    [self.playerVC refreshPlayer:YES];
}

- (void)clickedSpeedItem
{
    QHVCEditOverlaySpeedView* view = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditOverlaySpeedView class] description]
                                                                   owner:self
                                                                 options:nil][0];
    [view setSpeed:self.itemView.clipItem.clip.speed];
    [self.listView addSubview:view];
    
    WEAK_SELF
    [view setChangeSpeedAction:^(CGFloat speed)
     {
         STRONG_SELF
         [self.itemView.clipItem.clip setSpeed:speed];
         [[QHVCEditMediaEditor sharedInstance] updateOverlayClipParams:self.itemView.clipItem];
         SAFE_BLOCK(self.updatePlayerDuraionBlock);
         [self.playerVC resetPlayerOfCurrentTime];
     }];
}

- (void)clickedVolumeItem
{
    QHVCEditOverlayVolumeView* view = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditOverlayVolumeView class] description]
                                                                    owner:self
                                                                  options:nil][0];
    [view setVolume:self.itemView.clipItem.clip.volume];
    [self.listView addSubview:view];
    
    WEAK_SELF
    [view setChangeVolumeAction:^(NSInteger volume)
     {
         STRONG_SELF
         [self.itemView.clipItem.clip setVolume:volume];
         [[QHVCEditMediaEditor sharedInstance] updateOverlayClipParams:self.itemView.clipItem];
         [self.playerVC resetPlayerOfCurrentTime];
     }];
}

- (void)clickedDeleteItem
{
    [self.itemView removeFromSuperview];
    [[QHVCEditMediaEditor sharedInstance] deleteOverlayClip:self.itemView.clipItem];
    [[[QHVCEditMediaEditorConfig sharedInstance] overlayItemArray] removeObject:self.itemView];
    [self.playerVC resetPlayerOfCurrentTime];
    SAFE_BLOCK(self.updatePlayerDuraionBlock);
    SAFE_BLOCK(self.deleteOverlayBlock);
}

- (void)clickedFadeInOutItem
{
    QHVCEditTrackClip* clip = self.itemView.clipItem.clip;
    NSTimeInterval duration = clip.fileEndTime - clip.fileStartTime;
    NSTimeInterval lastTime = MIN(500, duration/2.0);
    
    QHVCEffectVideoTransferParam* fadeIn = [[QHVCEffectVideoTransferParam alloc] init];
    fadeIn.transferType = QHVCEffectVideoTransferTypeAlpha;
    fadeIn.startTime = 0;
    fadeIn.endTime = lastTime;
    fadeIn.startValue = 0;
    fadeIn.endValue = 1.0;
    
    QHVCEffectVideoTransferParam* fadeOut = [[QHVCEffectVideoTransferParam alloc] init];
    fadeOut.transferType = QHVCEffectVideoTransferTypeAlpha;
    fadeOut.startTime = duration - lastTime;
    fadeOut.endTime = duration;
    fadeOut.startValue = 1.0;
    fadeOut.endValue = 0;
    
    NSArray* transfers = @[fadeIn, fadeOut];
    self.videoTransferEffect.videoTransfer = transfers;
    [[QHVCEditMediaEditor sharedInstance] overlayClip:self.itemView.clipItem updateEffect:self.videoTransferEffect];
    [self.playerVC refreshPlayer:YES];
}

- (void)clickedMoveInOutItem
{
    QHVCEditTrackClip* clip = self.itemView.clipItem.clip;
    NSTimeInterval duration = clip.fileEndTime - clip.fileStartTime;
    NSTimeInterval lastTime = MIN(500, duration/2.0);
    QHVCEffectVideoTransferParam* moveIn = [[QHVCEffectVideoTransferParam alloc] init];
    moveIn.transferType = QHVCEffectVideoTransferTypeOffsetX;
    moveIn.curveType = QHVCEffectVideoTransferCurveTypeCurve;
    moveIn.startTime = 0;
    moveIn.endTime = lastTime;
    moveIn.startValue = -kOutputVideoWidth/5.0;
    moveIn.endValue = 0;
    
    QHVCEffectVideoTransferParam* moveOut = [[QHVCEffectVideoTransferParam alloc] init];
    moveOut.transferType = QHVCEffectVideoTransferTypeOffsetX;
    moveOut.curveType = QHVCEffectVideoTransferCurveTypeCurve;
    moveOut.startTime = duration - lastTime;
    moveOut.endTime = duration;
    moveOut.startValue = 0;
    moveOut.endValue = kOutputVideoWidth/5.0;
    
    QHVCEffectVideoTransferParam* fadeIn = [[QHVCEffectVideoTransferParam alloc] init];
    fadeIn.transferType = QHVCEffectVideoTransferTypeAlpha;
    fadeIn.curveType = QHVCEffectVideoTransferCurveTypeCurve;
    fadeIn.startTime = 0;
    fadeIn.endTime = lastTime;
    fadeIn.startValue = 0;
    fadeIn.endValue = 1.0;
    
    QHVCEffectVideoTransferParam* fadeOut = [[QHVCEffectVideoTransferParam alloc] init];
    fadeOut.transferType = QHVCEffectVideoTransferTypeAlpha;
    fadeOut.curveType = QHVCEffectVideoTransferCurveTypeCurve;
    fadeOut.startTime = duration - lastTime;
    fadeOut.endTime = duration;
    fadeOut.startValue = 1.0;
    fadeOut.endValue = 0;
    
    QHVCEffectVideoTransferParam* scaleIn = [[QHVCEffectVideoTransferParam alloc] init];
    scaleIn.transferType = QHVCEffectVideoTransferTypeScale;
    scaleIn.curveType = QHVCEffectVideoTransferCurveTypeCurve;
    scaleIn.startTime = 0;
    scaleIn.endTime = lastTime;
    scaleIn.startValue = 0.6;
    scaleIn.endValue = 1.0;
    
    QHVCEffectVideoTransferParam* scaleOut = [[QHVCEffectVideoTransferParam alloc] init];
    scaleOut.transferType = QHVCEffectVideoTransferTypeScale;
    scaleOut.curveType = QHVCEffectVideoTransferCurveTypeCurve;
    scaleOut.startTime = duration - lastTime;
    scaleOut.endTime = duration;
    scaleOut.startValue = 1.0;
    scaleOut.endValue = 0.6;
    
    NSArray* transfers = @[moveIn, moveOut, scaleIn, scaleOut, fadeIn, fadeOut];
    self.videoTransferEffect.videoTransfer = transfers;
    [[QHVCEditMediaEditor sharedInstance] overlayClip:self.itemView.clipItem updateEffect:self.videoTransferEffect];
    [self.playerVC refreshPlayer:YES];
}

- (void)clickedJumpInOutItem
{
    QHVCEditTrackClip* clip = self.itemView.clipItem.clip;
    NSTimeInterval duration = clip.fileEndTime - clip.fileStartTime;
    NSTimeInterval lastTime = MIN(500, duration/2.0);
    
    QHVCEffectVideoTransferParam* jumpIn = [[QHVCEffectVideoTransferParam alloc] init];
    jumpIn.transferType = QHVCEffectVideoTransferTypeOffsetY;
    jumpIn.startTime = 0;
    jumpIn.endTime = lastTime;
    jumpIn.startValue = kOutputVideoHeight/5.0;
    jumpIn.endValue = 0;
    
    QHVCEffectVideoTransferParam* jumpOut = [[QHVCEffectVideoTransferParam alloc] init];
    jumpOut.transferType = QHVCEffectVideoTransferTypeOffsetY;
    jumpOut.startTime = duration - lastTime;
    jumpOut.endTime = duration;
    jumpOut.startValue = 0;
    jumpOut.endValue = -kOutputVideoHeight/5.0;
    
    QHVCEffectVideoTransferParam* scaleIn = [[QHVCEffectVideoTransferParam alloc] init];
    scaleIn.transferType = QHVCEffectVideoTransferTypeScale;
    scaleIn.startTime = 0;
    scaleIn.endTime = lastTime;
    scaleIn.startValue = 0.1;
    scaleIn.endValue = 1.0;
    
    QHVCEffectVideoTransferParam* scaleOut = [[QHVCEffectVideoTransferParam alloc] init];
    scaleOut.transferType = QHVCEffectVideoTransferTypeScale;
    scaleOut.startTime = duration - lastTime;
    scaleOut.endTime = duration;
    scaleOut.startValue = 1.0;
    scaleOut.endValue = 0.1;
    
    QHVCEffectVideoTransferParam* fadeIn = [[QHVCEffectVideoTransferParam alloc] init];
    fadeIn.transferType = QHVCEffectVideoTransferTypeAlpha;
    fadeIn.startTime = 0;
    fadeIn.endTime = lastTime;
    fadeIn.startValue = 0;
    fadeIn.endValue = 1.0;
    
    QHVCEffectVideoTransferParam* fadeOut = [[QHVCEffectVideoTransferParam alloc] init];
    fadeOut.transferType = QHVCEffectVideoTransferTypeAlpha;
    fadeOut.startTime = duration - lastTime;
    fadeOut.endTime = duration;
    fadeOut.startValue = 1.0;
    fadeOut.endValue = 0;
    
    NSArray* transfers = @[jumpIn, jumpOut, scaleIn, scaleOut, fadeIn, fadeOut];
    self.videoTransferEffect.videoTransfer = transfers;
    [[QHVCEditMediaEditor sharedInstance] overlayClip:self.itemView.clipItem updateEffect:self.videoTransferEffect];
    [self.playerVC refreshPlayer:YES];
}

- (void)clickedRotateInOutItem
{
    QHVCEditTrackClip* clip = self.itemView.clipItem.clip;
    NSTimeInterval duration = clip.fileEndTime - clip.fileStartTime;
    NSTimeInterval lastTime = MIN(500, duration/2.0);
    
    QHVCEffectVideoTransferParam* rotateIn = [[QHVCEffectVideoTransferParam alloc] init];
    rotateIn.transferType = QHVCEffectVideoTransferTypeRadian;
    rotateIn.startTime = 0;
    rotateIn.endTime = lastTime;
    rotateIn.startValue = 30.0/180.0*M_PI;
    rotateIn.endValue = 0;
    
    QHVCEffectVideoTransferParam* rotateOut = [[QHVCEffectVideoTransferParam alloc] init];
    rotateOut.transferType = QHVCEffectVideoTransferTypeRadian;
    rotateOut.startTime = duration - lastTime;
    rotateOut.endTime = duration;
    rotateOut.startValue = 0;
    rotateOut.endValue = -30./180.0*M_PI;
    
    QHVCEffectVideoTransferParam* scaleIn = [[QHVCEffectVideoTransferParam alloc] init];
    scaleIn.transferType = QHVCEffectVideoTransferTypeScale;
    scaleIn.startTime = 0;
    scaleIn.endTime = lastTime;
    scaleIn.startValue = 1.2;
    scaleIn.endValue = 1.0;
    
    QHVCEffectVideoTransferParam* scaleOut = [[QHVCEffectVideoTransferParam alloc] init];
    scaleOut.transferType = QHVCEffectVideoTransferTypeScale;
    scaleOut.startTime = duration - lastTime;
    scaleOut.endTime = duration;
    scaleOut.startValue = 1.0;
    scaleOut.endValue = 1.2;
    
    QHVCEffectVideoTransferParam* fadeIn = [[QHVCEffectVideoTransferParam alloc] init];
    fadeIn.transferType = QHVCEffectVideoTransferTypeAlpha;
    fadeIn.startTime = 0;
    fadeIn.endTime = lastTime;
    fadeIn.startValue = 0;
    fadeIn.endValue = 1.0;
    
    QHVCEffectVideoTransferParam* fadeOut = [[QHVCEffectVideoTransferParam alloc] init];
    fadeOut.transferType = QHVCEffectVideoTransferTypeAlpha;
    fadeOut.startTime = duration - lastTime;
    fadeOut.endTime = duration;
    fadeOut.startValue = 1.0;
    fadeOut.endValue = 0;
    
    NSArray* transfers = @[rotateIn, rotateOut, scaleIn, scaleOut, fadeIn, fadeOut];
    self.videoTransferEffect.videoTransfer = transfers;
    [[QHVCEditMediaEditor sharedInstance] overlayClip:self.itemView.clipItem updateEffect:self.videoTransferEffect];
    [self.playerVC refreshPlayer:YES];
}

- (QHVCEditVideoTransferEffect *)videoTransferEffect
{
    NSMutableDictionary* dict = [[QHVCEditMediaEditorConfig sharedInstance] overlayVideoTransferEffects];
    QHVCEditVideoTransferEffect* effect = [dict objectForKey:@(self.itemView.clipItem.clip.clipId)];
    
    if (!effect)
    {
        QHVCEditTrackClip* clip = self.itemView.clipItem.clip;
        effect = [self createEffectVideoAnimation];
        effect.startTime = 0;
        effect.endTime = clip.fileEndTime - clip.fileStartTime;
        [[QHVCEditMediaEditor sharedInstance] overlayClip:self.itemView.clipItem addEffect:effect];
        NSMutableDictionary* dict = [[QHVCEditMediaEditorConfig sharedInstance] overlayVideoTransferEffects];
        [dict setObject:effect forKey:@(clip.clipId)];
        [self.playerVC refreshPlayerForEffectBasicParams];
    }
    
    _videoTransferEffect = effect;
    return effect;
}

- (QHVCEditVideoTransferEffect *)createEffectVideoAnimation
{
    QHVCEditTimeline* timeline = [[QHVCEditMediaEditor sharedInstance] timeline];
    QHVCEditVideoTransferEffect* effect = [[QHVCEditVideoTransferEffect alloc] initEffectWithTimeline:timeline];
    return effect;
}

- (void)clickedTopItem
{
    [[QHVCEditMediaEditor sharedInstance] updateOverlayClipZOrder:self.itemView.clipItem step:1];
    [self.playerVC refreshPlayer:YES];
}

- (void)clickedBottomItem
{
    [[QHVCEditMediaEditor sharedInstance] updateOverlayClipZOrder:self.itemView.clipItem step:-1];
    [self.playerVC refreshPlayer:YES];
}

@end
