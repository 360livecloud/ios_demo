//
//  QHVCGVDeviceListCell.h
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/10/25.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kQHVCGVDeviceListCellHeight        (271.0f * kQHVCScreenScaleTo6)

NS_ASSUME_NONNULL_BEGIN

@class QHVCGVDeviceListCell;
@protocol QHVCGVDeviceListCellDelegate <NSObject>
@optional;
- (void)deviceListCell:(QHVCGVDeviceListCell *)cell needChangeDeviceName:(NSString *)originalName toDeviceName:(NSString *)newDeviceName;
@end

@class QHVCGVDeviceModel;
@interface QHVCGVDeviceListCell : UITableViewCell

@property(nonatomic,weak) id<QHVCGVDeviceListCellDelegate> delegate;

- (void)updateCell:(QHVCGVDeviceModel *)deviceModel;

@end

NS_ASSUME_NONNULL_END
