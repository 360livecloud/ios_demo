//
//  QHVCGSDeviceListCell.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2019/4/19.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCGSDeviceListCell.h"
#import <QHVCCommonKit/QHVCCommonKit.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface QHVCGSDeviceListCell()
{
    __weak IBOutlet UILabel *deviceNameLabel;
    __weak IBOutlet UILabel *deviceSNLabel;
    __weak IBOutlet UILabel *deviceTypeLabel;
    __weak IBOutlet UIImageView *deviceCoverImage;
}

@end

@implementation QHVCGSDeviceListCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)updateCell:(QHVCGVDeviceModel *)deviceData
{
    if (deviceData == nil)
    {
        return;
    }
    _deviceData = deviceData;
    NSString* name = deviceData.name?deviceData.name:@"未知设备";
    [deviceNameLabel setText:name];
    NSString* SN = @"ID:";
    if (![QHVCToolUtils isNullString:deviceData.bindedSN])
    {
        SN = [SN stringByAppendingString:deviceData.bindedSN];
    }
    [deviceSNLabel setText:SN];
    [deviceTypeLabel setText:deviceData.isPublic?@"NVR":@"IPC"];
    [deviceCoverImage setImageWithURL:[NSURL URLWithString:deviceData.converImg] placeholderImage:[UIImage imageNamed:@"godsees_camera_default"]];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
