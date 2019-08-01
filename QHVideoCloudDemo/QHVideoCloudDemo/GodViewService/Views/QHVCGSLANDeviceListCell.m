//
//  QHVCGSLANDeviceListCell.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2019/1/16.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCGSLANDeviceListCell.h"
#import "QHVCGSLANDeviceModel.h"

@interface QHVCGSLANDeviceListCell ()
@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UILabel *labSerialNumber;
@property (weak, nonatomic) IBOutlet UILabel *labStatus;

@end

@implementation QHVCGSLANDeviceListCell

- (void)setupWithModel:(QHVCGSLANDeviceModel *)deviceMode
{
    self.labName.text = deviceMode.name;
//    self.labSerialNumber.text = deviceMode.serialNumber;
    self.labStatus.text = deviceMode.isOnline ? @"在线" : @"离线";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
