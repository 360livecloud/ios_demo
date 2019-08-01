//
//  QHVCEditAlterSoundView.m
//  QHVideoCloudToolSet
//
//  Created by yinchaoyu on 2018/5/10.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditAlterSoundView.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditMediaEditor.h"
#import "QHVCEditMediaEditorConfig.h"
#import "QHVCEditPlayerBaseVC.h"

@interface QHVCEditAlterSoundView ()
@property (nonatomic, assign) NSInteger pitch;
@property (nonatomic, assign) NSInteger volume;

@property (weak, nonatomic) IBOutlet UISwitch *switchFIFO;
@property (strong, nonatomic) IBOutlet UISlider *sliderVolume;
@property (strong, nonatomic) IBOutlet UISlider *sliderPitch;
@property (nonatomic, assign) BOOL preIsPlaying;

@end


@implementation QHVCEditAlterSoundView

- (void)confirmAction
{
    SAFE_BLOCK(self.confirmBlock, self);
}

- (void)prepareSubviews
{
    NSInteger volume = [[QHVCEditMediaEditorConfig sharedInstance] volume];
    NSInteger pitch = [[QHVCEditMediaEditorConfig sharedInstance] pitch];
    BOOL hasAudioTransfer = [[QHVCEditMediaEditorConfig sharedInstance] hasAudioTransfer];
    [self.sliderVolume setValue:volume];
    [self.sliderPitch setValue:pitch];
    [self.switchFIFO setOn:hasAudioTransfer];
}

- (IBAction)onSliderTouchDown:(id)sender
{
    self.preIsPlaying = [self.playerBaseVC isPlaying];
    if (self.preIsPlaying)
    {
        SAFE_BLOCK(self.pausePlayerBlock);
    }
}

- (IBAction)onPitchSliderTouchUpInside:(UISlider *)sender
{
    _pitch = (int)sender.value;
    [[QHVCEditMediaEditor sharedInstance] setMainTrackPitch:_pitch];
    [[QHVCEditMediaEditorConfig sharedInstance] setPitch:_pitch];
    SAFE_BLOCK(self.resetPlayerBlock);
    if (self.preIsPlaying)
    {
        SAFE_BLOCK(self.playPlayerBlock);
    }
}

- (IBAction)onVolumeSliderTouchUpInside:(UISlider *)sender
{
    _volume = (int)sender.value;
    [[QHVCEditMediaEditor sharedInstance] setMainTrackVolume:_volume];
    [[QHVCEditMediaEditorConfig sharedInstance] setVolume:_volume];
    SAFE_BLOCK(self.resetPlayerBlock);
    if (self.preIsPlaying)
    {
        SAFE_BLOCK(self.playPlayerBlock);
    }
}

- (IBAction)onFIFOChanged:(UISwitch *)sender
{
    BOOL isOn = sender.isOn;
    QHVCEditMediaEditor* mediaEditor = [QHVCEditMediaEditor sharedInstance];
    [[QHVCEditMediaEditorConfig sharedInstance] setHasAudioTransfer:isOn];
    
    if (isOn)
    {
        [[mediaEditor getMainTrackClips] enumerateObjectsUsingBlock:^(QHVCEditTrackClipItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
         {
             QHVCEditAudioTransferEffect *audioTransferFadeIn = [[QHVCEditAudioTransferEffect alloc] initEffectWithTimeline:[mediaEditor timeline]];
             audioTransferFadeIn.startTime = 0;
             audioTransferFadeIn.endTime = obj.clip.duration / 2.0;
             audioTransferFadeIn.transferType = QHVCEditAudioTransferTypeFadeIn;
             audioTransferFadeIn.gainMin = 0;
             audioTransferFadeIn.gainMax = 100;
             audioTransferFadeIn.transferCurveType = QHVCEditAudioTransferCurveTypeLog;
             [obj.clip addEffect:audioTransferFadeIn];

             QHVCEditAudioTransferEffect *audioTransferFadeOut = [[QHVCEditAudioTransferEffect alloc] initEffectWithTimeline:[mediaEditor timeline]];
             audioTransferFadeOut.startTime = obj.clip.duration / 2.0;
             audioTransferFadeOut.endTime = obj.clip.duration;
             audioTransferFadeOut.transferType = QHVCEditAudioTransferTypeFadeOut;
             audioTransferFadeOut.gainMin = 0;
             audioTransferFadeOut.gainMax = 100;
             audioTransferFadeOut.transferCurveType = QHVCEditAudioTransferCurveTypeLog;
             [obj.clip addEffect:audioTransferFadeOut];
         }];
    }
    else
    {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings)
      {
            QHVCEditEffect *effect = (QHVCEditEffect *)evaluatedObject;
            if (effect.effectType == QHVCEditEffectTypeAudio)
            {
                return YES;
            }
            return NO;
        }];
        
        [[[QHVCEditMediaEditor sharedInstance] getMainTrackClips] enumerateObjectsUsingBlock:^(QHVCEditTrackClipItem * _Nonnull clipItem, NSUInteger idx, BOOL * _Nonnull stop)
         {
            NSArray *clipEffects = [clipItem.clip getEffects];
            NSArray *effects = [clipEffects filteredArrayUsingPredicate:predicate];
            [effects enumerateObjectsUsingBlock:^(QHVCEditEffect *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
             {
                [clipItem.clip deleteEffectById:obj.effectId];
            }];
        }];
    }
    
    BOOL isPlaying = [self.playerBaseVC isPlaying];
    SAFE_BLOCK(self.resetPlayerBlock);
    if (isPlaying)
    {
        SAFE_BLOCK(self.playPlayerBlock);
    }
}


@end
