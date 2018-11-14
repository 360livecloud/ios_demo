//
//  QHVCEditOverlaySpeedView.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/3/6.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditOverlaySpeedView.h"
#import "QHVCEditCommandManager.h"
#import "QHVCEditPrefs.h"

@interface QHVCEditOverlaySpeedView ()
@property (weak, nonatomic) IBOutlet UILabel *maxSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *curSpeedLabel;
@property (nonatomic, assign) CGFloat speed;

@end

@implementation QHVCEditOverlaySpeedView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.speed = 1.0;
}

- (IBAction)clickedBackBtn:(id)sender
{
    [self removeFromSuperview];
}

- (IBAction)onSpeedValueChanged:(UISlider *)sender
{
    NSString* curSpeed = [NSString stringWithFormat:@"%.2fx", sender.value];
    [self.curSpeedLabel setText:curSpeed];
    self.speed = sender.value;
}

- (IBAction)onSpeedTouchUpInside:(id)sender
{
     SAFE_BLOCK(self.changeSpeedAction, self.speed);
}


@end
