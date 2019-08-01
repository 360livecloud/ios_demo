//
//  QHVCEditOverlaySpeedView.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/3/6.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditOverlaySpeedView.h"
#import "QHVCEditPrefs.h"

@interface QHVCEditOverlaySpeedView ()
@property (weak, nonatomic) IBOutlet UILabel *maxSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *curSpeedLabel;
@property (weak, nonatomic) IBOutlet UISlider *speedSlider;
@property (nonatomic, assign) CGFloat speed;

@end

@implementation QHVCEditOverlaySpeedView

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSpeed:(CGFloat)speed
{
    _speed = speed;
    [_speedSlider setValue:speed];
    [self updateSpeedLabel];
}

- (IBAction)clickedBackBtn:(id)sender
{
    [self removeFromSuperview];
}

- (IBAction)onSpeedValueChanged:(UISlider *)sender
{
    self.speed = sender.value;
    [self updateSpeedLabel];
}

- (IBAction)onSpeedTouchUpInside:(id)sender
{
     SAFE_BLOCK(self.changeSpeedAction, self.speed);
}

- (void)updateSpeedLabel
{
    NSString* curSpeed = [NSString stringWithFormat:@"%.2fx", self.speed];
    [self.curSpeedLabel setText:curSpeed];
}

@end
