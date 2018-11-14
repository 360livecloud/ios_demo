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
@property (nonatomic, assign) int volume;

@end

@implementation QHVCEditOverlayVolumeView

- (IBAction)clickedBackBtn:(id)sender
{
    [self removeFromSuperview];
}

- (IBAction)onVolumeValueChanged:(UISlider *)sender
{
    NSString* volume = [NSString stringWithFormat:@"%d", (int)sender.value];
    [self.curVolumeLabel setText:volume];
    self.volume = (int)sender.value;
}

- (IBAction)onVolumeTouchUpInside:(id)sender
{
    SAFE_BLOCK(self.changeVolumeAction, self.volume);
}

@end
