//
//  QHVCEditAlterSoundView.m
//  QHVideoCloudToolSet
//
//  Created by yinchaoyu on 2018/5/10.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditAlterSoundView.h"
#import "QHVCEditPrefs.h"

@interface QHVCEditAlterSoundView ()
@property (nonatomic, assign) int pitch;
@property (nonatomic, assign) int volume;

@property (weak, nonatomic) IBOutlet UISwitch *switchFI;
@property (weak, nonatomic) IBOutlet UISwitch *switchFO;

@end


@implementation QHVCEditAlterSoundView

- (IBAction)clickedBackBtn:(id)sender
{
    [self removeFromSuperview];
    SAFE_BLOCK(self.onViewClose);
}

- (IBAction)onSoundPitchValueChanged:(UISlider *)sender
{
    self.pitch = (int)sender.value;
}
- (IBAction)onTouchSliderUpInside:(id)sender {
    SAFE_BLOCK(self.changePitchAction, self.pitch);
}

- (IBAction)onVolumeChanged:(UISlider *)sender {
    self.volume = (int)sender.value;
}

- (IBAction)onTouchSliderVolumeInside:(id)sender{
    SAFE_BLOCK(self.changeVolumeAction, self.volume);
}

- (IBAction)onFIChanged:(UISwitch *)sender {
    BOOL isOn = sender.isOn;
    if (isOn) {
        [_switchFO setOn:!isOn];
    }
    SAFE_BLOCK(self.changeFIAction, sender.isOn);
}
- (IBAction)onFOChanged:(UISwitch *)sender {
    BOOL isOn = sender.isOn;
    if (isOn) {
        [_switchFI setOn:!isOn];
    }
    SAFE_BLOCK(self.changeFOAction, sender.isOn);
}


@end
