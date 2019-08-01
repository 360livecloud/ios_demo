//
//  QHVCEditTrackClipCell.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/2/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QHVCEditTrackClipItem;
typedef void(^SelectedAction)(QHVCEditTrackClipItem *item);

@interface QHVCEditTrackClipCell : UICollectionViewCell

- (void)updateCell:(QHVCEditTrackClipItem *)item canAddTransfer:(BOOL)canAddTransfer;

@property (nonatomic, copy) SelectedAction selectedCompletion;

@end
