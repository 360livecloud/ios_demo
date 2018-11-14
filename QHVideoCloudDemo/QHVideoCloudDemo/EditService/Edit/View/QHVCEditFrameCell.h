//
//  QHVCEditFrameCell.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/19.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, QHVCEditFrameHighlightViewType) {
    QHVCEditFrameHighlightViewTypeNone = 1,
    QHVCEditFrameHighlightViewTypeMask,
    QHVCEditFrameHighlightViewTypeSquare
};

@class QHVCEditThumbnailItem;

@interface QHVCEditFrameCell : UICollectionViewCell

- (void)updateCell:(UIImage *)coverImage highlightViewType:(QHVCEditFrameHighlightViewType)viewType;
- (void)setImageFillMode:(UIViewContentMode)mode;

@end
