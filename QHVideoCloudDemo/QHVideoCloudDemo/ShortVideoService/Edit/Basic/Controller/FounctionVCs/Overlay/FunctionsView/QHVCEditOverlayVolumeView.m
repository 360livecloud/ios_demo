//
//  QHVCEditOverlayVolumeView.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/3/6.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditOverlayVolumeView.h"
#import "QHVCEditPrefs.h"

@interface QHVCEditOverlayVolumeView ()
@property (weak, nonatomic) IBOutlet UILabel *curVolumeLabel;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (nonatomic, assign) NSInteger volume;

@end

@implementation QHVCEditOverlayVolumeView

- (void)setVolume:(NSInteger)volume
{
    _volume = volume;
    [self updateVolumeLabel];
    [_volumeSlider setValue:volume];
}

- (IBAction)clickedBackBtn:(id)sender
{
    [self removeFromSuperview];
}

- (IBAction)onVolumeValueChanged:(UISlider *)sender
{
    self.volume = (int)sender.value;
    [self updateVolumeLabel];
}

- (IBAction)onVolumeTouchUpInside:(id)sender
{
    SAFE_BLOCK(self.changeVolumeAction, self.volume);
}

- (void)updateVolumeLabel
{
    NSString* volume = [NSString stringWithFormat:@"%d", (int)self.volume];
    [self.curVolumeLabel setText:volume];
}

@end
