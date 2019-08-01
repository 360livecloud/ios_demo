//
//  QHVCEditQualityItem.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/5/21.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditQualityItem.h"
#import "QHVCEditPrefs.h"

@interface QHVCEditQualityItem ()

@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) NSInteger itemTag;

@end

@implementation QHVCEditQualityItem

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)updateCell:(NSString *)name tag:(int)tag minValue:(int)min maxValue:(int)max curValue:(int)value
{
    [self.slider setValue:value];
    [self.slider setMinimumValue:min];
    [self.slider setMaximumValue:max];
    [self.titleLabel setText:name];
    self.itemTag = tag;
}

- (IBAction)sliderValueChanged:(UISlider *)sender
{
    SAFE_BLOCK(self.valueChanged, (int)self.itemTag, (int)sender.value);
}

@end
