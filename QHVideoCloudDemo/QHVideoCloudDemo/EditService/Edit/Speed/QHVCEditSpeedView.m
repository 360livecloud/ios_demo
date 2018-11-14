//
//  QHVCEditSpeedView.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditSpeedView.h"
#import "QHVCEditPrefs.h"

@interface QHVCEditSpeedView()
{
    __weak IBOutlet UILabel *_currentSpeedLabel;
    __weak IBOutlet UISlider *_speedSlider;
}
@end

@implementation QHVCEditSpeedView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib
{
    [super awakeFromNib];
    _currentSpeedLabel.text = [NSString stringWithFormat:@"%.2fx",[QHVCEditPrefs sharedPrefs].editSpeed];
    _speedSlider.value = [QHVCEditPrefs sharedPrefs].editSpeed;
}

- (IBAction)speedAction:(UISlider *)sender
{
    NSString *s = [NSString stringWithFormat:@"%.2fx",sender.value];
    _currentSpeedLabel.text = s;
    
    if (self.changeCompletion) {
        self.changeCompletion(s.floatValue);
    }
}

@end
