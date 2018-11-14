//
//  QHVCEditFrameCell.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/19.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditFrameCell.h"
#import <QHVCEditKit/QHVCEditKit.h>

@interface QHVCEditFrameCell()
{
    __weak IBOutlet UIImageView *_frameImageView;
    __weak IBOutlet UIView *_maskView;
    __weak IBOutlet UIImageView *_squareImageView;
}
@end

@implementation QHVCEditFrameCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCell:(UIImage *)coverImage highlightViewType:(QHVCEditFrameHighlightViewType)viewType
{
    _frameImageView.image = coverImage;
    if (viewType == QHVCEditFrameHighlightViewTypeNone) {
        _maskView.hidden = YES;
        _squareImageView.hidden = YES;
    }
    else if (viewType == QHVCEditFrameHighlightViewTypeMask)
    {
        _maskView.hidden = NO;
        _squareImageView.hidden = YES;
    }
    else if (viewType == QHVCEditFrameHighlightViewTypeSquare)
    {
        _maskView.hidden = YES;
        _squareImageView.hidden = NO;
    }
}

- (void)setImageFillMode:(UIViewContentMode)mode
{
    [_frameImageView setContentMode:mode];
}
@end
