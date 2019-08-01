//
//  QHVCGSLANDeviceListHeaderView.h
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2019/1/17.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHVCGSLANDeviceListHeaderView : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UILabel *labDeviceType;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@end

NS_ASSUME_NONNULL_END
