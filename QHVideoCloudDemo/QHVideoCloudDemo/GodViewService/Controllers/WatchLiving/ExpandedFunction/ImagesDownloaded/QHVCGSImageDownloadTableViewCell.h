//
//  QHVCGSImageDownloadTableViewCell.h
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2019/5/6.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QHVCGSImageDownloadModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^QHVCGSImageDownloadDeleteBlock)(QHVCGSImageDownloadModel* model);

@interface QHVCGSImageDownloadTableViewCell : UITableViewCell

@property (nonatomic, copy) QHVCGSImageDownloadDeleteBlock deleteBlock;

- (void)updateCell:(QHVCGSImageDownloadModel *)model;

@end

NS_ASSUME_NONNULL_END
