//
//  QHVCGSDeviceListCell.h
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2019/4/19.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QHVCGVDeviceModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface QHVCGSDeviceListCell : UITableViewCell

@property (nonatomic, strong) QHVCGVDeviceModel* deviceData;

- (void)updateCell:(QHVCGVDeviceModel *)deviceData;

@end

NS_ASSUME_NONNULL_END
