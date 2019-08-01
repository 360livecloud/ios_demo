//
//  QHVCGSCloudRecordListViewController.h
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2019/1/7.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QHVCGVBaseViewController.h"
@class QHVCGVDeviceModel;
NS_ASSUME_NONNULL_BEGIN

@interface QHVCGSCloudRecordListViewController : QHVCGVBaseViewController
@property (nonatomic,strong) NSArray *dataSource;
@property (nonatomic,strong) QHVCGVDeviceModel *deviceModel;
@end

NS_ASSUME_NONNULL_END
