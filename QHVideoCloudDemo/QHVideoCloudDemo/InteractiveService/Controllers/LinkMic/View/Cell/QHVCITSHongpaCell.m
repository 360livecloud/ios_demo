//
//  QHVCITSHongpaCell.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/4/25.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCITSHongpaCell.h"
#import "QHVCITSVideoSession.h"

@interface QHVCITSHongpaCell()
{
    IBOutlet UIView *_leftView;
    IBOutlet UIView *_rightView;
}

@end

@implementation QHVCITSHongpaCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCell:(NSArray<QHVCITSVideoSession *> *)items
{
    for (UIView *view in _leftView.subviews) {
        [view removeFromSuperview];
    }
    for (UIView *view in _rightView.subviews) {
        [view removeFromSuperview];
    }
    if (items.count > 0) {
        [_leftView addSubview:items[0].videoView];
    }
    if (items.count > 1) {
        [_rightView addSubview:items[1].videoView];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
