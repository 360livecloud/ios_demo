//
//  QHVCEditMosaicView.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/7/23.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditMosaicView.h"
#import "QHVCEditPrefs.h"

@interface QHVCEditMosaicView ()
@property (weak, nonatomic) IBOutlet UISlider *slider;

@end

@implementation QHVCEditMosaicView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [_slider setValue:0.5];
    SAFE_BLOCK(self.mosaicValueChangedBlock, _slider.value, YES);
}

- (IBAction)onSliderValueChanged:(UISlider *)sender
{
    SAFE_BLOCK(self.mosaicValueChangedBlock, sender.value, NO);
}

- (IBAction)onSliderTouchUpInside:(UISlider *)sender
{
    SAFE_BLOCK(self.mosaicValueChangedBlock, sender.value, YES);
}


@end
