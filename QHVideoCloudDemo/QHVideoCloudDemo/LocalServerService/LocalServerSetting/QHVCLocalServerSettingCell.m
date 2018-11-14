//
//  QHVCLocalServerSettingCell.m
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/9/26.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCLocalServerSettingCell.h"

@interface QHVCLocalServerSettingCell ()

@property (nonatomic, strong) UISwitch *cellSwitch;

@end

@implementation QHVCLocalServerSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _cellSwitch = [UISwitch new];
        [self addSubview:_cellSwitch];
        [_cellSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-16);
            make.centerY.equalTo(self);
        }];
        _cellSwitch.transform = CGAffineTransformMakeScale(1.2,1.0);
        _cellSwitch.tintColor = [UIColor lightGrayColor];
        _cellSwitch.onTintColor = [UIColor greenColor];
        _cellSwitch.thumbTintColor = QHVC_COLOR_VIEW_WHITE;
        _cellSwitch.on = YES;
        [_cellSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    }
    
    return self;
}

- (void)switchAction:(UISwitch *)sender
{
    if (_switchAction)
    {
        _switchAction(sender.isOn);
    }
}

- (void)setSwitchHidden:(BOOL)hidden
{
    _cellSwitch.hidden = hidden;
}

- (void)setSwitchSelected:(BOOL)isSelected
{
    [_cellSwitch setValue:@(isSelected) forKey:@"on"];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
