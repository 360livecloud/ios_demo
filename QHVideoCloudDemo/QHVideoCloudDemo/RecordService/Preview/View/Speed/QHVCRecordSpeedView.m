//
//  QHVCEditSpeedView.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCRecordSpeedView.h"

@interface QHVCRecordSpeedView()
{
    __weak IBOutlet UILabel *_currentSpeedLabel;
}
@end

@implementation QHVCRecordSpeedView

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
    _currentSpeedLabel.text = [NSString stringWithFormat:@"%.2fx",1.0];
    _speedSlider.value = 1.0;
}

- (IBAction)speedAction:(UISlider *)sender
{
    NSString *s = [NSString stringWithFormat:@"%.2fx",sender.value];
    _currentSpeedLabel.text = s;
    
    if (self.speedAction) {
        self.speedAction(sender.value);
    }
}

@end
