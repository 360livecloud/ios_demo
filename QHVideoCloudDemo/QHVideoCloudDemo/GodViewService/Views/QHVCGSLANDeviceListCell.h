//
//  QHVCGSLANDeviceListCell.h
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2019/1/16.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QHVCGSLANDeviceModel;

NS_ASSUME_NONNULL_BEGIN

@interface QHVCGSLANDeviceListCell : UITableViewCell
- (void)setupWithModel:(QHVCGSLANDeviceModel *)deviceModel;
@end

NS_ASSUME_NONNULL_END
