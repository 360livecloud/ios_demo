//
//  QHVCITSHongpaCell.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/4/25.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QHVCITSVideoSession;

@interface QHVCITSHongpaCell : UITableViewCell

- (void)updateCell:(NSArray<QHVCITSVideoSession *> *)items;

@end
