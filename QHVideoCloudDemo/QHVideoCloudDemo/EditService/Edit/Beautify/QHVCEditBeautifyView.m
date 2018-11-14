//
//  QHVCEditBeautifyView.m
//  QHVideoCloudToolSet
//
//  Created by yinchaoyu on 2018/6/4.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditBeautifyView.h"

@interface QHVCEditBeautifyView ()
{
    __weak IBOutlet UISlider *beautySlider;
    __weak IBOutlet UISlider *whiteSlider;
    __weak IBOutlet UISlider *faceSlider;
    __weak IBOutlet UISlider *eyeSlider;
    
}
@end

@implementation QHVCEditBeautifyView

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (IBAction)onBeautifyChanged:(id)sender {
    float value = ((UISlider *)sender).value;
    if (self.onChangeComplete) {
        self.onChangeComplete(value, whiteSlider.value, faceSlider.value, eyeSlider.value);
    }
}
- (IBAction)onWhiteChanged:(id)sender {
    float value = ((UISlider *)sender).value;
    if (self.onChangeComplete) {
        self.onChangeComplete(beautySlider.value, value, faceSlider.value, eyeSlider.value);
    }
}
- (IBAction)onFaceChanged:(id)sender {
    float value = ((UISlider *)sender).value;
    if (self.onChangeComplete) {
        self.onChangeComplete(beautySlider.value, whiteSlider.value, value, eyeSlider.value);
    }
}
- (IBAction)onEyeChanged:(id)sender {
    float value = ((UISlider *)sender).value;
    if (self.onChangeComplete) {
        self.onChangeComplete(beautySlider.value, whiteSlider.value, faceSlider.value, value);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
