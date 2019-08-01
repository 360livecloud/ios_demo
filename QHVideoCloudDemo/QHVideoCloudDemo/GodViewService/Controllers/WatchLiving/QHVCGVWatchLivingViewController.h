//
//  QHVCGVWatchLivingViewController.h
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/10/24.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QHVCGVBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class QHVCGVDeviceModel;
@interface QHVCGVWatchLivingViewController : QHVCGVBaseViewController
@property (nonatomic, assign) BOOL isLocal;
@property (nonatomic,strong) QHVCGVDeviceModel *deviceModel;
@end

NS_ASSUME_NONNULL_END
