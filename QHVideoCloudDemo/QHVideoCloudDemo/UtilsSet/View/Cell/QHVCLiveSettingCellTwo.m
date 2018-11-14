//
//  QHVCLiveSettingCellTwo.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/6/29.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCLiveSettingCellTwo.h"

@interface QHVCLiveSettingCellTwo()
{
    IBOutlet UILabel *_titleLabel;
    IBOutlet UISlider *_bitrateSlider;
    
    IBOutlet UILabel *_maxLabel;
    IBOutlet UILabel *_minLabel;
    IBOutlet UILabel *_valueLabel;
}

@property (nonatomic, strong) NSMutableDictionary *liveItem;

@end

@implementation QHVCLiveSettingCellTwo

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCell:(NSMutableDictionary *)item
{
    self.liveItem = item;
    
    _titleLabel.text = item[@"title"];
    
    NSString *max = item[@"max"];
    NSString *min = item[@"min"];
    NSString *value = item[@"value"];
    
    _bitrateSlider.maximumValue = max.floatValue;
    _bitrateSlider.minimumValue = min.floatValue;
    _bitrateSlider.value = value.floatValue;
    
    _maxLabel.text = [NSString stringWithFormat:@"%@kbps",max];
    _minLabel.text = [NSString stringWithFormat:@"%@kbps",min];
    _valueLabel.text = [NSString stringWithFormat:@"%@kbps",value];
}

- (IBAction)bitrateSliderAction:(UISlider *)sender
{
    NSString *value = [NSString stringWithFormat:@"%.0f",sender.value];
    _valueLabel.text = [value stringByAppendingString:@"kbps"];
    [self.liveItem setObject:value forKey:@"value"];
}

- (IBAction)bitrateSwitch:(UISwitch *)sender
{
    if (sender.on) {
        [self.liveItem setObject:@"1" forKey:@"enable"];
    }
    else
    {
        [self.liveItem setObject:@"0" forKey:@"enable"];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
