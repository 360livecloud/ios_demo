//
//  QHVCEditOverlayChromakeyView.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/4/2.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditOverlayChromakeyView.h"
#import "QHVCEditPrefs.h"

@interface QHVCEditOverlayChromakeyView ()

@property (weak, nonatomic) IBOutlet UISlider *thresholdSlider;
@property (weak, nonatomic) IBOutlet UISlider *extendSlider;

@end

@implementation QHVCEditOverlayChromakeyView

- (IBAction)clickedBackBtn:(UIButton *)sender
{
    SAFE_BLOCK(self.chromakeyStoppedAction);
    [self removeFromSuperview];
}

- (IBAction)onThresholdSliderEvent:(UISlider *)sender
{
    int threshold = (int)self.thresholdSlider.value;
    int extend = (int)self.extendSlider.value;
    SAFE_BLOCK(self.chromakeyAction, threshold, extend);
}

- (IBAction)onExtendSliderEvent:(UISlider *)sender
{
    int threshold = (int)self.thresholdSlider.value;
    int extend = (int)self.extendSlider.value;
    SAFE_BLOCK(self.chromakeyAction, threshold, extend);
}

@end
