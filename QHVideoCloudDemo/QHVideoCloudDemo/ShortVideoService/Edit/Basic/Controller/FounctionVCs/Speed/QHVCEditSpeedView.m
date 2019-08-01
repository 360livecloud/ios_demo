//
//  QHVCEditSpeedView.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditSpeedView.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditMediaEditor.h"
#import "QHVCEditMediaEditorConfig.h"
#import "QHVCEditPlayerBaseVC.h"

@interface QHVCEditSpeedView()
{
    __weak IBOutlet UILabel *_currentSpeedLabel;
    __weak IBOutlet UISlider *_speedSlider;
}

@property (nonatomic, assign) BOOL preIsPlaying;

@end

@implementation QHVCEditSpeedView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _currentSpeedLabel.text = [NSString stringWithFormat:@"%.2fx",[QHVCEditMediaEditorConfig sharedInstance].speed];
    _speedSlider.value = [QHVCEditMediaEditorConfig sharedInstance].speed;
}

- (void)confirmAction
{
    SAFE_BLOCK(self.confirmBlock, self);
}

- (IBAction)onSpeedSliderTouchDown:(UISlider *)sender
{
    self.preIsPlaying = [self.playerBaseVC isPlaying];
    if (self.preIsPlaying)
    {
        SAFE_BLOCK(self.pausePlayerBlock);
    }
    
    NSString *s = [NSString stringWithFormat:@"%.2fx",sender.value];
    _currentSpeedLabel.text = s;
}

- (IBAction)onSpeedValueChanged:(UISlider *)sender
{
    NSString *s = [NSString stringWithFormat:@"%.2fx",sender.value];
    _currentSpeedLabel.text = s;
}

- (IBAction)speedAction:(UISlider *)sender
{
    NSString *s = [NSString stringWithFormat:@"%.2fx",sender.value];
    _currentSpeedLabel.text = s;
//    [[[QHVCEditMediaEditor sharedInstance] timeline] setSpeed:sender.value];
    [[[QHVCEditMediaEditor sharedInstance] mainTrack] setSpeed:sender.value];
    [[QHVCEditMediaEditorConfig sharedInstance] setSpeed:sender.value];
    SAFE_BLOCK(self.resetPlayerBlock);
    SAFE_BLOCK(self.updatePlayerDuraionBlock);
    if (self.preIsPlaying)
    {
        SAFE_BLOCK(self.playPlayerBlock);
    }
}

@end
